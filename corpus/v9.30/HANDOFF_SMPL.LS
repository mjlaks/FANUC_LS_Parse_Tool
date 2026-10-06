/PROG  HANDOFF_SMPL
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Handoff";
PROG_SIZE	= 2291;
CREATE		= DATE 25-11-12  TIME 16:03:50;
MODIFIED	= DATE 25-11-12  TIME 16:07:24;
FILE_NAME	= HANDOFF;
VERSION		= 0;
LINE_COUNT	= 68;
MEMORY_SIZE	= 2827;
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
   1:  CALL ROUTER(5) ;
   2:  UFRAME_NUM=1 ;
   3:  UTOOL_NUM=1 ;
   4:J PR[5:Handoff Perch] 50% CNT100    ;
   5:  LBL[15:Set offset PRs] ;
   6:  !******************************* ;
   7:  PR[31:Appr1_TO]=P[31]    ;
   8:  PR[32:Appr2_TO]=P[32]    ;
   9:  PR[36:Dprt1_TO]=P[36]    ;
  10:  PR[37:Dprt2_TO]=P[37]    ;
  11:  PR[38:Dprt3_TO]=P[38]    ;
  12:   ;
  13:   ;
  14:  !******************************* ;
  15:  LBL[100:Handoff] ;
  16:  !******************************* ;
  17:   ;
  18:  UFRAME_NUM=5 ;
  19:  UTOOL_NUM=1 ;
  20:   ;
  21:J P[3] 35% CNT100    ;
  22:J P[4] 35% CNT100    ;
  23:   ;
  24:L PR[15:Exchange] 750mm/sec CNT50 Tool_Offset,PR[32:Appr2_TO]    ;
  25:L PR[15:Exchange] 300mm/sec CNT0    ;
  26:  CALL GRP2_VAC    ;
  27:  $WAITTMOUT=3000 ;
  28:  DO[99:Robot 2 Vac On]=ON ;
  29:  DO[98:Robot 2 Req Release]=ON ;
  30:  WAIT DI[99:Robot 1 Blow ON]=ON    ;
  31:  WAIT RI[3:Vacuum ON 2]=ON AND RI[4:Part Present 2]=ON TIMEOUT,LBL[105] ;
  32:   ;
  33:  !Set payload ;
  34:  PAYLOAD[2:EOAT w/Part] ;
  35:   ;
  36:L PR[15:Exchange] 500mm/sec CNT75 Tool_Offset,PR[36:Dprt1_TO]    ;
  37:   ;
  38:  DO[98:Robot 2 Req Release]=OFF ;
  39:   ;
  40:  UFRAME_NUM=5 ;
  41:  UTOOL_NUM=1 ;
  42:   ;
  43:J P[5] 35% CNT100    ;
  44:J P[6] 35% CNT100    ;
  45:  !******************************* ;
  46:  LBL[200:Handoff complete] ;
  47:  !******************************* ;
  48:  UFRAME_NUM=1 ;
  49:  UTOOL_NUM=1 ;
  50:   ;
  51:J PR[5:Handoff Perch] 50% CNT100    ;
  52:  !******************************* ;
  53:  LBL[999:End] ;
  54:  !******************************* ;
  55:   ;
  56:  END ;
  57:   ;
  58:  !******************************* ;
  59:  !-------- Touchup area --------- ;
  60:  !******************************* ;
  61:  LBL[900:Touchup area] ;
  62:L P[31] 1mm/sec CNT0    ;
  63:L P[32] 1mm/sec CNT0    ;
  64:L P[33] 1mm/sec CNT0    ;
  65:L P[36] 1mm/sec CNT0    ;
  66:L P[37] 1mm/sec CNT0    ;
  67:L P[38] 1mm/sec CNT0    ;
  68:   ;
/POS
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
