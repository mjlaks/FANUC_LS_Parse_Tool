import { parseMotion, StmtError } from './motion';
import { CheckOptions, defaultConfig, Diagnostic, LsConfig, Severity } from './types';

const SECTION_ORDER = ['PROG', 'ATTR', 'APPL', 'MN', 'POS', 'END'];
const REQUIRED_ATTRS = [
  'OWNER', 'PROG_SIZE', 'CREATE', 'MODIFIED', 'FILE_NAME', 'VERSION', 'LINE_COUNT',
  'MEMORY_SIZE', 'PROTECT', 'TCD', 'DEFAULT_GROUP', 'CONTROL_CODE',
];

interface Seg { line: number; col: number; text: string }

export interface ParseResult {
  programName?: string;
  /** P[n] numbers defined in /POS */
  definedPositions: number[];
  diagnostics: Diagnostic[];
}

export function parseLs(source: string, config: LsConfig = defaultConfig): ParseResult {
  const lines = source.replace(/^\uFEFF/, '').split(/\r\n|\n|\r/);
  const diags: Diagnostic[] = [];
  const add = (sev: Severity, code: string, line: number, col: number, end: number, message: string, incomplete = false, span?: [number, number]) =>
    diags.push({ line, column: col, endColumn: Math.max(end, col + 1), severity: sev, code, message, incomplete: incomplete || undefined, span: incomplete ? span : undefined });

  let section = '';
  let lastRank = -1;
  const seen = new Set<string>();
  let result: ParseResult = { definedPositions: [], diagnostics: diags };
  let attrHeaderLine = 0;
  const attrKeys = new Set<string>();

  // /ATTR state
  let attrPending: Seg[] = [];
  // /MN state
  let stmt: Seg[] = [];
  let expectedNum = 1;
  const usedP: Array<{ n: number; line: number; col: number; end: number }> = [];
  const posLines = new Map<number, number>();
  // /POS state
  let posOpen: { n: number; line: number } | null = null;
  let sawEnd = false;
  let posSkip = false;
  let lastPosLine = 0;

  const segEnd = (s: Seg) => s.col + s.text.replace(/\s+$/, '').length;

  const flushAttr = () => {
    if (!attrPending.length) return;
    const last = attrPending[attrPending.length - 1];
    add('error', 'missing-semicolon', last.line, segEnd(last) - 1, segEnd(last), 'Statement is missing a closing ";"', true, [attrPending[0].line, last.line]);
    attrPending = [];
  };
  const flushStmt = () => {
    if (!stmt.length) return;
    const last = stmt[stmt.length - 1];
    add('error', 'missing-semicolon', last.line, segEnd(last), segEnd(last) + 1, 'Statement is missing a closing ";"', true, [stmt[0].line, last.line]);
    const open = stmt;
    stmt = [];
    analyzeStmt(open, false); // still validate what was typed
  };
  const closeSection = () => {
    if (section === 'ATTR') flushAttr();
    if (section === 'MN') flushStmt();
    if (section === 'POS' && posOpen) {
      add('error', 'unterminated-position', posOpen.line, 0, lines[posOpen.line].length, `P[${posOpen.n}] block is missing its closing "};"`, true, [posOpen.line, lastPosLine]);
      posOpen = null;
    }
  };

  function analyzeStmt(segs: Seg[], terminated = true): void {
    // join segments, strip the terminating ';' from the last one
    let text = '';
    const pieces: Array<{ off: number; seg: Seg; len: number }> = [];
    segs.forEach((seg, k) => {
      let t = seg.text;
      if (k === segs.length - 1) t = terminated ? t.replace(/\s+$/, '').slice(0, -1) : t.replace(/\s+$/, '');
      pieces.push({ off: text.length, seg, len: t.length });
      text += t + (k < segs.length - 1 ? '\n' : '');
    });
    const pos = (off: number) => {
      let p = pieces[0];
      for (const c of pieces) if (c.off <= off) p = c;
      return { line: p.seg.line, col: p.seg.col + Math.min(off - p.off, p.len), p };
    };
    const range = (a: number, b: number) => {
      const s = pos(a);
      const e = pos(b);
      return { line: s.line, col: s.col, end: e.line === s.line ? e.col : s.p.seg.col + s.p.len };
    };

    const body = text.trim();
    if (!body || body.startsWith('!')) return;

    let mStart = /^[JLCA][ \t]/.test(body) ? text.indexOf(body[0]) : -1;
    if (mStart < 0 && /^IF\b/i.test(body)) {
      // inline conditional: IF cond,<instruction> -- find the top-level comma
      let depth = 0;
      for (let k = 0; k < text.length; k++) {
        const c = text[k];
        if (c === '[' || c === '(') depth++;
        else if (c === ']' || c === ')') depth--;
        else if (c === ',' && depth === 0) {
          const m = /^\s*([JLCA])[ \t]/.exec(text.slice(k + 1));
          if (m) mStart = k + 1 + m[0].indexOf(m[1]);
          break;
        }
      }
    }
    if (mStart >= 0) {
      const rep = parseMotion(text.slice(mStart), config);
      const trimmedLen = text.slice(mStart).trimEnd().length;
      const base = mStart;
      for (const n of rep.notes) {
        const r = range(n.start + base, n.end + base);
        add(n.severity, n.code, r.line, r.col, r.end, n.message);
      }
      for (const [n, a, b] of rep.positions) {
        const r = range(a + base, b + base);
        usedP.push({ n, line: r.line, col: r.col, end: r.end });
      }
      if (rep.error) {
        const r = range(rep.error.start + base, rep.error.end + base);
        // a problem at the very end of the text is a statement still being typed
        const incomplete = rep.error.code === 'circular-incomplete' || rep.error.start >= trimmedLen;
        add(rep.error.severity, rep.error.code, r.line, r.col, r.end, rep.error.message, incomplete, [segs[0].line, segs[segs.length - 1].line]);
      }
      return;
    }

    // Generic statement: balanced brackets/quotes, and note any P[n] references.
    const stack: Array<[string, number]> = [];
    let quote = '';
    for (let k = 0; k < text.length; k++) {
      const c = text[k];
      if (quote) {
        if (c === quote) quote = '';
        continue;
      }
      if (c === '"' || c === "'") quote = c;
      else if (c === '[' || c === '(') stack.push([c, k]);
      else if (c === ']' || c === ')') {
        const top = stack.pop();
        if (!top || (top[0] === '[') !== (c === ']')) {
          const r = range(k, k + 1);
          add('error', 'unbalanced-bracket', r.line, r.col, r.end, `Unmatched '${c}'`, true);
          return;
        }
      }
    }
    if (quote || stack.length) {
      const k = quote ? text.length - 1 : stack[stack.length - 1][1];
      const r = range(k, k + 1);
      add('error', 'unbalanced-bracket', r.line, r.col, r.end, quote ? `Unterminated ${quote} string` : `Missing closing for '${stack[stack.length - 1][0]}'`, true);
      return;
    }
    for (const m of text.matchAll(/(?<![A-Za-z])P\[(\d+)/g)) {
      const r = range(m.index!, m.index! + m[0].length);
      usedP.push({ n: Number(m[1]), line: r.line, col: r.col, end: r.end });
    }
  };

  for (let ln = 0; ln < lines.length; ln++) {
    const raw = lines[ln];
    const sec = /^\/([A-Za-z]+)(.*)$/.exec(raw);
    if (sec) {
      closeSection();
      const name = sec![1].toUpperCase();
      const rank = SECTION_ORDER.indexOf(name);
      if (rank < 0) {
        add('warning', 'unknown-section', ln, 0, raw.trimEnd().length, `Unknown section /${name}`);
        section = 'UNKNOWN';
        continue;
      }
      if (rank < lastRank || (rank === lastRank && name !== 'APPL')) {
        add('error', 'section-order', ln, 0, raw.trimEnd().length, `/${name} is out of order (expected ${SECTION_ORDER.join(' → ')})`);
      }
      if (name !== 'APPL' && seen.has(name) && rank >= lastRank) { /* duplicate already reported above */ }
      lastRank = Math.max(lastRank, rank);
      seen.add(name);
      section = name;
      if (name === 'PROG') {
        const nm = /^\s*(\S+)/.exec(sec![2]);
        if (!nm) add('error', 'program-name', ln, 0, raw.length, '/PROG needs a program name');
        else {
          result.programName = nm[1];
          const col = raw.indexOf(nm[1]);
          if (!/^[A-Za-z_][A-Za-z0-9_]*$/.test(nm[1])) add('warning', 'program-name', ln, col, col + nm[1].length, 'Program names should be letters, digits and underscores, starting with a letter');
          if (nm[1].length > config.maxProgramNameLength) add('error', 'program-name', ln, col, col + nm[1].length, `Program name exceeds ${config.maxProgramNameLength} characters`);
        }
      } else if (name === 'ATTR') attrHeaderLine = ln;
      else if (name === 'END') sawEnd = true;
      continue;
    }
    if (!raw.trim()) continue;

    switch (section) {
      case 'ATTR': {
        if (attrPending.length && /^(TCD\s*:|[A-Z_]+\s*=)/.test(raw)) flushAttr(); // a new KEY = line starts
        const seg: Seg = { line: ln, col: 0, text: raw };
        attrPending.push(seg);
        if (raw.trimEnd().endsWith(';')) {
          const first = attrPending[0].text.trim();
          const km = /^(TCD)\s*:|^([A-Z_]+)\s*=/.exec(first);
          if (!km) add('warning', 'attr-syntax', attrPending[0].line, 0, first.length, 'Expected "KEY = value;" or "TCD: ..."');
          else {
            const key = km[1] ?? km[2];
            attrKeys.add(key);
            if (key === 'COMMENT') {
              const cm = /"(.*)"/.exec(first);
              if (cm && cm[1].length > 16) add('warning', 'comment-length', ln, raw.indexOf('"'), raw.length, `Program comment is ${cm[1].length} characters; the controller keeps 16`);
            }
          }
          attrPending = [];
        }
        break;
      }
      case 'MN': {
        const m = /^(\s*)(\d*)(\s*):/.exec(raw);
        if (m) {
          const body = raw.slice(m[0].length);
          const seg: Seg = { line: ln, col: m[0].length, text: body };
          if (m[2]) {
            flushStmt();
            const num = Number(m[2]);
            if (num !== expectedNum) add('hint', 'line-number', ln, m[1].length, m[1].length + m[2].length, `Line number ${num} (expected ${expectedNum})`);
            expectedNum = num + 1;
            stmt = [seg];
          } else if (stmt.length) stmt.push(seg);
          else {
            add('hint', 'line-number', ln, 0, m[0].length, 'Continuation line without a preceding statement');
            stmt = [seg];
          }
        } else {
          flushStmt();
          add('hint', 'line-number', ln, 0, raw.length, 'Missing line number');
          stmt = [{ line: ln, col: 0, text: raw }];
        }
        if (stmt[stmt.length - 1].text.trimEnd().endsWith(';')) {
          analyzeStmt(stmt);
          stmt = [];
        }
        break;
      }
      case 'POS': {
        if (posOpen) {
          lastPosLine = ln;
          if (/^\};\s*$/.test(raw)) {
            posOpen = null;
          } else if (/^P\[\d+/.test(raw)) {
            add('error', 'unterminated-position', posOpen.line, 0, lines[posOpen.line].length, `P[${posOpen.n}] block is missing its closing "};"`, true);
            posOpen = null;
            ln--; // re-read this line as a new header
          }
          break;
        }
        const hm = /^P\[(\d+)(?::(?:"[^"]*"|[^\]"])*)?\]\s*\{\s*$/.exec(raw);
        const loose = hm ?? /^P\[(\d+)/.exec(raw);
        if (!loose) {
          if (!posSkip) add('error', 'bad-position-def', ln, 0, raw.trimEnd().length, 'Expected a position definition: P[n]{ ... };');
          posSkip = true; // ignore the rest of this malformed block
          if (/^\};\s*$/.test(raw)) posSkip = false;
          break;
        }
        posSkip = false;
        if (!hm) add('error', 'bad-position-def', ln, 0, raw.trimEnd().length, 'Malformed position header; expected P[n]{ with nothing after the brace');
        const n = Number(loose[1]);
        if (posLines.has(n)) add('error', 'duplicate-position', ln, 0, raw.trimEnd().length, `P[${n}] is already defined on line ${posLines.get(n)! + 1}`);
        else posLines.set(n, ln);
        posOpen = { n, line: ln };
        lastPosLine = ln;
        break;
      }
      case 'END':
        add('warning', 'content-after-end', ln, 0, raw.trimEnd().length, 'Content after /END is ignored');
        break;
      default:
        break; // /PROG body, /APPL and unknown sections are not checked in M1
    }
  }
  closeSection();

  // Whole-file checks
  const eof = Math.max(0, lines.length - 1);
  for (const req of ['PROG', 'ATTR', 'MN', 'END']) {
    if (!seen.has(req)) add(req === 'ATTR' ? 'warning' : 'error', 'missing-section', 0, 0, 1, `Missing /${req} section`);
  }
  if (!seen.has('POS')) add('warning', 'missing-section', 0, 0, 1, 'Missing /POS section');
  if (seen.has('ATTR')) {
    const missing = REQUIRED_ATTRS.filter((k) => !attrKeys.has(k));
    if (missing.length) add('warning', 'missing-attr', attrHeaderLine, 0, 5, `/ATTR is missing: ${missing.join(', ')}`);
  }
  void eof;
  void sawEnd;

  // Cross references: /MN uses vs /POS definitions
  const used = new Set<number>();
  for (const u of usedP) {
    used.add(u.n);
    if (!posLines.has(u.n)) add('error', 'undefined-position', u.line, u.col, u.end, `P[${u.n}] is used but not defined in /POS`);
  }
  for (const [n, l] of posLines) {
    if (!used.has(n)) add('warning', 'unused-position', l, 0, lines[l].trimEnd().length, `P[${n}] is defined but never used`);
  }
  result.definedPositions = [...posLines.keys()];
  return result;
}

export function check(source: string, config: LsConfig = defaultConfig, opts: CheckOptions = {}): Diagnostic[] {
  const out: Diagnostic[] = [];
  for (const d of parseLs(source, config).diagnostics) {
    const rule = config.rules[d.code];
    if (rule === 'off') continue;
    const cur = opts.cursorLine;
    if (d.incomplete && cur !== undefined) {
      const [a, b] = d.span ?? [d.line, d.line];
      if (cur >= a && cur <= b) continue;
    }
    out.push(rule ? { ...d, severity: rule } : d);
  }
  return out.sort((a, b) => a.line - b.line || a.column - b.column);
}

export function formatDiagnostic(file: string, d: Diagnostic): string {
  return `${file}:${d.line + 1}:${d.column + 1}: ${d.severity} [${d.code}] ${d.message}`;
}
