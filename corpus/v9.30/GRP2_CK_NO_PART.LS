/PROG  GRP2_CK_NO_PART	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Chk Grip2 No Prt";
PROG_SIZE	= 2018;
CREATE		= DATE 22-03-27  TIME 12:25:34;
MODIFIED	= DATE 28-10-19  TIME 01:21:02;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 86;
MEMORY_SIZE	= 2458;
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
   8:  !Check for gripper 2 Unclamp ;
   9:  !and empty ;
  10:  ! ;
  11:  !R[148] for grip status ;
  12:  !0 = undefined ;
  13:  !1 = gripper is Unclamp ;
  14:  !2 = grippr clampd, part present ;
  15:  !******************************* ;
  16:  LBL[1:Begin] ;
  17:   ;
  18:  CALL GRPSTAT2    ;
  19:   ;
  20:  IF R[148:Grip2_Status]<>1,JMP LBL[500] ;
  21:   ;
  22:  !******************************* ;
  23:  LBL[100:End] ;
  24:  !******************************* ;
  25:  GO[2:Application Fault]=0 ;
  26:  END ;
  27:   ;
  28:   ;
  29:  !******************************* ;
  30:  !******* FAULT HANDLING ******** ;
  31:  !******************************* ;
  32:   ;
  33:  !******************************* ;
  34:  LBL[500] ;
  35:  !******************************* ;
  36:  Clear User Page    ;
  37:   ;
  38:  !******************************* ;
  39:  LBL[502:one grip] ;
  40:  !******************************* ;
  41:  R[137:Gripper Num]=2    ;
  42:   ;
  43:  ! Check for parts ;
  44:  !******************************* ;
  45:  LBL[510:Grip not unclamp] ;
  46:  !******************************* ;
  47:  !Gripper %s not Unclamp as expect ;
  48:  GO[2:Application Fault]=6 ;
  49:  DO[58:TP Input Required]=ON ;
  50:  WAIT    .50(sec) ;
  51:   ;
  52:  LBL[801] ;
  53:   ;
  54:  WAIT (DI[57:Request to Enter Cell] OR GI[2:App Fault Response]>0)    ;
  55:   ;
  56:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  57:   ;
  58:  IF GI[2:App Fault Response]<=0,JMP LBL[801] ;
  59:   ;
  60:  R[118]=GI[2:App Fault Response]    ;
  61:  !******************************* ;
  62:  !No part is detected in the ;
  63:  !gripper ;
  64:  !1 Abort" ;
  65:  DO[58:TP Input Required]=OFF ;
  66:   ;
  67:  SELECT R[118]=1,JMP LBL[50] ;
  68:         ELSE,JMP LBL[1] ;
  69:  !******************************* ;
  70:   ;
  71:  !******************************* ;
  72:  LBL[50:Abort] ;
  73:  !******************************* ;
  74:  CALL GRP2_UCLMP    ;
  75:  OVERRIDE=10% ;
  76:  R[20:Move home abort]=1    ;
  77:  GO[2:Application Fault]=0 ;
  78:  JMP LBL[999] ;
  79:   ;
  80:  !******************************* ;
  81:  LBL[999] ;
  82:  !******************************* ;
  83:  GO[2:Application Fault]=0 ;
  84:   ;
  85:  END ;
  86:   ;
/POS
/END
