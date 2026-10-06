import { test } from 'node:test';
import assert from 'node:assert/strict';
import { check, mergeConfig } from '../src';

const wrap = (mn: string, pos = '') => `/PROG  T
/ATTR
OWNER = MNEDITOR;
/MN
${mn}
/POS
${pos}/END
`;
const P = (n: number) => `P[${n}]{\n   GP1:\n\tX = 1 mm\n};\n`;
const codes = (src: string, opts = {}) => check(src, mergeConfig({ rules: { 'motion-before-frame': 'off' } }), opts).filter((d) => d.severity !== 'hint').map((d) => d.code);
const errs = (src: string) => check(src).filter((d) => d.severity === 'error').map((d) => d.code);

test('valid motion lines produce no errors', () => {
  const src = wrap(
    `   1:J P[1] 100% FINE    ;
   2:L P[1] 500mm/sec CNT50 VOFFSET,VR[1] Tool_Offset,PR[3:x] ACC80 Wjnt    ;
   3:J PR[1:Home] 50% CNT0 Skip,LBL[1]    ;
   4:C P[1] 100mm/sec CNT20
    :  P[1] 100mm/sec FINE    ;
   5:L P[1] R[3:spd]mm/sec CR10    ;
   6:LBL[1] ;`,
    P(1),
  );
  assert.deepEqual(errs(src), []);
});

test('speed unit must match motion type', () => {
  assert.deepEqual(errs(wrap('   1:J P[1] 100mm/sec FINE ;', P(1))), ['speed-unit-invalid']);
  assert.deepEqual(errs(wrap('   1:L P[1] 100% FINE ;', P(1))), ['speed-unit-invalid']);
});

test('termination and ranges', () => {
  assert.deepEqual(errs(wrap('   1:J P[1] 100% CNT101 ;', P(1))), ['cnt-range']);
  assert.deepEqual(errs(wrap('   1:J P[1] 100% ;', P(1))), ['expected-termination']);
  assert.deepEqual(errs(wrap('   1:J P[1] 101% FINE ;', P(1))), ['speed-range']);
});

test('position source and circular completeness', () => {
  assert.deepEqual(errs(wrap('   1:J X[1] 100% FINE ;', P(1))), ['expected-position']);
  assert.deepEqual(errs(wrap('   1:C P[1] 100mm/sec FINE ;', P(1))), ['circular-incomplete']);
});

test('P[n] cross reference with /POS', () => {
  assert.deepEqual(errs(wrap('   1:J P[9] 100% FINE ;', P(1))), ['undefined-position']);
  assert.ok(codes(wrap('   1:J P[1] 100% FINE ;', P(1) + P(2))).includes('unused-position'));
});

test('missing semicolon is reported per line and recovery continues', () => {
  const r = errs(wrap('   1:J P[1] 100% FINE\n   2:L P[1] 100% FINE ;', P(1)));
  assert.deepEqual(r, ['missing-semicolon', 'speed-unit-invalid']);
});

test('cursor line is lenient for incomplete statements', () => {
  const src = wrap('   1:J P[1] 100% FINE', P(1));
  assert.ok(codes(src).includes('missing-semicolon'));
  const line = src.split('\n').findIndex((l) => l.startsWith('   1:'));
  assert.ok(!codes(src, { cursorLine: line }).includes('missing-semicolon'));
});

test('line numbering is a hint only', () => {
  const d = check(wrap('   5:J P[1] 100% FINE ;\n   9:J P[1] 100% FINE ;', P(1)));
  assert.ok(d.some((x) => x.code === 'line-number' && x.severity === 'hint'));
  assert.equal(d.filter((x) => x.severity === 'error').length, 0);
});

test('structure: section order and missing sections', () => {
  const bad = `/PROG  T\n/MN\n   1:  ;\n/ATTR\nOWNER = X;\n/POS\n/END\n`;
  assert.ok(errs(bad).includes('section-order'));
  assert.ok(errs('/PROG  T\n/ATTR\nOWNER = X;\n').includes('missing-section'));
});

test('rules can be turned off or re-levelled', () => {
  const src = wrap('   1:J P[1] 100% FINE ;', P(1) + P(2));
  const off = check(src, mergeConfig({ rules: { 'unused-position': 'off' } }));
  assert.ok(!off.some((d) => d.code === 'unused-position'));
  const hard = check(src, mergeConfig({ rules: { 'unused-position': 'error' } }));
  assert.ok(hard.some((d) => d.code === 'unused-position' && d.severity === 'error'));
});

test('generic statements: NOT operator and bracket balance', () => {
  assert.deepEqual(errs(wrap('   1:  IF (!DI[1:x]),JMP LBL[5] ;\n   2:  LBL[5] ;')), []);
  assert.deepEqual(errs(wrap('   1:  R[1=2 ;')), ['unbalanced-bracket']);
});

const full = (attr: string, mn = '   1:  ;', pos = '') => `/PROG  T\n/ATTR\n${attr}\n/MN\n${mn}\n/POS\n${pos}/END\n`;

test('/ATTR: missing ; is reported on its own line, not swallowed', () => {
  const d = check(full('OWNER = X\nCOMMENT = "c";\nPROTECT = READ_WRITE;'));
  const semi = d.filter((x) => x.code === 'missing-semicolon');
  assert.equal(semi.length, 1);
  assert.equal(semi[0].line, 2);
});

test('unterminated statement is still validated and its P[n] counted', () => {
  const src = wrap('   1:J P[1] 100mm/sec FINE', P(1));
  const c = codes(src);
  assert.ok(c.includes('missing-semicolon') && c.includes('speed-unit-invalid'));
  assert.ok(!c.includes('unused-position'));
});

test('/POS: malformed header recovers without cascading errors', () => {
  const trailing = wrap('   1:J P[1] 100% FINE ;', 'P[1]{ junk\n   GP1:\n\tX = 1 mm\n};\n');
  assert.deepEqual(errs(trailing), ['bad-position-def']);
  const quoted = wrap('   1:J P[1] 100% FINE ;', 'P[1:"a]b"]{\n   GP1:\n\tX = 1 mm\n};\n');
  assert.deepEqual(errs(quoted), []);
  const garbage = wrap('   1:J P[1] 100% FINE ;', 'oops\n  more\n' + P(1));
  assert.deepEqual(errs(garbage), ['bad-position-def']);
});

test('quoted ] inside a position comment is not a bracket close', () => {
  assert.deepEqual(errs(wrap('   1:J P[1:"a]b"] 100% FINE ;', P(1))), []);
});

test('cursor anywhere inside an incomplete span suppresses it', () => {
  const src = wrap('   1:J P[1] 100% FINE ;', 'P[1]{\n   GP1:\n\tX = 1 mm');
  const lines = src.split('\n');
  const hdr = lines.findIndex((l) => l.startsWith('P[1]'));
  assert.ok(codes(src).includes('unterminated-position'));
  assert.ok(!codes(src, { cursorLine: hdr + 2 }).includes('unterminated-position'));
  const half = wrap('   1:J P[1] 100%', P(1));
  const ln = half.split('\n').findIndex((l) => l.startsWith('   1:'));
  assert.ok(codes(half).includes('missing-semicolon'));
  assert.deepEqual(codes(half, { cursorLine: ln }).filter((c) => c !== 'missing-attr' && c !== 'motion-before-frame'), []);
});

test('inline IF with a motion is validated', () => {
  assert.deepEqual(errs(wrap('   1:  IF R[1]=1,L P[1] 100% FINE ;', P(1))), ['speed-unit-invalid']);
  assert.deepEqual(errs(wrap('   1:  IF R[1]=1,L P[1] 100mm/sec FINE ;', P(1))), []);
  assert.deepEqual(errs(wrap('   1:  IF R[1]=1,CALL FOO ;', P(1))), []);
});

test('termination must be whole number with word boundary', () => {
  assert.deepEqual(errs(wrap('   1:J P[1] 100% CNT50.5 ;', P(1))), ['cnt-range']);
  assert.deepEqual(errs(wrap('   1:J P[1] 100% FINEX ;', P(1))), ['expected-termination']);
  assert.deepEqual(errs(wrap('   1:J P[1] 100% CNT5x ;', P(1))), ['cnt-range']);
});

test('space between speed value and unit warns', () => {
  const d = check(wrap('   1:L P[1] 50 mm/sec FINE ;', P(1))).filter((x) => x.code === 'speed-spacing');
  assert.equal(d.length, 1);
  assert.equal(d[0].severity, 'warning');
});

test('UTF-8 BOM is ignored', () => {
  assert.deepEqual(errs('﻿' + wrap('   1:J P[1] 100% FINE ;', P(1))), []);
});
