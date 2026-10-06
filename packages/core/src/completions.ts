/**
 * Instruction templates for editor completion, in VS Code snippet syntax. Every template expands to the exact
 * spacing the checker accepts (see spacing.ts): after the line number motion uses 0 spaces and everything else 2,
 * and the pad before ';' is fixed per form. Pure data and string work, so it is testable without an editor.
 */

export interface SnippetDef {
  id: string;
  /** Shown in the completion list */
  label: string;
  detail: string;
  /** Extra words the typed text is matched against (the first word is what you normally type) */
  keywords: string;
  /** Motion lines sit right against the colon; every other statement has two spaces after it */
  motion?: boolean;
  /**
   * Snippet body for one statement, including the pad and ';'. Tokens: @P@ next unused position index, @LBL@ next
   * unused label, @JMP@ a label to jump to, @R@ 1, @L1@ @L2@ ... line-number prefixes for following lines.
   */
  body: string;
}

const TERM = '${4|FINE,CNT100,CNT50,CNT0|}';
const CART = '${3|mm/sec,cm/min,inch/min,deg/sec,sec,msec|}';
const JOINT = '${3|%,sec,msec|}';

function motion(kind: 'J' | 'L', pos: 'P' | 'PR', opt?: { name: string; text: string; detail: string }): SnippetDef {
  const idx = pos === 'P' ? '@P@' : '@R@';
  const speed = kind === 'J' ? '${2:100}' + JOINT : '${2:500}' + CART;
  const tail = opt ? ` ${opt.text}` : '';
  return {
    id: `${kind}-${pos}${opt ? '-' + opt.name : ''}`,
    label: `${kind} ${pos}[n]${opt ? ' + ' + opt.name : ''}`,
    detail: `${kind === 'J' ? 'Joint' : 'Linear'} move to ${pos}[n]${opt ? ' with ' + opt.detail : ''}`,
    keywords: `${kind} ${kind === 'J' ? 'joint' : 'linear'} move motion ${pos}${opt ? ' ' + opt.name : ''}`,
    motion: true,
    body: `${kind} ${pos}[\${1:${idx}}] ${speed} ${TERM}${tail}    ;`,
  };
}

const MOTION_OPTIONS = [
  { name: 'Offset', text: 'Offset,PR[${5:1}]', detail: 'position register offset' },
  { name: 'Tool_Offset', text: 'Tool_Offset,PR[${5:1}]', detail: 'tool offset register' },
  { name: 'VOFFSET', text: 'VOFFSET,VR[${5:1}]', detail: 'vision offset' },
  { name: 'Skip', text: 'Skip,LBL[${5:@JMP@}]', detail: 'skip condition label' },
  { name: 'ACC', text: 'ACC${5:100}', detail: 'acceleration override' },
  { name: 'Wjnt', text: 'Wjnt', detail: 'wrist joint motion' },
  { name: 'INC', text: 'INC', detail: 'incremental move' },
];

const WAIT_TIMES = ['WAIT    .50(sec)', 'WAIT   1.00(sec)', 'WAIT   2.00(sec)', 'WAIT   5.00(sec)', 'WAIT  10.00(sec)'];

const stmt = (id: string, label: string, detail: string, keywords: string, body: string): SnippetDef => ({ id, label, detail, keywords, body });

export const SNIPPETS: SnippetDef[] = [
  motion('J', 'P'),
  motion('J', 'PR'),
  motion('L', 'P'),
  motion('L', 'PR'),
  ...(['J', 'L'] as const).flatMap((k) => MOTION_OPTIONS.map((o) => motion(k, 'P', o))),

  stmt('r-assign', 'R[n]=value', 'Register assignment', 'R register assign set', 'R[${1:@R@}]=${2:0}    ;'),
  stmt('r-arith', 'R[n]=R[n] + R[n]', 'Register arithmetic', 'R register add subtract multiply math', 'R[${1:@R@}]=R[${2:@R@}]${3|+,-,*|}${4:1}    ;'),
  stmt('pr-assign', 'PR[n]=P[n]', 'Position register from a position', 'PR position register assign', 'PR[${1:@R@}]=P[${2:@P@}]    ;'),
  stmt('r-vr', 'R[n]=VR[n].MODELID', 'Read a vision register field', 'R vision VR modelid', 'R[${1:@R@}]=VR[${2:1}].MODELID    ;'),
  stmt('pr-vr', 'PR[n]=VR[n].OFFSET', 'Read the vision offset', 'PR vision VR offset', 'PR[${1:@R@}]=VR[${2:1}].OFFSET    ;'),
  stmt('do', 'DO[n]=ON/OFF', 'Digital output', 'DO output digital', 'DO[${1:@R@}]=${2|ON,OFF|} ;'),
  stmt('ro', 'RO[n]=ON/OFF', 'Robot output', 'RO output robot', 'RO[${1:@R@}]=${2|ON,OFF|} ;'),
  stmt('do-pulse', 'DO[n]=PULSE', 'Pulse a digital output', 'DO pulse output', 'DO[${1:@R@}]=PULSE,${2:0.5}sec ;'),
  stmt('go', 'GO[n]=value', 'Group output', 'GO group output', 'GO[${1:@R@}]=${2:0} ;'),
  stmt('flag', 'F[n]=ON/OFF', 'Flag', 'F flag', 'F[${1:@R@}]=${2|ON,OFF|} ;'),
  stmt('uframe', 'UFRAME_NUM=n', 'Select the user frame', 'UFRAME_NUM user frame', 'UFRAME_NUM=${1:1} ;'),
  stmt('utool', 'UTOOL_NUM=n', 'Select the tool frame', 'UTOOL_NUM user tool frame', 'UTOOL_NUM=${1:1} ;'),
  stmt('override', 'OVERRIDE=n%', 'Speed override', 'OVERRIDE speed', 'OVERRIDE=${1:100}% ;'),
  stmt('timer', 'TIMER[n]=START/STOP/RESET', 'Timer control', 'TIMER start stop reset', 'TIMER[${1:@R@}]=${2|START,STOP,RESET|} ;'),

  stmt('lbl', 'LBL[n]', 'Label', 'LBL label', 'LBL[${1:@LBL@}] ;'),
  stmt('jmp', 'JMP LBL[n]', 'Jump to a label', 'JMP jump goto label', 'JMP LBL[${1:@JMP@}] ;'),
  stmt('if-jmp', 'IF cond,JMP LBL[n]', 'Inline conditional jump', 'IF jump condition', 'IF ${1:R[@R@]}${2|=,<>,>,<,>=,<=|}${3:1},JMP LBL[${4:@JMP@}] ;'),
  stmt('if-call', 'IF cond,CALL prog', 'Inline conditional call', 'IF call condition', 'IF ${1:DI[@R@]}=${2|ON,OFF|},CALL ${3:PROGRAM} ;'),
  stmt('if-then', 'IF (cond) THEN ... ENDIF', 'Conditional block', 'IF then endif block', 'IF (${1:R[@R@]}${2|=,<>,>,<,>=,<=|}${3:1}) THEN ;\n@L1@  $0 ;\n@L2@  ENDIF ;'),
  stmt('if-else', 'IF (cond) THEN ... ELSE ... ENDIF', 'Conditional block with ELSE', 'IF then else endif block', 'IF (${1:R[@R@]}${2|=,<>,>,<,>=,<=|}${3:1}) THEN ;\n@L1@  $0 ;\n@L2@  ELSE ;\n@L3@   ;\n@L4@  ENDIF ;'),
  stmt('select', 'SELECT R[n]=...', 'Multi-way branch', 'SELECT case branch', 'SELECT ${1:R[@R@]}=${2:1},JMP LBL[${3:@JMP@}] ;\n@L1@         =${4:2},JMP LBL[${5:@JMP@}] ;\n@L2@         ELSE,JMP LBL[${6:@JMP@}] ;'),
  stmt('for', 'FOR R[n]=a TO b ... ENDFOR', 'Counted loop', 'FOR loop endfor', 'FOR ${1:R[@R@]}=${2:1} TO ${3:10} ;\n@L1@  $0 ;\n@L2@  ENDFOR ;'),
  stmt('wait-time', 'WAIT time(sec)', 'Wait a fixed time (the controller pads the value to a fixed width)', 'WAIT time delay sec', '${1|' + WAIT_TIMES.join(',') + '|} ;'),
  stmt('wait-cond', 'WAIT condition', 'Wait for a condition', 'WAIT condition input', 'WAIT ${1:DI[@R@]}=${2|ON,OFF|}    ;'),
  stmt('wait-timeout', 'WAIT condition TIMEOUT', 'Wait for a condition with a timeout label', 'WAIT condition timeout', 'WAIT ${1:DI[@R@]}=${2|ON,OFF|} TIMEOUT,LBL[${3:@JMP@}] ;'),
  stmt('call', 'CALL program', 'Call a program', 'CALL program', 'CALL ${1:PROGRAM}    ;'),
  stmt('call-args', 'CALL program(args)', 'Call a program with arguments', 'CALL program arguments', 'CALL ${1:PROGRAM}(${2:1}) ;'),
  stmt('run', 'RUN program', 'Run a program as a parallel task', 'RUN program task', 'RUN ${1:PROGRAM} ;'),
  stmt('comment', '! comment', 'Comment line', '! comment', '!${1:comment} ;'),
  stmt('message', 'MESSAGE[text]', 'Operator message', 'MESSAGE', 'MESSAGE[${1:text}] ;'),
  stmt('pause', 'PAUSE', 'Pause the program', 'PAUSE', 'PAUSE ;'),
  stmt('abort', 'ABORT', 'Abort the program', 'ABORT', 'ABORT ;'),

  stmt('v-find', "VISION RUN_FIND 'process'", 'iRVision: run a vision process', 'VISION RUN_FIND irvision', "VISION RUN_FIND '${1:PROCESS}' ;"),
  stmt('v-offset', "VISION GET_OFFSET 'process' VR[n] JMP LBL[n]", 'iRVision: read the offset, jump if nothing found', 'VISION GET_OFFSET irvision', "VISION GET_OFFSET '${1:PROCESS}' VR[${2:1}] JMP LBL[${3:@JMP@}] ;"),
  stmt('v-nfound', "VISION GET_NFOUND 'process' R[n]", 'iRVision: number of parts found', 'VISION GET_NFOUND irvision', "VISION GET_NFOUND '${1:PROCESS}' R[${2:@R@}] ;"),
  stmt('v-ref', "VISION SET_REFERENCE 'process'", 'iRVision: set the reference position', 'VISION SET_REFERENCE irvision', "VISION SET_REFERENCE '${1:PROCESS}' ;"),
  stmt('v-override', "VISION OVERRIDE 'process' EXPOSURE=R[n]", 'iRVision: override a vision parameter', 'VISION OVERRIDE irvision', "VISION OVERRIDE '${1:PROCESS}' EXPOSURE=R[${2:@R@}] ;"),
  stmt('v-calib', "VISION CAMERA_CALIB 'camera' Request=n", 'iRVision: camera calibration request', 'VISION CAMERA_CALIB irvision', "VISION CAMERA_CALIB '${1:CAMERA}' Request=${2:1} ;"),
];

/** What the document already has, used for defaults and index completion. */
export interface DocFacts {
  definedP: number[];
  usedP: number[];
  labels: number[];
  jumped: number[];
  rNames: Map<number, string>;
  /** Largest line number in /MN (0 if none) */
  lastLine: number;
}

export function scanDoc(text: string): DocFacts {
  const defined = new Set<number>();
  const used = new Set<number>();
  const labels = new Set<number>();
  const jumped = new Set<number>();
  const rNames = new Map<number, string>();
  let section = '';
  let lastLine = 0;
  for (const raw of text.split(/\r\n|\n|\r/)) {
    const sec = /^\/([A-Za-z]+)/.exec(raw);
    if (sec) {
      section = sec[1].toUpperCase();
      continue;
    }
    if (section === 'POS') {
      const m = /^P\[(\d+)/.exec(raw);
      if (m) defined.add(Number(m[1]));
    } else if (section === 'MN') {
      const ln = /^\s*(\d+):/.exec(raw);
      if (ln) lastLine = Math.max(lastLine, Number(ln[1]));
      for (const m of raw.matchAll(/(?<![A-Za-z_])P\[(\d+)/g)) used.add(Number(m[1]));
      for (const m of raw.matchAll(/(?<![A-Za-z_])LBL\[(\d+)(?:[:\]])/g)) (/JMP\s+LBL|,LBL|Skip,LBL/i.test(raw.slice(Math.max(0, m.index! - 5), m.index! + 4)) ? jumped : labels).add(Number(m[1]));
      for (const m of raw.matchAll(/(?<![A-Za-z_])R\[(\d+):([^\]]+)\]/g)) rNames.set(Number(m[1]), m[2]);
    }
  }
  return { definedP: [...defined].sort((a, b) => a - b), usedP: [...used].sort((a, b) => a - b), labels: [...labels].sort((a, b) => a - b), jumped: [...jumped].sort((a, b) => a - b), rNames, lastLine };
}

const nextFree = (taken: number[]) => (taken.length ? Math.max(...taken) + 1 : 1);

export function pad4(n: number): string {
  return String(n).padStart(4, ' ');
}

/** Substitute the @token@ defaults. `lineNo` is the number of the line being completed (omit if it has none). */
export function renderBody(def: SnippetDef, facts?: DocFacts, lineNo?: number): string {
  const nextP = nextFree([...(facts?.definedP ?? []), ...(facts?.usedP ?? [])]);
  const nextLbl = nextFree([...(facts?.labels ?? []), ...(facts?.jumped ?? [])]);
  const jmp = facts && facts.labels.length ? facts.labels[facts.labels.length - 1] : 1;
  return def.body
    .replace(/@P@/g, String(nextP))
    .replace(/@LBL@/g, String(nextLbl))
    .replace(/@JMP@/g, String(jmp))
    .replace(/@R@/g, '1')
    // following lines of a multi-line template: a numbered prefix when we know our own number, else none
    .replace(/@L(\d)@/g, (_, k) => (lineNo === undefined ? '' : `${pad4(lineNo + Number(k))}:`));
}

/** Resolve a snippet body to plain text: placeholders take their default, choices their `pick`-th option (default 0). */
export function expandSnippet(body: string, pick: (tabstop: number, options: string[]) => string = (_, o) => o[0]): string {
  return body
    .replace(/\$\{(\d+)\|([^}]*?)\|\}/g, (_, n, opts) => pick(Number(n), opts.split(',')))
    .replace(/\$\{\d+:([^}]*)\}/g, '$1')
    .replace(/\$\{?\d+\}?/g, '');
}

/** All combinations of choice values for one body (small: every body has at most four choice stops). */
export function choiceCombinations(body: string): string[] {
  const stops: Array<{ n: number; options: string[] }> = [];
  for (const m of body.matchAll(/\$\{(\d+)\|([^}]*?)\|\}/g)) stops.push({ n: Number(m[1]), options: m[2].split(',') });
  let combos: Array<Map<number, string>> = [new Map()];
  for (const s of stops) combos = combos.flatMap((c) => s.options.map((o) => new Map(c).set(s.n, o)));
  return combos.map((c) => expandSnippet(body, (n, o) => c.get(n) ?? o[0]));
}

/** Gap between "N:" and the statement: 0 for motion, 2 for everything else. */
export function gapAfterColon(def: SnippetDef): string {
  return def.motion ? '' : '  ';
}
