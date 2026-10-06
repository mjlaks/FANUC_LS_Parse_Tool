/PROG  SET_SREG	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Set String Reg";
PROG_SIZE	= 420;
CREATE		= DATE 22-03-13  TIME 11:57:00;
MODIFIED	= DATE 22-03-13  TIME 11:57:00;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 11;
MEMORY_SIZE	= 880;
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
   1:  JMP LBL[1] ;
   2:  !******************************* ;
   3:  !COMPANY, INC ;
   4:  ! ;
   5:  !Set value for string register ;
   6:  !AR[1] = STRING REG NUMBER ;
   7:  !AR[2] = STRING REG VALUE ;
   8:  !******************************* ;
   9:  LBL[1:Begin] ;
  10:   ;
  11:  SR[AR[1]]=AR[2]    ;
/POS
/END
