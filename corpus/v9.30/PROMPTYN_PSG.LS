/PROG  PROMPTYN_PSG	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Prompt Box Y N";
PROG_SIZE	= 350;
CREATE		= DATE 07-06-01  TIME 13:57:16;
MODIFIED	= DATE 15-02-19  TIME 17:02:50;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 10;
MEMORY_SIZE	= 822;
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
   1:  ! Y N Prompt box ;
   2:  ! AR[1] menu no ;
   3:  ! AR[2] answer reg ;
   4:  VENDOR Module-1-07 ;
   5:  LBL[1] ;
   6:  R[116]=0    ;
   7:  R[AR[2]]=2    ;
   8:  CALL MSGBOXYN(AR[1],AR[2]) ;
   9:  WAIT R[116]>0    ;
  10:  IF R[116]>1,JMP LBL[1] ;
/POS
/END
