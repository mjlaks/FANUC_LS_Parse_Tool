/PROG  PART_AT_STARTUP1
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Part in grip str";
PROG_SIZE	= 1980;
CREATE		= DATE 22-03-26  TIME 13:12:02;
MODIFIED	= DATE 22-07-01  TIME 07:04:40;
FILE_NAME	= ALL_CLR;
VERSION		= 0;
LINE_COUNT	= 80;
MEMORY_SIZE	= 2428;
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
/MN
   1:  !******************************* ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:  ! ;
   8:  !This program is called when a ;
   9:  !part is in the gripper at the ;
  10:  !beginning of the sequence ;
  11:  !******************************** ;
  12:  LBL[1:Begin] ;
  13:   ;
  14:  CALL GRPSTAT1    ;
  15:   ;
  16:  IF R[143:Grip1_Status]<>1,JMP LBL[500] ;
  17:   ;
  18:  !******************************* ;
  19:  LBL[100:End] ;
  20:  !******************************* ;
  21:  GO[2:Application Fault]=0 ;
  22:  END ;
  23:   ;
  24:  !******************************* ;
  25:  !******* FAULT HANDLING ******** ;
  26:  !******************************* ;
  27:  LBL[500] ;
  28:  !******************************* ;
  29:  Clear User Page    ;
  30:   ;
  31:  !******************************* ;
  32:  LBL[502:one grip] ;
  33:  !******************************* ;
  34:  R[137:Gripper Num]=1    ;
  35:   ;
  36:  ! Check for parts ;
  37:  !******************************* ;
  38:  LBL[510:Grip not unclamp] ;
  39:  !******************************* ;
  40:  !Gripper 1 not unclamp as expect ;
  41:  GO[2:Application Fault]=7 ;
  42:  DO[57:Ok to Enter Cell]=ON ;
  43:  WAIT    .50(sec) ;
  44:   ;
  45:  WAIT GI[2:App Fault Response]>0    ;
  46:  R[118]=GI[2:App Fault Response]    ;
  47:  !******************************* ;
  48:  !No part is detected in the ;
  49:  !gripper ;
  50:  !1 ABORT ;
  51:  !2 Retest Vac ;
  52:  DO[57:Ok to Enter Cell]=OFF ;
  53:   ;
  54:  SELECT R[118]=1,JMP LBL[50] ;
  55:         =2,JMP LBL[70] ;
  56:         ELSE,JMP LBL[1] ;
  57:  !******************************* ;
  58:   ;
  59:  !******************************* ;
  60:  LBL[50:ABORT] ;
  61:  !******************************* ;
  62:  R[20:Move home abort]=1    ;
  63:  OVERRIDE=10% ;
  64:  WAIT   2.00(sec) ;
  65:  JMP LBL[999] ;
  66:   ;
  67:  !******************************* ;
  68:  LBL[70:Retest Vac] ;
  69:  !******************************* ;
  70:  GO[2:Application Fault]=0 ;
  71:  WAIT   1.50(sec) ;
  72:  JMP LBL[1] ;
  73:   ;
  74:  !******************************* ;
  75:  LBL[999] ;
  76:  !******************************* ;
  77:  GO[2:Application Fault]=0 ;
  78:   ;
  79:  END ;
  80:   ;
/POS
/END
