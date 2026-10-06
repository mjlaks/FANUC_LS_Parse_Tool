import { StmtError } from './motion';
import { LsConfig } from './types';

/**
 * Parser for every non-motion /MN statement: registers, I/O, flow control, WAIT, CALL/RUN, iRVision.
 * Motion statements are detected here (`motionAt`) and handed to motion.ts by the caller.
 *
 * Offsets in all results are into the statement text passed in (continuation lines joined by '\n').
 * Syntax marked "unverified" in comments is taken from the project brief, not from the controller manual
 * or a real corpus file, and is reported as a warning rather than an error where it matters.
 */

export interface Span {
  n?: number;
  name?: string;
  start: number;
  end: number;
}

export type StmtKind =
  | 'empty' | 'comment' | 'motion' | 'label' | 'jmp' | 'call' | 'run'
  | 'if-inline' | 'if-block' | 'else' | 'endif' | 'for' | 'endfor' | 'select' | 'case' | 'select-else'
  | 'end' | 'pause' | 'abort' | 'wait' | 'assign' | 'vision' | 'macro' | 'other';

export interface InstrReport {
  kind: StmtKind;
  notes: StmtError[];
  error?: StmtError;
  /** LBL[n] definitions */
  labels: Span[];
  /** Literal jump targets: JMP LBL[n], Skip,LBL[n], TIMEOUT,LBL[n], GET_OFFSET ... JMP LBL[n], SELECT/IF jumps */
  jumps: Span[];
  calls: Array<Span & { kind: 'CALL' | 'RUN' }>;
  /** P[n] references: [index, start, end] */
  posRefs: Array<[number, number, number]>;
  /** VR[n] populated by VISION GET_OFFSET */
  vrSets: Span[];
  /** VR[n] read in an expression */
  vrUses: Span[];
  /** Offset where a motion statement (J/L/C/A) begins, when the statement or its IF action is one */
  motionAt?: number;
  /** True for output assignments (DO/RO/GO/AO/UO/SO/F/M, PULSE) */
  io?: boolean;
  frameSet?: 'UFRAME' | 'UTOOL';
}

const KEYWORDS = [
  'CALL', 'RUN', 'JMP', 'LBL', 'IF', 'THEN', 'ELSE', 'ENDIF', 'FOR', 'ENDFOR', 'SELECT', 'WAIT', 'END', 'PAUSE', 'ABORT',
  'MONITOR', 'WHEN', 'VISION', 'MESSAGE', 'OVERRIDE', 'UFRAME_NUM', 'UTOOL_NUM', 'PAYLOAD', 'TIMER', 'SKIP', 'OFFSET',
  'TOOL_OFFSET', 'COL', 'LOCK', 'UNLOCK', 'UALM', 'RSR', 'ERROR_PROG', 'RESUME_PROG',
];

/** Index ranges [min, max key in cfg.limits]. SI/SO start at 0; everything else at 1. */
const REG_LIMITS: Record<string, [number, keyof LsConfig['limits']]> = {
  R: [1, 'r'], PR: [1, 'pr'], VR: [1, 'vr'], P: [1, 'p'],
  DI: [1, 'di'], DO: [1, 'do'], RI: [1, 'ri'], RO: [1, 'ro'], GI: [1, 'gi'], GO: [1, 'go'],
  AI: [1, 'ai'], AO: [1, 'ao'], UI: [1, 'ui'], UO: [1, 'uo'], SI: [0, 'si'], SO: [0, 'so'],
  F: [1, 'f'], M: [1, 'm'], SR: [1, 'sr'], AR: [1, 'ar'], TIMER: [1, 'timer'], PAYLOAD: [1, 'payload'],
  UFRAME: [1, 'uframe'], UTOOL: [1, 'utool'],
};
const REF_NAMES = new Set([...Object.keys(REG_LIMITS), 'TIMER_OVERFLOW', 'LBL', 'MESSAGE', 'UALM', 'RSR', 'JOINT_MAX_SPEED', 'LINEAR_MAX_SPEED']);
const INPUTS = new Set(['DI', 'RI', 'GI', 'AI', 'SI', 'UI', 'AR', 'P', 'VR']);
const OUTPUTS = new Set(['DO', 'RO', 'GO', 'AO', 'SO', 'UO', 'F', 'M']);
const CONSTANTS = new Set(['ON', 'OFF', 'START', 'STOP', 'RESET', 'JPOS', 'LPOS', 'ENABLE', 'DISABLE', 'TRUE', 'FALSE']);
/** VR[n].FIELD names; unverified against the iRVision manual, unknown fields only warn. */
const VR_FIELDS = new Set(['MODELID', 'FOUND_POS', 'OFFSET', 'MEASURE', 'ENCODER', 'ENC_CNT', 'FOUND_TIME', 'MODEL', 'SCALE', 'CONFIDENCE', 'MEASURE_POS', 'RESULT']);
const VISION_KEYWORDS = ['RUN_FIND', 'GET_OFFSET', 'GET_NFOUND', 'SET_REFERENCE', 'OVERRIDE', 'CAMERA_CALIB'];
/** String register functions and their argument counts. */
const STRING_FUNCS: Record<string, number> = { STRLEN: 1, SUBSTR: 3, FINDSTR: 2 };
const BLOCK_ONLY = new Set(['if-block', 'else', 'endif', 'for', 'endfor', 'select', 'case', 'select-else', 'label', 'end']);

function lev(a: string, b: string): number {
  const d: number[] = Array.from({ length: b.length + 1 }, (_, j) => j);
  for (let i = 1; i <= a.length; i++) {
    let prev = d[0];
    d[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const t = d[j];
      d[j] = Math.min(d[j] + 1, d[j - 1] + 1, prev + (a[i - 1] === b[j - 1] ? 0 : 1));
      prev = t;
    }
  }
  return d[b.length];
}

export function parseInstr(s: string, cfg: LsConfig): InstrReport {
  const rep: InstrReport = { kind: 'other', notes: [], labels: [], jumps: [], calls: [], posRefs: [], vrSets: [], vrUses: [] };
  let i = 0;
  const warn = (a: number, b: number, code: string, msg: string) => rep.notes.push(new StmtError(a, Math.max(b, a + 1), code, msg, 'warning'));
  const fail = (a: number, b: number, code: string, msg: string): never => {
    throw new StmtError(a, Math.max(b, a + 1), code, msg);
  };
  const ws = () => {
    while (i < s.length && (s[i] === ' ' || s[i] === '\t' || s[i] === '\n')) i++;
  };
  const atEnd = () => {
    ws();
    return i >= s.length;
  };
  const rest = () => s.slice(i);
  const word = (): string | null => {
    const m = /^[A-Za-z_][A-Za-z_0-9]*/.exec(rest());
    return m ? m[0] : null;
  };
  /** Consume a whole word (case-insensitive), not a prefix of a longer identifier. */
  const eatWord = (w: string): boolean => {
    ws();
    const m = word();
    if (m && m.toUpperCase() === w) {
      i += m.length;
      return true;
    }
    return false;
  };
  const eat = (c: string): boolean => {
    ws();
    if (s.startsWith(c, i)) {
      i += c.length;
      return true;
    }
    return false;
  };
  const expect = (c: string, what = `'${c}'`) => {
    if (!eat(c)) fail(i, i + 1, 'expected-token', `Expected ${what}`);
  };
  const endOfStatement = () => {
    if (!atEnd()) fail(i, s.length, 'unexpected-text', `Unexpected '${s.slice(i).trim().slice(0, 20)}' at end of statement`);
  };

  const readString = (): string => {
    const start = i;
    i++;
    const q = s.indexOf("'", i);
    if (q < 0) {
      i = s.length;
      return fail(start, s.length, 'unterminated-string', "Unterminated ' string");
    }
    const t = s.slice(i, q);
    i = q + 1;
    return t;
  };

  /** Reads NAME[...]; `i` must be at the name. Validates the index and returns what it found. */
  interface Ref { name: string; start: number; end: number; index?: number }
  const ref = (): Ref => {
    const m = /^[A-Za-z_]+/.exec(rest())!;
    const name = m[0].toUpperCase();
    const start = i;
    i += m[0].length + 1; // name and '['
    const cs = i;
    let depth = 1;
    while (i < s.length && depth > 0) {
      if (s[i] === '[') depth++;
      else if (s[i] === ']') depth--;
      i++;
    }
    if (depth > 0) fail(start, i, 'unbalanced-bracket', `Missing ']' for ${m[0]}[`);
    const end = i;
    const inner = s.slice(cs, end - 1);
    const out: Ref = { name, start, end };
    if (name === 'MESSAGE') return out; // free text
    const lead = inner.length - inner.trimStart().length;
    let k = cs + lead;
    const body = inner.trimStart();
    if (!body) fail(start, end, 'empty-index', `${m[0]}[] needs an index`);
    // a leading GPn: (group selector) is accepted on P/PR/UFRAME_NUM-style refs
    const gp = /^GP\d+:?/i.exec(body);
    let rem = gp ? body.slice(gp[0].length) : body;
    if (gp) k += gp[0].length;
    const lit = /^(\d+)/.exec(rem);
    if (lit) {
      out.index = Number(lit[1]);
      rem = rem.slice(lit[1].length);
      k += lit[1].length;
      const lim = REG_LIMITS[name];
      if (lim) {
        const max = cfg.limits[lim[1]];
        if (out.index < lim[0] || out.index > max) fail(start, end, 'index-range', `${name}[${out.index}] is outside ${lim[0]}..${max}`);
      }
    } else if (/^[A-Za-z]+\[/.test(rem)) {
      // indirect index, e.g. R[AR[2]]; validate the nested reference
      const save = i;
      i = k;
      const nested = ref();
      k = i;
      i = save;
      if (!['R', 'AR', 'GI', 'AI'].includes(nested.name)) fail(nested.start, nested.end, 'bad-index', `${nested.name}[...] cannot be used as an index`);
      rem = s.slice(k, cs + inner.length);
    } else if (!(gp && !rem.trim()) && !rem.startsWith(':')) {
      fail(start, end, 'bad-index', `${m[0]}[${inner.slice(0, 12)}] needs a numeric index, a register, or n:comment`);
    }
    // PR[i,j] element access
    const el = /^\s*,\s*(\d+)/.exec(rem);
    if (el) {
      if (name !== 'PR' && name !== 'P') fail(start, end, 'bad-index', `${name}[i,j] element access is only valid on PR`);
      if (Number(el[1]) < 1 || Number(el[1]) > 9) fail(start, end, 'index-range', `PR element ${el[1]} is outside 1..9`);
      rem = rem.slice(el[0].length);
    } else if (/^\s*,\s*[A-Za-z]+\[/.test(rem)) {
      rem = ''; // PR[i,R[n]]: indirect element; not checked further
    }
    const t = rem.trim();
    if (t && !t.startsWith(':')) fail(start, end, 'bad-index', `Unexpected '${t.slice(0, 12)}' inside ${m[0]}[...]`);
    return out;
  };

  const sysvar = () => {
    // $NAME, $A.$B, $A[1].$B[2]; contents of [] are not validated
    const start = i;
    const m = /^\$[A-Za-z_][A-Za-z_0-9]*(?:\[[^\]]*\])?(?:\.\$?[A-Za-z_][A-Za-z_0-9]*(?:\[[^\]]*\])?)*/.exec(rest());
    if (!m) fail(start, start + 1, 'bad-sysvar', 'Malformed system variable name');
    i += m![0].length;
  };

  const number = (): string | null => {
    const m = /^(?:\d+(?:\.\d*)?|\.\d+)/.exec(rest());
    if (!m) return null;
    i += m[0].length;
    return m[0];
  };

  const BINARY = ['<>', '<=', '>=', '=', '<', '>', '+', '-', '*', '/', '|'];
  const WORD_OPS = ['AND', 'OR', 'DIV', 'MOD'];

  const primary = () => {
    ws();
    if (i >= s.length) fail(i - 1, i, 'expected-operand', 'Expected a value or register');
    const c = s[i];
    if (c === "'") {
      readString();
      return;
    }
    if (c === '$') return sysvar();
    if (c === '(') {
      i++;
      expr();
      expect(')');
      return;
    }
    if (/[\d.]/.test(c)) {
      const at = i;
      if (number() === null) fail(at, at + 1, 'bad-number', 'Malformed number');
      return;
    }
    const w = word();
    if (!w) return fail(i, i + 1, 'expected-operand', `Unexpected '${c}'; expected a value or register`);
    const up = w.toUpperCase();
    if (s[i + w.length] === '[') {
      if (!REF_NAMES.has(up)) return fail(i, i + w.length, 'unknown-register', `Unknown register type '${w}'`);
      const r = ref();
      if (r.name === 'P' && r.index !== undefined) rep.posRefs.push([r.index, r.start, r.end]);
      if (r.name === 'VR') {
        if (r.index !== undefined) rep.vrUses.push({ n: r.index, start: r.start, end: r.end });
        const f = /^\.([A-Za-z_][A-Za-z_0-9]*)(\[[^\]]*\])?/.exec(rest());
        if (f) {
          if (!VR_FIELDS.has(f[1].toUpperCase())) warn(i + 1, i + 1 + f[1].length, 'unknown-vr-field', `Unrecognized vision register field '.${f[1]}' (unverified against the iRVision manual)`);
          i += f[0].length;
          for (const g of rest().matchAll(/^\.[A-Za-z_0-9]+(\[[^\]]*\])?/g)) i += g[0].length;
        }
      }
      return;
    }
    if (CONSTANTS.has(up)) {
      i += w.length;
      return;
    }
    const arity = STRING_FUNCS[up];
    if (arity) {
      // string register functions: STRLEN SR[1] / SUBSTR SR[1],2,3 / FINDSTR SR[1],SR[2]
      i += w.length;
      for (let k = 0; k < arity; k++) {
        if (k > 0) expect(',', `',' (${up} takes ${arity} arguments)`);
        ws();
        if (s[i] === "'") readString();
        else unary();
      }
      return;
    }
    fail(i, i + w.length, 'unknown-operand', `Unknown value '${w}'`);
  };

  const unary = () => {
    ws();
    while (s[i] === '!' || s[i] === '-') {
      i++;
      ws();
    }
    primary();
  };

  /** Arithmetic/logical expression; operator precedence is not modelled, only well-formedness. */
  const expr = () => {
    unary();
    for (;;) {
      ws();
      let op = BINARY.find((b) => s.startsWith(b, i));
      if (!op) {
        const w = word();
        if (w && WORD_OPS.includes(w.toUpperCase())) op = w;
      }
      if (!op) return;
      i += op.length;
      unary();
    }
  };

  // ---- statement forms ------------------------------------------------------------------------------

  const literalLabel = (): void => {
    ws();
    if (!/^LBL\[/i.test(rest())) fail(i, i + 1, 'expected-token', 'Expected LBL[n]');
    const r = ref();
    if (r.index === undefined) {
      // JMP LBL[R[n]] is legal; only literal targets are cross-checked
      return;
    }
    if (r.index < 1 || r.index > 32766) fail(r.start, r.end, 'index-range', 'Label numbers are 1..32766');
    rep.jumps.push({ n: r.index, start: r.start, end: r.end });
  };

  const progName = (what: string): Span => {
    ws();
    // indirect target through a register, e.g. CALL SR[1]; resolved at run time, so not looked up
    if (/^(?:SR|R|AR)\[/i.test(rest())) {
      const r = ref();
      return { start: r.start, end: r.end };
    }
    const m = /^[A-Za-z_][A-Za-z_0-9]*/.exec(rest());
    if (!m) return fail(i, i + 1, 'expected-program-name', `${what} needs a program name`);
    const sp: Span = { name: m[0].toUpperCase(), start: i, end: i + m[0].length };
    i += m[0].length;
    return sp;
  };

  const action = () => {
    ws();
    const at = i;
    const sub = statement(true);
    if (BLOCK_ONLY.has(sub) && sub !== 'end') fail(at, Math.min(s.length, at + 8), 'bad-inline-action', 'This instruction cannot be used as the action of IF/SELECT/WHEN');
    return sub;
  };

  const callArgs = () => {
    if (!eat('(')) return;
    if (eat(')')) return;
    for (;;) {
      ws();
      if (s[i] === "'") readString();
      else expr();
      if (eat(',')) continue;
      expect(')', "')' to close the argument list");
      return;
    }
  };

  const wait = () => {
    ws();
    // WAIT 2.00(sec)
    const save = i;
    const n = number();
    if (n !== null && /^\s*\(\s*sec\s*\)/i.test(rest())) {
      i += /^\s*\(\s*sec\s*\)/i.exec(rest())![0].length;
      return endOfStatement();
    }
    i = save;
    expr();
    if (eatWord('TIMEOUT')) {
      expect(',');
      literalLabel();
    }
    endOfStatement();
  };

  const vision = () => {
    ws();
    const kwAt = i;
    const kw = word();
    if (!kw) return fail(i, i + 1, 'expected-token', `VISION needs an instruction (${VISION_KEYWORDS.join(', ')})`);
    i += kw.length;
    const up = kw.toUpperCase();
    const name = () => {
      ws();
      if (s[i] !== "'") fail(i, i + 1, 'vision-name-quote', `VISION ${up} needs the vision process name as a quoted string, e.g. 'PROC'`);
      const at = i;
      if (!readString().trim()) fail(at, i, 'vision-name-empty', 'Vision process name is empty');
    };
    // All VISION syntax is unverified against the V9.x iRVision manual (no corpus examples except CAMERA_CALIB).
    switch (up) {
      case 'RUN_FIND':
      case 'SET_REFERENCE':
        name();
        break;
      case 'GET_OFFSET': {
        name();
        ws();
        if (!/^VR\[/i.test(rest())) fail(i, i + 1, 'expected-token', 'VISION GET_OFFSET needs a vision register: VR[n]');
        const r = ref();
        if (r.index !== undefined) rep.vrSets.push({ n: r.index, start: r.start, end: r.end });
        if (eatWord('JMP')) literalLabel();
        else warn(i, i + 1, 'vision-syntax', "VISION GET_OFFSET normally ends with 'JMP LBL[n]' for the not-found case (unverified)");
        break;
      }
      case 'GET_NFOUND': {
        name();
        ws();
        if (!/^R\[/i.test(rest())) fail(i, i + 1, 'expected-token', 'VISION GET_NFOUND needs a numeric register: R[n]');
        ref();
        break;
      }
      case 'CAMERA_CALIB': {
        name();
        if (eatWord('REQUEST')) {
          expect('=');
          expr();
        }
        break;
      }
      case 'OVERRIDE': {
        name();
        // key=value pairs, e.g. EXPOSURE_TIME=R[1]; format unverified
        while (!atEnd()) {
          if (!word()) break;
          i += word()!.length;
          expect('=');
          expr();
        }
        break;
      }
      default:
        warn(kwAt, kwAt + kw.length, 'unknown-vision-instruction', `Unrecognized VISION instruction '${kw}'; expected one of ${VISION_KEYWORDS.join(', ')} (unverified)`);
        i = s.length;
        return;
    }
    if (!atEnd()) warn(i, s.length, 'vision-syntax', 'Unexpected text after VISION instruction (unverified syntax)');
    i = s.length;
  };

  /** LHS = RHS where the statement starts with a register or system variable. */
  const assignment = () => {
    ws();
    const start = i;
    let lhsName = '';
    if (s[i] === '$') sysvar();
    else {
      const r = ref();
      lhsName = r.name;
      if (INPUTS.has(r.name)) fail(r.start, r.end, 'not-assignable', `${r.name}[...] is read-only and cannot be assigned`);
      if (!OUTPUTS.has(r.name) && !['R', 'PR', 'SR', 'TIMER', 'UFRAME', 'UTOOL', 'RSR', 'LBL'].includes(r.name))
        fail(r.start, r.end, 'not-assignable', `${r.name}[...] cannot be assigned`);
      if (r.name === 'LBL') fail(start, r.end, 'bad-statement', 'LBL[n] cannot be assigned; use JMP LBL[n] or LBL[n:comment]');
    }
    ws();
    if (!eat('=')) {
      // a bare statement like TIMER[1] has no meaning; PAYLOAD/MESSAGE/UALM are handled before this
      return fail(i, i + 1, 'expected-token', `Expected '=' after ${s.slice(start, i).trim() || 'the target'}`);
    }
    ws();
    if (lhsName === 'TIMER') {
      const w = word()?.toUpperCase();
      if (w !== 'START' && w !== 'STOP' && w !== 'RESET') fail(i, i + 1, 'expected-token', 'TIMER[n] is set with START, STOP or RESET');
      i += w!.length;
      return endOfStatement();
    }
    if (OUTPUTS.has(lhsName) && eatWord('PULSE')) {
      if (eat(',')) {
        ws();
        const at = i;
        if (/^R\[/i.test(rest())) ref();
        else {
          const n = number();
          if (n === null) fail(at, at + 1, 'expected-operand', 'PULSE needs a width such as 0.5sec');
          const um = /^(msec|sec)/i.exec(rest());
          if (um) i += um[0].length;
          const w = Number(n) * (um && um[0].toLowerCase() === 'msec' ? 0.001 : 1);
          if (w < 0.1 || w > 25.5) warn(at, i, 'pulse-width', 'PULSE width should be 0.1..25.5 sec');
        }
      }
      rep.io = true;
      return endOfStatement();
    }
    const valueAt = i;
    expr();
    // OVERRIDE-style percent suffix is handled by the caller; allow a bare % here only for those targets
    if (OUTPUTS.has(lhsName)) rep.io = true;
    if (lhsName === 'PR' && s.slice(valueAt, i).trim() === '') fail(valueAt, valueAt + 1, 'expected-operand', 'Expected a value');
    endOfStatement();
  };

  const statement = (inline: boolean): StmtKind => {
    ws();
    if (i >= s.length) {
      rep.kind = 'empty';
      return 'empty';
    }
    const set = (k: StmtKind): StmtKind => {
      if (!inline) rep.kind = k;
      return k;
    };
    const c = s[i];
    if (c === '!') {
      i = s.length;
      return set('comment');
    }
    if (c === '=' && !inline) {
      // SELECT case: =value,action
      i++;
      expr();
      expect(',', "',' and an action after the case value");
      action();
      return set('case');
    }
    if (/^[JLCA][ \t]/.test(rest())) {
      rep.motionAt = i;
      i = s.length;
      return set('motion');
    }
    const w = word();
    if (!w) {
      if (c === '$') {
        assignment();
        return set('assign');
      }
      return fail(i, i + 1, 'unknown-instruction', `Unexpected '${c}' at start of statement`);
    }
    const up = w.toUpperCase();
    const next = s[i + w.length];

    // names followed by '[' are register-like
    if (next === '[') {
      if (up === 'LBL') {
        const r = ref();
        if (r.index === undefined) fail(r.start, r.end, 'bad-index', 'LBL needs a literal number: LBL[n] or LBL[n:comment]');
        if (r.index! < 1 || r.index! > 32766) fail(r.start, r.end, 'index-range', 'Label numbers are 1..32766');
        rep.labels.push({ n: r.index, start: r.start, end: r.end });
        endOfStatement();
        return set('label');
      }
      if (up === 'MESSAGE') {
        ref();
        endOfStatement();
        return set('other');
      }
      if (up === 'PAYLOAD' || up === 'UALM') {
        ref();
        endOfStatement();
        return set('other');
      }
      if (up !== 'UFRAME_NUM' && up !== 'UTOOL_NUM' && (up === 'RSR' || REF_NAMES.has(up))) {
        assignment();
        return set('assign');
      }
      if (up !== 'UFRAME_NUM' && up !== 'UTOOL_NUM') return fail(i, i + w.length, 'unknown-register', `Unknown register type '${w}'`);
    }

    const KW = (name: string) => up === name;
    if (KW('JMP')) {
      i += w.length;
      literalLabel();
      endOfStatement();
      return set('jmp');
    }
    if (KW('CALL') || KW('RUN')) {
      i += w.length;
      const sp = progName(up);
      if (sp.name) rep.calls.push({ ...sp, kind: up as 'CALL' | 'RUN' });
      if (up === 'CALL') callArgs();
      endOfStatement();
      return set(up === 'CALL' ? 'call' : 'run');
    }
    if (KW('IF')) {
      if (inline) fail(i, i + w.length, 'bad-inline-action', 'IF cannot be nested inside another IF action');
      i += w.length;
      expr();
      if (eatWord('THEN')) {
        endOfStatement();
        return set('if-block');
      }
      if (!eat(',')) {
        const eol = atEnd();
        return fail(i, i + 1, 'expected-then', eol ? "IF needs 'THEN' or ',<action>'" : "Expected 'THEN' or ',<action>' after the IF condition");
      }
      action();
      return set('if-inline');
    }
    if (KW('ELSE')) {
      i += w.length;
      if (eat(',')) {
        action();
        return set('select-else');
      }
      endOfStatement();
      return set('else');
    }
    if (KW('ENDIF') || KW('ENDFOR') || KW('PAUSE') || KW('ABORT') || KW('END')) {
      i += w.length;
      endOfStatement();
      return set(KW('ENDIF') ? 'endif' : KW('ENDFOR') ? 'endfor' : KW('PAUSE') ? 'pause' : KW('ABORT') ? 'abort' : 'end');
    }
    if (KW('FOR')) {
      i += w.length;
      ws();
      if (!/^R\[/i.test(rest())) fail(i, i + 1, 'expected-token', 'FOR needs a numeric register: FOR R[n]=start TO end');
      ref();
      expect('=');
      expr();
      if (!eatWord('TO') && !eatWord('DOWNTO')) fail(i, i + 1, 'expected-token', "FOR needs 'TO' or 'DOWNTO'");
      expr();
      endOfStatement();
      return set('for');
    }
    if (KW('SELECT')) {
      i += w.length;
      ws();
      if (!/^[A-Za-z]+\[/.test(rest()) && s[i] !== '$') fail(i, i + 1, 'expected-token', 'SELECT needs a register: SELECT R[n]=value,action');
      expr(); // consumes "R[n]=value"
      expect(',', "',' and an action");
      action();
      return set('select');
    }
    if (KW('WAIT')) {
      i += w.length;
      wait();
      return set('wait');
    }
    if (KW('VISION')) {
      i += w.length;
      vision();
      return set('vision');
    }
    if (KW('MONITOR')) {
      i += w.length;
      eatWord('END');
      progName('MONITOR');
      endOfStatement();
      return set('other');
    }
    if (KW('WHEN')) {
      i += w.length;
      expr();
      expect(',');
      action();
      return set('other');
    }
    if (KW('SKIP') || KW('OFFSET') || KW('TOOL_OFFSET')) {
      i += w.length;
      if (!eatWord('CONDITION')) fail(i, i + 1, 'expected-token', `Expected '${up} CONDITION'`);
      expr();
      endOfStatement();
      return set('other');
    }
    if (KW('COL')) {
      i += w.length;
      if (eatWord('DETECT')) {
        if (!eatWord('ON') && !eatWord('OFF')) fail(i, i + 1, 'expected-token', 'COL DETECT needs ON or OFF');
      } else if (eatWord('GUARD')) {
        if (!eatWord('ADJUST')) fail(i, i + 1, 'expected-token', 'Expected COL GUARD ADJUST');
        expr();
      } else fail(i, i + 1, 'expected-token', 'Expected COL DETECT or COL GUARD');
      endOfStatement();
      return set('other');
    }
    if (KW('LOCK') || KW('UNLOCK')) {
      i += w.length;
      if (!eatWord('PREG')) fail(i, i + 1, 'expected-token', `Expected '${up} PREG'`);
      endOfStatement();
      return set('other');
    }
    if (KW('ERROR_PROG') || KW('RESUME_PROG')) {
      i += w.length;
      expect('=');
      progName(up);
      endOfStatement();
      return set('other');
    }
    if (KW('OVERRIDE')) {
      i += w.length;
      expect('=');
      ws();
      const at = i;
      expr();
      if (s[i] === '%') {
        const lit = Number(s.slice(at, i));
        if (!Number.isNaN(lit) && (lit < 1 || lit > 100)) fail(at, i + 1, 'numeric-range', 'OVERRIDE must be 1..100%');
        i++;
      }
      endOfStatement();
      return set('assign');
    }
    if (KW('UFRAME_NUM') || KW('UTOOL_NUM')) {
      i += w.length;
      if (s[i] === '[') {
        const close = s.indexOf(']', i);
        if (close < 0) fail(i, s.length, 'unbalanced-bracket', "Missing ']'");
        if (!/^\[\s*GP\d+\s*\]$/i.test(s.slice(i, close + 1))) fail(i, close + 1, 'bad-index', `${up}[...] takes a motion group, e.g. [GP1]`);
        i = close + 1;
      }
      expect('=');
      ws();
      const at = i;
      expr();
      const lit = /^\d+$/.test(s.slice(at, i).trim()) ? Number(s.slice(at, i)) : undefined;
      const max = up === 'UFRAME_NUM' ? cfg.limits.uframe : cfg.limits.utool;
      if (lit !== undefined && lit > max) fail(at, i, 'numeric-range', `${up} must be 0..${max}`);
      endOfStatement();
      rep.frameSet = up === 'UFRAME_NUM' ? 'UFRAME' : 'UTOOL';
      return set('assign');
    }

    // Macro-style call: free-form words, optional (args). User macros are named by the shop, so the first
    // word is compared with the keyword list only to catch typos of real instructions.
    const line = rest().trimEnd();
    if (/^[A-Za-z_][A-Za-z0-9_.\- ]*(\(.*\))?$/.test(line) && !/[=<>]/.test(line.split('(')[0])) {
      const first = line.split(/[ (]/)[0];
      if (cfg.macros.some((m) => m.toLowerCase() === first.toLowerCase() || m.toLowerCase() === line.split('(')[0].trim().toLowerCase())) {
        i = s.length;
        return set('macro');
      }
      const close = first.length >= 3 ? KEYWORDS.find((k) => k !== first.toUpperCase() && lev(first.toUpperCase(), k) <= (first.length >= 8 ? 2 : 1)) : undefined;
      // shops name their own macros, so even a near-miss of a keyword is only a warning
      if (close) rep.notes.push(new StmtError(i, i + first.length, 'unknown-instruction', `Unknown instruction '${first}'. Did you mean ${close}? (If it is a macro, list it under "macros" in .lscheckrc.json)`, 'warning'));
      else rep.notes.push(new StmtError(i, i + first.length, 'unknown-instruction', `'${first}' is not a recognized instruction; if it is a macro, list it under "macros" in .lscheckrc.json`, 'hint'));
      i = s.length;
      return set('macro');
    }
    return fail(i, Math.min(s.length, i + w.length), 'unknown-instruction', `Unrecognized statement starting with '${w}'`);
  };

  try {
    statement(false);
  } catch (e) {
    if (e instanceof StmtError) rep.error = e;
    else throw e;
  }
  return rep;
}
