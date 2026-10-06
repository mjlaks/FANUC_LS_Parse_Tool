/PROG  LD_OUTFEED
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Load Outfeed";
PROG_SIZE	= 3877;
CREATE		= DATE 29-07-24  TIME 08:20:38;
MODIFIED	= DATE 30-07-18  TIME 03:23:58;
FILE_NAME	= UL_INFEE;
VERSION		= 0;
LINE_COUNT	= 148;
MEMORY_SIZE	= 4357;
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
   1:  JMP LBL[1] ;
   2:  !******************************* ;
   3:  !COMPANY ;
   4:  !PROJECT 0000000 ;
   5:  !CUSTOMER Example Cell ;
   6:  ! ;
   7:  !Date: March 24, 2022 ;
   8:  ! ;
   9:  !Load parts to the ;
  10:  !the outfeed ;
  11:   ;
  12:  !******************************* ;
  13:  LBL[1:Begin] ;
  14:  !******************************* ;
  15:  !Send process status ;
  16:  Program Status(17) ;
  17:   ;
  18:  !Safe move to drawer perch ;
  19:  WAIT DI[54:Ok to Load Outfeed Drawe]=ON    ;
  20:  CALL ROUTER(3) ;
  21:  UFRAME_NUM=1 ;
  22:  UTOOL_NUM=1 ;
  23:J PR[3:Outfeed Perch] 50% CNT100    ;
  24:  !******************************* ;
  25:  LBL[5:Wait] ;
  26:  !******************************* ;
  27:  IF (R[49:Curr Outfd Cnt]>R[47:Max Outfd Count]) THEN ;
  28:  WAIT DI[65:Outfeed Drawer New Mag]=ON    ;
  29:  ENDIF ;
  30:   ;
  31:  IF (DI[65:Outfeed Drawer New Mag]) THEN ;
  32:  R[49:Curr Outfd Cnt]=1    ;
  33:  DO[66:Outfeed New Ack]=PULSE,1.0sec ;
  34:  ENDIF ;
  35:   ;
  36:  !Wait for outfeed A ready ;
  37:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  38:   ;
  39:  IF DI[54:Ok to Load Outfeed Drawe]=ON,JMP LBL[10] ;
  40:   ;
  41:  JMP LBL[5] ;
  42:  !******************************* ;
  43:  LBL[10:Check] ;
  44:  !******************************* ;
  45:  !Check gripper 1 ;
  46:  CALL GRP1_CKPART    ;
  47:  IF R[20:Move home abort]=1,JMP LBL[200] ;
  48:  !Check gripper 2 ;
  49:  CALL GRP2_CK_NO_PART    ;
  50:  IF R[20:Move home abort]=1,JMP LBL[200] ;
  51:   ;
  52:  !******************************* ;
  53:  LBL[15:Set offset PRs] ;
  54:  !******************************* ;
  55:  IF (R[124:Dry Run]=1),R[49:Curr Outfd Cnt]=(30) ;
  56:  CALL SET_SLOT_OUT    ;
  57:  PR[31:Appr1_TO]=P[31]    ;
  58:  PR[32:Appr2_TO]=P[32]    ;
  59:  PR[36:Dprt1_TO]=P[36]    ;
  60:  PR[37:Dprt2_TO]=P[37]    ;
  61:  PR[38:Dprt3_TO]=P[38]    ;
  62:  PR[24:Temp Load]=PR[116:Outfeed Ld]    ;
  63:  PR[24,1:Temp Load]=PR[24,1:Temp Load]+R[42:Temp Outfeed X]    ;
  64:  PR[24,2:Temp Load]=PR[24,2:Temp Load]+R[43:Temp Outfeed Y]    ;
  65:   ;
  66:  CALL OUTFEED_OFFSET    ;
  67:   ;
  68:  !******************************* ;
  69:  LBL[100:Load A] ;
  70:  !******************************* ;
  71:  !Reset cycle timer ;
  72:  TIMER[8]=RESET ;
  73:  !Start cycle timer ;
  74:  TIMER[8]=START ;
  75:   ;
  76:  !******************************* ;
  77:  LBL[150:Place part G2] ;
  78:  !******************************* ;
  79:   ;
  80:  !Safe move to perch ;
  81:  UFRAME_NUM=1 ;
  82:  UTOOL_NUM=1 ;
  83:J PR[3:Outfeed Perch] 50% CNT100    ;
  84:  !Send process status ;
  85:  Program Status(18) ;
  86:   ;
  87:  UFRAME_NUM=2 ;
  88:  UTOOL_NUM=3 ;
  89:   ;
  90:  DO[37:Clear of Outfeed]=OFF ;
  91:   ;
  92:L PR[24:Temp Load] 300mm/sec CNT0 Tool_Offset,PR[38:Dprt3_TO]    ;
  93:L PR[24:Temp Load] 250mm/sec CNT50 Tool_Offset,PR[32:Appr2_TO]    ;
  94:L PR[24:Temp Load] 300mm/sec CNT0    ;
  95:  !Drop part ;
  96:  CALL GRP1_BLOWOFF    ;
  97:  !Set payload ;
  98:  PAYLOAD[1:Empty EOAT] ;
  99:   ;
 100:  R[49:Curr Outfd Cnt]=R[49:Curr Outfd Cnt]+1    ;
 101:  DO[54:Outfeed Drawer Loaded]=PULSE,1.0sec ;
 102:   ;
 103:L PR[24:Temp Load] 250mm/sec CNT75 Tool_Offset,PR[36:Dprt1_TO]    ;
 104:   ;
 105:L PR[24:Temp Load] max_speed CNT0 Tool_Offset,PR[38:Dprt3_TO]    ;
 106:   ;
 107:  !******************************* ;
 108:  LBL[200:Place complete] ;
 109:  !******************************* ;
 110:  UFRAME_NUM=1 ;
 111:  UTOOL_NUM=1 ;
 112:   ;
 113:J PR[3:Outfeed Perch] 15% CNT55    ;
 114:  DO[37:Clear of Outfeed]=ON ;
 115:   ;
 116:  !Send process status ;
 117:  Program Status(19) ;
 118:  !Stop cycle timer ;
 119:  TIMER[8]=STOP ;
 120:  R[8:Outfeed Ld Time]=TIMER[8]    ;
 121:  !Stop cycle timer ;
 122:  TIMER[1]=STOP ;
 123:  R[1:Cycletime]=TIMER[1]    ;
 124:  !Reset cycle timer ;
 125:  TIMER[1]=RESET ;
 126:  !Start cycle timer ;
 127:  TIMER[1]=START ;
 128:  R[15:Cycle Count]=R[15:Cycle Count]+1    ;
 129:   ;
 130:  CALL ROUTER(1) ;
 131:   ;
 132:  !******************************* ;
 133:  LBL[999:End] ;
 134:  !******************************* ;
 135:   ;
 136:  END ;
 137:   ;
 138:  !******************************* ;
 139:  !-------- Touchup area --------- ;
 140:  !******************************* ;
 141:  LBL[900:Touchup area] ;
 142:L P[31] 1mm/sec CNT0    ;
 143:L P[32] 1mm/sec CNT0    ;
 144:L P[33] 1mm/sec CNT0    ;
 145:L P[36] 1mm/sec CNT0    ;
 146:L P[37] 1mm/sec CNT0    ;
 147:L P[38] 1mm/sec CNT0    ;
 148:   ;
/POS
P[31]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =  -100.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[32]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =   -25.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[33]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =   -10.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[36]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =   -25.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[37]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =  -100.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[38]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =   -75.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
/END
