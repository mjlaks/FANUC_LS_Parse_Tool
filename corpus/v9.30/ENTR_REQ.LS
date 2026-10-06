/PROG  ENTR_REQ	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Entry Requested";
PROG_SIZE	= 762;
CREATE		= DATE 22-03-26  TIME 13:11:16;
MODIFIED	= DATE 22-03-26  TIME 13:11:16;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 22;
MEMORY_SIZE	= 1062;
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
   1:  !******************************* ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:  ! ;
   8:  !This program handles cell ;
   9:  !Request to enter input ;
  10:  ! ;
  11:  !*********************** ;
  12:  CALL USERCLR    ;
  13:  CALL LONGMESG(' ') ;
  14:  CALL LONGMESG('The PLC has Sent',' REQUEST TO ','ENTER the') ;
  15:  CALL LONGMESG('cell. The robot ','will Pause t','he cycle.') ;
  16:  CALL LONGMESG('DI[57] = ON, wai','ting for it to b','e OFF.') ;
  17:  DO[57:Ok to Enter Cell]=ON ;
  18:  !Clear any robot request ;
  19:  PAUSE ;
  20:  WAIT DI[57:Request to Enter Cell]=OFF    ;
  21:  CALL USERCLR    ;
  22:  DO[57:Ok to Enter Cell]=OFF ;
/POS
/END
