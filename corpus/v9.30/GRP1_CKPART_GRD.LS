/PROG  GRP1_CKPART_GRD	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Chek Part Gripr1";
PROG_SIZE	= 2186;
CREATE		= DATE 22-06-13  TIME 08:07:00;
MODIFIED	= DATE 28-10-19  TIME 08:52:36;
FILE_NAME	= GRP1_CKP;
VERSION		= 0;
LINE_COUNT	= 96;
MEMORY_SIZE	= 2714;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 1200,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= 1,*,*,*,*;
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
  30:   ;
  31:  R[83]=2    ;
  32:  R[82]=R[82]+1    ;
  33:  IF R[82]<=R[83],JMP LBL[70] ;
  34:  R[82]=0    ;
  35:   ;
  36:L PR[4:Grinder Perch] 500mm/sec FINE    ;
  37:   ;
  38:  !Part not detected in gripper ;
  39:  !gripper closed - part pres ;
  40:  !sensor is off ;
  41:  GO[2:Application Fault]=2 ;
  42:  WAIT    .50(sec) ;
  43:   ;
  44:  LBL[801] ;
  45:   ;
  46:  WAIT (DI[57:Request to Enter Cell] OR GI[2:App Fault Response]>0)    ;
  47:   ;
  48:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  49:   ;
  50:  IF GI[2:App Fault Response]<=0,JMP LBL[801] ;
  51:   ;
  52:  R[118]=GI[2:App Fault Response]    ;
  53:  !******************************* ;
  54:  !No part is detected in the ;
  55:  !gripper ;
  56:  DO[58:TP Input Required]=ON ;
  57:  !1 Abort" ;
  58:  !5 Retry Pick ;
  59:  DO[58:TP Input Required]=OFF ;
  60:   ;
  61:  SELECT R[118]=1,JMP LBL[50] ;
  62:         =3,JMP LBL[60] ;
  63:         =5,JMP LBL[70] ;
  64:         ELSE,JMP LBL[1] ;
  65:  !******************************* ;
  66:   ;
  67:  !******************************* ;
  68:  LBL[50:Abort] ;
  69:  !******************************* ;
  70:  DO[39:RETRY PICK]=OFF ;
  71:  R[20:Move home abort]=1    ;
  72:  OVERRIDE=10% ;
  73:  WAIT   2.00(sec) ;
  74:  JMP LBL[999] ;
  75:   ;
  76:  !******************************* ;
  77:  LBL[60:Continue] ;
  78:  !******************************* ;
  79:  F[10]=(ON) ;
  80:  DO[39:RETRY PICK]=OFF ;
  81:  WAIT   2.00(sec) ;
  82:  JMP LBL[999] ;
  83:   ;
  84:  !******************************* ;
  85:  LBL[70:Retry Pick] ;
  86:  !******************************* ;
  87:  GO[2:Application Fault]=0 ;
  88:  DO[39:RETRY PICK]=ON ;
  89:  JMP LBL[999] ;
  90:  CALL LUL_GRINDER    ;
  91:  JMP LBL[1] ;
  92:   ;
  93:  !******************************* ;
  94:  LBL[999] ;
  95:  !******************************* ;
  96:  GO[2:Application Fault]=0 ;
/POS
/END
