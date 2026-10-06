import { test } from 'node:test';
import assert from 'node:assert/strict';
import * as fs from 'fs';
import * as path from 'path';
import { check, formatDiagnostic } from '../src';

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

const files = [...walk(root)];
test('corpus is not empty', () => assert.ok(files.length > 0, `no .LS files under ${root}`));
for (const f of files) {
  test(`corpus: ${path.relative(root, f)}`, () => {
    const errors = check(fs.readFileSync(f, 'utf8')).filter((d) => d.severity === 'error');
    assert.deepEqual(errors.map((d) => formatDiagnostic(f, d)), []);
  });
}
