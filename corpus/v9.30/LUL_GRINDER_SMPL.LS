/PROG  LUL_GRINDER_SMPL
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "LD/UL Grinder";
PROG_SIZE	= 5234;
CREATE		= DATE 25-11-12  TIME 16:07:44;
MODIFIED	= DATE 31-08-01  TIME 06:16:20;
FILE_NAME	= LUL_GRIN;
VERSION		= 0;
LINE_COUNT	= 223;
MEMORY_SIZE	= 5794;
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
   1:  CALL VISION_OFFSET    ;
   2:   ;
   3:  UTOOL_NUM=1 ;
   4:  UFRAME_NUM=1 ;
   5:  !Safe move to RD A perch ;
   6:  CALL ROUTER(4) ;
   7:   ;
   8:J PR[4:Grinder Perch] 50% CNT100    ;
   9:   ;
  10:  !******************************* ;
  11:  LBL[10:Set offset PRs] ;
  12:  !******************************* ;
  13:  CALL SET_LOAD_PR    ;
  14:  PR[31:Appr1_TO]=P[31]    ;
  15:  PR[32:Appr2_TO]=P[32]    ;
  16:  PR[36:Dprt1_TO]=P[36]    ;
  17:  PR[37:Dprt2_TO]=P[37]    ;
  18:  PR[38:Dprt3_TO]=P[38]    ;
  19:  PR[39:Dprt4_TO]=P[39]    ;
  20:  PR[21:Temp Unload]=PR[R[57]]    ;
  21:  PR[24:Temp Load]=PR[R[56]]    ;
  22:   ;
  23:  DO[47:Grinder 2 Unclamp Req]=ON ;
  24:   ;
  25:  UTOOL_NUM=3 ;
  26:  UFRAME_NUM=3 ;
  27:   ;
  28:L PR[21:Temp Unload] 600mm/sec CNT50 Tool_Offset,PR[31:Appr1_TO]    ;
  29:   ;
  30:   ;
  31:L PR[21:Temp Unload] 250mm/sec CNT50 Tool_Offset,PR[32:Appr2_TO]    ;
  32:   ;
  33:  PAUSE ;
  34:L PR[21:Temp Unload] 200mm/sec CNT0    ;
  35:   ;
  36:  CALL GRP1_VAC    ;
  37:   ;
  38:  !Picking part ;
  39:  WAIT    .50(sec) ;
  40:   ;
  41:  !******************************* ;
  42:  LBL[130:From pick] ;
  43:  !******************************* ;
  44:   ;
  45:  UTOOL_NUM=3 ;
  46:  UFRAME_NUM=3 ;
  47:   ;
  48:L PR[21:Temp Unload] 25mm/sec CNT75 Tool_Offset,PR[39:Dprt4_TO]    ;
  49:   ;
  50:L PR[21:Temp Unload] 250mm/sec FINE Tool_Offset,PR[37:Dprt2_TO]    ;
  51:   ;
  52:  //CALL GRP1_CKPART_GRD    ;
  53:   ;
  54:  IF DO[39:RETRY PICK]=ON,JMP LBL[120] ;
  55:   ;
  56:  DO[52:Grinder 2 Unload Comp]=PULSE,1.0sec ;
  57:  R[82]=0    ;
  58:   ;
  59:  UTOOL_NUM=3 ;
  60:  UFRAME_NUM=3 ;
  61:   ;
  62:J PR[21:Temp Unload] 10% FINE Tool_Offset,PR[37:Dprt2_TO]    ;
  63:   ;
  64:  WAIT    .10(sec) ;
  65:   ;
  66:  UTOOL_NUM=10 ;
  67:  UFRAME_NUM=3 ;
  68:   ;
  69:  DO[36:Clear of Grinder]=OFF ;
  70:   ;
  71:J PR[24:Temp Load] 15% CNT0 Tool_Offset,PR[31:Appr1_TO] VOFFSET,VR[1]    ;
  72:   ;
  73:L PR[24:Temp Load] 200mm/sec CNT75 Tool_Offset,PR[32:Appr2_TO] VOFFSET,VR[1]    ;
  74:   ;
  75:  PAUSE ;
  76:L PR[24:Temp Load] 25mm/sec FINE VOFFSET,VR[1]    ;
  77:  PAUSE ;
  78:  PR[R[56]]=PR[24:Temp Load]    ;
  79:   ;
  80:  UTOOL_NUM=10 ;
  81:   ;
  82:  SELECT R[51:Part Style]=1,JMP LBL[301] ;
  83:         =2,JMP LBL[302] ;
  84:         =3,JMP LBL[303] ;
  85:         =4,JMP LBL[304] ;
  86:         =5,JMP LBL[305] ;
  87:         =6,JMP LBL[306] ;
  88:         =8,JMP LBL[308] ;
  89:         =10,JMP LBL[310] ;
  90:         =11,JMP LBL[311] ;
  91:         =12,JMP LBL[312] ;
  92:         =13,JMP LBL[313] ;
  93:         =14,JMP LBL[314] ;
  94:         =15,JMP LBL[315] ;
  95:         =16,JMP LBL[316] ;
  96:         =17,JMP LBL[317] ;
  97:         =18,JMP LBL[318] ;
  98:         =19,JMP LBL[319] ;
  99:         =20,JMP LBL[420] ;
 100:         =21,JMP LBL[421] ;
 101:         =22,JMP LBL[422] ;
 102:         ELSE,JMP LBL[800] ;
 103:   ;
 104:   ;
 105:  LBL[301] ;
 106:L P[1] 100mm/sec FINE INC    ;
 107:  JMP LBL[320] ;
 108:  LBL[302] ;
 109:L P[2] 100mm/sec FINE INC    ;
 110:  JMP LBL[320] ;
 111:  LBL[303] ;
 112:L P[3] 100mm/sec FINE INC    ;
 113:  JMP LBL[320] ;
 114:  LBL[304] ;
 115:L P[4] 100mm/sec FINE INC    ;
 116:  JMP LBL[320] ;
 117:  LBL[305] ;
 118:L P[5] 100mm/sec FINE INC    ;
 119:  JMP LBL[320] ;
 120:  LBL[306] ;
 121:L P[6] 100mm/sec FINE INC    ;
 122:  JMP LBL[320] ;
 123:  LBL[308] ;
 124:L P[8] 100mm/sec FINE INC    ;
 125:  JMP LBL[320] ;
 126:  LBL[310] ;
 127:L P[10] 100mm/sec FINE INC    ;
 128:  JMP LBL[320] ;
 129:  LBL[311] ;
 130:L P[11] 100mm/sec FINE INC    ;
 131:  JMP LBL[320] ;
 132:  LBL[312] ;
 133:L P[12] 100mm/sec FINE INC    ;
 134:  JMP LBL[320] ;
 135:  LBL[313] ;
 136:L P[13] 100mm/sec FINE INC    ;
 137:  JMP LBL[320] ;
 138:  LBL[314] ;
 139:L P[14] 100mm/sec FINE INC    ;
 140:  JMP LBL[320] ;
 141:  LBL[315] ;
 142:L P[15] 100mm/sec FINE INC    ;
 143:  JMP LBL[320] ;
 144:  LBL[316] ;
 145:L P[16] 100mm/sec FINE INC    ;
 146:  JMP LBL[320] ;
 147:  LBL[317] ;
 148:L P[17] 100mm/sec FINE INC    ;
 149:  JMP LBL[320] ;
 150:  LBL[318] ;
 151:L P[18] 100mm/sec FINE INC    ;
 152:  JMP LBL[320] ;
 153:  LBL[319] ;
 154:L P[19] 100mm/sec FINE INC    ;
 155:  JMP LBL[320] ;
 156:  LBL[420] ;
 157:L P[20] 100mm/sec FINE INC    ;
 158:  JMP LBL[320] ;
 159:  LBL[421] ;
 160:L P[21] 100mm/sec FINE INC    ;
 161:  JMP LBL[320] ;
 162:  LBL[422] ;
 163:L P[22] 100mm/sec FINE INC    ;
 164:  JMP LBL[320] ;
 165:   ;
 166:   ;
 167:  LBL[320] ;
 168:  !Placing part ;
 169:   ;
 170:  DO[48:Grinder 2 Clamp Request]=ON ;
 171:  DO[53:Grinder 2 Load Comp]=PULSE,4.0sec ;
 172:  WAIT DI[48:Grinder 2 Fixture Clampe]=ON    ;
 173:  CALL GRP2_BLOWOFF    ;
 174:  DO[48:Grinder 2 Clamp Request]=OFF ;
 175:   ;
 176:  UTOOL_NUM=10 ;
 177:  UFRAME_NUM=3 ;
 178:   ;
 179:L PR[24:Temp Load] 750mm/sec CNT25 Tool_Offset,PR[39:Dprt4_TO] VOFFSET,VR[1]    ;
 180:   ;
 181:  UTOOL_NUM=1 ;
 182:  UFRAME_NUM=1 ;
 183:L PR[4:Grinder Perch] 750mm/sec CNT20    ;
 184:   ;
 185:  DO[47:Grinder 2 Unclamp Req]=OFF ;
 186:  DO[48:Grinder 2 Clamp Request]=OFF ;
 187:  DO[36:Clear of Grinder]=(ON) ;
 188:  DO[39:RETRY PICK]=OFF ;
 189:   ;
 190:   ;
 191:  END ;
 192:   ;
 193:  !Stop cycle timer ;
 194:  TIMER[6]=STOP ;
 195:  R[6:GRD Ld & UL Time]=TIMER[6]    ;
 196:  ABORT ;
 197:   ;
 198:  !******************************* ;
 199:  LBL[800:End] ;
 200:  !******************************* ;
 201:  GO[2:Application Fault]=10 ;
 202:  PAUSE ;
 203:  GO[2:Application Fault]=0 ;
 204:  JMP LBL[1] ;
 205:   ;
 206:   ;
 207:  !******************************* ;
 208:  !-------- Touchup area --------- ;
 209:  !******************************* ;
 210:  LBL[900:Touchup area] ;
 211:L P[1] 1mm/sec CNT0    ;
 212:L P[2] 1mm/sec CNT0    ;
 213:L P[3] 1mm/sec CNT0    ;
 214:L P[4] 1mm/sec CNT0    ;
 215:L P[5] 1mm/sec CNT0    ;
 216:L P[6] 1mm/sec CNT0    ;
 217:L P[31] 1mm/sec CNT0    ;
 218:L P[32] 1mm/sec CNT0    ;
 219:L P[33] 1mm/sec CNT0    ;
 220:L P[36] 1mm/sec CNT0    ;
 221:L P[37] 1mm/sec CNT0    ;
 222:L P[38] 1mm/sec CNT0    ;
 223:L P[39] 1mm/sec CNT0    ;
/POS
P[1]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.750 deg
};
P[2]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.000 deg
};
P[3]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.750 deg
};
P[4]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[5]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.950 deg
};
P[6]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[8]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[10]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.800 deg
};
P[11]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.750 deg
};
P[12]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.700 deg
};
P[13]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[14]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.900 deg
};
P[15]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[16]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.250 deg
};
P[17]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[18]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.250 deg
};
P[19]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.700 deg
};
P[20]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.700 deg
};
P[21]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.700 deg
};
P[22]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.700 deg
};
P[31]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =   -25.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[32]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =   -15.000  mm,
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
	X =     0.000  mm,	Y =     0.000  mm,	Z =  -100.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[37]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =   -50.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[38]{
   GP1:
	UF : 0, UT : 1,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =  -200.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[39]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =    -7.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
/END
