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
- A space between a speed value and its unit (`50 mm/sec`) is a `speed-spacing` error (see Spacing above).
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
- **Spacing** (`bad-spacing` error): hand-typed spacing fails on the controller, so only the spacing the controller itself writes (as seen in the corpus) is accepted. Text inside comments, `MESSAGE[...]` and quoted strings is free. Turn off or downgrade with `"bad-spacing"` in `rules`; errors on the line being edited are hidden until you move away. The rules:
  - Line number right-aligned in 4 columns, no space before the colon.
  - Spaces after the colon: motion 0, empty line 3, `SELECT` case lines and `ELSE,<action>` 9, everything else (including comments and disabled `//` lines) 2.
  - Inside a statement: one space only between words and values (`JMP LBL[1]`, `J P[1] 50% CNT100`, `IF (...) THEN`, `AND`/`OR`). Never around `=` `,` `+ - * /` `< >`, before `[`, inside `[ ]`, in `CNT 1`, `25 mm/sec` or `1.0 sec`. `WAIT <time>` is padded so `WAIT` plus gap plus the number is 7 characters (`WAIT    .50(sec)`, `WAIT   2.00(sec)`).
  - Spaces before the closing `;`, per instruction form (counts from the corpus):

    | Form | Spaces before `;` |
    | --- | --- |
    | Motion (`J`/`L`/`C`/`A`) | 4 |
    | `!` comment, `JMP`, `LBL`, `IF ... THEN`, `ELSE`, `ENDIF`, `SELECT`, `=n,` cases, `ELSE,<action>`, `END`, `PAUSE`, `ABORT`, `VISION` | 1 |
    | `IF cond,<action>` (not a motion action) | 1 |
    | `CALL prog(args)` | 1 |
    | `CALL prog` (no arguments) | 4 |
    | Macro-style line with arguments (`Program Status(5)`) | 1 |
    | Macro-style line without arguments (`Clear User Page`) | 4 or 5 (4 in the corpus; 5 reported valid for `COL GUARD ADJUST`, rule not understood yet) |
    | `WAIT <condition>` | 4 |
    | `WAIT <time>(sec)`, `WAIT <condition> TIMEOUT,LBL[n]` | 1 |
    | `R`/`PR`/`SR` assignment | 4 |
    | `R`/`PR`/`SR` assignment from a system variable, or with parenthesised arithmetic such as `R[1]=((R[2]-1)*R[3])` (a negative literal `(-3)` is not arithmetic) | 1 |
    | `DO`/`RO`/`GO`/`F` outputs, `UFRAME_NUM`, `UTOOL_NUM`, `OVERRIDE`, `$sysvar=`, `TIMER`, `PAYLOAD`, `UALM`, `MESSAGE` | 1 |
    | `//` disabled line | 1 or 4 (unverified: the corpus shows both) |
    | Instructions the corpus never shows (`FOR`, `ENDFOR`, `MONITOR`, ...) | 1 or 4 (unverified) |
- **Style lints** (warnings; turn off with `rules`): `io-after-cnt` (output instruction directly after a CNT/CR move), `motion-before-frame` (first motion before `UFRAME_NUM` and `UTOOL_NUM` are set; skipped after a `CALL`/`RUN`)

Not yet covered: type checks between operands (`R[1]=ON`), mixed AND/OR precedence rules, `/APPL` contents, `/POS` coordinate fields, KAREL calls with typed arguments.

## Tests

`npm test` runs unit tests, CLI tests and the corpus runner, which asserts zero errors for every `.LS` under `corpus/` (two stub programs with jumps to labels that do not exist are listed in `KNOWN_DEFECTS` in the test, which fails if an entry stops applying)
(`LS_CORPUS_DIR=/path npm run corpus` checks another folder). Note: the real corpus has no circular (`C`/`A`) moves yet, so those paths are covered by unit tests only.

## VS Code extension

`cd packages/vscode && npm run build`, then run via the Extension Development Host (F5) or package with `vsce`. Requires the TP editor extension `NathanBadanjek.fanuctpp` (declared as an extension dependency) for the `fanuctp_ls` language ID. Package with `npm run package -w ls-check` (core is bundled by esbuild, so vsce runs with `--no-dependencies`).

### Completions and quick fix

- **Templates**: on an `/MN` line, start typing an instruction (`J`, `L`, `IF`, `WAIT`, `CALL`, `VISION`, ...) or press Ctrl+Space right after the line number. Each template is inserted with tab stops and with the exact spacing the checker enforces (motion against the colon, two spaces for everything else, the per-form pad before `;`), so a completed line passes clean. The first word that offers choices (speed unit, `FINE`/`CNT`, `ON`/`OFF`, ...) opens a drop-down on Tab. Multi-line forms (`IF ... THEN`, `SELECT`, `FOR`) insert their following lines with line numbers; the TP editor extension renumbers them as usual. New `P[n]` and `LBL[n]` default to the next unused index (highest used plus one; gaps are not filled). Jump templates default to the last label defined in the program, or `LBL[1]`; when that label does not exist yet the quick fix below creates it. The placeholder line inside a block template is the empty-line form; whatever you type there must still follow the per-form pad before `;` (for example `R[2]=5` wants 4 spaces), which the spacing quick fix applies for you. Circular (`C`/`A`) templates are not offered because the corpus has no circular moves to confirm their layout.
- **Index and program suggestions**: inside `P[`, `LBL[` and `R[` the program's known indices are offered (with `R` register names); after `CALL ` / `RUN ` the programs found in the workspace plus `externalPrograms`. Nothing is offered inside comments, disabled `//` lines, quoted strings or `MESSAGE[...]`/register-name text.
- **Quick fix**: on an `undefined-position` error, the light bulb (Ctrl+.) offers `Create P[n] in /POS`, and `Create all N undefined positions in /POS` when there are several. The record is inserted in index order with all-zero coordinates; `UF`/`UT` come from the last literal `UFRAME_NUM`/`UTOOL_NUM` before the first use of that position (else 1/1), `CONFIG 'N U T, 0, 0, 0'`. A missing `/POS` section is created. **A created position is the zeroed frame origin, not a taught point: teach it on the robot before running the program.**
- **Other quick fixes**: `Create LBL[n] after this line` for an undefined label, and `Fix spacing on this line` for `bad-spacing`, which rewrites the line number alignment, the gap after the colon, inner gaps and the pad before `;` to the form the checker expects.
- Settings: `lscheck.completions.enabled`; `lscheck.completions.semicolon` (default off: templates stop before the pad and `;`, leaving the `;` to the TP editor extension, which places it itself; turn on to have the template write the controller's pad); `lscheck.autoFixSpacing` (default on: after you move off a line you just edited, its spacing errors are rewritten to the controller form, once per line text, so a pad the TP editor extension changed is put right).
