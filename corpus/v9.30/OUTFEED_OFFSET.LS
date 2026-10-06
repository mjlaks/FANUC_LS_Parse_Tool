/PROG  OUTFEED_OFFSET
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 3658;
CREATE		= DATE 22-03-27  TIME 14:20:46;
MODIFIED	= DATE 31-08-09  TIME 05:17:44;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 144;
MEMORY_SIZE	= 4098;
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
   1:  UFRAME_NUM=1 ;
   2:  UTOOL_NUM=1 ;
   3:   ;
   4:  R[155:Outfeed Error]=1    ;
   5:   ;
   6:  IF (GI[3:Style Code]=1) THEN ;
   7:  PR[24:Temp Load]=PR[24:Temp Load]+P[1]    ;
   8:  R[155:Outfeed Error]=0    ;
   9:  ENDIF ;
  10:   ;
  11:  IF (GI[3:Style Code]=2) THEN ;
  12:  PR[24:Temp Load]=PR[24:Temp Load]+P[2]    ;
  13:  R[155:Outfeed Error]=0    ;
  14:  ENDIF ;
  15:   ;
  16:  IF (GI[3:Style Code]=3) THEN ;
  17:  PR[24:Temp Load]=PR[24:Temp Load]+P[3]    ;
  18:  R[155:Outfeed Error]=0    ;
  19:  ENDIF ;
  20:   ;
  21:  IF (GI[3:Style Code]=4) THEN ;
  22:  PR[24:Temp Load]=PR[24:Temp Load]+P[4]    ;
  23:  R[155:Outfeed Error]=0    ;
  24:  ENDIF ;
  25:   ;
  26:  IF (GI[3:Style Code]=5) THEN ;
  27:  PR[24:Temp Load]=PR[24:Temp Load]+P[5]    ;
  28:  R[155:Outfeed Error]=0    ;
  29:  ENDIF ;
  30:   ;
  31:  IF (GI[3:Style Code]=6) THEN ;
  32:  PR[24:Temp Load]=PR[24:Temp Load]+P[6]    ;
  33:  R[155:Outfeed Error]=0    ;
  34:  ENDIF ;
  35:   ;
  36:  IF (GI[3:Style Code]=6) THEN ;
  37:  PR[24:Temp Load]=PR[24:Temp Load]+P[6]    ;
  38:  R[155:Outfeed Error]=0    ;
  39:  ENDIF ;
  40:   ;
  41:  IF (GI[3:Style Code]=7) THEN ;
  42:  PR[24:Temp Load]=PR[24:Temp Load]+P[7]    ;
  43:  R[155:Outfeed Error]=0    ;
  44:  ENDIF ;
  45:   ;
  46:  IF (GI[3:Style Code]=8) THEN ;
  47:  PR[24:Temp Load]=PR[24:Temp Load]+P[8]    ;
  48:  R[155:Outfeed Error]=0    ;
  49:  ENDIF ;
  50:   ;
  51:  IF (GI[3:Style Code]=9) THEN ;
  52:  PR[24:Temp Load]=PR[24:Temp Load]+P[9]    ;
  53:  R[155:Outfeed Error]=0    ;
  54:  ENDIF ;
  55:   ;
  56:  IF (GI[3:Style Code]=10) THEN ;
  57:  PR[24:Temp Load]=PR[24:Temp Load]+P[10]    ;
  58:  R[155:Outfeed Error]=0    ;
  59:  ENDIF ;
  60:   ;
  61:  IF (GI[3:Style Code]=11) THEN ;
  62:  PR[24:Temp Load]=PR[24:Temp Load]+P[11]    ;
  63:  R[155:Outfeed Error]=0    ;
  64:  ENDIF ;
  65:   ;
  66:  IF (GI[3:Style Code]=12) THEN ;
  67:  PR[24:Temp Load]=PR[24:Temp Load]+P[12]    ;
  68:  R[155:Outfeed Error]=0    ;
  69:  ENDIF ;
  70:   ;
  71:  IF (GI[3:Style Code]=13) THEN ;
  72:  PR[24:Temp Load]=PR[24:Temp Load]+P[13]    ;
  73:  R[155:Outfeed Error]=0    ;
  74:  ENDIF ;
  75:   ;
  76:  IF (GI[3:Style Code]=14) THEN ;
  77:  PR[24:Temp Load]=PR[24:Temp Load]+P[14]    ;
  78:  R[155:Outfeed Error]=0    ;
  79:  ENDIF ;
  80:   ;
  81:  IF (GI[3:Style Code]=15) THEN ;
  82:  PR[24:Temp Load]=PR[24:Temp Load]+P[15]    ;
  83:  R[155:Outfeed Error]=0    ;
  84:  ENDIF ;
  85:   ;
  86:  IF (GI[3:Style Code]=16) THEN ;
  87:  PR[24:Temp Load]=PR[24:Temp Load]+P[16]    ;
  88:  R[155:Outfeed Error]=0    ;
  89:  ENDIF ;
  90:   ;
  91:  IF (GI[3:Style Code]=17) THEN ;
  92:  PR[24:Temp Load]=PR[24:Temp Load]+P[17]    ;
  93:  R[155:Outfeed Error]=0    ;
  94:  ENDIF ;
  95:   ;
  96:  IF (GI[3:Style Code]=18) THEN ;
  97:  PR[24:Temp Load]=PR[24:Temp Load]+P[18]    ;
  98:  R[155:Outfeed Error]=0    ;
  99:  ENDIF ;
 100:   ;
 101:  IF (GI[3:Style Code]=19) THEN ;
 102:  PR[24:Temp Load]=PR[24:Temp Load]+P[19]    ;
 103:  R[155:Outfeed Error]=0    ;
 104:  ENDIF ;
 105:   ;
 106:  IF (GI[3:Style Code]=20) THEN ;
 107:  PR[24:Temp Load]=PR[24:Temp Load]+P[20]    ;
 108:  R[155:Outfeed Error]=0    ;
 109:  ENDIF ;
 110:   ;
 111:  IF (GI[3:Style Code]=21) THEN ;
 112:  PR[24:Temp Load]=PR[24:Temp Load]+P[21]    ;
 113:  R[155:Outfeed Error]=0    ;
 114:  ENDIF ;
 115:   ;
 116:  IF (R[155:Outfeed Error]=1) THEN ;
 117:  LBL[1] ;
 118:  PAUSE ;
 119:  JMP LBL[1] ;
 120:  ENDIF ;
 121:   ;
 122:  END ;
 123:   ;
 124:L P[1] 1mm/sec FINE    ;
 125:L P[2] 1mm/sec FINE    ;
 126:L P[3] 1mm/sec FINE    ;
 127:L P[4] 1mm/sec FINE    ;
 128:L P[5] 1mm/sec FINE    ;
 129:L P[6] 100mm/sec FINE    ;
 130:L P[7] 100mm/sec FINE    ;
 131:L P[8] 100mm/sec FINE    ;
 132:L P[9] 100mm/sec FINE    ;
 133:L P[10] 100mm/sec FINE    ;
 134:L P[11] 100mm/sec FINE    ;
 135:L P[12] 100mm/sec FINE    ;
 136:L P[13] 100mm/sec FINE    ;
 137:L P[14] 100mm/sec FINE    ;
 138:L P[15] 100mm/sec FINE    ;
 139:L P[16] 100mm/sec FINE    ;
 140:L P[17] 100mm/sec FINE    ;
 141:L P[18] 100mm/sec FINE    ;
 142:L P[19] 100mm/sec FINE    ;
 143:L P[20] 100mm/sec FINE    ;
 144:L P[21] 100mm/sec FINE    ;
/POS
P[1]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[2]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[3]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[4]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[5]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[6]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[7]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[8]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[9]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[10]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[11]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[12]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[13]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[14]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[15]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[16]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[17]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[18]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[19]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[20]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[21]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 1',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
/END
