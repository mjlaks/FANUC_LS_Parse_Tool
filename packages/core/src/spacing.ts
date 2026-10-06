import type { StmtKind } from './instr';

/**
 * Whitespace rules for /MN lines, taken from how the controller writes real programs (the corpus). Hand-typed
 * spacing that deviates from these is reported as `bad-spacing`; the project owner reports such lines fail on the
 * controller. The rules deliberately cover only patterns the corpus shows:
 *
 *  - line numbers are right-aligned in 4 columns, with no space before the colon
 *  - after the colon: motion 0 spaces, empty statement 3, SELECT cases and ELSE,<action> 9, everything else 2
 *  - before the closing ';': a fixed pad per kind of statement (motion 4, comment 1, JMP/IF/DO... 1, CALL 1 with
 *    arguments and 4 without, WAIT <condition> and register assignments 4, WAIT <time> and WAIT..TIMEOUT 1)
 *  - inside a statement: one space only between words/values (JMP LBL, J P[1] 50% CNT100, IF (...) THEN, AND/OR);
 *    never around = , + - * / < > or inside/before [ ], and WAIT time values are padded to a fixed width
 */

export interface SpaceIssue {
  start: number;
  end: number;
  message: string;
  /** Replacement for [start,end) that satisfies the rule */
  fix: string;
}

const WORD_BEFORE_PAREN = new Set(['IF', 'WAIT', 'AND', 'OR']);
const WORD_BEFORE_BANG = new Set(['IF', 'WAIT', 'AND', 'OR']);

/** Positions inside strings, bracket comments (after ':' in a register) and MESSAGE[...] text, where spacing is free. */
function freeText(text: string): boolean[] {
  const free = new Array<boolean>(text.length).fill(false);
  const stack: Array<{ comment: boolean }> = [];
  let quote = false;
  for (let i = 0; i < text.length; i++) {
    const c = text[i];
    if (quote) {
      if (c === "'") quote = false;
      else free[i] = true;
      continue;
    }
    if (c === "'") quote = true;
    else if (c === '[') {
      const msg = /(?:^|[^A-Za-z_])MESSAGE$/i.test(text.slice(0, i));
      stack.push({ comment: msg || (stack.length > 0 && stack[stack.length - 1].comment) });
    } else if (c === ']') stack.pop();
    else if (c === ':' && stack.length && !stack[stack.length - 1].comment && !/GP\d+$/i.test(text.slice(0, i))) stack[stack.length - 1].comment = true;
    else if (stack.length && stack[stack.length - 1].comment) free[i] = true;
    if (stack.length && stack[stack.length - 1].comment && c !== ']') free[i] = true;
  }
  return free;
}

/** Spacing problems inside one statement (text has no line-number prefix and no trailing ';'). */
export function intraSpacing(text: string, kind: StmtKind): SpaceIssue[] {
  const out: SpaceIssue[] = [];
  if (kind === 'comment') return out;
  const free = freeText(text);
  const body = text.trim();
  const waitTime = kind === 'wait' ? /^WAIT([ \t]+)(\d*\.?\d+)\(sec\)/i.exec(body) : null;
  const lead = text.length - text.trimStart().length;
  const end = text.trimEnd().length;
  let i = lead;
  while (i < end) {
    if (text[i] !== ' ' && text[i] !== '\t') {
      i++;
      continue;
    }
    let j = i;
    while (j < end && (text[j] === ' ' || text[j] === '\t')) j++;
    const run = text.slice(i, j);
    if (free[i] || free[j - 1] || text[i - 1] === '\n') {
      i = j;
      continue;
    }
    const L = text[i - 1];
    const R = text[j];
    const prevWord = /([A-Za-z_]+)$/.exec(text.slice(0, i))?.[1].toUpperCase() ?? '';
    if (waitTime && i === lead + 4) {
      const want = Math.max(1, 7 - waitTime[2].length);
      if (run !== ' '.repeat(want)) out.push({ start: i, end: j, message: `WAIT times are padded so the value is right-aligned: expected ${want} space(s) after WAIT`, fix: ' '.repeat(want) });
    } else if (run !== ' ') {
      out.push({ start: i, end: j, message: run.includes('\t') ? 'Tabs are not used inside statements; use a single space' : 'Use a single space here; the controller never writes extra spaces', fix: ' ' });
    } else if (!/[A-Za-z0-9_%\])'.]/.test(L) || !/[A-Za-z0-9_(!'$.]/.test(R)) {
      out.push({ start: i, end: j, message: `Unexpected space between '${L}' and '${R}'; the controller writes these together`, fix: '' });
    } else if (R === '(' && !WORD_BEFORE_PAREN.has(prevWord)) {
      out.push({ start: i, end: j, message: "Unexpected space before '('; the controller writes these together", fix: '' });
    } else if ((R === '!' || R === '$') && !WORD_BEFORE_BANG.has(prevWord)) {
      out.push({ start: i, end: j, message: `Unexpected space before '${R}'; the controller writes these together`, fix: '' });
    } else if (R === '.' && prevWord !== 'WAIT') {
      out.push({ start: i, end: j, message: "Unexpected space before '.'", fix: '' });
    }
    i = j;
  }
  // gaps that look like ordinary word breaks but are not valid here
  for (const m of text.matchAll(/(?<![A-Za-z_])(CNT|CR)([ \t]+)(\d)/gi)) {
    if (!free[m.index!]) out.push({ start: m.index! + m[1].length, end: m.index! + m[1].length + m[2].length, message: `Remove the space after ${m[1].toUpperCase()} (write ${m[1].toUpperCase()}50)`, fix: '' });
  }
  for (const m of text.matchAll(/(\d)([ \t]+)(msec|sec)\b(?!\))/gi)) {
    if (!free[m.index!]) out.push({ start: m.index! + 1, end: m.index! + 1 + m[2].length, message: `Remove the space before ${m[3]} (write 1.0${m[3]})`, fix: '' });
  }
  return out;
}

/** Number of spaces after "N:" the controller writes for a statement of this kind. */
export function spacesAfterColon(kind: StmtKind, disabled: boolean): number | null {
  if (disabled) return 2;
  switch (kind) {
    case 'motion': return 0;
    case 'case':
    case 'select-else': return 9;
    case 'if-inline': return null; // may carry a motion action; not shown by the corpus
    default: return 2;
  }
}

/** Allowed numbers of spaces before the closing ';'. null = not constrained. */
export function allowedPad(kind: StmtKind, text: string): number[] | null {
  const t = text.trim();
  switch (kind) {
    case 'motion': return [4];
    case 'comment': return [1];
    case 'empty': return null; // the 3 spaces are checked as the gap after the colon
    case 'jmp': case 'label': case 'if-block': case 'else': case 'endif': case 'select': case 'case': case 'select-else':
    case 'end': case 'pause': case 'abort': case 'vision':
      return [1];
    case 'call': return /\(/.test(t) ? [1] : [4];
    // WAIT <time>(sec) and WAIT ... TIMEOUT,LBL[n] end with 1 space; a plain WAIT <condition> ends with 4
    case 'wait': return /^WAIT\s+[\d.]+\(sec\)$/i.test(t) || /\bTIMEOUT\b/i.test(t) ? [1] : [4];
    case 'if-inline': return /,\s*[JLCA][ \t]/.test(t) ? [1, 4] : [1];
    case 'assign': {
      // register assignments end with 4 spaces, except the forms below (each exact, from the corpus)
      if (/^(R|PR|SR)\b/i.test(t) && t.includes('$')) return [1]; // R[n]=$SYSVAR is padded 1 in the corpus
      if (/^(R|PR|SR)\b/i.test(t)) {
        // parenthesised arithmetic, e.g. R[1]=((R[2]-1)*R[3]), is padded 1; a negative literal (-3) is not arithmetic
        const rhs = t.slice(t.indexOf('=') + 1).replace(/\(-\d+(\.\d+)?\)/g, '0');
        return /\(/.test(rhs) && /[-+*\/]/.test(rhs) ? [1] : [4];
      }
      return [1];
    }
    case 'macro': return /\(/.test(t) ? [1] : [4, 5]; // 1 with arguments; 4 without (corpus), 5 also seen on a real controller (`COL GUARD ADJUST     ;`, unverified why)
    default: return [1, 4]; // forms the corpus never shows: unverified
  }
}
