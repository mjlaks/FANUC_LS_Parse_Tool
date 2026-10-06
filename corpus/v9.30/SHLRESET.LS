/PROG  SHLRESET	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Flt Reset Action";
PROG_SIZE	= 346;
CREATE		= DATE 22-03-26  TIME 13:12:16;
MODIFIED	= DATE 22-03-26  TIME 13:12:16;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 9;
MEMORY_SIZE	= 814;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 1,
      ABORT_REQUEST	= 3,
      PAUSE_REQUEST	= 7;
DEFAULT_GROUP	= *,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/MN
   1:  JMP LBL[1] ;
   2:  !COMPANY, INC ;
   3:  !NO MOTION ALLOWED ;
   4:  !This program is called ;
   5:  !When a Fault Reset ;
   6:  !Condition Occurs ;
   7:  LBL[1] ;
   8:  !Reset the fault outputs ;
   9:   ;
/POS
/END
