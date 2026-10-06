/PROG  LUL_GRINDER
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "LD/UL Grinder";
PROG_SIZE	= 7756;
CREATE		= DATE 29-07-24  TIME 08:20:12;
MODIFIED	= DATE 31-06-28  TIME 05:29:58;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 335;
MEMORY_SIZE	= 8536;
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
   9:  !This program unloads and loads ;
  10:  !Grinder ;
  11:  ! ;
  12:  !******************************* ;
  13:  LBL[1:Begin] ;
  14:  !******************************* ;
  15:   ;
  16:  IF RI[4:Part Present 2]=OFF AND RI[3:Vacuum ON 2]=OFF,JMP LBL[2] ;
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
  92:L PR[21:Temp Unload] 50mm/sec CNT0    ;
  93:   ;
  94:  CALL GRP1_VAC    ;
  95:   ;
  96:  !Picking part ;
  97:  WAIT    .50(sec) ;
  98:   ;
  99:  IF (GI[3:Style Code]=19 OR GI[3:Style Code]=20) THEN ;
 100:L P[55] 2mm/sec FINE INC    ;
 101:  WAIT   1.00(sec) ;
 102:L P[56] 7mm/sec FINE INC    ;
 103:  ENDIF ;
 104:   ;
 105:   ;
 106:  !******************************* ;
 107:  LBL[130:From pick] ;
 108:  !******************************* ;
 109:   ;
 110:  UTOOL_NUM=3 ;
 111:  UFRAME_NUM=3 ;
 112:   ;
 113:L PR[21:Temp Unload] 25mm/sec CNT75 Tool_Offset,PR[39:Dprt4_TO]    ;
 114:   ;
 115:L PR[21:Temp Unload] 250mm/sec FINE Tool_Offset,PR[37:Dprt2_TO]    ;
 116:   ;
 117:  CALL GRP1_CKPART_GRD    ;
 118:   ;
 119:  IF DO[39:RETRY PICK]=ON,JMP LBL[120] ;
 120:   ;
 121:  DO[52:Grinder 2 Unload Comp]=PULSE,1.0sec ;
 122:  R[82]=0    ;
 123:   ;
 124:  IF R[20:Move home abort]=1,JMP LBL[400] ;
 125:   ;
 126:  !******************************* ;
 127:  LBL[150:Check for load] ;
 128:  !******************************* ;
 129:   ;
 130:  F[10]=(OFF) ;
 131:  IF R[20:Move home abort]=1,JMP LBL[400] ;
 132:  IF RI[4:Part Present 2]=OFF,JMP LBL[400] ;
 133:   ;
 134:  !******************************* ;
 135:  LBL[200:Load] ;
 136:  !******************************* ;
 137:  !Send process status ;
 138:  Program Status(14) ;
 139:   ;
 140:  !******************************* ;
 141:  LBL[202:Wait] ;
 142:  !******************************* ;
 143:   ;
 144:  IF DI[57:Request to Enter Cell]=ON,CALL ENTR_REQ ;
 145:   ;
 146:  IF DI[52:Ok to Load Grinder]=ON,JMP LBL[210] ;
 147:   ;
 148:  JMP LBL[202] ;
 149:   ;
 150:  !******************************* ;
 151:  LBL[210:Check] ;
 152:  !******************************* ;
 153:  !Check gripper 2 ;
 154:  CALL GRP2_CKPART    ;
 155:  IF R[20:Move home abort]=1,JMP LBL[400] ;
 156:   ;
 157:  UTOOL_NUM=3 ;
 158:  UFRAME_NUM=3 ;
 159:   ;
 160:J PR[21:Temp Unload] 10% FINE Tool_Offset,PR[37:Dprt2_TO]    ;
 161:   ;
 162:  WAIT    .10(sec) ;
 163:   ;
 164:  UTOOL_NUM=10 ;
 165:  UFRAME_NUM=3 ;
 166:   ;
 167:  DO[36:Clear of Grinder]=OFF ;
 168:   ;
 169:J PR[24:Temp Load] 15% CNT0 Tool_Offset,PR[31:Appr1_TO] VOFFSET,VR[1]    ;
 170:   ;
 171:L PR[24:Temp Load] 200mm/sec CNT75 Tool_Offset,PR[32:Appr2_TO] VOFFSET,VR[1]    ;
 172:   ;
 173:L PR[24:Temp Load] 25mm/sec FINE VOFFSET,VR[1]    ;
 174:   ;
 175:  UTOOL_NUM=10 ;
 176:   ;
 177:  SELECT R[51:Part Style]=1,JMP LBL[301] ;
 178:         =2,JMP LBL[302] ;
 179:         =3,JMP LBL[303] ;
 180:         =4,JMP LBL[304] ;
 181:         =5,JMP LBL[305] ;
 182:         =6,JMP LBL[306] ;
 183:         =8,JMP LBL[308] ;
 184:         =10,JMP LBL[310] ;
 185:         =11,JMP LBL[311] ;
 186:         =12,JMP LBL[312] ;
 187:         =13,JMP LBL[313] ;
 188:         =14,JMP LBL[314] ;
 189:         =15,JMP LBL[315] ;
 190:         =16,JMP LBL[316] ;
 191:         =17,JMP LBL[317] ;
 192:         =18,JMP LBL[318] ;
 193:         =19,JMP LBL[319] ;
 194:         =20,JMP LBL[420] ;
 195:         =21,JMP LBL[421] ;
 196:         =22,JMP LBL[422] ;
 197:         ELSE,JMP LBL[800] ;
 198:   ;
 199:   ;
 200:  LBL[301] ;
 201:L P[1] 100mm/sec FINE INC    ;
 202:  JMP LBL[320] ;
 203:  LBL[302] ;
 204:L P[2] 100mm/sec FINE INC    ;
 205:  JMP LBL[320] ;
 206:  LBL[303] ;
 207:L P[3] 100mm/sec FINE INC    ;
 208:  JMP LBL[320] ;
 209:  LBL[304] ;
 210:L P[4] 100mm/sec FINE INC    ;
 211:  JMP LBL[320] ;
 212:  LBL[305] ;
 213:L P[5] 100mm/sec FINE INC    ;
 214:  JMP LBL[320] ;
 215:  LBL[306] ;
 216:L P[6] 100mm/sec FINE INC    ;
 217:  JMP LBL[320] ;
 218:  LBL[308] ;
 219:L P[7] 100mm/sec FINE INC    ;
 220:  JMP LBL[320] ;
 221:  LBL[310] ;
 222:L P[10] 100mm/sec FINE INC    ;
 223:  JMP LBL[320] ;
 224:  LBL[311] ;
 225:L P[11] 100mm/sec FINE INC    ;
 226:  JMP LBL[320] ;
 227:  LBL[312] ;
 228:L P[12] 100mm/sec FINE INC    ;
 229:  JMP LBL[320] ;
 230:  LBL[313] ;
 231:L P[13] 100mm/sec FINE INC    ;
 232:  JMP LBL[320] ;
 233:  LBL[314] ;
 234:L P[14] 100mm/sec FINE INC    ;
 235:  JMP LBL[320] ;
 236:  LBL[315] ;
 237:L P[15] 100mm/sec FINE INC    ;
 238:  JMP LBL[320] ;
 239:  LBL[316] ;
 240:L P[16] 100mm/sec FINE INC    ;
 241:  JMP LBL[320] ;
 242:  LBL[317] ;
 243:L P[17] 100mm/sec FINE INC    ;
 244:  JMP LBL[320] ;
 245:  LBL[318] ;
 246:L P[18] 100mm/sec FINE INC    ;
 247:  JMP LBL[320] ;
 248:  LBL[319] ;
 249:L P[19] 100mm/sec FINE INC    ;
 250:  JMP LBL[320] ;
 251:  LBL[420] ;
 252:L P[20] 100mm/sec FINE INC    ;
 253:  JMP LBL[320] ;
 254:  LBL[421] ;
 255:L P[21] 100mm/sec FINE INC    ;
 256:  JMP LBL[320] ;
 257:  LBL[422] ;
 258:L P[22] 100mm/sec FINE INC    ;
 259:  JMP LBL[320] ;
 260:   ;
 261:   ;
 262:  LBL[320] ;
 263:  !Placing part ;
 264:   ;
 265:  DO[48:Grinder 2 Clamp Request]=ON ;
 266:  DO[53:Grinder 2 Load Comp]=PULSE,4.0sec ;
 267:  WAIT DI[48:Grinder 2 Fixture Clampe]=ON    ;
 268:  CALL GRP2_BLOWOFF    ;
 269:  DO[48:Grinder 2 Clamp Request]=OFF ;
 270:   ;
 271:  UTOOL_NUM=10 ;
 272:  UFRAME_NUM=3 ;
 273:   ;
 274:L PR[24:Temp Load] 750mm/sec CNT25 Tool_Offset,PR[39:Dprt4_TO] VOFFSET,VR[1]    ;
 275:   ;
 276:  IF R[20:Move home abort]=1,JMP LBL[290] ;
 277:  LBL[290] ;
 278:   ;
 279:  !Send process status ;
 280:  Program Status(15) ;
 281:   ;
 282:  !******************************* ;
 283:  LBL[400:Perch RD A] ;
 284:  !******************************* ;
 285:  !Robot to station perch position ;
 286:  UTOOL_NUM=1 ;
 287:  UFRAME_NUM=1 ;
 288:L PR[4:Grinder Perch] 750mm/sec CNT20    ;
 289:   ;
 290:  DO[47:Grinder 2 Unclamp Req]=OFF ;
 291:  DO[48:Grinder 2 Clamp Request]=OFF ;
 292:  DO[36:Clear of Grinder]=(ON) ;
 293:  DO[39:RETRY PICK]=OFF ;
 294:   ;
 295:  !Stop cycle timer ;
 296:  TIMER[6]=STOP ;
 297:  R[6:GRD Ld & UL Time]=TIMER[6]    ;
 298:   ;
 299:  !******************************* ;
 300:  LBL[500:End] ;
 301:  !******************************* ;
 302:   ;
 303:  END ;
 304:   ;
 305:  !Stop cycle timer ;
 306:  TIMER[6]=STOP ;
 307:  R[6:GRD Ld & UL Time]=TIMER[6]    ;
 308:  ABORT ;
 309:   ;
 310:  !******************************* ;
 311:  LBL[800:End] ;
 312:  !******************************* ;
 313:  GO[2:Application Fault]=10 ;
 314:  PAUSE ;
 315:  GO[2:Application Fault]=0 ;
 316:  JMP LBL[1] ;
 317:   ;
 318:   ;
 319:  !******************************* ;
 320:  !-------- Touchup area --------- ;
 321:  !******************************* ;
 322:  LBL[900:Touchup area] ;
 323:L P[1] 1mm/sec CNT0    ;
 324:L P[2] 1mm/sec CNT0    ;
 325:L P[3] 1mm/sec CNT0    ;
 326:L P[4] 1mm/sec CNT0    ;
 327:L P[5] 1mm/sec CNT0    ;
 328:L P[6] 1mm/sec CNT0    ;
 329:L P[31] 1mm/sec CNT0    ;
 330:L P[32] 1mm/sec CNT0    ;
 331:L P[33] 1mm/sec CNT0    ;
 332:L P[36] 1mm/sec CNT0    ;
 333:L P[37] 1mm/sec CNT0    ;
 334:L P[38] 1mm/sec CNT0    ;
 335:L P[39] 1mm/sec CNT0    ;
/POS
P[1]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.000 deg
};
P[2]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.350 deg
};
P[3]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.500 deg
};
P[4]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.250 deg
};
P[5]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.350 deg
};
P[6]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.250 deg
};
P[7]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.000 deg
};
P[10]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.950 deg
};
P[11]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     1.850 deg
};
P[12]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.000 deg
};
P[13]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.500 deg
};
P[14]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     3.000 deg
};
P[15]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.000 deg
};
P[16]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.700 deg
};
P[17]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.000 deg
};
P[18]{
   GP1:
	UF : 3, UT : 10,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     2.700 deg
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
P[55]{
   GP1:
	UF : 3, UT : 3,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =    -2.000  mm,	Z =      .500  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[56]{
   GP1:
	UF : 3, UT : 3,		CONFIG : 'N D B, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     7.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
/END
