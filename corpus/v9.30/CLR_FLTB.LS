/PROG  CLR_FLTB	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Clear Fault Bits";
PROG_SIZE	= 618;
CREATE		= DATE 22-03-13  TIME 11:22:04;
MODIFIED	= DATE 22-03-13  TIME 11:50:16;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 22;
MEMORY_SIZE	= 1042;
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
   4:  !VENDOR Module ;
   5:  !Clear fault outputs ;
   6:  ! (not status outputs) ;
   7:  !******************************** ;
   8:  LBL[1] ;
   9:  //DO[66:Outfeed New Ack]=OFF ;
  10:  //DO[67:Spare]=OFF ;
  11:  //!DO[198:Application Flt]=OFF ;
  12:  //DO[69:Spare]=OFF ;
  13:  //DO[70:Spare]=OFF ;
  14:  //DO[76:Spare]=OFF ;
  15:  //DO[77:Spare]=OFF ;
  16:  //DO[78:Spare]=OFF ;
  17:  //DO[79:Spare]=OFF ;
  18:  //DO[80:Spare]=OFF ;
  19:  //    ;
  20:  //!Clear application group faults ;
  21:  //GO[7]=0 ;
  22:  //CALL CLRTPERW    ;
/POS
/END
