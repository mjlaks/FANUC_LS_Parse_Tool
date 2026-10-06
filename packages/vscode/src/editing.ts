import * as vscode from 'vscode';
import { completionContext, createLabelEdit, createPositionEdits, expandSnippet, gapEdit, Diagnostic, DocFacts, renderBody, scanDoc, SNIPPETS } from '@lscheck/core';

const LANGUAGE_ID = 'fanuctp_ls';

export interface EditingDeps {
  /** Program names (upper case) CALL/RUN can target for this document */
  programs: (doc: vscode.TextDocument) => string[];
  /** Diagnostics from the most recent check of this exact document version, if there is one (they carry the spacing fixes) */
  diagnostics: (doc: vscode.TextDocument) => Diagnostic[] | undefined;
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
  // version alone can repeat after a reopen, so the text length is part of the key
  const key = `${doc.uri.toString()}@${doc.version}@${doc.offsetAt(new vscode.Position(doc.lineCount, 0))}`;
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

      const cx = completionContext(before);
      if (!cx) return undefined;

      // Inside P[ / LBL[ / R[ : offer indices the program already knows
      if (cx.kind === 'index') {
        const facts = factsFor(doc);
        const range = new vscode.Range(pos.line, pos.character - cx.typed.length, pos.line, pos.character);
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
        if (cx.type === 'P') {
          const defined = new Set(facts.definedP);
          for (const n of [...new Set([...facts.definedP, ...facts.usedP])].sort((a, b) => a - b)) add(n, defined.has(n) ? 'defined in /POS' : 'not defined in /POS yet');
          add(Math.max(0, ...facts.definedP, ...facts.usedP) + 1, 'next unused');
        } else if (cx.type === 'LBL') {
          for (const n of facts.labels) add(n, 'defined in this program');
          add(Math.max(0, ...facts.labels, ...facts.jumped) + 1, 'next unused');
        } else {
          for (const [n, name] of [...facts.rNames].sort((a, b) => a[0] - b[0])) add(n, name, `${n}:${name}`, `${n} ${name}`);
        }
        return items;
      }

      // After CALL / RUN : workspace programs
      if (cx.kind === 'call') {
        const range = new vscode.Range(pos.line, pos.character - cx.typed.length, pos.line, pos.character);
        return [...new Set(deps.programs(doc))].sort().map((name, i) => {
          const item = new vscode.CompletionItem(name, vscode.CompletionItemKind.Module);
          item.range = range;
          item.sortText = sortKey(i);
          item.detail = 'program';
          return item;
        });
      }

      // Start of a statement. Keep the list quiet unless something was typed or the user asked for it (Ctrl+Space)
      const typed = cx.typed;
      if (!typed && ctx.triggerKind !== vscode.CompletionTriggerKind.Invoke) return undefined;
      const wordStart = pos.character - typed.length;
      const facts = factsFor(doc);
      const rest = doc.lineAt(pos.line).text.slice(pos.character);
      const semicolon = settings.get<boolean>('semicolon', true);
      const range = new vscode.Range(pos.line, wordStart, pos.line, pos.character);

      return SNIPPETS.map((def, i) => {
        let body = renderBody(def, facts, cx.lineNo);
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
        // motion sits against the colon, everything else has two spaces after it
        const gap = gapEdit(cx, def);
        if (gap) item.additionalTextEdits = [vscode.TextEdit.replace(new vscode.Range(pos.line, gap.start, pos.line, gap.end), gap.newText)];
        return item;
      });
    },
  };
}

function codeActionProvider(deps: EditingDeps): vscode.CodeActionProvider {
  const codeOf = (d: vscode.Diagnostic) => (d.source === 'lscheck' ? String(d.code) : '');
  const undefinedN = (d: vscode.Diagnostic) => (codeOf(d) === 'undefined-position' ? Number(/^P\[(\d+)\]/.exec(d.message)?.[1]) : NaN);
  const labelN = (d: vscode.Diagnostic) => (codeOf(d) === 'undefined-label' ? Number(/^LBL\[(\d+)\]/.exec(d.message)?.[1]) : NaN);
  const insert = (action: vscode.CodeAction, doc: vscode.TextDocument, line: number, character: number, text: string) =>
    action.edit!.insert(doc.uri, new vscode.Position(line, character), text);
  const positions = (doc: vscode.TextDocument, title: string, indices: number[], diags: vscode.Diagnostic[], preferred: boolean) => {
    const edits = createPositionEdits(doc.getText(), indices);
    if (!edits.length) return undefined;
    const action = new vscode.CodeAction(title, vscode.CodeActionKind.QuickFix);
    action.edit = new vscode.WorkspaceEdit();
    for (const e of edits) insert(action, doc, e.line, e.character, e.newText);
    action.diagnostics = diags;
    action.isPreferred = preferred;
    return action;
  };
  return {
    provideCodeActions(doc, range, ctx) {
      const out: vscode.CodeAction[] = [];

      const here = ctx.diagnostics.filter((d) => !Number.isNaN(undefinedN(d)));
      if (here.length) {
        // only the diagnostic under the cursor is the preferred (auto-fix) action
        const mine = here.find((d) => d.range.contains(range.start));
        for (const n of [...new Set(here.map(undefinedN))]) {
          const a = positions(doc, `Create P[${n}] in /POS`, [n], here.filter((d) => undefinedN(d) === n), mine !== undefined && undefinedN(mine) === n);
          if (a) out.push(a);
        }
        const all = [...new Set(vscode.languages.getDiagnostics(doc.uri).map(undefinedN).filter((n) => !Number.isNaN(n)))];
        if (all.length > 1) {
          const a = positions(doc, `Create all ${all.length} undefined positions in /POS`, all, here, false);
          if (a) out.push(a);
        }
      }

      for (const d of ctx.diagnostics.filter((x) => !Number.isNaN(labelN(x)))) {
        const n = labelN(d);
        const e = createLabelEdit(doc.getText(), d.range.start.line, n);
        const action = new vscode.CodeAction(`Create LBL[${n}] after this line`, vscode.CodeActionKind.QuickFix);
        action.edit = new vscode.WorkspaceEdit();
        insert(action, doc, e.line, e.character, e.newText);
        action.diagnostics = [d];
        out.push(action);
      }

      // bad-spacing: the checker knows the controller's exact whitespace, so apply it to the whole line
      const spacing = ctx.diagnostics.filter((d) => codeOf(d) === 'bad-spacing');
      if (spacing.length) {
        const core = deps.diagnostics(doc);
        const lines = new Set(spacing.map((d) => d.range.start.line));
        const fixes = (core ?? []).filter((d) => d.code === 'bad-spacing' && d.fix && lines.has(d.fix.line));
        if (fixes.length) {
          const action = new vscode.CodeAction(lines.size === 1 ? 'Fix spacing on this line' : 'Fix spacing on these lines', vscode.CodeActionKind.QuickFix);
          action.edit = new vscode.WorkspaceEdit();
          for (const d of fixes) action.edit.replace(doc.uri, new vscode.Range(d.fix!.line, d.fix!.column, d.fix!.line, d.fix!.endColumn), d.fix!.newText);
          action.diagnostics = spacing;
          action.isPreferred = true;
          out.push(action);
        }
      }
      return out;
    },
  };
}

export function registerEditing(context: vscode.ExtensionContext, deps: EditingDeps) {
  context.subscriptions.push(
    vscode.languages.registerCompletionItemProvider({ language: LANGUAGE_ID }, completionProvider(deps), '[', ' '),
    vscode.languages.registerCodeActionsProvider({ language: LANGUAGE_ID }, codeActionProvider(deps), { providedCodeActionKinds: [vscode.CodeActionKind.QuickFix] }),
  );
}
