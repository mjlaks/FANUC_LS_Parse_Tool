/PROG  SET_PAYL	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Set Payload";
PROG_SIZE	= 1454;
CREATE		= DATE 22-03-26  TIME 13:12:32;
MODIFIED	= DATE 22-03-26  TIME 13:12:32;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 60;
MEMORY_SIZE	= 1854;
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
   1:  !******************************** ;
   2:  !COMPANY ;
   3:  !PROJECT 0000000 ;
   4:  !CUSTOMER Example Cell ;
   5:  ! ;
   6:  !Date: March 24, 2022 ;
   7:   ;
   8:  !Set Payload based on EOAT ;
   9:  !attached and parts held ;
  10:  !******************************** ;
  11:   ;
  12:  !CALL GRIPSTAT ;
  13:  !2 = gripper closed, part present ;
  14:   ;
  15:  IF R[143:Grip1_Status]<>2 AND R[148:Grip2_Status]<>2 AND R[153]<>2,JMP LBL[5] ;
  16:   ;
  17:  IF R[143:Grip1_Status]=2 AND R[148:Grip2_Status]=2 AND R[153]=2,JMP LBL[20] ;
  18:   ;
  19:  IF R[143:Grip1_Status]<>2 AND R[148:Grip2_Status]=2 AND R[153]=2,JMP LBL[15] ;
  20:   ;
  21:  IF R[143:Grip1_Status]=2 AND R[148:Grip2_Status]<>2 AND R[153]=2,JMP LBL[15] ;
  22:   ;
  23:  IF R[143:Grip1_Status]=2 AND R[148:Grip2_Status]=2 AND R[153]<>2,JMP LBL[15] ;
  24:   ;
  25:  IF R[143:Grip1_Status]<>2 AND R[148:Grip2_Status]<>2 AND R[153]=2,JMP LBL[10] ;
  26:   ;
  27:  IF R[143:Grip1_Status]<>2 AND R[148:Grip2_Status]=2 AND R[153]<>2,JMP LBL[10] ;
  28:   ;
  29:  IF R[143:Grip1_Status]=2 AND R[148:Grip2_Status]<>2 AND R[153]<>2,JMP LBL[10] ;
  30:   ;
  31:  MESSAGE[no match in SET_PAYL] ;
  32:  PAUSE ;
  33:  !Choose a safe one ;
  34:  JMP LBL[15] ;
  35:   ;
  36:  LBL[5: No parts] ;
  37:  ! PAYLOAD[1] ;
  38:  R[109]=1    ;
  39:  JMP LBL[50] ;
  40:   ;
  41:  LBL[10: Parts 1 grips] ;
  42:  !Parts in one gripper ;
  43:  ! PAYLOAD[2] ;
  44:  R[109]=2    ;
  45:  JMP LBL[50] ;
  46:   ;
  47:  LBL[15: Parts 2 grips] ;
  48:  !Parts in both grippers ;
  49:  !PAYLOAD[3] ;
  50:  R[109]=3    ;
  51:  JMP LBL[50] ;
  52:   ;
  53:  LBL[20: Parts 3 grip] ;
  54:  !Part in all 3 grippers ;
  55:  !PAYLOAD[4] ;
  56:  R[109]=4    ;
  57:  JMP LBL[50] ;
  58:   ;
  59:  LBL[50] ;
  60:  CALL KARL_RTN('SET_PAYLD',R[109]) ;
/POS
/END
