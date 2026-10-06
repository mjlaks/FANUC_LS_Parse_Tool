import { InstrReport, parseInstr, StmtKind } from './instr';
import { parseMotion, StmtError } from './motion';
import { allowedPad, intraSpacing, spacesAfterColon } from './spacing';
import { CheckOptions, defaultConfig, Diagnostic, LsConfig, Severity, WorkspaceIndex } from './types';

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

export function parseLs(source: string, config: LsConfig = defaultConfig, workspace?: WorkspaceIndex): ParseResult {
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
  interface At { line: number; col: number; end: number }
  const labelDefs: Array<At & { n: number }> = [];
  const jumpRefs: Array<At & { n: number }> = [];
  const callRefs: Array<At & { name: string; kind: 'CALL' | 'RUN' }> = [];
  const blocks: Array<At & { kind: 'IF' | 'FOR'; seenElse: boolean }> = [];
  const vrPopulated = new Set<number>();
  let selectOpen = false;
  let sawCall = false;
  let pendingBlend = false;
  let uframeSet = false;
  let utoolSet = false;
  let firstMotionChecked = false;
  let lastMnLine = 0;
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
    if (section === 'MN') {
      flushStmt();
      for (const b of blocks) {
        add('error', 'unbalanced-block', b.line, b.col, b.end, b.kind === 'IF' ? 'IF ... THEN has no matching ENDIF' : 'FOR has no matching ENDFOR', true, [b.line, lastMnLine]);
      }
      blocks.length = 0;
    }
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
    const span: [number, number] = [segs[0].line, segs[segs.length - 1].line];
    const trimmedAll = text.trimEnd().length;

    // Whitespace rules (see spacing.ts): prefix after "N:", padding before ';', and gaps inside the statement
    const spacingCheck = (kind: StmtKind, disabled: boolean, hasError: boolean) => {
      const flag = (line: number, col: number, end: number, msg: string) => add('error', 'bad-spacing', line, col, Math.max(end, col + 1), msg, true, span);
      const first = segs[0];
      const raw = lines[first.line];
      const pm = /^( *)(\d+)( *):( *)/.exec(raw);
      if (pm && !hasError) {
        const numEnd = pm[1].length + pm[2].length;
        if (pm[3]) flag(first.line, numEnd, numEnd + pm[3].length, "Remove the space before ':' in the line number");
        else if (pm[2].length < 4 && numEnd !== 4) flag(first.line, 0, numEnd, 'Line numbers are right-aligned in 4 columns (e.g. "  38:")');
        const want = kind === 'empty' ? 3 : spacesAfterColon(kind, disabled);
        const colon = numEnd + pm[3].length + 1;
        if (want !== null && (terminated || kind !== 'empty') && pm[4].length !== want) {
          const hasBody = raw.slice(colon).trim() !== '';
          if (hasBody || terminated) flag(first.line, colon, colon + pm[4].length, `Expected ${want} space${want === 1 ? '' : 's'} between the line number and the ${kind === 'motion' ? 'motion' : 'instruction'} (the controller writes "${' '.repeat(Math.max(0, 4 - numEnd))}${pm[2]}:${' '.repeat(want)}…")`);
        }
      }
      if (!disabled && kind !== 'empty') for (const x of intraSpacing(text, kind)) {
        const r = range(x.start, x.end);
        flag(r.line, r.col, r.end, x.message);
      }
      if (terminated && segs.length === 1 && !hasError) {
        const pad = /([ \t]*);\s*$/.exec(raw);
        const allowed = disabled ? [1, 4] : allowedPad(kind, text);
        if (pad && allowed && !allowed.includes(pad[1].length)) {
          const at = raw.length - raw.replace(/\s+$/, '').length;
          const col = raw.replace(/\s+$/, '').length - 1 - pad[1].length;
          void at;
          flag(first.line, col + 1, col + 1 + Math.max(1, pad[1].length), `Expected ${allowed.join(' or ')} space${allowed.length === 1 && allowed[0] === 1 ? '' : 's'} before ';' for this instruction`);
        }
      }
    };

    const body = text.trim();
    if (!body) {
      spacingCheck('empty', false, false);
      return;
    }
    if (body.startsWith('//')) {
      spacingCheck('other', true, false);
      // Disabled line: not checked, but its P[n] references still count as uses
      for (const m of text.matchAll(/(?<![A-Za-z])P\[(\d+)/g)) {
        const r = range(m.index!, m.index! + m[0].length);
        usedP.push({ n: Number(m[1]), line: r.line, col: r.col, end: r.end });
      }
      return;
    }

    const stmtStart = range(text.indexOf(body[0]), text.indexOf(body[0]) + 1);
    let kind: StmtKind = 'other';
    let io = false;
    let blend = false;
    let isMotion = false;
    let frameSet: 'UFRAME' | 'UTOOL' | undefined;
    let calledBefore = sawCall;

    // Merge a sub-report found at `base` (offset of its text inside the statement).
    const absorb = (r: { notes: StmtError[]; error?: StmtError }, base: number, limit: number) => {
      for (const n of r.notes) {
        const x = range(n.start + base, n.end + base);
        add(n.severity, n.code, x.line, x.col, x.end, n.message);
      }
      if (r.error) {
        const x = range(r.error.start + base, r.error.end + base);
        // a problem at the very end of the text is a statement still being typed
        const incomplete = r.error.code === 'circular-incomplete' || r.error.start + base >= limit || r.error.code === 'expected-then';
        add(r.error.severity, r.error.code, x.line, x.col, x.end, r.error.message, incomplete, span);
      }
    };
    const refs = (r: InstrReport, base: number) => {
      for (const [n, a, b] of r.posRefs) {
        const x = range(a + base, b + base);
        usedP.push({ n, line: x.line, col: x.col, end: x.end });
      }
      for (const l of r.labels) {
        const x = range(l.start + base, l.end + base);
        labelDefs.push({ n: l.n!, line: x.line, col: x.col, end: x.end });
      }
      for (const j of r.jumps) {
        const x = range(j.start + base, j.end + base);
        jumpRefs.push({ n: j.n!, line: x.line, col: x.col, end: x.end });
      }
      for (const c of r.calls) {
        const x = range(c.start + base, c.end + base);
        callRefs.push({ name: c.name!, kind: c.kind, line: x.line, col: x.col, end: x.end });
        sawCall = true;
      }
      for (const v of r.vrSets) vrPopulated.add(v.n!);
    };

    const rep = parseInstr(text, config);
    kind = rep.kind;
    io = !!rep.io;
    frameSet = rep.frameSet;
    refs(rep, 0);
    const motionFrom = rep.motionAt;
    // Report instruction errors only when no motion is involved; otherwise errors before the motion still count
    absorb(rep, 0, trimmedAll);

    if (motionFrom !== undefined) {
      isMotion = true;
      const mrep = parseMotion(text.slice(motionFrom), config);
      const base = motionFrom;
      const mlimit = trimmedAll - motionFrom;
      for (const n of mrep.notes) {
        const r = range(n.start + base, n.end + base);
        add(n.severity, n.code, r.line, r.col, r.end, n.message);
      }
      for (const [n, a, b] of mrep.positions) {
        const r = range(a + base, b + base);
        usedP.push({ n, line: r.line, col: r.col, end: r.end });
      }
      for (const [n, a, b] of mrep.jumps) {
        const r = range(a + base, b + base);
        jumpRefs.push({ n, line: r.line, col: r.col, end: r.end });
      }
      for (const [n, a, b] of mrep.vrUses) {
        if (!vrPopulated.has(n)) {
          const r = range(a + base, b + base);
          add('warning', 'vr-not-populated', r.line, r.col, r.end, `VR[${n}] is used by VOFFSET but no VISION GET_OFFSET earlier in this program fills it (a CALLed program may; disable vr-not-populated if so)`);
        }
      }
      for (const [a, b] of mrep.actions) {
        const act = parseInstr(text.slice(base + a, base + b), config);
        refs(act, base + a);
        absorb(act, base + a, trimmedAll);
        if (act.motionAt !== undefined || (act.kind !== 'macro' && act.kind !== 'call' && act.kind !== 'assign' && act.kind !== 'jmp' && act.kind !== 'other' && !act.error))
          add('warning', 'bad-trigger-action', ...(() => { const r = range(base + a, base + b); return [r.line, r.col, r.end] as [number, number, number]; })(), 'TB/TA/DB action should be an I/O or register assignment, CALL or JMP');
      }
      if (mrep.error) {
        const r = range(mrep.error.start + base, mrep.error.end + base);
        const incomplete = mrep.error.code === 'circular-incomplete' || mrep.error.start >= mlimit;
        add(mrep.error.severity, mrep.error.code, r.line, r.col, r.end, mrep.error.message, incomplete, span);
      }
      blend = mrep.blend && !mrep.error;
      kind = 'motion';
    }

    // ---- state tracking: blocks, style lints ----------------------------------------------------
    const bad = (code: string, msg: string, incomplete = false) => {
      const lineEnd = lines[stmtStart.line].trimEnd().length;
      const word = /^[A-Za-z]+/.exec(body)?.[0].length ?? 1;
      add('error', code, stmtStart.line, stmtStart.col, Math.min(lineEnd, stmtStart.col + word), msg, incomplete, span);
    };
    // A block opener with a parse error is still pushed, so only the root cause is reported
    if (rep.error && /^IF\b/i.test(body) && /\bTHEN\s*$/i.test(body)) kind = 'if-block';
    else if (rep.error && /^FOR\b/i.test(body)) kind = 'for';
    if (!rep.error || kind === 'if-block' || kind === 'for') {
      if (kind !== 'case' && kind !== 'select-else' && kind !== 'comment' && kind !== 'empty' && kind !== 'label' && kind !== 'select') selectOpen = false;
      switch (kind) {
        case 'if-block':
          blocks.push({ kind: 'IF', line: stmtStart.line, col: stmtStart.col, end: stmtStart.end, seenElse: false });
          break;
        case 'for':
          blocks.push({ kind: 'FOR', line: stmtStart.line, col: stmtStart.col, end: stmtStart.end, seenElse: false });
          break;
        case 'else': {
          const top = blocks[blocks.length - 1];
          if (!top || top.kind !== 'IF') bad('unbalanced-block', top ? `ELSE inside ${top.kind} without a matching IF` : 'ELSE without a matching IF ... THEN');
          else if (top.seenElse) bad('unbalanced-block', 'IF block already has an ELSE');
          else top.seenElse = true;
          break;
        }
        case 'endif': {
          const top = blocks[blocks.length - 1];
          if (!top || top.kind !== 'IF') bad('unbalanced-block', top ? `ENDIF found while a ${top.kind} block is open (missing ENDFOR?)` : 'ENDIF without a matching IF ... THEN');
          blocks.pop();
          break;
        }
        case 'endfor': {
          const top = blocks[blocks.length - 1];
          if (!top || top.kind !== 'FOR') bad('unbalanced-block', top ? `ENDFOR found while an ${top.kind} block is open (missing ENDIF?)` : 'ENDFOR without a matching FOR');
          blocks.pop();
          break;
        }
        case 'select':
          selectOpen = true;
          break;
        case 'case':
        case 'select-else':
          if (!selectOpen) bad('unbalanced-block', kind === 'case' ? 'Case line (=value,action) without a preceding SELECT' : "'ELSE,<action>' without a preceding SELECT");
          break;
        case 'end':
          selectOpen = false;
          break;
        default:
          break;
      }
    }
    spacingCheck(kind, false, !!rep.error);
    if (kind === 'comment' || kind === 'empty') return;
    if (kind === 'label') return;

    // I/O right after a CNT/CR move runs before the robot reaches the point
    if (pendingBlend && io && !isMotion) {
      add('warning', 'io-after-cnt', stmtStart.line, stmtStart.col, stmtStart.end, 'I/O instruction directly after a CNT/CR move runs before the robot reaches the point; use FINE, a TB/TA option, or WAIT');
    }
    pendingBlend = blend;
    if (frameSet === 'UFRAME') uframeSet = true;
    if (frameSet === 'UTOOL') utoolSet = true;
    if (isMotion && !firstMotionChecked) {
      firstMotionChecked = true;
      if (!(uframeSet && utoolSet) && !calledBefore) {
        const missing = [uframeSet ? '' : 'UFRAME_NUM', utoolSet ? '' : 'UTOOL_NUM'].filter(Boolean).join(' and ');
        add('warning', 'motion-before-frame', stmtStart.line, stmtStart.col, stmtStart.end, `First motion runs before ${missing} is set in this program`);
      }
    }
  }

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
        lastMnLine = ln;
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

  // Labels: unique, and every literal JMP/Skip/TIMEOUT target defined
  const defined = new Map<number, At>();
  for (const l of labelDefs) {
    const prev = defined.get(l.n);
    if (prev) add('error', 'duplicate-label', l.line, l.col, l.end, `LBL[${l.n}] is already defined on line ${prev.line + 1}`);
    else defined.set(l.n, l);
  }
  const jumped = new Set<number>();
  for (const j of jumpRefs) {
    jumped.add(j.n);
    if (!defined.has(j.n)) add('error', 'undefined-label', j.line, j.col, j.end, `LBL[${j.n}] is jumped to but never defined`);
  }
  for (const l of labelDefs) if (!jumped.has(l.n)) add('hint', 'unused-label', l.line, l.col, l.end, `LBL[${l.n}] is never jumped to`);

  // CALL/RUN targets, only when a workspace index is available
  if (workspace?.truncated) {
    add('warning', 'workspace-truncated', 0, 0, 1, 'The workspace folder is too large to scan completely; CALL/RUN targets are not checked. Put .lscheckrc.json in a smaller folder.');
  } else if (workspace) {
    const self = result.programName?.toUpperCase();
    const external = new Set(config.externalPrograms.map((n) => n.toUpperCase()));
    for (const c of callRefs) {
      if (c.name === self || workspace.programs.has(c.name) || external.has(c.name)) continue;
      add('warning', 'unknown-program', c.line, c.col, c.end, `${c.kind} target ${c.name} was not found in the workspace; add it to "externalPrograms" if it lives only on the controller`);
    }
  }
  result.definedPositions = [...posLines.keys()];
  return result;
}

export function check(source: string, config: LsConfig = defaultConfig, opts: CheckOptions = {}): Diagnostic[] {
  const out: Diagnostic[] = [];
  for (const d of parseLs(source, config, opts.workspace).diagnostics) {
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
