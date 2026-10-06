import * as vscode from 'vscode';
import { createPositionEdits, expandSnippet, gapAfterColon, DocFacts, renderBody, scanDoc, SNIPPETS } from '@lscheck/core';

const LANGUAGE_ID = 'fanuctp_ls';

export interface EditingDeps {
  /** Program names (upper case) CALL/RUN can target for this document */
  programs: (doc: vscode.TextDocument) => string[];
}

/** True when the line is inside the /MN section (nearest section header above it is /MN). */
function inMain(doc: vscode.TextDocument, line: number): boolean {
  for (let l = line; l >= 0; l--) {
    const text = doc.lineAt(l).text;
    if (text.startsWith('/')) return /^\/MN\b/i.test(text);
  }
  return false;
}

// The document is scanned once per version; completion runs on keystrokes
let cached: { key: string; facts: DocFacts } | undefined;
function factsFor(doc: vscode.TextDocument): DocFacts {
  const key = `${doc.uri.toString()}@${doc.version}`;
  if (cached?.key !== key) cached = { key, facts: scanDoc(doc.getText()) };
  return cached.facts;
}

const sortKey = (i: number) => String(i).padStart(3, '0');

function completionProvider(deps: EditingDeps): vscode.CompletionItemProvider {
  return {
    provideCompletionItems(doc, pos, _token, ctx) {
      const settings = vscode.workspace.getConfiguration('lscheck.completions', doc.uri);
      if (!settings.get<boolean>('enabled', true) || !inMain(doc, pos.line)) return undefined;
      const before = doc.lineAt(pos.line).text.slice(0, pos.character);

      // Inside P[ / LBL[ / R[ : offer indices the program already knows
      const idx = /(?<![A-Za-z_])(P|LBL|R)\[(\d*)$/i.exec(before);
      if (idx) {
        const kind = idx[1].toUpperCase();
        const facts = factsFor(doc);
        const range = new vscode.Range(pos.line, pos.character - idx[2].length, pos.line, pos.character);
        const items: vscode.CompletionItem[] = [];
        const add = (n: number, detail: string, insert = String(n), filter = String(n)) => {
          const item = new vscode.CompletionItem(String(n), vscode.CompletionItemKind.Value);
          item.insertText = insert;
          item.filterText = filter;
          item.detail = detail;
          item.range = range;
          item.sortText = sortKey(items.length);
          items.push(item);
        };
        if (kind === 'P') {
          const defined = new Set(facts.definedP);
          for (const n of [...new Set([...facts.definedP, ...facts.usedP])].sort((a, b) => a - b)) add(n, defined.has(n) ? 'defined in /POS' : 'not defined in /POS yet');
          add(Math.max(0, ...facts.definedP, ...facts.usedP) + 1, 'next unused');
        } else if (kind === 'LBL') {
          for (const n of facts.labels) add(n, 'defined in this program');
          add(Math.max(0, ...facts.labels, ...facts.jumped) + 1, 'next unused');
        } else {
          for (const [n, name] of [...facts.rNames].sort((a, b) => a[0] - b[0])) add(n, name, `${n}:${name}`, `${n} ${name}`);
        }
        return items;
      }

      // After CALL / RUN : workspace programs
      const call = /(?<![A-Za-z_])(CALL|RUN)\s+([A-Za-z0-9_]*)$/i.exec(before);
      if (call) {
        const range = new vscode.Range(pos.line, pos.character - call[2].length, pos.line, pos.character);
        return [...new Set(deps.programs(doc))].sort().map((name, i) => {
          const item = new vscode.CompletionItem(name, vscode.CompletionItemKind.Module);
          item.range = range;
          item.sortText = sortKey(i);
          item.detail = 'program';
          return item;
        });
      }

      // Start of a statement: "  12:", optionally followed by blanks and the word typed so far
      const st = /^(\s*\d+:)(\s*)([A-Za-z_!]*)$/.exec(before);
      const bare = st ? null : /^(\s*)([A-Za-z_!]*)$/.exec(before);
      if (!st && !bare) return undefined;
      const typed = st ? st[3] : bare![2];
      // Keep the list quiet unless something was typed or the user asked for it (Ctrl+Space)
      if (!typed && ctx.triggerKind !== vscode.CompletionTriggerKind.Invoke) return undefined;
      const wordStart = pos.character - typed.length;
      const colonEnd = st ? st[1].length : 0;
      const lineNo = st ? Number(/\d+/.exec(st[1])![0]) : undefined;
      const facts = factsFor(doc);
      const rest = doc.lineAt(pos.line).text.slice(pos.character);
      const semicolon = settings.get<boolean>('semicolon', true);
      const range = new vscode.Range(pos.line, wordStart, pos.line, pos.character);

      return SNIPPETS.map((def, i) => {
        let body = renderBody(def, facts, lineNo);
        // honour the semicolon setting, and never double one that is already after the cursor
        if (!semicolon) body = body.replace(/ *;$/gm, '');
        else if (/^\s*;/.test(rest) || /;/.test(rest)) body = body.replace(/ *;(?=\n|$)/, '');
        const item = new vscode.CompletionItem(def.label, vscode.CompletionItemKind.Snippet);
        item.insertText = new vscode.SnippetString(body);
        item.range = range;
        item.keepWhitespace = true; // the continuation lines carry their own line numbers
        item.filterText = `${def.keywords} ${def.label}`;
        item.detail = def.detail;
        item.sortText = sortKey(i);
        item.documentation = new vscode.MarkdownString().appendCodeblock(expandSnippet(body), 'text');
        if (st) {
          // motion sits against the colon, everything else has two spaces after it
          const want = gapAfterColon(def);
          if (st[2] !== want) item.additionalTextEdits = [vscode.TextEdit.replace(new vscode.Range(pos.line, colonEnd, pos.line, wordStart), want)];
        }
        return item;
      });
    },
  };
}

function codeActionProvider(): vscode.CodeActionProvider {
  const undefinedN = (d: vscode.Diagnostic) => (d.code === 'undefined-position' && d.source === 'lscheck' ? Number(/^P\[(\d+)\]/.exec(d.message)?.[1]) : NaN);
  const build = (doc: vscode.TextDocument, title: string, indices: number[], diags: vscode.Diagnostic[], preferred: boolean) => {
    const edits = createPositionEdits(doc.getText(), indices);
    if (!edits.length) return undefined;
    const action = new vscode.CodeAction(title, vscode.CodeActionKind.QuickFix);
    action.edit = new vscode.WorkspaceEdit();
    for (const e of edits) action.edit.insert(doc.uri, new vscode.Position(e.line, e.character), e.newText);
    action.diagnostics = diags;
    action.isPreferred = preferred;
    return action;
  };
  return {
    provideCodeActions(doc, _range, ctx) {
      const here = ctx.diagnostics.filter((d) => !Number.isNaN(undefinedN(d)));
      if (!here.length) return undefined;
      const out: vscode.CodeAction[] = [];
      for (const n of [...new Set(here.map(undefinedN))]) {
        const a = build(doc, `Create P[${n}] in /POS`, [n], here.filter((d) => undefinedN(d) === n), true);
        if (a) out.push(a);
      }
      const all = [...new Set(vscode.languages.getDiagnostics(doc.uri).map(undefinedN).filter((n) => !Number.isNaN(n)))];
      if (all.length > 1) {
        const a = build(doc, `Create all ${all.length} undefined positions in /POS`, all, here, false);
        if (a) out.push(a);
      }
      return out;
    },
  };
}

export function registerEditing(context: vscode.ExtensionContext, deps: EditingDeps) {
  context.subscriptions.push(
    vscode.languages.registerCompletionItemProvider({ language: LANGUAGE_ID }, completionProvider(deps), '[', ' '),
    vscode.languages.registerCodeActionsProvider({ language: LANGUAGE_ID }, codeActionProvider(), { providedCodeActionKinds: [vscode.CodeActionKind.QuickFix] }),
  );
}
