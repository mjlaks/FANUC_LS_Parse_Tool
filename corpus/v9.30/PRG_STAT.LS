/PROG  PRG_STAT	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Set Status Out";
PROG_SIZE	= 448;
CREATE		= DATE 22-03-26  TIME 13:12:02;
MODIFIED	= DATE 22-03-26  TIME 13:12:02;
FILE_NAME	= ALL_CLR;
VERSION		= 0;
LINE_COUNT	= 12;
MEMORY_SIZE	= 772;
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
/APPL
/MN
   1:  !******************************* ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:  ! ;
   8:  !This program sets GO[3] ;
   9:  !******************************** ;
  10:   ;
  11:  GO[3:Program Status]=AR[1] ;
  12:   ;
/POS
/END
