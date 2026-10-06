/PROG  TOPERCH	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "SAFE TO PERCH";
PROG_SIZE	= 1505;
CREATE		= DATE 22-03-26  TIME 13:12:20;
MODIFIED	= DATE 22-03-26  TIME 13:12:20;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 65;
MEMORY_SIZE	= 2045;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 2000,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= 1,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/APPL

AUTO_SINGULARITY_HEADER;
  ENABLE_SINGULARITY_AVOIDANCE   : TRUE;
/MN
   1:  JMP LBL[1] ;
   2:  !******************************** ;
   3:  !COMPANY ;
   4:  !PROJECT 0000000 ;
   5:  !CUSTOMER Example Cell ;
   6:  ! ;
   7:  !Date: March 24, 2022 ;
   8:   ;
   9:  !This program moves the robot ;
  10:  !Safely to nearest perch ;
  11:  !rail does not move ;
  12:  !******************************** ;
  13:  LBL[1] ;
  14:   ;
  15:  UFRAME_NUM[GP1]=R[135:Nilp Uframe] ;
  16:  UTOOL_NUM[GP1]=R[136:Base Utool] ;
  17:  !Set R[101] for Number of Perches ;
  18:   ;
  19:  !Execute recovery path ;
  20:  !if possible ;
  21:  CALL REC_PATH    ;
  22:   ;
  23:  UFRAME_NUM=R[135:Nilp Uframe] ;
  24:  UTOOL_NUM=R[136:Base Utool] ;
  25:   ;
  26:  !Skip get_pos if needed ;
  27:  IF R[106:Skip Curpos]>0,JMP LBL[4] ;
  28:  !Compare curpos with PR[s] to ;
  29:  !set cur Location ID R[104] ;
  30:  !First wait for robot to stop ;
  31:  WAIT    .10(sec) ;
  32:  CALL GET_POS    ;
  33:  !Get pos considers the ;
  34:  !rail for posn # returned ;
  35:  LBL[4] ;
  36:   ;
  37:  IF R[104:Curr Perch PR#]=0,JMP LBL[50] ;
  38:   ;
  39:  IF R[104:Curr Perch PR#]=12,JMP LBL[60] ;
  40:   ;
  41:   ;
  42:  !******************************** ;
  43:  LBL[5:mv perch] ;
  44:J PR[R[104]] 40% CNT1    ;
  45:  JMP LBL[999] ;
  46:   ;
  47:  LBL[50] ;
  48:  !Not close to known position ;
  49:  DO[262]=ON ;
  50:  CALL GO_PERCH    ;
  51:   ;
  52:  DO[262]=OFF ;
  53:  !GoPerch sets current perch ;
  54:  !in R[104] ;
  55:  IF R[104:Curr Perch PR#]>0,JMP LBL[5] ;
  56:  DO[262]=ON ;
  57:  CALL PROMPTOK_PSG('HOME_NO_GO') ;
  58:  ABORT ;
  59:   ;
  60:  LBL[60:From PR12] ;
  61:  R[103:Dest Perch PR#]=10    ;
  62:  CALL ROUTER    ;
  63:  JMP LBL[999] ;
  64:   ;
  65:  LBL[999] ;
/POS
/END
