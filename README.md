# LS Parse Tool

Syntax and semantic checker for TP programs in ASCII `.LS` format (R-30iB Plus, V9.30/V9.40 baseline).

| Package | Purpose |
| --- | --- |
| `packages/core` | Hand-written lexer/parser and diagnostics (`check(source, config, { cursorLine })`) |
| `packages/cli` | `lscheck file.LS` for terminals, CI and pre-commit |
| `packages/vscode` | Live diagnostics on the `fanuctp_ls` language ID from the existing TP editor extension (no grammar, renumbering or navigation duplicated) |

## Use

```
npm install && npm test
node packages/cli/dist/cli.js corpus/samples/SAMPLE_MOVE.LS      # or: npx lscheck ...
```

Options: `--format json`, `--firmware V9.40`, `--max-warnings N`. Exit code 1 on any error.

## Config

`.lscheckrc.json` (found by walking up from the file; used by both CLI and extension, overrides VS Code `lscheck.*` settings):

```json
{ "firmware": "V9.30", "limits": { "pr": 1000, "p": 32767, "vr": 10 }, "rules": { "unused-position": "off", "missing-attr": "error" } }
```

## Notes

- `firmware` / `--firmware` is **reserved**: it is carried in the config but no rule is gated on it yet (V9.30 and V9.40 share one dialect in Milestone 1).
- A space between a speed value and its unit (`50 mm/sec`) produces a `speed-spacing` warning: the controller always writes them together, and it is unconfirmed whether the loader accepts a gap. Verify with maketp.
- A malformed `.lscheckrc.json` yields a `config-error` diagnostic and falls back to defaults.

## Milestone 1 coverage

- Sections `/PROG /ATTR /APPL /MN /POS /END`: order, missing sections, `/ATTR` keys, `;` termination, program name and comment length
- J/L/C/A motion: `P[n]`/`PR[n]`, speed units per motion type, `FINE`/`CNTn`/`CRn`, circular via+end points, common options (Offset, Tool_Offset, VOFFSET, Skip, TB/TA/DB, INC, ACC, Wjnt, ...); unknown options warn
- Other statements: bracket/quote balance only (full instruction grammar is Milestone 2)
- `P[n]` used vs defined in `/POS`; unused positions warn
- Line numbering problems are hints. Errors for a statement still being typed are suppressed on the cursor line.

## Tests

`npm test` runs unit tests, CLI tests and the corpus runner, which asserts zero errors for every `.LS` under `corpus/`
(`LS_CORPUS_DIR=/path npm run corpus` checks another folder). Note: the real corpus has no circular (`C`/`A`) moves yet, so those paths are covered by unit tests only.

## VS Code extension

`cd packages/vscode && npm run build`, then run via the Extension Development Host (F5) or package with `vsce`. Requires the TP editor extension `NathanBadanjek.fanuctpp` (declared as an extension dependency) for the `fanuctp_ls` language ID. Package with `npm run package -w ls-check` (core is bundled by esbuild, so vsce runs with `--no-dependencies`).
