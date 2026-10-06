import * as fs from 'fs';
import * as path from 'path';
import { Diagnostic, LsConfig, mergeConfig } from './types';

export const CONFIG_FILE = '.lscheckrc.json';

export interface LoadedConfig {
  config: LsConfig;
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
        return { config: mergeConfig({ ...base, ...rc, limits: { ...base.limits, ...rc.limits }, rules: { ...base.rules, ...rc.rules } }) };
      } catch (e) {
        return { config: mergeConfig(base), error: `${f}: ${(e as Error).message}` };
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
