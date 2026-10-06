import * as path from 'path';
import * as vscode from 'vscode';
import { check, Diagnostic, mergeConfig, WorkspaceIndex } from '@lscheck/core';
import { buildWorkspaceIndexAsync, configErrorDiagnostic, loadConfigFor } from '@lscheck/core/dist/node';

// Language ID registered by the TP editor extension; this extension adds diagnostics only.
const LANGUAGE_ID = 'fanuctp_ls';

const SEVERITY: Record<Diagnostic['severity'], vscode.DiagnosticSeverity> = {
  error: vscode.DiagnosticSeverity.Error,
  warning: vscode.DiagnosticSeverity.Warning,
  hint: vscode.DiagnosticSeverity.Hint,
};

export function activate(context: vscode.ExtensionContext) {
  const collection = vscode.languages.createDiagnosticCollection('lscheck');
  const timers = new Map<string, NodeJS.Timeout>();

  const configFor = (doc: vscode.TextDocument) => {
    const s = vscode.workspace.getConfiguration('lscheck', doc.uri);
    const base = mergeConfig({ firmware: s.get('firmware', 'V9.30'), limits: s.get('limits', {}), rules: s.get('rules', {}), macros: s.get('macros', []), externalPrograms: s.get('externalPrograms', []) });
    // .lscheckrc.json (shared with the CLI) overrides editor settings
    return doc.uri.scheme === 'file' ? loadConfigFor(path.dirname(doc.uri.fsPath), base) : { config: base };
  };

  // CALL/RUN targets: index of programs under the config folder (or the file's folder). Built asynchronously,
  // reused until a program file is created or deleted (file watcher below), never built inside run().
  const indexes = new Map<string, WorkspaceIndex>();
  const building = new Map<string, Promise<void>>();
  const workspaceFor = (doc: vscode.TextDocument, dir?: string): WorkspaceIndex | undefined => {
    if (doc.uri.scheme !== 'file') return undefined;
    const root = dir ?? path.dirname(doc.uri.fsPath);
    const hit = indexes.get(root);
    if (hit) return hit;
    if (!building.has(root)) {
      building.set(
        root,
        buildWorkspaceIndexAsync(root).then((index) => {
          indexes.set(root, index);
          building.delete(root);
          vscode.workspace.textDocuments.forEach(schedule); // re-check once the index is ready
        }),
      );
    }
    return undefined; // no CALL/RUN checks until the first scan finishes
  };

  const run = (doc: vscode.TextDocument) => {
    if (doc.languageId !== LANGUAGE_ID) return;
    const editor = vscode.window.visibleTextEditors.find((e) => e.document === doc);
    const loaded: { config: ReturnType<typeof mergeConfig>; error?: string; dir?: string } = configFor(doc);
    const diags = check(doc.getText(), loaded.config, { cursorLine: editor?.selection.active.line, workspace: workspaceFor(doc, loaded.dir) });
    if (loaded.error) diags.unshift(configErrorDiagnostic(loaded.error));
    collection.set(
      doc.uri,
      diags.map((d) => {
        const vd = new vscode.Diagnostic(new vscode.Range(d.line, d.column, d.line, d.endColumn), d.message, SEVERITY[d.severity]);
        vd.source = 'lscheck';
        vd.code = d.code;
        return vd;
      }),
    );
  };

  const schedule = (doc: vscode.TextDocument) => {
    if (doc.languageId !== LANGUAGE_ID) return;
    const key = doc.uri.toString();
    clearTimeout(timers.get(key));
    const delay = vscode.workspace.getConfiguration('lscheck', doc.uri).get<number>('debounceMs', 400);
    timers.set(
      key,
      setTimeout(() => {
        timers.delete(key);
        run(doc);
      }, delay),
    );
  };

  // A program file appearing or disappearing changes CALL/RUN results in every open document
  const watcher = vscode.workspace.createFileSystemWatcher('**/*.{[lL][sS],[tT][pP],[kK][lL],[pP][cC]}');
  const invalidate = () => {
    indexes.clear();
    vscode.workspace.textDocuments.forEach(schedule);
  };

  context.subscriptions.push(
    collection,
    vscode.workspace.onDidOpenTextDocument(schedule),
    vscode.workspace.onDidChangeTextDocument((e) => schedule(e.document)),
    vscode.window.onDidChangeTextEditorSelection((e) => schedule(e.textEditor.document)),
    vscode.workspace.onDidCloseTextDocument((d) => {
      clearTimeout(timers.get(d.uri.toString()));
      timers.delete(d.uri.toString());
      collection.delete(d.uri);
    }),
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (e.affectsConfiguration('lscheck')) vscode.workspace.textDocuments.forEach(schedule);
    }),
    watcher,
    watcher.onDidCreate(invalidate),
    watcher.onDidDelete(invalidate),
    { dispose: () => timers.forEach(clearTimeout) },
  );
  vscode.workspace.textDocuments.forEach(schedule);
}

export function deactivate() {}
