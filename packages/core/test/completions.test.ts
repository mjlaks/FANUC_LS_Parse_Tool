import { test } from 'node:test';
import assert from 'node:assert/strict';
import * as fs from 'node:fs';
import * as path from 'node:path';
import { applyInsertEdits, check, choiceCombinations, createPositionEdits, gapAfterColon, mergeConfig, pad4, parseLs, positionRecord, renderBody, scanDoc, SNIPPETS, undefinedPositions } from '../src';

const cfg = mergeConfig();
const HEAD = '/PROG  T\n/ATTR\nOWNER\t\t= MNEDITOR;\n/MN\n';
const PRE = [
  '   1:  UFRAME_NUM=1 ;',
  '   2:  UTOOL_NUM=1 ;',
  "   3:  VISION GET_OFFSET 'P' VR[1] JMP LBL[1] ;",
  '   4:  LBL[1] ;',
  '   5:J P[1] 100% FINE    ;',
  '   6:  !a ;',
  '   7:  !b ;',
  '   8:  !c ;',
  '   9:  !d ;',
];
const POS = positionRecord(1);

test('snippet catalogue has unique ids', () => {
  const ids = SNIPPETS.map((s) => s.id);
  assert.equal(new Set(ids).size, ids.length);
  assert.ok(ids.length > 40);
});

test('every snippet, with every choice, expands to checker-clean text', () => {
  let checked = 0;
  for (const def of SNIPPETS) {
    const base = HEAD + PRE.join('\n') + '\n';
    const facts = scanDoc(base + '/POS\n' + POS + '/END\n');
    const body = renderBody(def, facts, 10);
    for (const expanded of choiceCombinations(body)) {
      const lines = expanded.split('\n');
      lines[0] = `${pad4(10)}:${gapAfterColon(def)}${lines[0]}`;
      let doc = base + lines.join('\n') + '\n/POS\n' + POS + '/END\n';
      // positions the snippet introduced (next unused P) are defined with the quick fix, like a user would
      const missing = undefinedPositions(doc, cfg);
      if (missing.length) doc = applyInsertEdits(doc, createPositionEdits(doc, missing));
      const diags = check(doc, cfg);
      const onSnippet = diags.filter((d) => d.code !== 'missing-attr');
      const allowed = def.id === 'lbl' ? ['unused-label'] : [];
      const bad = onSnippet.filter((d) => !allowed.includes(d.code));
      assert.deepEqual(bad.map((d) => `${d.line + 1}:${d.code} ${d.message}`), [], `${def.id}: ${JSON.stringify(expanded)}`);
      checked++;
    }
  }
  assert.ok(checked >= SNIPPETS.length);
});

test('motion snippets sit against the colon, others have two spaces', () => {
  assert.equal(gapAfterColon(SNIPPETS.find((s) => s.id === 'J-P')!), '');
  assert.equal(gapAfterColon(SNIPPETS.find((s) => s.id === 'jmp')!), '  ');
});

test('defaults pick the next unused P index and label', () => {
  const doc = HEAD + PRE.join('\n') + '\n/POS\n' + POS + '/END\n';
  const facts = scanDoc(doc);
  assert.match(renderBody(SNIPPETS.find((s) => s.id === 'L-P')!, facts), /^L P\[\$\{1:2\}\]/);
  assert.match(renderBody(SNIPPETS.find((s) => s.id === 'lbl')!, facts), /^LBL\[\$\{1:2\}\]/);
});

// ---- create-position quick fix ----

const MN = (...l: string[]) => `/PROG  T\n/ATTR\nOWNER\t\t= MNEDITOR;\n/MN\n${l.join('\n')}\n`;
const fix = (src: string, n?: number[]) => applyInsertEdits(src, createPositionEdits(src, n ?? undefinedPositions(src, cfg)));
const errors = (src: string) => check(src, cfg).filter((d) => d.severity === 'error' && d.code !== 'missing-section');

test('creates a missing position in sorted place and parses clean', () => {
  const src = MN('   1:J P[1] 100% FINE    ;', '   2:J P[2] 100% FINE    ;', '   3:J P[3] 100% FINE    ;') + '/POS\n' + positionRecord(1) + positionRecord(3) + '/END\n';
  assert.deepEqual(undefinedPositions(src, cfg), [2]);
  const out = fix(src);
  assert.equal(out, MN('   1:J P[1] 100% FINE    ;', '   2:J P[2] 100% FINE    ;', '   3:J P[3] 100% FINE    ;') + '/POS\n' + positionRecord(1) + positionRecord(2) + positionRecord(3) + '/END\n');
  assert.deepEqual(errors(out), []);
});

test('appends after the last record and fixes several at once', () => {
  const src = MN('   1:J P[5] 100% FINE    ;', '   2:J P[2] 100% FINE    ;', '   3:J P[9] 100% FINE    ;') + '/POS\n' + positionRecord(5) + '/END\n';
  const out = fix(src);
  assert.deepEqual(errors(out), []);
  assert.deepEqual(parseLs(out, cfg).definedPositions, [2, 5, 9]);
  assert.ok(out.indexOf('P[2]{') < out.indexOf('P[5]{') && out.indexOf('P[5]{') < out.indexOf('P[9]{'));
});

test('creates the /POS section when missing (before /END, or at the end)', () => {
  const mn = MN('   1:J P[1] 100% FINE    ;');
  for (const tail of ['/END\n', '']) {
    const out = fix(mn + tail);
    assert.equal(out, mn + '/POS\n' + positionRecord(1) + tail);
    assert.deepEqual(errors(out), []);
  }
  const noNewline = fix(mn.trimEnd());
  assert.equal(noNewline, mn + '/POS\n' + positionRecord(1));
});

test('works with an empty /POS section and CRLF files', () => {
  const src = (MN('   1:J P[4] 100% FINE    ;') + '/POS\n/END\n').replace(/\n/g, '\r\n');
  const out = fix(src);
  assert.equal(out, (MN('   1:J P[4] 100% FINE    ;') + '/POS\n' + positionRecord(4) + '/END\n').replace(/\n/g, '\r\n'));
  assert.deepEqual(errors(out), []);
});

test('uses the frame in effect where the position is first used', () => {
  const src = MN('   1:  UFRAME_NUM=3 ;', '   2:  UTOOL_NUM=R[5] ;', '   3:  UTOOL_NUM=7 ;', '   4:J P[1] 100% FINE    ;', '   5:  UFRAME_NUM=4 ;', '   6:J P[2] 100% FINE    ;', '   7:  //UTOOL_NUM=9 ;', '   8:J P[3] 100% FINE    ;') + '/POS\n/END\n';
  const out = fix(src);
  assert.match(out, /P\[1\]\{\n {3}GP1:\n\tUF : 3, UT : 7,/);
  assert.match(out, /P\[2\]\{\n {3}GP1:\n\tUF : 4, UT : 7,/);
  assert.match(out, /P\[3\]\{\n {3}GP1:\n\tUF : 4, UT : 7,/);
  const bare = fix(MN('   1:J P[1] 100% FINE    ;') + '/POS\n/END\n');
  assert.match(bare, /UF : 1, UT : 1,\t\tCONFIG : 'N U T, 0, 0, 0',/);
});

test('already defined positions are left alone', () => {
  const src = MN('   1:J P[1] 100% FINE    ;') + '/POS\n' + positionRecord(1) + '/END\n';
  assert.deepEqual(createPositionEdits(src, [1]), []);
});

// ---- layout matches the controller's own records ----

const corpus = path.resolve(__dirname, '../../../corpus/v9.30');
const records: string[] = [];
for (const f of fs.readdirSync(corpus).filter((n) => /\.ls$/i.test(n))) {
  const text = fs.readFileSync(path.join(corpus, f), 'utf8');
  for (const m of text.matchAll(/^P\[\d+\]\{\n {3}GP1:\n\tUF : \d+, UT : \d+,\t\tCONFIG : '[^']*',\n(?:[^\n]*\n){2}\};\n/gm)) records.push(m[0]);
}
const shape = (r: string) => r.replace(/P\[\d+\]/, 'P[#]').replace(/UF : \d+, UT : \d+/, 'UF : #, UT : #').replace(/CONFIG : '[^']*'/, "CONFIG : '#'").replace(/-?\d*\.\d{3}/g, '#.###');

test('inserted record has the same layout as every corpus record that carries a CONFIG', () => {
  assert.ok(records.length > 50);
  const mine = shape(positionRecord(7, 3, 10));
  // value widths differ per number, so compare with the numbers' padding removed too
  const loose = (s: string) => s.replace(/ +#\.###/g, ' #.###');
  for (const r of records) assert.equal(loose(shape(r)), loose(mine));
});

test('inserted record matches a corpus record byte for byte', () => {
  // a corpus record whose only non-zero coordinate is Z = -7; zero it and renumber
  const real = records.find((r) => r.includes("UF : 1, UT : 1,\t\tCONFIG : 'N U T, 0, 0, 0'") && r.includes('Z =    -7.000  mm'))!;
  assert.ok(real);
  const expected = real.replace(/^P\[\d+\]/, 'P[12]').replace('Z =    -7.000  mm', 'Z =     0.000  mm');
  assert.equal(positionRecord(12, 1, 1), expected);
});
