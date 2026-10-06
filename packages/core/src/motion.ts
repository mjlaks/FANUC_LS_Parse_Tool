import { LsConfig } from './types';

/** A problem found inside a statement, as offsets into the joined statement text. */
export class StmtError extends Error {
  constructor(
    public start: number,
    public end: number,
    public code: string,
    message: string,
    public severity: 'error' | 'warning' | 'hint' = 'error',
  ) {
    super(message);
  }
}

export interface MotionReport {
  /** Non-fatal findings (warnings) */
  notes: StmtError[];
  /** Numeric P[n] references: [index, start, end] */
  positions: Array<[number, number, number]>;
  /** LBL targets of Skip,LBL[n]: [index, start, end] */
  jumps: Array<[number, number, number]>;
  /** VR[n] used by VOFFSET: [index, start, end] */
  vrUses: Array<[number, number, number]>;
  /** Offsets of TB/TA/DB action text (run to end of statement), to be checked as instructions */
  actions: Array<[number, number]>;
  /** True when the move ends in CNT/CR, so following instructions run before the robot arrives */
  blend: boolean;
  /** First fatal error, if any */
  error?: StmtError;
}

const JOINT_UNITS = ['%', 'sec', 'msec'];
const CART_UNITS = ['mm/sec', 'cm/min', 'inch/min', 'deg/sec', 'sec', 'msec'];
const UNIT_RE = /^(mm\/sec|cm\/min|inch\/min|deg\/sec|msec|sec|%)/i;
const FLAG_OPTIONS = new Set(['inc', 'wjnt', 'rtcp', 'coord', 'break', 'pth', 'ptp']);
/** options taking a number (+ optional unit) directly after the keyword */
const VALUE_OPTIONS = new Set(['acc', 'ev', 'ind.ev', 'ap_ld', 'rt_ld', 'pspd']);
/** options taking "<time/dist>,<action...>" where the action runs to end of statement */
const TRIGGER_OPTIONS = new Set(['tb', 'ta', 'db']);

/**
 * Parse one motion statement (text with no trailing ';'; continuation lines joined by '\n').
 * Stops at the first fatal error, which is reported in `error`.
 */
export function parseMotion(s: string, cfg: LsConfig): MotionReport {
  const rep: MotionReport = { notes: [], positions: [], jumps: [], vrUses: [], actions: [], blend: false };
  let i = 0;
  const ws = () => {
    while (i < s.length && (s[i] === ' ' || s[i] === '\t' || s[i] === '\n')) i++;
  };
  const fail = (a: number, b: number, code: string, msg: string): never => {
    throw new StmtError(a, Math.max(b, a + 1), code, msg);
  };

  interface Ref { name: string; content: string; start: number; end: number; index?: number }
  const readRef = (): Ref | null => {
    const m = /^[A-Za-z]+/.exec(s.slice(i));
    if (!m || s[i + m[0].length] !== '[') return null;
    const start = i;
    i += m[0].length + 1;
    const cs = i;
    let depth = 1;
    while (i < s.length && depth > 0) {
      if (s[i] === '"') {
        const q = s.indexOf('"', i + 1);
        if (q >= 0) i = q; // skip quoted text, e.g. P[1:"a]b"]
      } else if (s[i] === '[') depth++;
      else if (s[i] === ']') depth--;
      i++;
    }
    if (depth > 0) fail(start, i, 'unbalanced-bracket', `Missing ']' for ${m[0]}[`);
    const content = s.slice(cs, i - 1);
    const im = /^\s*(?:GP\d+:)?(\d+)/.exec(content);
    return { name: m[0].toUpperCase(), content, start, end: i, index: im ? Number(im[1]) : undefined };
  };

  const number = (): string | null => {
    const m = /^(?:\d+(?:\.\d+)?|\.\d+)/.exec(s.slice(i));
    if (!m) return null;
    i += m[0].length;
    return m[0];
  };

  const position = () => {
    ws();
    const at = i;
    const r = readRef();
    if (!r || (r.name !== 'P' && r.name !== 'PR')) {
      fail(at, at + 1, 'expected-position', 'Expected a position: P[n] or PR[n]');
      return;
    }
    if (r!.index !== undefined) {
      const max = r!.name === 'P' ? cfg.limits.p : cfg.limits.pr;
      if (r!.index < 1 || r!.index > max) {
        fail(r!.start, r!.end, 'index-range', `${r!.name}[${r!.index}] is outside 1..${max}`);
      }
      if (r!.name === 'P') rep.positions.push([r!.index, r!.start, r!.end]);
    }
  };

  const speed = (kind: string) => {
    ws();
    const at = i;
    let value: number | undefined;
    const mx = /^max_speed\b/i.exec(s.slice(i));
    if (mx) {
      i += mx[0].length; // unit-less "maximum speed" keyword
      return;
    }
    if (/^R\[/i.test(s.slice(i))) {
      readRef();
    } else {
      const n = number();
      if (n === null) return fail(at, at + 1, 'expected-speed', 'Expected a speed such as 100mm/sec, 50% or R[n]mm/sec');
      value = Number(n);
      if (s[i] === ' ' || s[i] === '\t') {
        let k = i;
        while (s[k] === ' ' || s[k] === '\t') k++;
        if (UNIT_RE.test(s.slice(k))) {
          // controller output never has a gap; unconfirmed whether the loader accepts one
          rep.notes.push(new StmtError(i, k, 'speed-spacing', 'Space between speed value and unit; the controller writes them together (e.g. 100mm/sec)', 'warning'));
          i = k;
        }
      }
    }
    const um = UNIT_RE.exec(s.slice(i));
    if (!um) return fail(i, i + 1, 'bad-speed-unit', 'Expected a speed unit (%, mm/sec, cm/min, inch/min, deg/sec, sec, msec)');
    const unit = um[1].toLowerCase();
    const uStart = i;
    i += um[1].length;
    const valid = kind === 'J' ? JOINT_UNITS : CART_UNITS;
    if (!valid.includes(unit)) {
      const why = unit === '%' ? "'%' is only valid for joint (J) moves" : `'${unit}' is not valid for a ${kind} move`;
      fail(uStart, i, 'speed-unit-invalid', `${why}; use ${valid.join(', ')}`);
    }
    if (value !== undefined) {
      if (value <= 0) fail(at, i, 'speed-range', 'Speed must be greater than 0');
      if (unit === '%' && value > 100) fail(at, i, 'speed-range', 'Joint speed must be 1..100%');
      if (unit === 'mm/sec' && value > 2000) fail(at, i, 'speed-range', 'Speed exceeds 2000 mm/sec');
    }
  };

  const termination = () => {
    ws();
    const at = i;
    const m = /^(FINE|CNT|CR)(?![A-Za-z_])/i.exec(s.slice(i));
    if (!m) return fail(at, at + 1, 'expected-termination', 'Expected termination: FINE, CNTn (0-100) or CRn');
    i += m[0].length;
    const word = m[0].toUpperCase();
    if (word === 'FINE') return;
    rep.blend = true;
    while (s[i] === ' ' || s[i] === '\t') i++;
    if (/^R\[/i.test(s.slice(i))) {
      readRef();
      return;
    }
    const n = /^\d+/.exec(s.slice(i));
    if (!n) return fail(at, i, 'expected-termination', `${word} needs a value 0-100 or R[n]`);
    i += n[0].length;
    if (s[i] === '.' || /[A-Za-z_]/.test(s[i] ?? '')) fail(at, i + 1, 'cnt-range', `${word} value must be a whole number 0..100`);
    if (Number(n[0]) > 100) fail(at, i, 'cnt-range', `${word} value ${n[0]} is outside 0..100`);
  };

  const options = () => {
    for (;;) {
      ws();
      if (i >= s.length) return;
      const at = i;
      const m = /^[A-Za-z_][A-Za-z_.]*/.exec(s.slice(i));
      if (!m) return fail(at, at + 1, 'unexpected-text', `Unexpected '${s[i]}' in motion statement`);
      i += m[0].length;
      const name = m[0].toLowerCase();
      if (FLAG_OPTIONS.has(name)) continue;
      if (VALUE_OPTIONS.has(name)) {
        while (s[i] === ' ' || s[i] === '\t') i++;
        if (/^R\[/i.test(s.slice(i))) readRef();
        else {
          const vs = i;
          const num = number();
          if (num === null) fail(at, i, 'option-arg', `${m[0]} needs a value`);
          if (name === 'acc' && Number(num) > 500) fail(vs, i, 'numeric-range', 'ACC must be 0..500');
        }
        const u = /^(%|sec)/i.exec(s.slice(i));
        if (u) i += u[0].length;
        continue;
      }
      if (TRIGGER_OPTIONS.has(name)) {
        ws();
        if (number() === null) fail(at, i, 'option-arg', `${m[0]} needs a time/distance value`);
        const u = /^(sec|mm|inch)/i.exec(s.slice(i));
        if (u) i += u[0].length;
        if (s[i] !== ',') fail(at, i, 'option-arg', `${m[0]} needs ",<action>" after the value`);
        // action text runs up to the next motion option (or the end of the statement)
        const from = i + 1;
        const nxt = /[ \t\n](?:tb|ta|db|acc|inc|wjnt|rtcp|pth|ptp|coord|break|ev|ind\.ev|offset|tool_offset|voffset|skip|ap_ld|rt_ld|pspd)(?![A-Za-z_])/i.exec(s.slice(from));
        const to = nxt ? from + nxt.index : s.length;
        rep.actions.push([from, to]);
        i = to;
        continue;
      }
      if (name === 'offset' || name === 'tool_offset' || name === 'voffset' || name === 'skip') {
        const want = name === 'voffset' ? 'VR' : name === 'skip' ? 'LBL' : 'PR';
        if (s[i] !== ',') {
          if (name === 'voffset' || name === 'skip') fail(at, i, 'option-arg', `${m[0]} needs ",${want}[n]"`);
          continue;
        }
        i++;
        const a = i;
        const r = readRef();
        if (!r || r.name !== want) fail(a, Math.max(i, a + 1), 'option-arg', `${m[0]} expects ${want}[n]`);
        if (r!.index !== undefined) {
          const max = r!.name === 'VR' ? cfg.limits.vr : r!.name === 'PR' ? cfg.limits.pr : undefined;
          if (max !== undefined && (r!.index < 1 || r!.index > max)) fail(r!.start, r!.end, 'index-range', `${r!.name}[${r!.index}] is outside 1..${max}`);
          if (r!.name === 'VR') rep.vrUses.push([r!.index, r!.start, r!.end]);
          if (r!.name === 'LBL') rep.jumps.push([r!.index, r!.start, r!.end]);
        }
        if (name === 'skip' && s[i] === ',') {
          while (i < s.length && s[i] !== ' ' && s[i] !== '\t' && s[i] !== '\n') i++; // ,PR[n]=LPOS
        }
        continue;
      }
      rep.notes.push(new StmtError(at, i, 'unknown-motion-option', `Unrecognized motion option '${m[0]}'`, 'warning'));
      while (i < s.length && s[i] === ',') {
        i++;
        if (!readRef()) while (i < s.length && !/[\s,]/.test(s[i])) i++;
      }
    }
  };

  try {
    ws();
    const kind = s[i].toUpperCase();
    i++;
    position();
    speed(kind);
    termination();
    if (kind === 'C') {
      ws();
      if (i >= s.length) fail(i - 1, i, 'circular-incomplete', 'Circular move needs a via point and an end point (second P[n] on the next line)');
      position();
      speed(kind);
      termination();
    }
    options();
  } catch (e) {
    if (e instanceof StmtError) rep.error = e;
    else throw e;
  }
  return rep;
}
