#!/usr/bin/env node
import * as fs from 'fs';
import * as path from 'path';
import { check, formatDiagnostic, Severity, WorkspaceIndex } from '@lscheck/core';
import { buildWorkspaceIndex, configErrorDiagnostic, loadConfigFor } from '@lscheck/core/dist/node';

const USAGE = `Usage: lscheck [--format text|json] [--firmware V9.30] [--max-warnings N] [--no-workspace] <file.LS>...
CALL/RUN targets are looked up in the folder tree of the nearest .lscheckrc.json (or the file's folder).
Exits 1 if any error is found (or warnings exceed --max-warnings), 2 on bad usage.`;

export function run(argv: string[], out: (s: string) => void = console.log): number {
  const files: string[] = [];
  let format = 'text';
  let firmware: string | undefined;
  let maxWarnings = Infinity;
  let useWorkspace = true;
  const indexes = new Map<string, WorkspaceIndex>();
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--format') format = argv[++i];
    else if (a === '--firmware') firmware = argv[++i];
    else if (a === '--max-warnings') {
      const v = argv[++i];
      maxWarnings = /^\d+$/.test(v ?? '') ? Number(v) : NaN;
      if (Number.isNaN(maxWarnings)) return out(`--max-warnings needs a non-negative integer\n${USAGE}`), 2;
    }
    else if (a === '--no-workspace') useWorkspace = false;
    else if (a === '-h' || a === '--help') return out(USAGE), 0;
    else if (a.startsWith('-')) return out(`Unknown option ${a}\n${USAGE}`), 2;
    else files.push(a);
  }
  if (!files.length || firmware === undefined && argv.includes('--firmware') || (format !== 'text' && format !== 'json')) return out(USAGE), 2;

  let errors = 0;
  let warnings = 0;
  const json: Record<string, unknown[]> = {};
  for (const file of files) {
    const loaded = loadConfigFor(path.dirname(path.resolve(file)), firmware ? { firmware } : {});
    let workspace: WorkspaceIndex | undefined;
    if (useWorkspace) {
      const root = loaded.dir ?? path.dirname(path.resolve(file));
      workspace = indexes.get(root) ?? buildWorkspaceIndex(root);
      indexes.set(root, workspace);
    }
    const diags = check(fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, ''), loaded.config, { workspace });
    if (loaded.error) diags.unshift(configErrorDiagnostic(loaded.error));
    const count = (s: Severity) => diags.filter((d) => d.severity === s).length;
    errors += count('error');
    warnings += count('warning');
    if (format === 'json') json[file] = diags;
    else for (const d of diags) out(formatDiagnostic(file, d));
  }
  if (format === 'json') out(JSON.stringify(json, null, 2));
  else out(`${errors} error(s), ${warnings} warning(s)`);
  return errors > 0 || warnings > maxWarnings ? 1 : 0;
}

if (require.main === module) process.exitCode = run(process.argv.slice(2));
