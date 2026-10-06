/PROG  GRP2_VAC	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Vacuum Grippr 2";
PROG_SIZE	= 564;
CREATE		= DATE 22-03-27  TIME 12:26:46;
MODIFIED	= DATE 22-06-23  TIME 09:08:42;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 19;
MEMORY_SIZE	= 1000;
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
   1:  !******************************* ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:  ! ;
   8:  !Unclamp gripper 2 ;
   9:  !No error checking: ;
  10:  !******************************* ;
  11:  LBL[1:Begin] ;
  12:  !******************************* ;
  13:   ;
  14:  RO[4:Blowoff ON 2]=OFF ;
  15:  RO[3:Vacuum ON 2]=ON ;
  16:   ;
  17:  !Wait gripper open delay ;
  18:  //WAIT R[146] ;
  19:  CALL GRPSTAT2    ;
/POS
/END
