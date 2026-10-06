/PROG  LD_AUDIT
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Load audit";
PROG_SIZE	= 3737;
CREATE		= DATE 29-07-24  TIME 08:19:26;
MODIFIED	= DATE 30-09-27  TIME 08:07:48;
FILE_NAME	= LD_OUTFE;
VERSION		= 0;
LINE_COUNT	= 137;
MEMORY_SIZE	= 4245;
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
  15:   ;
  16:  !Safe move to drawer perch ;
  17:  CALL ROUTER(7) ;
  18:  UFRAME_NUM=1 ;
  19:  UTOOL_NUM=1 ;
  20:J PR[7:Audit] 50% CNT100    ;
  21:  !Send process status ;
  22:  Program Status(55) ;
  23:   ;
  24:  !******************************* ;
  25:  LBL[5:Wait] ;
  26:  !******************************* ;
  27:   ;
  28:  !Wait for outfeed A ready ;
  29:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  30:   ;
  31:  IF DI[55:Ok to Load Audit Chute]=ON,JMP LBL[10] ;
  32:   ;
  33:  IF DI[33:Audit Part Request]=OFF,JMP LBL[999] ;
  34:   ;
  35:  JMP LBL[5] ;
  36:   ;
  37:  !******************************* ;
  38:  LBL[10:Check] ;
  39:  !******************************* ;
  40:  IF (DI[41:Dry Run]),JMP LBL[15] ;
  41:  !Check gripper 1 open ;
  42:  CALL GRP1_CKPART    ;
  43:  IF R[20:Move home abort]=1,JMP LBL[200] ;
  44:  !Check gripper 2 part ;
  45:  CALL GRP2_CK_NO_PART    ;
  46:  IF R[20:Move home abort]=1,JMP LBL[200] ;
  47:   ;
  48:  !******************************* ;
  49:  LBL[15:Set offset PRs] ;
  50:  !******************************* ;
  51:  PR[31:Appr1_TO]=P[31]    ;
  52:  PR[32:Appr2_TO]=P[32]    ;
  53:  PR[36:Dprt1_TO]=P[36]    ;
  54:  PR[37:Dprt2_TO]=P[37]    ;
  55:  PR[38:Dprt3_TO]=P[38]    ;
  56:   ;
  57:  !******************************* ;
  58:  LBL[100:Load A] ;
  59:  !******************************* ;
  60:  !Reset cycle timer ;
  61:  TIMER[8]=RESET ;
  62:  !Start cycle timer ;
  63:  TIMER[8]=START ;
  64:   ;
  65:  !******************************* ;
  66:  LBL[150:Place part G2] ;
  67:  !******************************* ;
  68:   ;
  69:  !Safe move to perch ;
  70:  UFRAME_NUM=1 ;
  71:  UTOOL_NUM=1 ;
  72:J PR[7:Audit] 50% CNT100    ;
  73:   ;
  74:  !Send process status ;
  75:  Program Status(56) ;
  76:   ;
  77:  UFRAME_NUM=4 ;
  78:  UTOOL_NUM=2 ;
  79:   ;
  80:  DO[35:Clear of Infeed]=OFF ;
  81:   ;
  82:L P[2:Retreat] 150mm/sec FINE    ;
  83:L P[1:LOAD AUDIT] 100mm/sec FINE    ;
  84:   ;
  85:  !Drop part ;
  86:  CALL GRP1_BLOWOFF    ;
  87:  !Set payload ;
  88:  PAYLOAD[1:Empty EOAT] ;
  89:  DO[51:Audit Chute Loaded]=PULSE,1.5sec ;
  90:   ;
  91:L P[2:Retreat] 150mm/sec CNT100    ;
  92:   ;
  93:  !******************************* ;
  94:  LBL[200:Place complete] ;
  95:  !******************************* ;
  96:  UFRAME_NUM=1 ;
  97:  UTOOL_NUM=1 ;
  98:   ;
  99:J PR[7:Audit] 15% CNT100    ;
 100:  DO[35:Clear of Infeed]=ON ;
 101:   ;
 102:  WAIT DI[34:Audit Wait]=OFF    ;
 103:   ;
 104:  WAIT   2.00(sec) ;
 105:   ;
 106:  !Send process status ;
 107:  Program Status(57) ;
 108:  !Stop cycle timer ;
 109:  TIMER[8]=STOP ;
 110:  R[7:Audit Ld Time]=TIMER[8]    ;
 111:  !Stop cycle timer ;
 112:  TIMER[1]=STOP ;
 113:  R[1:Cycletime]=TIMER[1]    ;
 114:  !Reset cycle timer ;
 115:  TIMER[1]=RESET ;
 116:  !Start cycle timer ;
 117:  TIMER[1]=START ;
 118:  R[16:Audit Count]=R[16:Audit Count]+1    ;
 119:   ;
 120:  CALL ROUTER(1) ;
 121:  !******************************* ;
 122:  LBL[999:End] ;
 123:  !******************************* ;
 124:   ;
 125:  END ;
 126:   ;
 127:  !******************************* ;
 128:  !-------- Touchup area --------- ;
 129:  !******************************* ;
 130:  LBL[900:Touchup area] ;
 131:L P[31] 1mm/sec CNT0    ;
 132:L P[32] 1mm/sec CNT0    ;
 133:L P[33] 1mm/sec CNT0    ;
 134:L P[36] 1mm/sec CNT0    ;
 135:L P[37] 1mm/sec CNT0    ;
 136:L P[38] 1mm/sec CNT0    ;
 137:   ;
/POS
P[1:"LOAD AUDIT"]{
   GP1:
	UF : 4, UT : 2,		CONFIG : 'N U T, 0, 0, 0',
	X =   694.107  mm,	Y =    10.835  mm,	Z =  -369.560  mm,
	W =   179.757 deg,	P =    27.593 deg,	R =     2.200 deg
};
P[2:"Retreat"]{
   GP1:
	UF : 4, UT : 2,		CONFIG : 'N U T, 0, 0, 0',
	X =   543.007  mm,	Y =    10.533  mm,	Z =  -280.665  mm,
	W =   179.740 deg,	P =    34.043 deg,	R =     2.167 deg
};
P[31]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =  -100.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[32]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =    -5.000  mm,	Y =     0.000  mm,	Z =   -10.000  mm,
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
