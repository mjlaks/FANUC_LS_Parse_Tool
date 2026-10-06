/PROG  SHLEXIT	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Cust Main Exit";
PROG_SIZE	= 636;
CREATE		= DATE 22-03-26  TIME 13:12:14;
MODIFIED	= DATE 22-03-26  TIME 13:12:14;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 21;
MEMORY_SIZE	= 1064;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 7;
DEFAULT_GROUP	= *,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/MN
   1:  JMP LBL[1] ;
   2:  !******************************* ;
   3:  !COMPANY ;
   4:  !PROJECT 0000000 ;
   5:  !CUSTOMER Example Cell ;
   6:  ! ;
   7:  !Date: March 24, 2022 ;
   8:   ;
   9:  !NO MOTION ALLOWED ;
  10:  !This program is called ;
  11:  !When the main sequence ;
  12:  !Task ends - either by ;
  13:  !completing or by getting ;
  14:  !aborted ;
  15:  !******************************* ;
  16:  LBL[1:Begin] ;
  17:  !Generic outputs off ;
  18:   ;
  19:  CALL RESET_IO    ;
  20:   ;
  21:  !RESET all the data ;
/POS
/END
