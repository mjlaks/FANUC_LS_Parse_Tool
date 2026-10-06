/PROG  RST_DATA	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Reset PLC Data";
PROG_SIZE	= 436;
CREATE		= DATE 22-03-13  TIME 11:57:00;
MODIFIED	= DATE 22-03-13  TIME 11:57:00;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 19;
MEMORY_SIZE	= 732;
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
   1:  !RESET all the data ;
   2:  R[50]=0    ;
   3:  R[51:Part Style]=0    ;
   4:  R[55]=0    ;
   5:  R[56:Grinder Ld PR]=0    ;
   6:  R[40]=0    ;
   7:   ;
   8:  DO[66:Outfeed New Ack]=OFF ;
   9:  DO[16:Gripper 2 Blow On]=OFF ;
  10:  DO[70:Spare]=OFF ;
  11:  GO[1]=0 ;
  12:  !GO[2:Part Style2]=0 ;
  13:  GO[3:Program Status]=0 ;
  14:  GO[4]=0 ;
  15:  GO[5]=0 ;
  16:  GO[6]=0 ;
  17:   ;
  18:  DO[15:Gripper 1 Blow On]=ON ;
  19:  WAIT (!DI[15:Gripper 2 Vacuum Off])    ;
/POS
/END
