/PROG  NO_AUTO	  Macro
/ATTR
OWNER		= ASCBIN;
COMMENT		= "Cell NOT in Auto";
PROG_SIZE	= 528;
CREATE		= DATE 22-03-13  TIME 11:57:16;
MODIFIED	= DATE 22-03-13  TIME 11:57:16;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 15;
MEMORY_SIZE	= 972;
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
   2:  !******************************* ;
   3:  !COMPANY ;
   4:  !PSG Standard Module ;
   5:   ;
   6:  !Report loss of Auto ;
   7:  !******************************** ;
   8:  LBL[1] ;
   9:  Clear User Page    ;
  10:  macro_14('The Auto Input DI[1]is OFF.') ;
  11:  macro_14('The robot is waiting for AUTO') ;
  12:  macro_14('to resume the current Operation') ;
  13:  WAIT DI[11:Spare]=ON OR DI[10:Manual Mode]=ON OR DI[15:Gripper 2 Vacuum Off]=ON    ;
  14:  WAIT   1.00(sec) ;
  15:  Clear User Page    ;
/POS
/END
