/PROG  HOME	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Move home";
PROG_SIZE	= 524;
CREATE		= DATE 22-03-26  TIME 13:11:20;
MODIFIED	= DATE 22-03-26  TIME 13:11:20;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 15;
MEMORY_SIZE	= 852;
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
/MN
   1:  !******************************** ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:   ;
   8:  !This program moves the robot ;
   9:  !Safely to home ;
  10:  !******************************** ;
  11:   ;
  12:  !************************ ;
  13:  CALL ROUTER(1) ;
  14:  !Turn on CLEAR Signals ;
  15:  CALL ALL_CLR    ;
/POS
/END
