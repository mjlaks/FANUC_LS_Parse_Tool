/PROG  LIMTOVRD	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Limit Override";
PROG_SIZE	= 480;
CREATE		= DATE 04-01-27  TIME 11:06:06;
MODIFIED	= DATE 04-01-27  TIME 11:06:06;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 13;
MEMORY_SIZE	= 964;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 1200,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= *,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/MN
   1:  !******************************** ;
   2:  !COMPANY ;
   3:   ;
   4:  !Macro program that sets the ;
   5:  !speed override to AR[1] ;
   6:  !if greater ;
   7:   ;
   8:  !Inputs: ;
   9:  !AR[1] - Desired max Override ;
  10:  !******************************** ;
  11:  IF $MCR.$GENOVERRIDE<AR[1],JMP LBL[99] ;
  12:  OVERRIDE=AR[1] ;
  13:  LBL[99] ;
/POS
/END
