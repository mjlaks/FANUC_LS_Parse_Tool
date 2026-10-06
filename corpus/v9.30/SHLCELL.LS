/PROG  SHLCELL	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Custom Cell Init";
PROG_SIZE	= 1762;
CREATE		= DATE 22-03-26  TIME 13:12:14;
MODIFIED	= DATE 22-03-26  TIME 13:12:14;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 76;
MEMORY_SIZE	= 2218;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 7;
DEFAULT_GROUP	= *,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/MN
   1:  JMP LBL[1] ;
   2:  !******************************* ;
   3:  !COMPANY ;
   4:  !PROJECT 0000000 ;
   5:  !CUSTOMER Example Cell ;
   6:  ! ;
   7:  !Date: March 24, 2022 ;
   8:  ! ;
   9:  !This program is called at ;
  10:  !Power up to initialize ;
  11:  !I/O and program registers ;
  12:  !******************************** ;
  13:  LBL[1] ;
  14:  !Initialize frame regs ;
  15:  !User frame ;
  16:  R[135:Nilp Uframe]=1    ;
  17:  !Tool frame ;
  18:  R[136:Base Utool]=1    ;
  19:   ;
  20:  !Set number of perches ;
  21:  R[101:Number Perches]=8    ;
  22:   ;
  23:  !Set R[#] of first perch ;
  24:  R[102:First Perch PR#]=1    ;
  25:   ;
  26:  !Dist in mm from perch to ;
  27:  !allow auto homing ;
  28:  !R[100:Max Recov Dist]=25 ;
  29:  R[100:Max Recov Dist]=25    ;
  30:   ;
  31:  !Gripper timeout in .01 sec ;
  32:  !R[140:Gripper Timeout]=300 ;
  33:  R[140:Gripper Timeout]=300    ;
  34:   ;
  35:  !Gripper1 open delay sec ;
  36:  !R[141:Grip1 Open Delay] ;
  37:  R[141:Grip1_Open_Delay]=.75    ;
  38:   ;
  39:  !Gripper1 close delay sec ;
  40:  !R[142:Grip1 Clos Delay] ;
  41:  R[142:Grip1_Clos_Delay]=.75    ;
  42:   ;
  43:  !Gripper2 open delay sec ;
  44:  !R[146:Grip2 Open Delay] ;
  45:  R[146:Grip2_Open_Delay]=.75    ;
  46:   ;
  47:  !Gripper2 close delay sec ;
  48:  !R[147:Grip2 Clos Delay] ;
  49:  R[147:Grip2_Clos_Delay]=.75    ;
  50:   ;
  51:  !disable Skip check curpos ;
  52:  !in Tohome ;
  53:  R[106:Skip Curpos]=0    ;
  54:   ;
  55:  !Disable dry run ;
  56:  R[124:Dry Run]=0    ;
  57:   ;
  58:  !Set start from abort ;
  59:  R[125:Start from Abort]=1    ;
  60:   ;
  61:  !Initialize safe start ;
  62:  R[123]=0    ;
  63:   ;
  64:  !Initialize severity reg ;
  65:  !0 = warning and more severe ;
  66:  !will force user screen ;
  67:  R[115]=0    ;
  68:   ;
  69:  !Initialize end cycle abort ;
  70:  R[126:End Cycle Stop]=0    ;
  71:   ;
  72:  !Initialize kill_shlio_r ;
  73:  R[130]=0    ;
  74:   ;
  75:   ;
  76:  Clear User Page    ;
/POS
/END
