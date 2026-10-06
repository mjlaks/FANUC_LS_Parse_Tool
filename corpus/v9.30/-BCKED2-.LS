/PROG  -BCKED2-
/ATTR
OWNER		= BACKGRND;
COMMENT		= "LUL_GRINDER";
PROG_SIZE	= 6227;
CREATE		= DATE 29-07-28  TIME 06:05:22;
MODIFIED	= DATE 29-07-28  TIME 06:05:22;
FILE_NAME	= LUL_GRIN;
VERSION		= 0;
LINE_COUNT	= 276;
MEMORY_SIZE	= 6855;
PROTECT		= READ;
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
   9:  !This program unloads and loads ;
  10:  !Grinder ;
  11:  ! ;
  12:  !******************************* ;
  13:  LBL[1:Begin] ;
  14:  !******************************* ;
  15:   ;
  16:  IF RI[4:Part Present 2]=OFF,JMP LBL[2] ;
  17:   ;
  18:  CALL VISION_OFFSET    ;
  19:   ;
  20:  IF R[20:Move home abort]=1,JMP LBL[400] ;
  21:   ;
  22:  !******************************* ;
  23:  LBL[2:Begin] ;
  24:  !******************************* ;
  25:  !Send process status ;
  26:  Program Status(13) ;
  27:   ;
  28:  UTOOL_NUM=1 ;
  29:  UFRAME_NUM=1 ;
  30:  !Safe move to RD A perch ;
  31:  CALL ROUTER(4) ;
  32:   ;
  33:J PR[4:Grinder Perch] 50% CNT100    ;
  34:   ;
  35:  !******************************* ;
  36:  LBL[10:Set offset PRs] ;
  37:  !******************************* ;
  38:  CALL SET_LOAD_PR    ;
  39:  PR[31:Appr1_TO]=P[31]    ;
  40:  PR[32:Appr2_TO]=P[32]    ;
  41:  PR[36:Dprt1_TO]=P[36]    ;
  42:  PR[37:Dprt2_TO]=P[37]    ;
  43:  PR[38:Dprt3_TO]=P[38]    ;
  44:  PR[39:Dprt4_TO]=P[39]    ;
  45:  PR[21:Temp Unload]=PR[R[57]]    ;
  46:  PR[24:Temp Load]=PR[R[56]]    ;
  47:   ;
  48:  !******************************* ;
  49:  LBL[20:Wait] ;
  50:  !******************************* ;
  51:  !Wait for ready ;
  52:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
  53:   ;
  54:  IF DI[53:Ok to Unload Grinder]=ON,JMP LBL[100] ;
  55:  IF DI[52:Ok to Load Grinder]=ON,JMP LBL[200] ;
  56:   ;
  57:  JMP LBL[20] ;
  58:   ;
  59:  !******************************* ;
  60:  LBL[100:Unld] ;
  61:  !******************************* ;
  62:  !Reset cycle timer ;
  63:  TIMER[6]=RESET ;
  64:  !Start cycle timer ;
  65:  TIMER[6]=START ;
  66:   ;
  67:  !Send process status ;
  68:  Program Status(14) ;
  69:  DO[47:Grinder 2 Unclamp Req]=ON ;
  70:   ;
  71:  CALL GRP1_CK_NO_PART    ;
  72:   ;
  73:  IF R[20:Move home abort]=1,JMP LBL[400] ;
  74:   ;
  75:  !******************************* ;
  76:  LBL[120:Unld] ;
  77:  !******************************* ;
  78:   ;
  79:  DO[36:Clear of Grinder]=OFF ;
  80:  DO[39:RETRY PICK]=OFF ;
  81:   ;
  82:  UTOOL_NUM=3 ;
  83:  UFRAME_NUM=3 ;
  84:   ;
  85:L PR[21:Temp Unload] 600mm/sec CNT50 Tool_Offset,PR[31:Appr1_TO]    ;
  86:   ;
  87:  WAIT DI[47:Grinder 2 Fixture Unclam]=ON    ;
  88:  DO[47:Grinder 2 Unclamp Req]=OFF ;
  89:   ;
  90:L PR[21:Temp Unload] 250mm/sec CNT50 Tool_Offset,PR[32:Appr2_TO]    ;
  91:   ;
  92:L PR[21:Temp Unload] 200mm/sec CNT0    ;
  93:   ;
  94:  CALL GRP1_VAC    ;
  95:   ;
  96:  !Picking part ;
  97:  WAIT    .50(sec) ;
  98:   ;
  99:  !******************************* ;
 100:  LBL[130:From pick] ;
 101:  !******************************* ;
 102:   ;
 103:  UTOOL_NUM=3 ;
 104:  UFRAME_NUM=3 ;
 105:   ;
 106:L PR[21:Temp Unload] 25mm/sec CNT75 Tool_Offset,PR[39:Dprt4_TO]    ;
 107:   ;
 108:L PR[21:Temp Unload] 250mm/sec FINE Tool_Offset,PR[37:Dprt2_TO]    ;
 109:   ;
 110:  CALL GRP1_CKPART_GRD    ;
 111:   ;
 112:  IF DO[39:RETRY PICK]=ON,JMP LBL[120] ;
 113:   ;
 114:  DO[52:Grinder 2 Unload Comp]=PULSE,1.0sec ;
 115:  R[82]=0    ;
 116:   ;
 117:  IF R[20:Move home abort]=1,JMP LBL[400] ;
 118:   ;
 119:  !******************************* ;
 120:  LBL[150:Check for load] ;
 121:  !******************************* ;
 122:   ;
 123:  F[10]=(OFF) ;
 124:  IF R[20:Move home abort]=1,JMP LBL[400] ;
 125:  IF RI[4:Part Present 2]=OFF,JMP LBL[400] ;
 126:   ;
 127:  !******************************* ;
 128:  LBL[200:Load] ;
 129:  !******************************* ;
 130:  !Send process status ;
 131:  Program Status(14) ;
 132:   ;
 133:  !******************************* ;
 134:  LBL[202:Wait] ;
 135:  !******************************* ;
 136:   ;
 137:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
 138:   ;
 139:  IF DI[52:Ok to Load Grinder]=ON,JMP LBL[210] ;
 140:   ;
 141:  JMP LBL[202] ;
 142:   ;
 143:  !******************************* ;
 144:  LBL[210:Check] ;
 145:  !******************************* ;
 146:  !Check gripper 2 ;
 147:  CALL GRP2_CKPART    ;
 148:  IF R[20:Move home abort]=1,JMP LBL[400] ;
 149:   ;
 150:  UTOOL_NUM=3 ;
 151:  UFRAME_NUM=3 ;
 152:   ;
 153:J PR[21:Temp Unload] 10% FINE Tool_Offset,PR[37:Dprt2_TO]    ;
 154:   ;
 155:  WAIT    .10(sec) ;
 156:   ;
 157:  UTOOL_NUM=10 ;
 158:  UFRAME_NUM=3 ;
 159:   ;
 160:  DO[36:Clear of Grinder]=OFF ;
 161:   ;
 162:J PR[24:Temp Load] 15% CNT0 Tool_Offset,PR[31:Appr1_TO] VOFFSET,VR[1]    ;
 163:   ;
 164:L PR[24:Temp Load] 200mm/sec CNT75 Tool_Offset,PR[32:Appr2_TO] VOFFSET,VR[1]    ;
 165:   ;
 166:L PR[24:Temp Load] 25mm/sec FINE VOFFSET,VR[1]    ;
 167:   ;
 168:  UTOOL_NUM=10 ;
 169:   ;
 170:  SELECT R[51:Part Style]=1,JMP LBL[301] ;
 171:         =2,JMP LBL[302] ;
 172:         =3,JMP LBL[303] ;
 173:         =4,JMP LBL[304] ;
 174:         =5,JMP LBL[305] ;
 175:         =6,JMP LBL[306] ;
 176:         =8,JMP LBL[308] ;
 177:         ELSE,JMP LBL[800] ;
 178:   ;
 179:   ;
 180:  LBL[301] ;
 181:L P[1] 100mm/sec FINE INC    ;
 182:  JMP LBL[320] ;
 183:  LBL[302] ;
 184:L P[2] 100mm/sec FINE INC    ;
 185:  JMP LBL[320] ;
 186:  LBL[303] ;
 187:L P[3] 100mm/sec FINE INC    ;
 188:  JMP LBL[320] ;
 189:  LBL[304] ;
 190:L P[4] 100mm/sec FINE INC    ;
 191:  JMP LBL[320] ;
 192:  LBL[305] ;
 193:L P[5] 100mm/sec FINE INC    ;
 194:  JMP LBL[320] ;
 195:  LBL[306] ;
 196:L P[6] 100mm/sec FINE INC    ;
 197:  JMP LBL[320] ;
 198:  LBL[308] ;
 199:L P[7] 100mm/sec FINE INC    ;
 200:  JMP LBL[320] ;
 201:   ;
 202:   ;
 203:  LBL[320] ;
 204:  !Placing part ;
 205:   ;
 206:  DO[48:Grinder 2 Clamp Request]=ON ;
 207:  DO[53:Grinder 2 Load Comp]=PULSE,4.0sec ;
 208:  WAIT DI[48:Grinder 2 Fixture Clampe]=ON    ;
 209:  CALL GRP2_BLOWOFF    ;
 210:  DO[48:Grinder 2 Clamp Request]=OFF ;
 211:   ;
 212:  UTOOL_NUM=10 ;
 213:  UFRAME_NUM=3 ;
 214:   ;
 215:L PR[24:Temp Load] 750mm/sec CNT25 Tool_Offset,PR[39:Dprt4_TO] VOFFSET,VR[1]    ;
 216:   ;
 217:  IF R[20:Move home abort]=1,JMP LBL[290] ;
 218:  LBL[290] ;
 219:   ;
 220:  !Send process status ;
 221:  Program Status(15) ;
 222:   ;
 223:  !******************************* ;
 224:  LBL[400:Perch RD A] ;
 225:  !******************************* ;
 226:  !Robot to station perch position ;
 227:  UTOOL_NUM=1 ;
 228:  UFRAME_NUM=1 ;
 229:L PR[4:Grinder Perch] 750mm/sec CNT20    ;
 230:   ;
 231:  DO[47:Grinder 2 Unclamp Req]=OFF ;
 232:  DO[48:Grinder 2 Clamp Request]=OFF ;
 233:  DO[36:Clear of Grinder]=(ON) ;
 234:  DO[39:RETRY PICK]=OFF ;
 235:   ;
 236:  !Stop cycle timer ;
 237:  TIMER[6]=STOP ;
 238:  R[6:GRD Ld & UL Time]=TIMER[6]    ;
 239:   ;
 240:  !******************************* ;
 241:  LBL[500:End] ;
 242:  !******************************* ;
 243:   ;
 244:  END ;
 245:   ;
 246:  !Stop cycle timer ;
 247:  TIMER[6]=STOP ;
 248:  R[6:GRD Ld & UL Time]=TIMER[6]    ;
 249:  ABORT ;
 250:   ;
 251:  !******************************* ;
 252:  LBL[800:End] ;
 253:  !******************************* ;
 254:  GO[2:Application Fault]=10 ;
 255:  PAUSE ;
 256:  GO[2:Application Fault]=0 ;
 257:  JMP LBL[1] ;
 258:   ;
 259:   ;
 260:  !******************************* ;
 261:  !-------- Touchup area --------- ;
 262:  !******************************* ;
 263:  LBL[900:Touchup area] ;
 264:L P[1] 1mm/sec CNT0    ;
 265:L P[2] 1mm/sec CNT0    ;
 266:L P[3] 1mm/sec CNT0    ;
 267:L P[4] 1mm/sec CNT0    ;
 268:L P[5] 1mm/sec CNT0    ;
 269:L P[6] 1mm/sec CNT0    ;
 270:L P[31] 1mm/sec CNT0    ;
 271:L P[32] 1mm/sec CNT0    ;
 272:L P[33] 1mm/sec CNT0    ;
 273:L P[36] 1mm/sec CNT0    ;
 274:L P[37] 1mm/sec CNT0    ;
 275:L P[38] 1mm/sec CNT0    ;
 276:L P[39] 1mm/sec CNT0    ;
/POS
P[1]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[2]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[3]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
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
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[6]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.500 deg
};
P[7]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.000 deg
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
