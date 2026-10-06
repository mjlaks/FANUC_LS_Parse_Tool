/PROG  GRP1_CKPART	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Chek Part Gripr1";
PROG_SIZE	= 1764;
CREATE		= DATE 22-03-26  TIME 13:11:22;
MODIFIED	= DATE 28-10-19  TIME 01:20:34;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 75;
MEMORY_SIZE	= 2240;
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
   8:  !This is for checking gripper ;
   9:  ! part present status ;
  10:  ! on gripper 1 ;
  11:  ! to see if part is still held ;
  12:  ! ;
  13:  !******************************** ;
  14:   ;
  15:  !******************************* ;
  16:  LBL[1: Begin] ;
  17:  !******************************* ;
  18:   ;
  19:  !Check gripper status ;
  20:  CALL GRPSTAT1    ;
  21:   ;
  22:  IF R[143:Grip1_Status]=2,JMP LBL[999] ;
  23:   ;
  24:  Clear User Page    ;
  25:   ;
  26:  !******************************* ;
  27:  LBL[20:Part fault] ;
  28:  !******************************* ;
  29:  R[137:Gripper Num]=1    ;
  30:  !Part not detected in gripper ;
  31:  !gripper closed - part pres ;
  32:  !sensor is off ;
  33:  GO[2:Application Fault]=6 ;
  34:  WAIT    .50(sec) ;
  35:   ;
  36:  LBL[801] ;
  37:   ;
  38:  WAIT (DI[57:Request to Enter Cell] OR GI[2:App Fault Response]>0)    ;
  39:   ;
  40:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  41:   ;
  42:  IF GI[2:App Fault Response]<=0,JMP LBL[801] ;
  43:   ;
  44:  R[118]=GI[2:App Fault Response]    ;
  45:  !******************************* ;
  46:  !No part is detected in the ;
  47:  !gripper ;
  48:  DO[58:TP Input Required]=ON ;
  49:  !1 Abort" ;
  50:  DO[58:TP Input Required]=OFF ;
  51:   ;
  52:  SELECT R[118]=1,JMP LBL[50] ;
  53:         =2,JMP LBL[60] ;
  54:         ELSE,JMP LBL[1] ;
  55:  !******************************* ;
  56:   ;
  57:  !******************************* ;
  58:  LBL[50:Abort] ;
  59:  !******************************* ;
  60:  R[20:Move home abort]=1    ;
  61:  OVERRIDE=10% ;
  62:  WAIT   2.00(sec) ;
  63:  JMP LBL[999] ;
  64:   ;
  65:  !******************************* ;
  66:  LBL[60:Retest Vac] ;
  67:  !******************************* ;
  68:  GO[2:Application Fault]=0 ;
  69:  WAIT   1.00(sec) ;
  70:  JMP LBL[1] ;
  71:   ;
  72:  !******************************* ;
  73:  LBL[999] ;
  74:  !******************************* ;
  75:  GO[2:Application Fault]=0 ;
/POS
/END
