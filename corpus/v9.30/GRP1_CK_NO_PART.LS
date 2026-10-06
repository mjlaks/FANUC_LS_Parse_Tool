/PROG  GRP1_CK_NO_PART	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Chk Grip1 No Prt";
PROG_SIZE	= 2160;
CREATE		= DATE 22-03-27  TIME 12:23:26;
MODIFIED	= DATE 28-10-19  TIME 01:20:46;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 93;
MEMORY_SIZE	= 2564;
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
   8:  !Check for gripper 1 Unclamp ;
   9:  !and empty ;
  10:  ! ;
  11:  !R[143] for grip status ;
  12:  !0 = undefined ;
  13:  !1 = gripper is Unclamp ;
  14:  !2 = grippr clampd, part present ;
  15:  !******************************* ;
  16:  LBL[1:Begin] ;
  17:   ;
  18:  CALL GRPSTAT1    ;
  19:   ;
  20:  IF R[143:Grip1_Status]<>1,JMP LBL[500] ;
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
  32:  LBL[500] ;
  33:  !******************************* ;
  34:  Clear User Page    ;
  35:   ;
  36:  !******************************* ;
  37:  LBL[502:one grip] ;
  38:  !******************************* ;
  39:  R[137:Gripper Num]=1    ;
  40:   ;
  41:  ! Check for parts ;
  42:  !******************************* ;
  43:  LBL[510:Grip not unclamp] ;
  44:  !******************************* ;
  45:  !Gripper 1 not unclamp as expect ;
  46:  GO[2:Application Fault]=6 ;
  47:  DO[58:TP Input Required]=ON ;
  48:  WAIT    .50(sec) ;
  49:   ;
  50:  LBL[801] ;
  51:   ;
  52:  WAIT (DI[57:Request to Enter Cell] OR GI[2:App Fault Response]>0)    ;
  53:   ;
  54:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  55:   ;
  56:  IF GI[2:App Fault Response]<=0,JMP LBL[801] ;
  57:   ;
  58:  R[118]=GI[2:App Fault Response]    ;
  59:  !******************************* ;
  60:  !No part is detected in the ;
  61:  !gripper ;
  62:  !1 Abort" ;
  63:  DO[58:TP Input Required]=OFF ;
  64:   ;
  65:  SELECT R[118]=1,JMP LBL[50] ;
  66:         =2,JMP LBL[70] ;
  67:         ELSE,JMP LBL[1] ;
  68:  !******************************* ;
  69:   ;
  70:  !******************************* ;
  71:  LBL[50:Abort] ;
  72:  !******************************* ;
  73:  OVERRIDE=10% ;
  74:  R[20:Move home abort]=1    ;
  75:  GO[2:Application Fault]=0 ;
  76:  JMP LBL[999] ;
  77:   ;
  78:  !******************************* ;
  79:  LBL[70:Retest Vac] ;
  80:  !******************************* ;
  81:  GO[2:Application Fault]=0 ;
  82:  JMP LBL[1] ;
  83:   ;
  84:  !******************************* ;
  85:   ;
  86:   ;
  87:  !******************************* ;
  88:  LBL[999] ;
  89:  !******************************* ;
  90:  GO[2:Application Fault]=0 ;
  91:   ;
  92:  END ;
  93:   ;
/POS
/END
