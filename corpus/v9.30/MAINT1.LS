/PROG  MAINT1	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Maintenance 1";
PROG_SIZE	= 487;
CREATE		= DATE 22-03-26  TIME 13:11:48;
MODIFIED	= DATE 22-03-26  TIME 13:11:48;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 12;
MEMORY_SIZE	= 819;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= 1,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/APPL

AUTO_SINGULARITY_HEADER;
  ENABLE_SINGULARITY_AVOIDANCE   : TRUE;
/MN
   1:  !******************************* ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:  ! ;
   8:  !This program moves the robot ;
   9:  !safely to maintenance position ;
  10:  !******************************** ;
  11:   ;
  12:  CALL ROUTER(2) ;
/POS
/END
