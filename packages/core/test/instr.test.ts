import { test } from 'node:test';
import assert from 'node:assert/strict';
import * as core from '../src';
const { mergeConfig } = core;
// Most tests use loosely formatted lines; spacing rules are exercised in spacing.test.ts
const check: typeof core.check = (src, cfg = mergeConfig(), opts) => core.check(src, { ...cfg, rules: { 'bad-spacing': 'off', ...cfg.rules } }, opts);


const wrap = (mn: string, pos = '') => `/PROG  T
/ATTR
OWNER = MNEDITOR;
/MN
${mn}
/POS
${pos}/END
`;
const P1 = `P[1]{\n   GP1:\n\tX = 1 mm\n};\n`;
const body = (...stmts: string[]) => wrap(stmts.map((s, i) => `${String(i + 1).padStart(4)}:  ${s} ;`).join('\n'), P1);
const codes = (src: string, sev: 'error' | 'warning' | 'hint' = 'error', cfg = mergeConfig(), opts = {}) =>
  check(src, cfg, opts).filter((d) => d.severity === sev && d.code !== 'missing-attr' && d.code !== 'unused-position').map((d) => d.code);
const errs = (...stmts: string[]) => codes(body(...stmts));

test('valid register, I/O and flow statements are clean', () => {
  assert.deepEqual(
    errs(
      'R[1:count]=R[2]+1', 'R[3]=(-3)', 'R[4]=.75', 'R[5]=R[6]*R[7] DIV 2', 'R[8]=TIMER[1]', 'R[9]=GI[2:x]', 'R[AR[1]]=1',
      'PR[1]=P[1]', 'PR[2,3:z]=PR[2,3]+25', 'PR[3]=JPOS', 'PR[4]=PR[5]+P[1]',
      'DO[1:x]=ON', 'DO[2]=(RO[3])', 'DO[3]=PULSE,1.0sec', 'DO[4]=PULSE', 'GO[1]=R[2]', 'RO[1]=OFF', 'SO[0]=ON', 'F[1]=(ON)', 'AO[1]=5',
      'TIMER[1]=START', 'TIMER[1]=RESET', 'SR[1]=SR[2]+\'abc\'', '$WAITTMOUT=3000', '$MCR.$GENOVERRIDE=R[21]', 'R[1]=$MNUTOOLNUM[1]',
      'UFRAME_NUM=1', 'UTOOL_NUM=R[3]', 'UTOOL_NUM[GP1]=2', 'OVERRIDE=10%', 'OVERRIDE=R[1]', 'PAYLOAD[2:grip]', 'UALM[5]', 'MESSAGE[hello world]',
      '! a comment', '//R[1]=1', 'PAUSE', 'ABORT',
    ),
    [],
  );
});

test('valid conditions and control flow are clean', () => {
  const src = body(
    'LBL[1:top]', 'IF R[1]=1,JMP LBL[1]', 'IF (R[1]>2 AND R[2]<3),CALL FOO', 'IF DI[1]=ON AND DI[2]=OFF,R[3]=(1)', 'IF (!DI[4]),JMP LBL[1]',
    'IF R[1]=AR[1] THEN', 'R[2]=1', 'ELSE', 'R[2]=2', 'ENDIF', 'FOR R[5]=1 TO 10', 'R[6]=R[6]+R[5]', 'ENDFOR', 'FOR R[5]=10 DOWNTO 1', 'ENDFOR',
    'SELECT R[1]=1,JMP LBL[1]', '=2,CALL FOO', 'ELSE,JMP LBL[1]', 'WAIT .50(sec)', 'WAIT 2.00(sec)', 'WAIT DI[1]=ON', 'WAIT (DI[1] OR GI[2]>0) TIMEOUT,LBL[1]',
    'CALL FOO', 'CALL BAR(1,AR[1],R[2],\'text\')', 'RUN BAZ', 'JMP LBL[1]', 'IF R[1]=1,PAUSE', 'IF DI[1]=ON,CALL BAR(1)', 'END',
  );
  assert.deepEqual(codes(src), []);
});

test('unknown instructions and typos', () => {
  // near-misses of a keyword are warnings (they may be shop macros); text that cannot be a macro is an error
  for (const bad of ['CALLL FOO', 'ENDIFF', 'Waits Done', 'Run2']) {
    assert.deepEqual(errs(bad), [], bad);
    assert.deepEqual(codes(body(bad), 'warning'), ['unknown-instruction'], bad);
  }
  assert.deepEqual(errs('1234'), ['unknown-instruction']);
  assert.deepEqual(errs('JUMP LBL[1]'), ['unknown-instruction']); // brackets: cannot be a macro name
  // macro-like names that are not near any keyword are only a hint, and can be listed in config
  const src = body('Program Status(5)');
  assert.deepEqual(codes(src), []);
  assert.deepEqual(codes(src, 'hint'), ['unknown-instruction']);
  assert.deepEqual(codes(src, 'hint', mergeConfig({ macros: ['program status'] })), []);
});

test('assignment errors', () => {
  assert.deepEqual(errs('DI[1]=ON'), ['not-assignable']);
  assert.deepEqual(errs('R[1]=1+'), ['expected-operand']);
  assert.deepEqual(errs('R[1]=1 2'), ['unexpected-text']);
  assert.deepEqual(errs('R[1]'), ['expected-token']);
  assert.deepEqual(errs('R[1]=ZZZ'), ['unknown-operand']);
  assert.deepEqual(errs('R[0]=1'), ['index-range']);
  assert.deepEqual(errs('R[1001]=1'), ['index-range']);
  assert.deepEqual(errs('R[]=1'), ['empty-index']);
  assert.deepEqual(errs('R[x]=1'), ['bad-index']);
  assert.deepEqual(errs('XR[1]=1'), ['unknown-register']);
  assert.deepEqual(errs('R[1]=(1+2'), ['expected-token']);
  assert.deepEqual(errs('TIMER[1]=ON'), ['expected-token']);
  assert.deepEqual(errs('R[1]=SR[2'), ['unbalanced-bracket']);
  assert.deepEqual(errs("SR[1]='abc"), ['unterminated-string']);
});

test('register and I/O index limits come from config', () => {
  assert.deepEqual(errs('DO[1025]=ON'), ['index-range']);
  assert.deepEqual(errs('RO[9]=ON'), ['index-range']);
  assert.deepEqual(errs('UO[19]=ON'), ['index-range']);
  assert.deepEqual(errs('R[1]=VR[11].MODELID'), ['index-range']);
  assert.deepEqual(errs('R[1]=TIMER[11]'), ['index-range']);
  assert.deepEqual(codes(body('DO[2000]=ON'), 'error', mergeConfig({ limits: { do: 4096 } })), []);
  assert.deepEqual(codes(body('R[5]=1'), 'error', mergeConfig({ limits: { r: 4 } })), ['index-range']);
});

test('numeric ranges', () => {
  assert.deepEqual(errs('OVERRIDE=150%'), ['numeric-range']);
  assert.deepEqual(errs('UFRAME_NUM=10'), ['numeric-range']);
  assert.deepEqual(errs('UTOOL_NUM=11'), ['numeric-range']);
  assert.deepEqual(errs('LBL[40000]'), ['index-range']);
  assert.deepEqual(codes(body('DO[1]=PULSE,30sec'), 'warning'), ['pulse-width']);
});

test('IF / ELSE / ENDIF / FOR balancing', () => {
  assert.deepEqual(errs('IF R[1]=1 THEN', 'R[2]=1'), ['unbalanced-block']);
  assert.deepEqual(errs('ENDIF'), ['unbalanced-block']);
  assert.deepEqual(errs('ELSE'), ['unbalanced-block']);
  assert.deepEqual(errs('IF R[1]=1 THEN', 'ELSE', 'ELSE', 'ENDIF'), ['unbalanced-block']);
  assert.deepEqual(errs('FOR R[1]=1 TO 3'), ['unbalanced-block']);
  assert.deepEqual(errs('ENDFOR'), ['unbalanced-block']);
  assert.deepEqual(errs('FOR R[1]=1 TO 3', 'IF R[2]=1 THEN', 'ENDFOR', 'ENDIF').length, 2);
  assert.deepEqual(errs('IF R[1]=1', 'R[2]=1'), ['expected-then']);
  assert.deepEqual(errs('FOR R[1]=1 3', 'ENDFOR'), ['expected-token']);
  assert.deepEqual(errs('FOR DO[1]=1 TO 3', 'ENDFOR'), ['expected-token']);
  assert.deepEqual(errs('=1,JMP LBL[1]', 'LBL[1]'), ['unbalanced-block']);
  assert.deepEqual(errs('IF R[1]=1,IF R[2]=1,JMP LBL[1]', 'LBL[1]'), ['bad-inline-action']);
  assert.deepEqual(errs('SELECT R[1]=1'), ['expected-token']);
});

test('labels: duplicates and missing targets', () => {
  assert.deepEqual(errs('LBL[1]', 'LBL[1]'), ['duplicate-label']);
  assert.deepEqual(errs('JMP LBL[2]'), ['undefined-label']);
  assert.deepEqual(errs('IF R[1]=1,JMP LBL[3]', 'LBL[4]'), ['undefined-label']);
  assert.deepEqual(errs('WAIT DI[1]=ON TIMEOUT,LBL[9]'), ['undefined-label']);
  assert.deepEqual(codes(wrap('   1:J P[1] 100% FINE Skip,LBL[7] ;', P1)), ['undefined-label']);
  assert.deepEqual(errs('JMP LBL[R[1]]'), []);
  assert.deepEqual(codes(body('LBL[5]'), 'hint').includes('unused-label'), true);
  assert.deepEqual(errs('JMP LBL'), ['expected-token']);
});

test('CALL / RUN targets are checked only with a workspace', () => {
  const src = body('CALL KNOWN', 'RUN OTHER', 'CALL T', 'CALL missing_one');
  assert.deepEqual(codes(src, 'warning'), []);
  const ws = { workspace: { programs: new Set(['KNOWN', 'OTHER']) } };
  const w = check(src, mergeConfig(), ws).filter((d) => d.code === 'unknown-program');
  assert.equal(w.length, 1);
  assert.equal(w[0].severity, 'warning');
  assert.deepEqual(check(src, mergeConfig({ externalPrograms: ['Missing_One'] }), ws).filter((d) => d.code === 'unknown-program'), []);
  assert.deepEqual(errs('CALL'), ['expected-program-name']);
  assert.deepEqual(errs('CALL FOO(1,'), ['expected-operand']);
  assert.deepEqual(errs('RUN 1'), ['expected-program-name']);
});

test('WAIT forms', () => {
  assert.deepEqual(errs('WAIT'), ['expected-operand']);
  assert.deepEqual(errs('WAIT DI[1]=ON TIMEOUT'), ['expected-token']);
  assert.deepEqual(errs('WAIT 5'), []);
});

test('iRVision statements (syntax unverified against the V9.x manual)', () => {
  const ok = body(
    "VISION RUN_FIND 'PROC1'", "VISION GET_OFFSET 'PROC1' VR[1] JMP LBL[10]", "VISION GET_NFOUND 'PROC1' R[5]", "VISION SET_REFERENCE 'PROC1'",
    "VISION OVERRIDE 'PROC1' EXPOSURE=R[1]", "VISION CAMERA_CALIB 'CAM2' Request=1", 'LBL[10]', 'R[1]=VR[1].MODELID', 'PR[2]=VR[1].OFFSET', 'PR[3]=VR[1].FOUND_POS[1]',
  );
  assert.deepEqual(codes(ok), []);
  assert.deepEqual(errs('VISION RUN_FIND PROC1'), ['vision-name-quote']);
  assert.deepEqual(errs("VISION GET_OFFSET 'P' R[1] JMP LBL[1]", 'LBL[1]'), ['expected-token']);
  assert.deepEqual(errs("VISION GET_NFOUND 'P' VR[1]"), ['expected-token']);
  assert.deepEqual(errs("VISION RUN_FIND ''"), ['vision-name-empty']);
  assert.deepEqual(errs('VISION'), ['expected-token']);
  assert.deepEqual(codes(body("VISION GET_OFFSET 'P' VR[1]"), 'warning'), ['vision-syntax']);
  assert.deepEqual(codes(body("VISION FROBNICATE 'P'"), 'warning'), ['unknown-vision-instruction']);
  assert.deepEqual(codes(body('R[1]=VR[1].BOGUS'), 'warning'), ['unknown-vr-field']);
  assert.deepEqual(errs("VISION GET_OFFSET 'P' VR[11] JMP LBL[1]", 'LBL[1]'), ['index-range']);
});

test('VOFFSET warns when the VR was not populated by an earlier GET_OFFSET', () => {
  const mv = '   2:L P[1] 100mm/sec FINE VOFFSET,VR[1] ;';
  const bare = wrap(`${mv}`, P1);
  assert.deepEqual(codes(bare, 'warning').filter((c) => c === 'vr-not-populated'), ['vr-not-populated']);
  const populated = wrap(`   1:VISION GET_OFFSET 'P' VR[1] JMP LBL[9] ;\n${mv}\n   3:LBL[9] ;`, P1);
  assert.deepEqual(codes(populated, 'warning').filter((c) => c === 'vr-not-populated'), []);
  const wrongVr = wrap(`   1:VISION GET_OFFSET 'P' VR[2] JMP LBL[9] ;\n${mv}\n   3:LBL[9] ;`, P1);
  assert.deepEqual(codes(wrongVr, 'warning').filter((c) => c === 'vr-not-populated'), ['vr-not-populated']);
  // a CALLed program may populate it, but that is not knowable here, so the warning stays (and can be turned off)
  const called = wrap(`   1:CALL VISION_OFFSET ;\n${mv}`, P1);
  assert.deepEqual(codes(called, 'warning').filter((c) => c === 'vr-not-populated'), ['vr-not-populated']);
});

test('motion options: ranges, targets and trigger actions', () => {
  const mv = (opts: string) => wrap(`   1:L P[1] 100mm/sec CNT10 ${opts} ;\n   2:LBL[1] ;`, P1);
  assert.deepEqual(codes(mv('ACC80 Skip,LBL[1] Offset,PR[2] Tool_Offset,PR[3] TB 0.5sec,DO[1]=ON TA 0.2sec,CALL FOO DB 10mm,R[1]=1 PTH RTCP COORD INC Wjnt')), []);
  assert.deepEqual(codes(mv('ACC600')), ['numeric-range']);
  assert.deepEqual(codes(mv('Offset,PR[1001]')), ['index-range']);
  assert.deepEqual(codes(mv('TB 0.5sec,DO[9999]=ON')), ['index-range']);
  assert.deepEqual(codes(mv('TB 0.5sec,R[1]=')), ['expected-operand']);
  assert.deepEqual(codes(mv('Skip,LBL[5]')), ['undefined-label']);
});

test('inline IF with a motion action checks the motion', () => {
  assert.deepEqual(codes(wrap('   1:IF R[1]=1,J P[1] 100% FINE ;', P1)), []);
  assert.deepEqual(codes(wrap('   1:IF R[1]=1,J P[1] 100mm/sec FINE ;', P1)), ['speed-unit-invalid']);
});

test('style lint: I/O right after a CNT move', () => {
  const src = (term: string, next: string) => wrap(`   1:UFRAME_NUM=1 ;\n   2:UTOOL_NUM=1 ;\n   3:L P[1] 100mm/sec ${term} ;\n   4:${next} ;`, P1);
  assert.deepEqual(codes(src('CNT50', 'DO[1]=ON'), 'warning'), ['io-after-cnt']);
  assert.deepEqual(codes(src('CNT50', 'DO[1]=PULSE,1.0sec'), 'warning'), ['io-after-cnt']);
  assert.deepEqual(codes(src('FINE', 'DO[1]=ON'), 'warning'), []);
  assert.deepEqual(codes(src('CNT50', 'R[1]=1'), 'warning'), []);
  assert.deepEqual(codes(src('CNT50', 'WAIT .50(sec)'), 'warning'), []);
  assert.deepEqual(codes(src('CNT50', 'DO[1]=ON'), 'warning', mergeConfig({ rules: { 'io-after-cnt': 'off' } })), []);
});

test('style lint: motion before UFRAME_NUM / UTOOL_NUM', () => {
  const mv = '   3:L P[1] 100mm/sec FINE ;';
  assert.deepEqual(codes(wrap(mv, P1), 'warning'), ['motion-before-frame']);
  assert.deepEqual(codes(wrap(`   1:UFRAME_NUM=1 ;\n   2:UTOOL_NUM=1 ;\n${mv}`, P1), 'warning'), []);
  assert.deepEqual(codes(wrap(`   1:UFRAME_NUM=1 ;\n${mv}`, P1), 'warning'), ['motion-before-frame']);
  assert.deepEqual(codes(wrap(`   1:CALL SETFRAMES ;\n${mv}`, P1), 'warning'), []);
  assert.deepEqual(codes(wrap(mv, P1), 'warning', mergeConfig({ rules: { 'motion-before-frame': 'off' } })), []);
});

test('statements still being typed are suppressed on the cursor line', () => {
  const src = wrap('   1:IF R[1]=1 THEN ;\n   2:R[1]=1+ ;');
  const diags = check(src, mergeConfig(), { cursorLine: 5 }).filter((d) => d.severity === 'error').map((d) => d.code);
  assert.ok(!diags.includes('expected-operand'));
  assert.ok(!diags.includes('unbalanced-block')); // open block spans the cursor
  const away = check(src, mergeConfig(), { cursorLine: 0 }).filter((d) => d.severity === 'error').map((d) => d.code);
  assert.ok(away.includes('expected-operand'));
  assert.ok(away.includes('unbalanced-block'));
});

test('synthetic iRVision fixture parses clean', async () => {
  const fs = await import('fs');
  const path = await import('path');
  const src = fs.readFileSync(path.resolve(__dirname, '../../../test-fixtures/IRVISION_SYNTH.LS'), 'utf8');
  assert.deepEqual(check(src).filter((d) => d.severity !== 'hint').map((d) => `${d.line + 1}:${d.code}`), []);
});

test('string register functions', () => {
  assert.deepEqual(errs('R[1]=STRLEN SR[2]', 'SR[1]=SUBSTR SR[2],1,3', 'R[1]=FINDSTR SR[1],SR[2]', "R[1]=FINDSTR SR[1],'ab'"), []);
  assert.deepEqual(errs('SR[1]=SUBSTR SR[2],1'), ['expected-token']);
  assert.deepEqual(errs('R[1]=STRLEN'), ['expected-operand']);
});

test('indirect CALL/RUN through a register is not looked up', () => {
  const src = body('CALL SR[1]', 'RUN SR[2]', 'CALL R[3]');
  const ws = { workspace: { programs: new Set<string>() } };
  assert.deepEqual(check(src, mergeConfig(), ws).filter((d) => d.severity !== 'hint' && d.code !== 'missing-attr' && d.code !== 'unused-position' && d.code !== 'motion-before-frame'), []);
  assert.deepEqual(errs('CALL SR[0]'), ['index-range']);
});

test('a truncated workspace scan is one warning and skips CALL/RUN checks', () => {
  const src = body('CALL NOPE', 'CALL NOPE2');
  const d = check(src, mergeConfig(), { workspace: { programs: new Set(), truncated: true } });
  assert.deepEqual(d.filter((x) => x.code === 'workspace-truncated').length, 1);
  assert.deepEqual(d.filter((x) => x.code === 'unknown-program'), []);
});

test('block errors do not cascade', () => {
  // mismatched ENDIF: one error, and the FOR is consumed so there is no extra "no matching ENDFOR"
  assert.deepEqual(errs('FOR R[1]=1 TO 3', 'ENDIF'), ['unbalanced-block']);
  // IF with a bad condition still opens its block, so its ENDIF matches
  assert.deepEqual(errs('IF R[1]=+ THEN', 'ENDIF'), ['expected-operand']);
  assert.deepEqual(errs('FOR R[1]=1 TO', 'ENDFOR'), ['expected-operand']);
});

test('SELECT cases end at the first unrelated statement', () => {
  assert.deepEqual(errs('SELECT R[1]=1,JMP LBL[1]', '=2,JMP LBL[1]', '! note', 'ELSE,JMP LBL[1]', 'LBL[1]'), []);
  assert.deepEqual(errs('SELECT R[1]=1,JMP LBL[1]', 'R[2]=1', '=2,JMP LBL[1]', 'LBL[1]'), ['unbalanced-block']);
});

test('block diagnostics stay inside the line', () => {
  const d = check(body('ENDIF'), mergeConfig()).find((x) => x.code === 'unbalanced-block')!;
  const line = body('ENDIF').split('\n')[d.line];
  assert.ok(d.endColumn <= line.length);
});

