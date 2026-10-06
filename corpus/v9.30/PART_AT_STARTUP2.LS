/PROG  PART_AT_STARTUP2
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Part in grip str";
PROG_SIZE	= 1898;
CREATE		= DATE 22-03-26  TIME 13:11:14;
MODIFIED	= DATE 28-10-19  TIME 05:56:26;
FILE_NAME	= PART_AT_;
VERSION		= 0;
LINE_COUNT	= 78;
MEMORY_SIZE	= 2354;
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
  14:  CALL GRPSTAT2    ;
  15:   ;
  16:  IF R[148:Grip2_Status]<>1,JMP LBL[500] ;
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
  31:  R[137:Gripper Num]=2    ;
  32:   ;
  33:  ! Check for parts ;
  34:  !******************************* ;
  35:  LBL[510:Grip Not Unclamp] ;
  36:  !******************************* ;
  37:  !Gripper 2 not Unclamp as expect ;
  38:  GO[2:Application Fault]=8 ;
  39:  DO[57:Ok to Enter Cell]=ON ;
  40:  WAIT    .50(sec) ;
  41:   ;
  42:  WAIT GI[2:App Fault Response]>0    ;
  43:  R[118]=GI[2:App Fault Response]    ;
  44:  !******************************* ;
  45:  !No part is detected in the ;
  46:  !gripper ;
  47:  !1 ABORT ;
  48:  !2 Retest Vac ;
  49:  DO[57:Ok to Enter Cell]=OFF ;
  50:   ;
  51:  SELECT R[118]=1,JMP LBL[50] ;
  52:         =2,JMP LBL[70] ;
  53:         ELSE,JMP LBL[1] ;
  54:  !******************************* ;
  55:   ;
  56:  !******************************* ;
  57:  LBL[50:ABORT] ;
  58:  !******************************* ;
  59:  R[20:Move home abort]=1    ;
  60:  OVERRIDE=10% ;
  61:  WAIT   2.00(sec) ;
  62:  JMP LBL[999] ;
  63:   ;
  64:  !******************************* ;
  65:  LBL[70:Retest Vac] ;
  66:  !******************************* ;
  67:  GO[2:Application Fault]=0 ;
  68:  RO[3:Vacuum ON 2]=OFF ;
  69:  WAIT   1.50(sec) ;
  70:  JMP LBL[1] ;
  71:   ;
  72:  !******************************* ;
  73:  LBL[999] ;
  74:  !******************************* ;
  75:  GO[2:Application Fault]=0 ;
  76:   ;
  77:  END ;
  78:   ;
/POS
/END
