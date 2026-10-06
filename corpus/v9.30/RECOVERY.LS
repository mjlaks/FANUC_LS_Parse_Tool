/PROG  RECOVERY	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "";
PROG_SIZE	= 5119;
CREATE		= DATE 22-03-26  TIME 13:24:48;
MODIFIED	= DATE 28-12-13  TIME 08:06:38;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 205;
MEMORY_SIZE	= 5751;
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
   1:  !******************************* ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:  ! ;
   8:  !This program moves the robot ;
   9:  !safely to home ;
  10:  !******************************** ;
  11:   ;
  12:  !******************************* ;
  13:  LBL[1:Begin] ;
  14:  !******************************* ;
  15:   ;
  16:  !******************************* ;
  17:  LBL[5:Check for perch] ;
  18:  !******************************* ;
  19:  !Check for perch position ;
  20:  CALL GET_POS    ;
  21:  IF R[104:Curr Perch PR#]<>0,JMP LBL[9000] ;
  22:   ;
  23:  !******************************* ;
  24:  LBL[10:Store pos data] ;
  25:  !******************************* ;
  26:  !Get frame data ;
  27:  R[60:UTOOL Group 1]=$MNUTOOLNUM[1] ;
  28:  R[61:UFRAME Group 1]=$MNUFRAMENUM[1] ;
  29:   ;
  30:  !Get data from current position ;
  31:  UFRAME_NUM=1 ;
  32:  UTOOL_NUM=1 ;
  33:  PR[49]=JPOS    ;
  34:  PR[50]=LPOS    ;
  35:   ;
  36:  !******************************* ;
  37:  LBL[15:Check pos data] ;
  38:  !******************************* ;
  39:  !Check Y data for area ;
  40:   ;
  41:  !Grinder Area ;
  42:  IF (PR[50,2]<=(-400)),JMP LBL[1000] ;
  43:   ;
  44:  !Handoff Area ;
  45:  IF (PR[50,2]>(-400) AND PR[50,2]<250),JMP LBL[2000] ;
  46:   ;
  47:  !Vision/Audit/Infeed ;
  48:  IF (PR[50,2]>=250),JMP LBL[3000] ;
  49:   ;
  50:  !******************************* ;
  51:  LBL[1000:Check Grinder Ps] ;
  52:  !******************************* ;
  53:   ;
  54:  IF (PR[50,3]<=(-500)) THEN ;
  55:  PR[50,3]=(-500)    ;
  56:L PR[50] 100mm/sec FINE    ;
  57:   ;
  58:  PR[50,1]=200    ;
  59:L PR[50] 100mm/sec FINE    ;
  60:  ENDIF ;
  61:   ;
  62:L PR[4:Grinder Perch] 250mm/sec FINE    ;
  63:   ;
  64:  JMP LBL[9000] ;
  65:   ;
  66:  !******************************* ;
  67:  LBL[2000:Check Handoff Ps] ;
  68:  !******************************* ;
  69:   ;
  70:  !Closer To Perch ;
  71:  IF (PR[50,1]<=500),JMP LBL[2100] ;
  72:   ;
  73:  !Closer To Handoff ;
  74:  IF (PR[50,1]>500),JMP LBL[2200] ;
  75:   ;
  76:  !******************************* ;
  77:  LBL[2100:Closer to Perch] ;
  78:  !******************************* ;
  79:   ;
  80:  !Closer To Perch ;
  81:  IF (PR[50,3]<=0),JMP LBL[2540] ;
  82:   ;
  83:  !Closer To Handoff ;
  84:  IF (PR[50,3]>0),JMP LBL[2550] ;
  85:   ;
  86:  !******************************* ;
  87:  LBL[2200:Closer to Handof] ;
  88:  !******************************* ;
  89:   ;
  90:  !Closer To Perch ;
  91:  IF (PR[50,1]<=650),JMP LBL[2530] ;
  92:   ;
  93:  !Closer To Handoff ;
  94:  IF (PR[50,3]<=(-215)),JMP LBL[2520] ;
  95:   ;
  96:  IF (PR[50,3]>(-215)),JMP LBL[2510] ;
  97:   ;
  98:  !******************************* ;
  99:  LBL[2500:Positions] ;
 100:  !******************************* ;
 101:   ;
 102:  !******************************* ;
 103:  LBL[2510:Handoff] ;
 104:  !******************************* ;
 105:   ;
 106:  UFRAME_NUM=5 ;
 107:  UTOOL_NUM=1 ;
 108:L PR[15:Exchange] 400mm/sec CNT60    ;
 109:   ;
 110:  !******************************* ;
 111:  LBL[2520:Retreat 1] ;
 112:  !******************************* ;
 113:   ;
 114:  UFRAME_NUM=5 ;
 115:  UTOOL_NUM=1 ;
 116:J P[1] 10% CNT60    ;
 117:   ;
 118:  !******************************* ;
 119:  LBL[2530:Retreat 2] ;
 120:  !******************************* ;
 121:   ;
 122:  UFRAME_NUM=5 ;
 123:  UTOOL_NUM=1 ;
 124:J P[2] 10% CNT60    ;
 125:   ;
 126:  !******************************* ;
 127:  LBL[2540:Retreat 3] ;
 128:  !******************************* ;
 129:   ;
 130:  UFRAME_NUM=5 ;
 131:  UTOOL_NUM=1 ;
 132:J P[3] 10% CNT60    ;
 133:   ;
 134:  !******************************* ;
 135:  LBL[2550:Retreat 4] ;
 136:  !******************************* ;
 137:   ;
 138:  UFRAME_NUM=5 ;
 139:  UTOOL_NUM=1 ;
 140:J P[4] 10% CNT60    ;
 141:   ;
 142:  !******************************* ;
 143:  LBL[2900:Handoff PR] ;
 144:  !******************************* ;
 145:  UFRAME_NUM=1 ;
 146:  UTOOL_NUM=1 ;
 147:   ;
 148:J PR[5:Handoff Perch] 50% CNT100    ;
 149:   ;
 150:  JMP LBL[9000] ;
 151:   ;
 152:  !******************************* ;
 153:  LBL[3000:Vision\Outfd\Aut] ;
 154:  !******************************* ;
 155:   ;
 156:  !Vision Area ;
 157:  IF (PR[50,1]>=300),JMP LBL[3100] ;
 158:   ;
 159:  !Outfeed Area ;
 160:  IF (PR[50,1]<300 AND PR[50,1]>=0),JMP LBL[3200] ;
 161:   ;
 162:  !Audit Area ;
 163:  IF (PR[50,1]<0),JMP LBL[3300] ;
 164:   ;
 165:  !******************************* ;
 166:  LBL[3100:Vision Area] ;
 167:  !******************************* ;
 168:   ;
 169:J PR[6:Vision Perch] 10% FINE    ;
 170:   ;
 171:  JMP LBL[9000] ;
 172:   ;
 173:  !******************************* ;
 174:  LBL[3200:Outfeed] ;
 175:  !******************************* ;
 176:  IF (PR[50,3]<=(-510)) THEN ;
 177:  PR[50,3]=(-510)    ;
 178:L PR[50] 100mm/sec FINE    ;
 179:   ;
 180:  PR[50,1]=150    ;
 181:L PR[50] 100mm/sec FINE    ;
 182:  ENDIF ;
 183:   ;
 184:J PR[3:Outfeed Perch] 10% FINE    ;
 185:   ;
 186:  JMP LBL[9000] ;
 187:   ;
 188:  !******************************* ;
 189:  LBL[3300:Audit] ;
 190:  !******************************* ;
 191:  IF (PR[50,3]<=(-160)) THEN ;
 192:  PR[50,3]=(-160)    ;
 193:L PR[50] 100mm/sec FINE    ;
 194:  ENDIF ;
 195:   ;
 196:J PR[7:Audit] 10% FINE    ;
 197:   ;
 198:  JMP LBL[9000] ;
 199:   ;
 200:  !******************************* ;
 201:  LBL[9000:At Perch] ;
 202:  !******************************* ;
 203:   ;
 204:  CALL RESET_IO    ;
 205:   ;
/POS
P[1]{
   GP1:
	UF : 5, UT : 1,	
	J1=     1.315 deg,	J2=   138.143 deg,	J3=   -10.432 deg,
	J4=      .773 deg,	J5=   100.539 deg,	J6=     2.000 deg
};
P[2]{
   GP1:
	UF : 5, UT : 1,		CONFIG : 'F U T, 0, 0, 0',
	X =   576.022  mm,	Y =    14.297  mm,	Z =  -377.659  mm,
	W =   169.976 deg,	P =   -78.899 deg,	R =    12.310 deg
};
P[3]{
   GP1:
	UF : 5, UT : 1,		CONFIG : 'F U T, 0, 0, 0',
	X =   488.586  mm,	Y =    12.225  mm,	Z =  -193.776  mm,
	W =   175.738 deg,	P =   -65.359 deg,	R =     6.798 deg
};
P[4]{
   GP1:
	UF : 5, UT : 1,	
	J1=     1.315 deg,	J2=     3.357 deg,	J3=   -55.303 deg,
	J4=      .777 deg,	J5=   -39.859 deg,	J6=     2.000 deg
};
/END
