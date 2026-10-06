/PROG  RESET_IO	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 659;
CREATE		= DATE 22-03-26  TIME 13:12:24;
MODIFIED	= DATE 28-10-19  TIME 05:56:44;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 25;
MEMORY_SIZE	= 931;
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
   8:  !This program resets all ;
   9:  !process I/O ;
  10:  !******************************** ;
  11:   ;
  12:  !Turn off all complete signals ;
  13:  DO[47:Grinder 2 Unclamp Req]=OFF ;
  14:  DO[48:Grinder 2 Clamp Request]=OFF ;
  15:  DO[49:Spare]=OFF ;
  16:  DO[50:Spare]=OFF ;
  17:  DO[51:Audit Chute Loaded]=OFF ;
  18:  DO[52:Grinder 2 Unload Comp]=OFF ;
  19:  DO[53:Grinder 2 Load Comp]=OFF ;
  20:  DO[54:Outfeed Drawer Loaded]=OFF ;
  21:  DO[57:Ok to Enter Cell]=OFF ;
  22:  DO[58:TP Input Required]=OFF ;
  23:  DO[65:Outfeed Drawer Full]=OFF ;
  24:  DO[73:Vision Light ON Request]=OFF ;
  25:  GO[2:Application Fault]=0 ;
/POS
/END
