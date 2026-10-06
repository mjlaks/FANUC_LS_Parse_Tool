/PROG  ALL_CLR	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "ALL CLRS ON";
PROG_SIZE	= 658;
CREATE		= DATE 22-03-26  TIME 13:11:16;
MODIFIED	= DATE 22-03-27  TIME 08:53:48;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 26;
MEMORY_SIZE	= 926;
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
   8:  !This program turns ON all clear ;
   9:  !Signals when at home or perch ;
  10:  !******************************** ;
  11:   ;
  12:  !Turn ON all clear signals ;
  13:  DO[35:Clear of Infeed]=ON ;
  14:  DO[36:Clear of Grinder]=ON ;
  15:  DO[37:Clear of Outfeed]=ON ;
  16:  DO[47:Grinder 2 Unclamp Req]=OFF ;
  17:  DO[48:Grinder 2 Clamp Request]=OFF ;
  18:  DO[49:Spare]=OFF ;
  19:  DO[50:Spare]=OFF ;
  20:  DO[51:Audit Chute Loaded]=OFF ;
  21:  DO[52:Grinder 2 Unload Comp]=OFF ;
  22:  DO[53:Grinder 2 Load Comp]=OFF ;
  23:  DO[58:TP Input Required]=OFF ;
  24:  GO[2:Application Fault]=0 ;
  25:  DO[57:Ok to Enter Cell]=OFF ;
  26:   ;
/POS
/END
