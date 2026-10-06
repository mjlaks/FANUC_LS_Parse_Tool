import { defaultConfig, LsConfig } from './types';
import { parseLs } from './parser';

/** Text inserted at a 0-based line/character of the original document (no deletions are ever needed). */
export interface InsertEdit {
  line: number;
  character: number;
  newText: string;
}

export const DEFAULT_CONFIG_STRING = 'N U T, 0, 0, 0';

/** One /POS record exactly as the controller writes it (tabs, column widths and all); `eol` is the line ending. */
export function positionRecord(n: number, uf = 1, ut = 1, eol = '\n', config = DEFAULT_CONFIG_STRING): string {
  return [
    `P[${n}]{`,
    '   GP1:',
    `\tUF : ${uf}, UT : ${ut},\t\tCONFIG : '${config}',`,
    '\tX =     0.000  mm,\tY =     0.000  mm,\tZ =     0.000  mm,',
    '\tW =     0.000 deg,\tP =     0.000 deg,\tR =     0.000 deg',
    '};',
  ].join(eol) + eol;
}

/** Indices of P[n] used in /MN but not defined in /POS, in first-use order, as the checker sees them. */
export function undefinedPositions(source: string, config: LsConfig = defaultConfig): number[] {
  const seen = new Set<number>();
  for (const d of parseLs(source, config).diagnostics) {
    const m = d.code === 'undefined-position' ? /^P\[(\d+)\]/.exec(d.message) : null;
    if (m) seen.add(Number(m[1]));
  }
  return [...seen];
}

const sectionOf = (line: string) => /^\/([A-Za-z]+)/.exec(line)?.[1].toUpperCase();

/** UFRAME_NUM / UTOOL_NUM in effect where P[n] is first used (literal values only), else 1/1. */
function frameAtFirstUse(lines: string[], mnStart: number, mnEnd: number, n: number): { uf: number; ut: number } {
  let uf = 1;
  let ut = 1;
  const use = new RegExp(`(?<![A-Za-z_])P\\[\\s*${n}\\s*[:\\]]`);
  for (let l = mnStart; l < mnEnd; l++) {
    const body = lines[l].replace(/^\s*\d*:\s*/, '');
    if (body.startsWith('!') || body.startsWith('//')) continue;
    if (use.test(body)) break;
    const f = /^UFRAME_NUM\s*=\s*(\d+)\s*;/i.exec(body);
    const t = /^UTOOL_NUM\s*=\s*(\d+)\s*;/i.exec(body);
    if (f) uf = Number(f[1]);
    if (t) ut = Number(t[1]);
  }
  return { uf, ut };
}

/**
 * Edits that add an all-zero record for each index to /POS, keeping the records sorted by index. Creates the /POS
 * section (before /END, else at the end) when it is missing. Indices already defined are skipped.
 */
export function createPositionEdits(source: string, indices: number[]): InsertEdit[] {
  const eol = /\r\n/.test(source) ? '\r\n' : /\n/.test(source) ? '\n' : /\r/.test(source) ? '\r' : '\n';
  const lines = source.replace(/^﻿/, '').split(/\r\n|\n|\r/);
  let mnStart = -1;
  let mnEnd = lines.length;
  let posAt = -1;
  let endAt = -1;
  let posEnd = lines.length;
  lines.forEach((raw, l) => {
    const s = sectionOf(raw);
    if (!s) return;
    if (s === 'MN') mnStart = l + 1;
    if (mnStart >= 0 && mnEnd === lines.length && s !== 'MN') mnEnd = l;
    if (s === 'POS' && posAt < 0) posAt = l;
    if (s === 'END' && endAt < 0) endAt = l;
    if (posAt >= 0 && l > posAt && posEnd === lines.length) posEnd = l;
  });
  const records: Array<{ n: number; line: number }> = [];
  if (posAt >= 0) {
    for (let l = posAt + 1; l < posEnd; l++) {
      const m = /^P\[(\d+)/.exec(lines[l]);
      if (m) records.push({ n: Number(m[1]), line: l });
    }
  }
  const defined = new Set(records.map((r) => r.n));
  const wanted = [...new Set(indices)].filter((n) => !defined.has(n)).sort((a, b) => a - b);
  if (!wanted.length) return [];

  const text = (n: number) => {
    const { uf, ut } = mnStart >= 0 ? frameAtFirstUse(lines, mnStart, mnEnd, n) : { uf: 1, ut: 1 };
    return positionRecord(n, uf, ut, eol);
  };
  // group by insertion line: before the first record with a higher index, else at the end of /POS
  const endLine = posAt >= 0 ? posEnd : endAt >= 0 ? endAt : lines.length;
  const byLine = new Map<number, string>();
  for (const n of wanted) {
    const next = records.find((r) => r.n > n);
    const at = next ? next.line : endLine;
    byLine.set(at, (byLine.get(at) ?? '') + text(n));
  }
  const edits: InsertEdit[] = [];
  for (const [at, body] of byLine) {
    if (posAt < 0) {
      // no /POS yet: add the whole section
      if (at < lines.length) edits.push({ line: at, character: 0, newText: `/POS${eol}${body}` });
      else {
        const lastLen = lines[lines.length - 1].length;
        edits.push({ line: lines.length - 1, character: lastLen, newText: `${lastLen ? eol : ''}/POS${eol}${body}` });
      }
    } else if (at < lines.length) edits.push({ line: at, character: 0, newText: body });
    else edits.push({ line: lines.length - 1, character: lines[lines.length - 1].length, newText: `${lines[lines.length - 1].length ? eol : ''}${body}` });
  }
  return edits.sort((a, b) => a.line - b.line);
}

/** Apply insert edits (positions refer to the original text); used by tests and the CLI-free callers. */
export function applyInsertEdits(source: string, edits: InsertEdit[]): string {
  const lineStarts = [0];
  for (let i = 0; i < source.length; i++) {
    if (source[i] === '\r' && source[i + 1] === '\n') i++;
    if (source[i] === '\n' || source[i] === '\r') lineStarts.push(i + 1);
  }
  let out = source;
  for (const e of [...edits].sort((a, b) => b.line - a.line || b.character - a.character)) {
    const off = lineStarts[e.line] + e.character;
    out = out.slice(0, off) + e.newText + out.slice(off);
  }
  return out;
}

/**
 * Edit that defines LBL[n] on its own line right after `line` (0-based), numbered one past that line. The number is
 * only a hint; the TP editor extension renumbers.
 */
export function createLabelEdit(source: string, line: number, n: number): InsertEdit {
  const eol = /\r\n/.test(source) ? '\r\n' : /\n/.test(source) ? '\n' : /\r/.test(source) ? '\r' : '\n';
  const text = source.replace(/^\uFEFF/, '').split(/\r\n|\n|\r/)[line] ?? '';
  const ln = /^\s*(\d+):/.exec(text);
  const prefix = ln ? `${String(Number(ln[1]) + 1).padStart(4, ' ')}:  ` : '  ';
  return { line, character: text.length, newText: `${eol}${prefix}LBL[${n}] ;` };
}
