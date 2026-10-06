/PROG  CHK1_PART	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Chek Part Gripr1";
PROG_SIZE	= 1994;
CREATE		= DATE 22-03-13  TIME 11:22:40;
MODIFIED	= DATE 22-03-13  TIME 11:22:40;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 84;
MEMORY_SIZE	= 2442;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 1200,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= *,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/MN
   1:  JMP LBL[1] ;
   2:  !******************************* ;
   3:  !COMPANY ;
   4:  !PROJECT ;
   5:  ! ;
   6:  ! ;
   7:  ! ;
   8:  !This is for checking gripper ;
   9:  ! part present status ;
  10:  ! on gripper 1 ;
  11:  ! to see if part is still held ;
  12:  ! ;
  13:  !******************************** ;
  14:   ;
  15:  LBL[1: Begin] ;
  16:   ;
  17:  !Check gripper status ;
  18:  CALL GRPSTAT1    ;
  19:  IF R[124:Dry Run]=1,JMP LBL[999] ;
  20:  !2 = gripper closed, part present ;
  21:  IF R[143:Grip1_Status]=2,JMP LBL[999] ;
  22:  Clear User Page    ;
  23:  macro_14('---------  PART DROP FAULT -------',' ') ;
  24:  !CALL DICT_MSG('DROP_FAULT') ;
  25:  MESSAGE[   ] ;
  26:   ;
  27:  R[137:Gripper Num]=1    ;
  28:  ! 3 past closed no part ;
  29:  ! 5 closed no part ;
  30:  IF R[143:Grip1_Status]=3 OR R[143:Grip1_Status]=5,JMP LBL[30] ;
  31:   ;
  32:  LBL[20] ;
  33:  DO[198]=ON ;
  34:  GO[7]=26 ;
  35:  !CALL DICT_ALM('CUST_160','WARN', ;
  36:  CALL ALRM_LOG('Bad Gripper State. Not expected',137,12) ;
  37:  !Bad Gripper %s State ;
  38:  JMP LBL[40] ;
  39:   ;
  40:  LBL[30] ;
  41:  DO[198]=ON ;
  42:  GO[7]=26 ;
  43:  CALL ALRM_LOG('Part not detected in gripper',137,30) ;
  44:  !CALL DICT_ALM('CUST_157','WARN', ;
  45:  macro_14('Part not detected',' in gripper','...',137,30) ;
  46:  macro_14('gripper closed -',' part present') ;
  47:  macro_14('sensor is off') ;
  48:  LBL[40] ;
  49:  CALL LISTMENU_PSG('PART_FAULT',118) ;
  50:  !No part is detected in the ;
  51:  !gripper ;
  52:  !1 Retest for Part in Gripper" ;
  53:  !2 Pause to Allow Cell Entry" ;
  54:  !3 Ignore - part is OK" ;
  55:  !4 Allow cell entry now" ;
  56:  LBL[42] ;
  57:  WAIT R[116]=1    ;
  58:  GO[7]=0 ;
  59:  DO[198]=OFF ;
  60:   ;
  61:  SELECT R[118]=1,JMP LBL[50] ;
  62:         =2,JMP LBL[55] ;
  63:         =3,JMP LBL[60] ;
  64:         =4,JMP LBL[65] ;
  65:         ELSE,JMP LBL[1] ;
  66:  !------------------------------- ;
  67:   ;
  68:  LBL[50:Retest] ;
  69:  WAIT   1.50(sec) ;
  70:  JMP LBL[1] ;
  71:   ;
  72:  LBL[55:Pause and Entry] ;
  73:  PAUSE ;
  74:  JMP LBL[1] ;
  75:   ;
  76:  LBL[60:Continue] ;
  77:  WAIT   1.50(sec) ;
  78:  OVERRIDE=5% ;
  79:  JMP LBL[999] ;
  80:   ;
  81:  LBL[65] ;
  82:  ABORT ;
  83:   ;
  84:  LBL[999] ;
/POS
/END
