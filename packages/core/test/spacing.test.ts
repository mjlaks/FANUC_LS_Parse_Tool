import { test } from 'node:test';
import assert from 'node:assert/strict';
import { check, mergeConfig } from '../src';

const P1 = 'P[8]{\n   GP1:\n\tX = 1 mm\n};\n';
const file = (...mn: string[]) => `/PROG  T\n/ATTR\nOWNER = X;\n/MN\n${mn.join('\n')}\n/POS\n${P1}/END\n`;
const spacing = (...mn: string[]) => check(file(...mn), mergeConfig()).filter((d) => d.code === 'bad-spacing');
const errs = (...mn: string[]) => check(file(...mn), mergeConfig()).filter((d) => d.severity === 'error').map((d) => d.code);

// The controller's own formatting, as seen in the corpus
const GOOD = [
  '   1:  UFRAME_NUM=1 ;',
  '   2:  UTOOL_NUM=1 ;',
  '  38:L P[8] 25mm/sec CNT1    ;',
  '  39:J P[8] 50% FINE    ;',
  ' 100:  JMP LBL[1] ;',
  ' 101:  LBL[1:top] ;',
  ' 102:  DO[1:x]=ON ;',
  ' 103:  DO[2]=PULSE,1.0sec ;',
  ' 104:  R[1:count]=R[2]+1    ;',
  ' 105:  IF R[1]=1,JMP LBL[1] ;',
  ' 106:  IF (R[1]=1 AND !DI[2:a b]) THEN ;',
  ' 107:  ELSE ;',
  ' 108:  ENDIF ;',
  ' 109:  SELECT R[1]=1,JMP LBL[1] ;',
  ' 110:         =2,JMP LBL[1] ;',
  ' 111:         ELSE,JMP LBL[1] ;',
  ' 112:  WAIT    .50(sec) ;',
  ' 113:  WAIT   2.00(sec) ;',
  ' 114:  WAIT  20.00(sec) ;',
  ' 115:  WAIT DI[1]=ON OR DI[2]=OFF    ;',
  ' 116:  WAIT (!DI[1]) TIMEOUT,LBL[1] ;',
  ' 117:  CALL FOO(1,AR[2]) ;',
  ' 118:  CALL FOO    ;',
  '  46:  COL GUARD ADJUST     ;', // macro without arguments: 5 spaces seen on a real controller
  '  47:  Clear User Page    ;',
  ' 119:  MESSAGE[  Two  spaces  ok  here] ;',
  ' 120:  ! a  comment  with spaces ;',
  ' 121:  //DO[1]=OFF ;',
  ' 122:   ;',
  ' 123:  VISION CAMERA_CALIB \'CAM 2\' Request=1 ;',
  ' 124:J P[8] 50% CNT0 Tool_Offset,PR[3:a b]    ;',
  ' 125:L P[8] R[3:s p]mm/sec CNT R[4:c n]    ;',
];

test('spacing the controller writes is accepted', () => {
  const bad = check(file(...GOOD), mergeConfig()).filter((d) => d.code === 'bad-spacing').map((d) => `${d.line + 1}:${d.message}`);
  assert.deepEqual(bad, []);
});

test('the example from the project owner: odd spacing between line number and motion', () => {
  assert.equal(spacing('  38:   L P[8] 25mm/sec CNT1     ;').length, 2); // 3 spaces after colon, 5 before ';'
  assert.equal(spacing('  38:L P[8] 25mm/sec CNT1     ;').length, 1);
  assert.equal(spacing('  38:  L P[8] 25mm/sec CNT1    ;').length, 1);
});

test('bad spacing is an error, with a precise range', () => {
  const d = spacing('   1:  DO [1]=ON ;')[0];
  assert.equal(d.severity, 'error');
  assert.equal(d.line, 4);
  assert.equal(d.column, 9);
  assert.deepEqual(errs('   1:  DO [1]=ON ;'), ['bad-spacing']);
});

test('instruction spacing variants are flagged', () => {
  for (const bad of [
    '   1:  DO [1]=ON ;', '   1:  R [1]=5    ;', '   1:  R[ 1 ]=5    ;', '   1:  DO[1] = ON ;', '   1:  DO[1]= ON ;', '   1:  DO[1] =ON ;',
    '   1:  R[1]=R[2] + 1    ;', '   1:  R[1]=R[2]+ 1    ;', '   1:  R[1]=5 ;'.replace('5 ;', '5  ;'), '   1:  JMP  LBL[1] ;', '   1:  JMP LBL [1] ;',
    '   1:  IF R[1]=1 , JMP LBL[1] ;', '   1:  IF R[1] = 1,JMP LBL[1] ;', '   1:  CALL FOO (1) ;', '   1:  CALL FOO(1, 2) ;', '   1:  DO[1]=PULSE, 1.0sec ;',
    '   1:  DO[1]=PULSE,1.0 sec ;', '   1:  WAIT .50(sec) ;', '   1:  WAIT  DI[1]=ON ;', '   1:\tJMP LBL[1] ;', '   1:  JMP LBL[1];', '   1:  JMP LBL[1]   ;',
    '   1:  UFRAME_NUM = 1 ;', '   1:  LBL [1] ;', '  1:  JMP LBL[1] ;', '   1 :  JMP LBL[1] ;', '1:  JMP LBL[1] ;',
    '  38:L P [8] 25mm/sec CNT1    ;', '  38:L P[ 8 ] 25mm/sec CNT1    ;', '  38:L  P[8] 25mm/sec CNT1    ;', '  38:L P[8]  25mm/sec CNT1    ;', '  38:L P[8] 25mm/sec CNT 1    ;',
    '  38:L P[8] 25 mm/sec CNT1    ;', '  38:L P[8] 25mm/sec CNT1 ACC 80    ;'.replace('ACC 80', 'ACC  80'), '  38:L P[8] 25mm/sec CNT1 Offset, PR[1]    ;',
  ]) {
    assert.ok(check(file(bad), mergeConfig()).some((d) => d.code === 'bad-spacing' || d.code === 'speed-spacing'), bad);
  }
});

test('bad-spacing can be downgraded or turned off in config', () => {
  const src = file('   1:  DO [1]=ON ;');
  assert.equal(check(src, mergeConfig({ rules: { 'bad-spacing': 'warning' } })).find((d) => d.code === 'bad-spacing')!.severity, 'warning');
  assert.equal(check(src, mergeConfig({ rules: { 'bad-spacing': 'off' } })).some((d) => d.code === 'bad-spacing'), false);
});

test('spacing errors on the line being edited are suppressed', () => {
  const src = file('   1:  DO [1]=ON ;');
  assert.equal(check(src, mergeConfig(), { cursorLine: 4 }).some((d) => d.code === 'bad-spacing'), false);
  assert.equal(check(src, mergeConfig(), { cursorLine: 0 }).some((d) => d.code === 'bad-spacing'), true);
});

test('WAIT and register assignments end with 4 spaces', () => {
  const bad = (s: string) => spacing(s).length;
  assert.equal(bad(' 104:  R[1]=R[2]+1    ;'), 0);
  assert.equal(bad(' 104:  PR[1]=P[1]    ;'), 0);
  assert.equal(bad(' 104:  SR[1]=SR[2]    ;'), 0);
  assert.equal(bad(' 104:  R[1]=(-3)    ;'), 0);
  assert.equal(bad(' 104:  R[1]=((R[2]-1)*R[3]) ;'), 0); // parenthesised arithmetic is padded 1 in the corpus
  assert.equal(bad(' 104:  R[1]=((R[2]-1)*R[3])    ;'), 1);
  assert.equal(bad(' 104:  R[1]=$MNUTOOLNUM[1] ;'), 0); // system variable reads are padded 1 in the corpus
  assert.equal(bad(' 104:  R[1]=R[2]+1 ;'), 1);
  assert.equal(bad(' 104:  R[1]=R[2]+1  ;'), 1);
  assert.equal(bad(' 104:  R[1]=5     ;'), 1);
  assert.equal(bad(' 104:  PR[1]=P[1] ;'), 1);
  assert.equal(bad(' 104:  WAIT DI[1]=ON    ;'), 0);
  assert.equal(bad(' 104:  WAIT DI[1]=ON ;'), 1);
  assert.equal(bad(' 104:  WAIT DI[1]=ON TIMEOUT,LBL[1] ;'), 0);
  assert.equal(bad(' 104:  WAIT DI[1]=ON TIMEOUT,LBL[1]    ;'), 1);
  assert.equal(bad(' 104:  WAIT    .50(sec) ;'), 0);
  assert.equal(bad(' 104:  WAIT    .50(sec)    ;'), 1);
});

test('macro-style lines: 1 space with arguments, 4 without', () => {
  assert.equal(spacing(' 104:  Program Status(5) ;').length, 0);
  assert.equal(spacing(' 104:  Program Status(5)    ;').length, 1);
  assert.equal(spacing(' 104:  Clear User Page    ;').length, 0);
  assert.equal(spacing(' 104:  Clear User Page ;').length, 1);
});

test('after the colon: motion 0 spaces, other instructions 2', () => {
  assert.equal(spacing('  38:L P[6] 25mm/sec CNT1    ;').length, 0);
  assert.equal(spacing('  38:  LBL[999] ;').length, 0);
  assert.equal(spacing('  38: L P[6] 25mm/sec CNT1    ;').length, 1);
  assert.equal(spacing('  38:  L P[6] 25mm/sec CNT1    ;').length, 1);
  assert.equal(spacing('  38:LBL[999] ;').length, 1);
  assert.equal(spacing('  38: LBL[999] ;').length, 1);
  assert.equal(spacing('  38:   LBL[999] ;').length, 1);
});

test('a gap inside a numeric index is an error', () => {
  assert.ok(errs('  38:L P[1 020] 25mm/sec CNT1    ;').includes('bad-index'));
});
