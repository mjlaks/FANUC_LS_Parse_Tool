/PROG  SHLSTART	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Pre Run Init";
PROG_SIZE	= 606;
CREATE		= DATE 22-03-26  TIME 13:12:16;
MODIFIED	= DATE 22-03-26  TIME 13:12:16;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 21;
MEMORY_SIZE	= 1026;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= *,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/MN
   1:  JMP LBL[1] ;
   2:  !******************************** ;
   3:  !COMPANY ;
   4:  !PROJECT 0000000 ;
   5:  !CUSTOMER Example Cell ;
   6:  ! ;
   7:  !Date: March 24, 2022 ;
   8:  ! ;
   9:  !NO MOTION ALLOWED ;
  10:  !This program is called ;
  11:  !Just before the main ;
  12:  !Sequence task is started ;
  13:  !******************************** ;
  14:  LBL[1: Begin] ;
  15:   ;
  16:  R[96]=0    ;
  17:  R[106:Skip Curpos]=0    ;
  18:  R[126:End Cycle Stop]=0    ;
  19:  R[125:Start from Abort]=1    ;
  20:  R[133]=0    ;
  21:  R[17]=0    ;
/POS
/END
