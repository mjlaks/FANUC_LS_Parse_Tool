import { test } from 'node:test';
import assert from 'node:assert/strict';
import * as fs from 'fs';
import * as path from 'path';
import { check, formatDiagnostic } from '../src';
import { buildWorkspaceIndex } from '../src/node';

// Every .LS under the corpus folder must parse with zero errors.
// Point LS_CORPUS_DIR at another folder (e.g. a backup export) to check that instead.
const root = process.env.LS_CORPUS_DIR ?? path.resolve(__dirname, '../../../corpus');

function* walk(dir: string): Generator<string> {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) yield* walk(p);
    else if (/\.ls$/i.test(e.name)) yield p;
  }
}

// Real files known to contain a genuine defect. Each entry is "<relative path>: <code>[, <code>]"; the test fails
// if an entry is no longer needed, so the list cannot go stale. Currently: stub programs whose jump targets were
// removed (LBL[n] is jumped to but never defined), which the controller would refuse to load.
const KNOWN_DEFECTS: Record<string, string[]> = {
  'v9.30/HANDOFF_SMPL.LS': ['undefined-label'],
  'v9.30/LUL_GRINDER_SMPL.LS': ['undefined-label'],
  // scrub placeholder line ("VENDOR Module-1-07") written with 3 spaces after the line number instead of 2
  'v9.30/LISTMENU_PSG.LS': ['bad-spacing'],
  'v9.30/OPERMENU_PSG.LS': ['bad-spacing'],
  'v9.30/PROMPTOK_PSG.LS': ['bad-spacing'],
  'v9.30/PROMPTYN_PSG.LS': ['bad-spacing'],
};

const files = [...walk(root)];
const workspace = buildWorkspaceIndex(root);
test('corpus is not empty', () => assert.ok(files.length > 0, `no .LS files under ${root}`));
for (const f of files) {
  test(`corpus: ${path.relative(root, f)}`, () => {
    const rel = path.relative(root, f).split(path.sep).join('/');
    const known = process.env.LS_CORPUS_DIR ? [] : KNOWN_DEFECTS[rel] ?? [];
    const errors = check(fs.readFileSync(f, 'utf8'), undefined, { workspace }).filter((d) => d.severity === 'error');
    const unexpected = errors.filter((d) => !known.includes(d.code));
    assert.deepEqual(unexpected.map((d) => formatDiagnostic(f, d)), []);
    for (const code of known) assert.ok(errors.some((d) => d.code === code), `${rel}: known defect '${code}' no longer occurs; remove it from KNOWN_DEFECTS`);
  });
}
