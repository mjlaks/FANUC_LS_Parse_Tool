export type Severity = 'error' | 'warning' | 'hint';

export interface Diagnostic {
  /** 0-based line */
  line: number;
  /** 0-based start column */
  column: number;
  /** 0-based exclusive end column */
  endColumn: number;
  severity: Severity;
  code: string;
  message: string;
  /** True for "still being typed" problems that are suppressed on the cursor line. */
  incomplete?: boolean;
  /** Inclusive line span of the incomplete construct; the cursor anywhere inside it suppresses the diagnostic. */
  span?: [number, number];
}

export interface LsConfig {
  /** Controller firmware dialect, e.g. "V9.30". Used to gate version-specific rules. */
  firmware: string;
  limits: Limits;
  maxProgramNameLength: number;
  /** Macro names (first word of the statement, case-insensitive) that are accepted without an unknown-instruction diagnostic. */
  macros: string[];
  /** Program names CALLed/RUN that live only on the controller (not in the workspace); never reported as unknown-program. */
  externalPrograms: string[];
  /** Per-code severity override; "off" disables a rule. */
  rules: Record<string, Severity | 'off'>;
}

/** Highest valid index per register/I/O type (lowest is 1, except where noted in instr.ts). */
export interface Limits {
  p: number; pr: number; vr: number; r: number;
  di: number; do: number; ri: number; ro: number; gi: number; go: number; ai: number; ao: number;
  ui: number; uo: number; si: number; so: number; f: number; m: number; sr: number; ar: number;
  timer: number; payload: number; uframe: number; utool: number;
}

/** Program names (upper case, no extension) known to exist in the workspace; used for CALL/RUN target checks. */
export interface WorkspaceIndex {
  programs: ReadonlySet<string>;
  /** True when the folder scan hit its size cap, so the set may be incomplete and CALL/RUN targets are not checked. */
  truncated?: boolean;
}

export interface CheckOptions {
  /** 0-based line the user is editing; incomplete-statement errors on it are suppressed. */
  cursorLine?: number;
  /** When given, CALL/RUN targets are checked against it. Omit to skip that check. */
  workspace?: WorkspaceIndex;
}

export const defaultConfig: LsConfig = {
  firmware: 'V9.30',
  limits: {
    p: 32767, pr: 1000, vr: 10, r: 1000,
    di: 1024, do: 1024, ri: 8, ro: 8, gi: 100, go: 100, ai: 100, ao: 100,
    ui: 18, uo: 18, si: 100, so: 100, f: 1000, m: 1000, sr: 100, ar: 10,
    timer: 10, payload: 10, uframe: 9, utool: 10,
  },
  maxProgramNameLength: 36,
  macros: [],
  externalPrograms: [],
  rules: {},
};

export function mergeConfig(partial: Partial<Omit<LsConfig, 'limits'>> & { limits?: Partial<LsConfig['limits']> } = {}): LsConfig {
  return {
    ...defaultConfig,
    ...partial,
    limits: { ...defaultConfig.limits, ...partial.limits },
    rules: { ...defaultConfig.rules, ...partial.rules },
    macros: Array.isArray(partial.macros) ? partial.macros.map(String) : defaultConfig.macros,
    externalPrograms: Array.isArray(partial.externalPrograms) ? partial.externalPrograms.map(String) : defaultConfig.externalPrograms,
  };
}
