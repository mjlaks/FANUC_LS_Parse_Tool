/PROG  DSP_WEBP	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Display web page";
PROG_SIZE	= 350;
CREATE		= DATE 03-06-17  TIME 17:15:18;
MODIFIED	= DATE 03-06-18  TIME 11:47:22;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 6;
MEMORY_SIZE	= 706;
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
   1:  !Displays a user-created web page ;
   2:  !located under MENUS Browser ;
   3:  !Valid AR[1] values are 1-11. ;
   4:  !1 = Browser menu (Not user) ;
   5:  !2-11 = User created web pages ;
   6:  CALL DSPWEBPG(AR[1]) ;
/POS
/END
