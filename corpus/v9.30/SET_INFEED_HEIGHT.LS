/PROG  SET_INFEED_HEIGHT
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Set height";
PROG_SIZE	= 2017;
CREATE		= DATE 22-03-26  TIME 14:35:12;
MODIFIED	= DATE 22-03-27  TIME 07:21:06;
FILE_NAME	= SET_SLOT;
VERSION		= 0;
LINE_COUNT	= 107;
MEMORY_SIZE	= 2477;
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
   9:  !This program calculates the part ;
  10:  !position offsets. ;
  11:  ! ;
  12:  !******************************* ;
  13:  LBL[1:Begin] ;
  14:  !******************************* ;
  15:   ;
  16:  R[51:Part Style]=GI[3:Style Code]    ;
  17:   ;
  18:  !******************************* ;
  19:  LBL[5:Set Z values] ;
  20:  !******************************* ;
  21:   ;
  22:  IF (F[1]) THEN ;
  23:  R[48:Curr Infd Cnt]=0    ;
  24:  F[1]=(OFF) ;
  25:  DO[65:Outfeed Drawer Full]=OFF ;
  26:  ENDIF ;
  27:   ;
  28:  SELECT R[51:Part Style]=1,JMP LBL[101] ;
  29:         =2,JMP LBL[102] ;
  30:         =3,JMP LBL[103] ;
  31:         =4,JMP LBL[104] ;
  32:         =5,JMP LBL[105] ;
  33:         =6,JMP LBL[106] ;
  34:         =7,JMP LBL[107] ;
  35:         =8,JMP LBL[108] ;
  36:         =9,JMP LBL[109] ;
  37:         =10,JMP LBL[110] ;
  38:         ELSE,JMP LBL[900] ;
  39:   ;
  40:  LBL[101] ;
  41:  R[52]=0    ;
  42:  R[53]=(-3)    ;
  43:  JMP LBL[200] ;
  44:   ;
  45:  LBL[102] ;
  46:  R[52]=0    ;
  47:  R[53]=(-3)    ;
  48:  JMP LBL[200] ;
  49:   ;
  50:  LBL[103] ;
  51:  R[52]=0    ;
  52:  R[53]=(-3)    ;
  53:  JMP LBL[200] ;
  54:   ;
  55:  LBL[104] ;
  56:  R[52]=0    ;
  57:  R[53]=(-3)    ;
  58:  JMP LBL[200] ;
  59:   ;
  60:  LBL[105] ;
  61:  R[52]=0    ;
  62:  R[53]=(-3)    ;
  63:  JMP LBL[200] ;
  64:   ;
  65:  LBL[106] ;
  66:  R[52]=0    ;
  67:  R[53]=(-3)    ;
  68:  JMP LBL[200] ;
  69:   ;
  70:  LBL[107] ;
  71:  R[52]=0    ;
  72:  R[53]=(-3)    ;
  73:  JMP LBL[200] ;
  74:   ;
  75:  LBL[108] ;
  76:  R[52]=0    ;
  77:  R[53]=(-3)    ;
  78:  JMP LBL[200] ;
  79:   ;
  80:  LBL[109] ;
  81:  R[52]=0    ;
  82:  R[53]=(-3)    ;
  83:  JMP LBL[200] ;
  84:   ;
  85:  LBL[110] ;
  86:  R[52]=0    ;
  87:  R[53]=(-3)    ;
  88:  JMP LBL[200] ;
  89:   ;
  90:  LBL[200] ;
  91:  //R[54]=((R[48:Curr Infd Cnt]*R[53])+R[52]) ;
  92:  R[54]=R[40]    ;
  93:   ;
  94:   ;
  95:  !******************************* ;
  96:  LBL[999:End] ;
  97:  !******************************* ;
  98:  END ;
  99:   ;
 100:  !******************************* ;
 101:  LBL[900:Invalid Slot] ;
 102:  !******************************* ;
 103:   ;
 104:  GO[2:Application Fault]=10 ;
 105:  PAUSE ;
 106:  JMP LBL[1] ;
 107:   ;
/POS
/END
