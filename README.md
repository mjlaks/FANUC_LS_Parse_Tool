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

Options: `--format json`, `--firmware V9.40`, `--max-warnings N`, `--no-workspace`. Exit code 1 on any error.

## Config

`.lscheckrc.json` (found by walking up from the file; used by both CLI and extension, overrides VS Code `lscheck.*` settings):

```json
{
  "firmware": "V9.30",
  "limits": { "pr": 1000, "r": 1000, "vr": 10, "do": 1024, "ro": 8 },
  "macros": ["Program Status", "Clear User Page"],
  "externalPrograms": ["ALARM_LOG"],
  "rules": { "unused-position": "off", "missing-attr": "error", "io-after-cnt": "off" }
}
```

## Notes

- `firmware` / `--firmware` is **reserved**: it is carried in the config but no rule is gated on it yet (V9.30 and V9.40 share one dialect in Milestone 1).
- A space between a speed value and its unit (`50 mm/sec`) produces a `speed-spacing` warning: the controller always writes them together, and it is unconfirmed whether the loader accepts a gap. Verify with maketp.
- A malformed `.lscheckrc.json` yields a `config-error` diagnostic and falls back to defaults.

## Coverage

Milestone 1
- Sections `/PROG /ATTR /APPL /MN /POS /END`: order, missing sections, `/ATTR` keys, `;` termination, program name and comment length
- J/L/C/A motion: `P[n]`/`PR[n]`, speed units per motion type, `FINE`/`CNTn`/`CRn`, circular via+end points
- `P[n]` used vs defined in `/POS`; unused positions warn
- Line numbering problems are hints. Errors for a statement still being typed are suppressed on the cursor line.

Milestones 2 and 3
- **Registers and I/O**: `R`, `PR` (including `PR[i,j]`), `SR`, `F`, `M`, `DI/DO`, `RI/RO`, `GI/GO`, `AI/AO`, `UI/UO`, `SI/SO`, `AR`, `TIMER`, `$sysvar`, indirect indices (`R[AR[2]]`), `PULSE`, assigning to read-only inputs (`not-assignable`), malformed expressions, index limits per type (`index-range`, configurable under `limits`)
- **Flow**: `IF` (inline and `THEN`), `ELSE`, `ENDIF`, `FOR`/`ENDFOR`, `SELECT` cases, `WAIT` (time, condition, `TIMEOUT,LBL`), `JMP`, `LBL`, `CALL` (with arguments), `RUN`, `MONITOR`, `WHEN`, `PAUSE`, `ABORT`, `END`; block balancing (`unbalanced-block`)
- **Labels**: duplicate `LBL[n]` and jumps to undefined labels (also `Skip,LBL`, `TIMEOUT,LBL`, vision `JMP LBL`); never-jumped labels are hints
- **CALL/RUN targets**: warns (`unknown-program`) when the program is not under the workspace root (the folder holding `.lscheckrc.json`, else the file's folder; `.LS`, `.TP`, `.KL`, `.PC` files; folders over a size cap give one `workspace-truncated` warning and skip the check; `CALL SR[n]` indirect targets are not looked up). List controller-only programs under `externalPrograms`. `--no-workspace` turns the lookup off.
- **iRVision**: `VISION RUN_FIND`, `GET_OFFSET` (VR + `JMP LBL`), `GET_NFOUND`, `SET_REFERENCE`, `OVERRIDE`, `CAMERA_CALIB`; quoted process names; `VR[n].FIELD`; `vr-not-populated` warning when `VOFFSET,VR[n]` has no earlier `GET_OFFSET` for that VR (a CALLed program may fill it; turn the rule off if that is how you work). **Only `CAMERA_CALIB` appears in the real corpus; the rest of the VISION syntax comes from the project brief and is unverified against the V9.x manual**, so deviations there are warnings.
- **Motion options**: `Offset`, `Tool_Offset`, `VOFFSET`, `Skip`, `TB`/`TA`/`DB` (their actions are checked as instructions), `INC`, `ACC` (0..500), `PTH`, `Wjnt`, `RTCP`, `COORD`, `EV`, `AP_LD`, `RT_LD`, `PSPD`, ...; PR/VR indices checked
- **Ranges**: `OVERRIDE` 1..100, `UFRAME_NUM`, `UTOOL_NUM`, labels 1..32766, `PULSE` width
- **Unknown instructions**: TP macros are named by the shop, so an unrecognized name is a hint, and a near-miss of a real keyword (`CALLL`) is a warning with a suggestion; list known macros under `macros` to silence both. Only text that cannot be a macro name is an error.
- **Spacing** (`odd-spacing` warning; none appears in the real corpus): space before `[` (`DO [1]`, `P [8]`), spaces inside brackets (`R[ 1 ]`), spaces around the `=` of an assignment (`DO[1] = ON`), `CNT 1`, a space before a PULSE unit. Extra spaces or tabs after the line number, before `;`, or between motion fields are not flagged (the controller writes them itself). It is unconfirmed whether the loader rejects these; verify with maketp.
- **Style lints** (warnings; turn off with `rules`): `io-after-cnt` (output instruction directly after a CNT/CR move), `motion-before-frame` (first motion before `UFRAME_NUM` and `UTOOL_NUM` are set; skipped after a `CALL`/`RUN`)

Not yet covered: type checks between operands (`R[1]=ON`), mixed AND/OR precedence rules, `/APPL` contents, `/POS` coordinate fields, KAREL calls with typed arguments.

## Tests

`npm test` runs unit tests, CLI tests and the corpus runner, which asserts zero errors for every `.LS` under `corpus/` (two stub programs with jumps to labels that do not exist are listed in `KNOWN_DEFECTS` in the test, which fails if an entry stops applying)
(`LS_CORPUS_DIR=/path npm run corpus` checks another folder). Note: the real corpus has no circular (`C`/`A`) moves yet, so those paths are covered by unit tests only.

## VS Code extension

`cd packages/vscode && npm run build`, then run via the Extension Development Host (F5) or package with `vsce`. Requires the TP editor extension `NathanBadanjek.fanuctpp` (declared as an extension dependency) for the `fanuctp_ls` language ID. Package with `npm run package -w ls-check` (core is bundled by esbuild, so vsce runs with `--no-dependencies`).
