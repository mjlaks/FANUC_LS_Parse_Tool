/PROG  GRPSTAT2	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Get Grip2 Status";
PROG_SIZE	= 1302;
CREATE		= DATE 22-03-26  TIME 13:11:20;
MODIFIED	= DATE 22-06-16  TIME 06:36:48;
FILE_NAME	= GRPSTAT1;
VERSION		= 0;
LINE_COUNT	= 55;
MEMORY_SIZE	= 1714;
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
/APPL
/MN
   1:  !******************************* ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:  ! ;
   8:  !This program checks gripper 2 ;
   9:  !to determine status and sets ;
  10:  !Gripper status register 148 ;
  11:  ! ;
  12:  !0 = undefined ;
  13:  !1 = no part ;
  14:  !2 = part presnt ;
  15:  !******************************* ;
  16:  LBL[1:Begin] ;
  17:   ;
  18:  IF R[124:Dry Run]=1,JMP LBL[50] ;
  19:   ;
  20:  !------------------------------- ;
  21:  LBL[2: Normal] ;
  22:  !------------------------------- ;
  23:  IF (!RI[3:Vacuum ON 2] AND !RI[4:Part Present 2]),JMP LBL[5] ;
  24:   ;
  25:  IF (RI[3:Vacuum ON 2] AND RI[4:Part Present 2]),JMP LBL[10] ;
  26:   ;
  27:  R[148:Grip2_Status]=0    ;
  28:  JMP LBL[199] ;
  29:   ;
  30:  LBL[5:Gripper Open] ;
  31:  R[148:Grip2_Status]=1    ;
  32:  JMP LBL[199] ;
  33:   ;
  34:  LBL[10:Grip Clsd, PP] ;
  35:  R[148:Grip2_Status]=2    ;
  36:  JMP LBL[199] ;
  37:   ;
  38:  !------------------------------- ;
  39:  LBL[50:Dry Run] ;
  40:  !------------------------------- ;
  41:  IF RO[3:Vacuum ON 2]=OFF,JMP LBL[55] ;
  42:  IF RO[3:Vacuum ON 2]=ON,JMP LBL[60] ;
  43:   ;
  44:  R[148:Grip2_Status]=0    ;
  45:  JMP LBL[199] ;
  46:   ;
  47:  LBL[55:Gripper Open] ;
  48:  R[148:Grip2_Status]=1    ;
  49:  JMP LBL[199] ;
  50:   ;
  51:  LBL[60:Grip Clsd, PP] ;
  52:  R[148:Grip2_Status]=2    ;
  53:  JMP LBL[199] ;
  54:   ;
  55:  LBL[199: End G1] ;
/POS
/END
