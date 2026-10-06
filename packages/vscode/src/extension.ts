import * as path from 'path';
import * as vscode from 'vscode';
import { check, Diagnostic, mergeConfig } from '@lscheck/core';
import { configErrorDiagnostic, loadConfigFor } from '@lscheck/core/dist/node';

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
    const base = mergeConfig({ firmware: s.get('firmware', 'V9.30'), limits: s.get('limits', {}), rules: s.get('rules', {}) });
    // .lscheckrc.json (shared with the CLI) overrides editor settings
    return doc.uri.scheme === 'file' ? loadConfigFor(path.dirname(doc.uri.fsPath), base) : { config: base };
  };

  const run = (doc: vscode.TextDocument) => {
    if (doc.languageId !== LANGUAGE_ID) return;
    const editor = vscode.window.visibleTextEditors.find((e) => e.document === doc);
    const loaded = configFor(doc);
    const diags = check(doc.getText(), loaded.config, { cursorLine: editor?.selection.active.line });
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
    timers.set(key, setTimeout(() => run(doc), delay));
  };

  context.subscriptions.push(
    collection,
    vscode.workspace.onDidOpenTextDocument(run),
    vscode.workspace.onDidChangeTextDocument((e) => schedule(e.document)),
    vscode.window.onDidChangeTextEditorSelection((e) => schedule(e.textEditor.document)),
    vscode.workspace.onDidCloseTextDocument((d) => {
      clearTimeout(timers.get(d.uri.toString()));
      collection.delete(d.uri);
    }),
    vscode.workspace.onDidChangeConfiguration((e) => {
      if (e.affectsConfiguration('lscheck')) vscode.workspace.textDocuments.forEach(run);
    }),
    { dispose: () => timers.forEach(clearTimeout) },
  );
  vscode.workspace.textDocuments.forEach(run);
}

export function deactivate() {}
