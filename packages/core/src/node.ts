import * as fs from 'fs';
import * as path from 'path';
import { Diagnostic, LsConfig, mergeConfig, WorkspaceIndex } from './types';

export const CONFIG_FILE = '.lscheckrc.json';

export interface LoadedConfig {
  config: LsConfig;
  /** Folder holding the .lscheckrc.json that was used; the workspace root for CALL/RUN lookups. Undefined when none was found. */
  dir?: string;
  /** Set when a .lscheckrc.json exists but could not be used; defaults/base settings apply. */
  error?: string;
}

/** Walk up from `start` looking for .lscheckrc.json; returns the merged config over `base`. */
export function loadConfigFor(start: string, base: Partial<LsConfig> = {}): LoadedConfig {
  let dir = path.resolve(start);
  for (;;) {
    const f = path.join(dir, CONFIG_FILE);
    if (fs.existsSync(f)) {
      try {
        const rc = JSON.parse(fs.readFileSync(f, 'utf8').replace(/^﻿/, ''));
        if (rc === null || typeof rc !== 'object' || Array.isArray(rc)) throw new Error('top level must be a JSON object');
        return { dir, config: mergeConfig({ ...base, ...rc, limits: { ...base.limits, ...rc.limits }, rules: { ...base.rules, ...rc.rules } }) };
      } catch (e) {
        return { dir, config: mergeConfig(base), error: `${f}: ${(e as Error).message}` };
      }
    }
    const up = path.dirname(dir);
    if (up === dir) return { config: mergeConfig(base) };
    dir = up;
  }
}

/** A diagnostic to show at the top of a file when its config could not be loaded. */
export function configErrorDiagnostic(message: string): Diagnostic {
  return { line: 0, column: 0, endColumn: 1, severity: 'error', code: 'config-error', message: `Invalid ${CONFIG_FILE}: ${message}` };
}

/** File types that can be CALLed/RUN: TP source/binary and KAREL source/binary. */
export const PROGRAM_EXT = /\.(ls|tp|kl|pc)$/i;
const SKIP_DIRS = new Set(['node_modules', '.git']);
const MAX_FILES = 20000;
const MAX_DIRS = 5000;

const progName = (file: string) => file.replace(PROGRAM_EXT, '').toUpperCase();
const protoNameOf = (head: string) => /\/PROG\s+(\S+)/.exec(head)?.[1].toUpperCase();

/** Collect program names under `root` (recursive): file names without extension, plus the /PROG name of each .LS file. */
export function buildWorkspaceIndex(root: string): WorkspaceIndex {
  const programs = new Set<string>();
  let files = 0;
  let dirs = 0;
  let truncated = false;
  const walk = (dir: string) => {
    if (++dirs > MAX_DIRS) return void (truncated = true);
    let entries: fs.Dirent[];
    try {
      entries = fs.readdirSync(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const e of entries) {
      if (truncated) return;
      const p = path.join(dir, e.name);
      if (e.isDirectory()) {
        if (!SKIP_DIRS.has(e.name)) walk(p);
      } else if (PROGRAM_EXT.test(e.name)) {
        if (++files > MAX_FILES) return void (truncated = true);
        programs.add(progName(e.name));
        if (/\.ls$/i.test(e.name)) {
          try {
            const fd = fs.openSync(p, 'r');
            const buf = Buffer.alloc(256);
            const len = fs.readSync(fd, buf, 0, 256, 0);
            fs.closeSync(fd);
            const m = protoNameOf(buf.toString('utf8', 0, len));
            if (m) programs.add(m);
          } catch {
            /* unreadable file: the file name alone is used */
          }
        }
      }
    }
  };
  walk(root);
  return { programs, truncated };
}

/** Same as buildWorkspaceIndex but does not block the event loop (used by the editor extension). */
export async function buildWorkspaceIndexAsync(root: string): Promise<WorkspaceIndex> {
  const programs = new Set<string>();
  let files = 0;
  let dirs = 0;
  let truncated = false;
  const walk = async (dir: string): Promise<void> => {
    if (++dirs > MAX_DIRS) {
      truncated = true;
      return;
    }
    let entries: fs.Dirent[];
    try {
      entries = await fs.promises.readdir(dir, { withFileTypes: true });
    } catch {
      return;
    }
    for (const e of entries) {
      if (truncated) return;
      const p = path.join(dir, e.name);
      if (e.isDirectory()) {
        if (!SKIP_DIRS.has(e.name)) await walk(p);
      } else if (PROGRAM_EXT.test(e.name)) {
        if (++files > MAX_FILES) {
          truncated = true;
          return;
        }
        programs.add(progName(e.name));
        if (/\.ls$/i.test(e.name)) {
          try {
            const h = await fs.promises.open(p, 'r');
            const buf = Buffer.alloc(256);
            const { bytesRead } = await h.read(buf, 0, 256, 0);
            await h.close();
            const m = protoNameOf(buf.toString('utf8', 0, bytesRead));
            if (m) programs.add(m);
          } catch {
            /* unreadable file */
          }
        }
      }
    }
  };
  await walk(root);
  return { programs, truncated };
}
