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
  limits: { p: number; pr: number; vr: number; r: number };
  maxProgramNameLength: number;
  /** Per-code severity override; "off" disables a rule. */
  rules: Record<string, Severity | 'off'>;
}

export interface CheckOptions {
  /** 0-based line the user is editing; incomplete-statement errors on it are suppressed. */
  cursorLine?: number;
}

export const defaultConfig: LsConfig = {
  firmware: 'V9.30',
  limits: { p: 32767, pr: 1000, vr: 10, r: 1000 },
  maxProgramNameLength: 36,
  rules: {},
};

export function mergeConfig(partial: Partial<Omit<LsConfig, 'limits'>> & { limits?: Partial<LsConfig['limits']> } = {}): LsConfig {
  return {
    ...defaultConfig,
    ...partial,
    limits: { ...defaultConfig.limits, ...partial.limits },
    rules: { ...defaultConfig.rules, ...partial.rules },
  };
}
