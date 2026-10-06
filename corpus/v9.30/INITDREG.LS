/PROG  INITDREG
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Init Data Reg";
PROG_SIZE	= 714;
CREATE		= DATE 04-05-02  TIME 15:46:16;
MODIFIED	= DATE 04-05-02  TIME 15:46:16;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 20;
MEMORY_SIZE	= 1014;
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
   1:  !******************************** ;
   2:  !COMPANY ;
   3:   ;
   4:  !Macro program that sets the ;
   5:  !register(s) with the argument ;
   6:  !values - ONLY WHEN THE REG ;
   7:  !value is zero initially ;
   8:   ;
   9:  !Inputs: ;
  10:  !AR[1] - Register  number ;
  11:  !AR[2] - Register value ;
  12:  !AR[3] - Minimum value ;
  13:  !AR[4] - Maximum value ;
  14:   ;
  15:  !If current reg value is non- ;
  16:  !zero, then check for within ;
  17:  !limits - args 3 and 4 ;
  18:  !******************************** ;
  19:   ;
  20:  CALL INI_DREG(AR[1],AR[2],AR[3],AR[4]) ;
/POS
/END
