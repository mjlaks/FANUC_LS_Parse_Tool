/PROG  GRP2_CKPART	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Chek Part Gripr1";
PROG_SIZE	= 1848;
CREATE		= DATE 22-07-11  TIME 10:12:46;
MODIFIED	= DATE 29-06-14  TIME 05:17:06;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 77;
MEMORY_SIZE	= 2316;
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
   7:  !This is for checking gripper ;
   8:  ! part present status ;
   9:  ! on Gripper 2 ;
  10:  ! to see if part is still held ;
  11:  ! ;
  12:  !******************************** ;
  13:   ;
  14:  !******************************* ;
  15:  LBL[1: Begin] ;
  16:  !******************************* ;
  17:   ;
  18:  !Check gripper status ;
  19:  CALL GRPSTAT2    ;
  20:   ;
  21:  IF R[148:Grip2_Status]=2,JMP LBL[999] ;
  22:   ;
  23:  Clear User Page    ;
  24:   ;
  25:  !******************************* ;
  26:  LBL[20:Part fault] ;
  27:  !******************************* ;
  28:  R[137:Gripper Num]=2    ;
  29:  !Part not detected in gripper 0 ;
  30:  !gripper closed - part pres ;
  31:  !sensor is off ;
  32:  GO[2:Application Fault]=6 ;
  33:  DO[58:TP Input Required]=ON ;
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
  48:  !1 Abort" ;
  49:  DO[58:TP Input Required]=OFF ;
  50:   ;
  51:  SELECT R[118]=1,JMP LBL[50] ;
  52:         =2,JMP LBL[60] ;
  53:         ELSE,JMP LBL[1] ;
  54:  !******************************* ;
  55:   ;
  56:  !******************************* ;
  57:  LBL[50:Abort] ;
  58:  !******************************* ;
  59:  R[20:Move home abort]=1    ;
  60:  OVERRIDE=10% ;
  61:  WAIT   2.00(sec) ;
  62:  JMP LBL[1000] ;
  63:   ;
  64:  !******************************* ;
  65:  LBL[60:Retest Vac] ;
  66:  !******************************* ;
  67:  GO[2:Application Fault]=0 ;
  68:  WAIT   1.00(sec) ;
  69:  JMP LBL[1] ;
  70:   ;
  71:  !******************************* ;
  72:  LBL[999] ;
  73:  !******************************* ;
  74:  GO[2:Application Fault]=0 ;
  75:  !******************************* ;
  76:  LBL[1000] ;
  77:  !******************************* ;
/POS
/END
