/PROG  MV_Z_UP	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Move Up World Z";
PROG_SIZE	= 409;
CREATE		= DATE 22-03-13  TIME 11:56:58;
MODIFIED	= DATE 22-03-13  TIME 11:56:58;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 12;
MEMORY_SIZE	= 865;
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
   1:  !Set correct tools and frames ;
   2:  UFRAME_NUM=R[135:Nilp Uframe] ;
   3:  UTOOL_NUM=R[136:Base Utool] ;
   4:   ;
   5:  !Get current position of robot ;
   6:  PR[65:Temp Z-up]=LPOS    ;
   7:  PR[65,3:Temp Z-up]=PR[65,3:Temp Z-up]+25    ;
   8:   ;
   9:  !Move up until F3 released ;
  10:  SKIP CONDITION R[110]=0    ;
  11:L PR[65:Temp Z-up] 500mm/sec CNT100 Skip,LBL[1]    ;
  12:  LBL[1] ;
/POS
/END
