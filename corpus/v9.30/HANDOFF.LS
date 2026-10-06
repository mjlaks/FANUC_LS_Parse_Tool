/PROG  HANDOFF
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Handoff";
PROG_SIZE	= 4185;
CREATE		= DATE 28-12-14  TIME 08:05:38;
MODIFIED	= DATE 29-07-28  TIME 02:55:10;
FILE_NAME	= LD_OUTFE;
VERSION		= 0;
LINE_COUNT	= 152;
MEMORY_SIZE	= 4673;
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
  11:  ! ;
  12:  !******************************* ;
  13:  LBL[1:Begin] ;
  14:  !******************************* ;
  15:  !Send process status ;
  16:  Program Status(5) ;
  17:   ;
  18:  !Safe move to drawer perch ;
  19:  CALL ROUTER(5) ;
  20:  UFRAME_NUM=1 ;
  21:  UTOOL_NUM=1 ;
  22:J PR[5:Handoff Perch] 50% CNT100    ;
  23:   ;
  24:  !******************************* ;
  25:  LBL[5:Wait] ;
  26:  !******************************* ;
  27:  !Wait for outfeed A ready ;
  28:   ;
  29:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  30:   ;
  31:  !******************************* ;
  32:  LBL[10:Check] ;
  33:  !******************************* ;
  34:  !Check gripper 1 open ;
  35:  CALL GRP1_CK_NO_PART    ;
  36:  IF R[20:Move home abort]=1,JMP LBL[200] ;
  37:  !Check gripper 2 part ;
  38:  CALL GRP2_CK_NO_PART    ;
  39:  IF R[20:Move home abort]=1,JMP LBL[200] ;
  40:   ;
  41:  !******************************* ;
  42:  LBL[15:Set offset PRs] ;
  43:  !******************************* ;
  44:  PR[31:Appr1_TO]=P[31]    ;
  45:  PR[32:Appr2_TO]=P[32]    ;
  46:  PR[36:Dprt1_TO]=P[36]    ;
  47:  PR[37:Dprt2_TO]=P[37]    ;
  48:  PR[38:Dprt3_TO]=P[38]    ;
  49:   ;
  50:   ;
  51:  !******************************* ;
  52:  LBL[100:Handoff] ;
  53:  !******************************* ;
  54:  !Reset cycle timer ;
  55:  TIMER[8]=RESET ;
  56:  !Start cycle timer ;
  57:  TIMER[8]=START ;
  58:   ;
  59:  !Safe move to perch ;
  60:  UFRAME_NUM=1 ;
  61:  UTOOL_NUM=1 ;
  62:J PR[5:Handoff Perch] 50% CNT100    ;
  63:   ;
  64:  UFRAME_NUM=5 ;
  65:  UTOOL_NUM=1 ;
  66:   ;
  67:  //J P[1] 35% CNT100    ;
  68:  //J P[2] 35% CNT100    ;
  69:J P[3] 35% CNT100    ;
  70:J P[4] 35% CNT100    ;
  71:   ;
  72:L PR[15:Exchange] 750mm/sec CNT50 Tool_Offset,PR[32:Appr2_TO]    ;
  73:L PR[15:Exchange] 300mm/sec CNT0    ;
  74:  !Send process status ;
  75:  Program Status(6) ;
  76:   ;
  77:  !Get part ;
  78:  LBL[103] ;
  79:  IF DI[97:Robot 1 At Exchange]=ON,JMP LBL[104] ;
  80:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  81:  JMP LBL[103] ;
  82:   ;
  83:  LBL[104] ;
  84:  CALL GRP2_VAC    ;
  85:  $WAITTMOUT=3000 ;
  86:  DO[99:Robot 2 Vac On]=ON ;
  87:  DO[98:Robot 2 Req Release]=ON ;
  88:  LBL[110] ;
  89:  WAIT DI[99:Robot 1 Blow ON]=ON OR DI[57:Request to Enter Cell]=ON    ;
  90:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  91:  IF DI[99:Robot 1 Blow ON]=OFF,JMP LBL[110] ;
  92:   ;
  93:  IF DI[41:Dry Run]=ON,JMP LBL[105] ;
  94:   ;
  95:  WAIT RI[3:Vacuum ON 2]=ON AND RI[4:Part Present 2]=ON TIMEOUT,LBL[105] ;
  96:   ;
  97:   ;
  98:  LBL[105] ;
  99:  CALL GRP2_CKPART    ;
 100:   ;
 101:  !Set payload ;
 102:  PAYLOAD[2:EOAT w/Part] ;
 103:   ;
 104:L PR[15:Exchange] 500mm/sec CNT75 Tool_Offset,PR[36:Dprt1_TO]    ;
 105:   ;
 106:  DO[98:Robot 2 Req Release]=OFF ;
 107:   ;
 108:  UFRAME_NUM=5 ;
 109:  UTOOL_NUM=1 ;
 110:   ;
 111:J P[5] 35% CNT100    ;
 112:J P[6] 35% CNT100    ;
 113:  //J P[7] 35% CNT60    ;
 114:  //J P[8] 35% CNT60    ;
 115:   ;
 116:  !******************************* ;
 117:  LBL[200:Handoff complete] ;
 118:  !******************************* ;
 119:  UFRAME_NUM=1 ;
 120:  UTOOL_NUM=1 ;
 121:   ;
 122:J PR[5:Handoff Perch] 50% CNT100    ;
 123:  !Send process status ;
 124:  Program Status(7) ;
 125:  !Stop cycle timer ;
 126:  TIMER[8]=STOP ;
 127:  R[8:Outfeed Ld Time]=TIMER[8]    ;
 128:  !Stop cycle timer ;
 129:  TIMER[1]=STOP ;
 130:  R[1:Cycletime]=TIMER[1]    ;
 131:  !Reset cycle timer ;
 132:  TIMER[1]=RESET ;
 133:  !Start cycle timer ;
 134:  TIMER[1]=START ;
 135:   ;
 136:  !******************************* ;
 137:  LBL[999:End] ;
 138:  !******************************* ;
 139:   ;
 140:  END ;
 141:   ;
 142:  !******************************* ;
 143:  !-------- Touchup area --------- ;
 144:  !******************************* ;
 145:  LBL[900:Touchup area] ;
 146:L P[31] 1mm/sec CNT0    ;
 147:L P[32] 1mm/sec CNT0    ;
 148:L P[33] 1mm/sec CNT0    ;
 149:L P[36] 1mm/sec CNT0    ;
 150:L P[37] 1mm/sec CNT0    ;
 151:L P[38] 1mm/sec CNT0    ;
 152:   ;
/POS
P[1]{
   GP1:
	UF : 5, UT : 1,	
	J1=     1.315 deg,	J2=     3.357 deg,	J3=   -55.303 deg,
	J4=      .777 deg,	J5=   -39.859 deg,	J6=     2.000 deg
};
P[2]{
   GP1:
	UF : 5, UT : 1,	
	J1=     1.315 deg,	J2=    53.652 deg,	J3=   -93.187 deg,
	J4=      .777 deg,	J5=    68.618 deg,	J6=     2.000 deg
};
P[3]{
   GP1:
	UF : 5, UT : 1,	
	J1=     1.315 deg,	J2=    82.319 deg,	J3=   -93.186 deg,
	J4=      .777 deg,	J5=    82.256 deg,	J6=     2.000 deg
};
P[4]{
   GP1:
	UF : 5, UT : 1,	
	J1=     1.315 deg,	J2=   138.143 deg,	J3=   -10.432 deg,
	J4=      .773 deg,	J5=   100.539 deg,	J6=     2.000 deg
};
P[5]{
   GP1:
	UF : 5, UT : 1,	
	J1=     1.315 deg,	J2=   138.143 deg,	J3=   -10.432 deg,
	J4=      .773 deg,	J5=   100.539 deg,	J6=     2.000 deg
};
P[6]{
   GP1:
	UF : 5, UT : 1,		CONFIG : 'F U T, 0, 0, 0',
	X =   576.022  mm,	Y =    14.297  mm,	Z =  -377.659  mm,
	W =   169.976 deg,	P =   -78.899 deg,	R =    12.310 deg
};
P[7]{
   GP1:
	UF : 5, UT : 1,		CONFIG : 'F U T, 0, 0, 0',
	X =   488.586  mm,	Y =    12.225  mm,	Z =  -193.776  mm,
	W =   175.738 deg,	P =   -65.359 deg,	R =     6.798 deg
};
P[8]{
   GP1:
	UF : 5, UT : 1,	
	J1=     1.315 deg,	J2=     3.357 deg,	J3=   -55.303 deg,
	J4=      .777 deg,	J5=   -39.859 deg,	J6=     2.000 deg
};
P[31]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =   -50.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[32]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =   -25.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[33]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =   -10.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[36]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =   -25.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[37]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =  -100.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[38]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =  -200.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
/END
