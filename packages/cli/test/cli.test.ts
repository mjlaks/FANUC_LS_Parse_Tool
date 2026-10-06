import { test } from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import * as fs from 'fs';
import * as path from 'path';
import { check, formatDiagnostic, mergeConfig } from '@lscheck/core';

const root = path.resolve(__dirname, '../../..');
const cli = path.join(root, 'packages/cli/dist/cli.js');
const bad = path.join(root, 'test-fixtures/BAD.LS');

test('exit codes: clean file 0, broken file 1', () => {
  assert.equal(spawnSync('node', [cli, path.join(root, 'corpus/samples/SAMPLE_MOVE.LS')]).status, 0);
  assert.equal(spawnSync('node', [cli, bad]).status, 1);
});

// The VS Code extension calls the same check() with the same config, so matching
// the library output here means CLI and extension agree on a file.
test('CLI output matches core check() diagnostics', () => {
  const out = spawnSync('node', [cli, bad]).stdout.toString().trim().split('\n');
  const expected = check(fs.readFileSync(bad, 'utf8'), mergeConfig()).map((d) => formatDiagnostic(bad, d));
  assert.deepEqual(out.slice(0, -1), expected);
});

test('json format', () => {
  const j = JSON.parse(spawnSync('node', [cli, '--format', 'json', bad]).stdout.toString());
  assert.ok(j[bad].some((d: { code: string }) => d.code === 'cnt-range'));
});

import * as os from 'os';

test('malformed .lscheckrc.json reports config-error instead of crashing', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'lscheck-'));
  fs.writeFileSync(path.join(dir, '.lscheckrc.json'), '{ nope');
  fs.copyFileSync(path.join(root, 'corpus/samples/SAMPLE_MOVE.LS'), path.join(dir, 'A.LS'));
  const r = spawnSync('node', [cli, path.join(dir, 'A.LS')]);
  assert.equal(r.status, 1);
  assert.match(r.stdout.toString(), /config-error/);
});

test('BOM file matches BOM-free output; bad --max-warnings rejected', () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'lscheck-'));
  const src = fs.readFileSync(bad, 'utf8');
  fs.writeFileSync(path.join(dir, 'B.LS'), '﻿' + src);
  fs.writeFileSync(path.join(dir, 'C.LS'), src);
  const strip = (s: string) => s.replace(/^.*[\\/]/gm, '').replace(/^[BC]\.LS/gm, 'X.LS');
  const run = (f: string) => strip(spawnSync('node', [cli, path.join(dir, f)]).stdout.toString());
  assert.equal(run('B.LS').replace(/B\.LS/g, 'X.LS'), run('C.LS').replace(/C\.LS/g, 'X.LS'));
  assert.equal(spawnSync('node', [cli, '--max-warnings', 'abc', bad]).status, 2);
});
