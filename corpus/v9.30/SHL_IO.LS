/PROG  SHL_IO	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Concurrent IO";
PROG_SIZE	= 1774;
CREATE		= DATE 22-03-26  TIME 13:12:12;
MODIFIED	= DATE 28-11-03  TIME 05:00:20;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 72;
MEMORY_SIZE	= 2254;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 1,
      ABORT_REQUEST	= 3,
      PAUSE_REQUEST	= 7;
DEFAULT_GROUP	= *,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/MN
   1:  JMP LBL[1] ;
   2:  !******************************** ;
   3:  !COMPANY ;
   4:  !PROJECT 0000000 ;
   5:  !CUSTOMER Example Cell ;
   6:  ! ;
   7:  !Date: March 24, 2022 ;
   8:  !This program is called on a ;
   9:  !timed interrupt basis (100 ms) ;
  10:  !Low performance I/O logic ONLY ;
  11:  ! ;
  12:  !DO NOT USE ANY LONG WAIT ;
  13:  !STATEMEMTS OR REPEAT LOOPS ;
  14:  !******************************** ;
  15:  LBL[1:Begin] ;
  16:   ;
  17:  WAIT   2.00(sec) ;
  18:  R[130]=0    ;
  19:   ;
  20:  !------------------------------- ;
  21:  LBL[2:Dry Run] ;
  22:  !------------------------------- ;
  23:   ;
  24:  !Handle dry run ;
  25:  !if robot uses IO for dry cycle ;
  26:   ;
  27:  IF (DI[41:Dry Run]),R[124:Dry Run]=(1) ;
  28:  IF (!DI[41:Dry Run]),R[124:Dry Run]=(0) ;
  29:   ;
  30:  !------------------------------- ;
  31:  !Update PLC with tool status ;
  32:  !------------------------------- ;
  33:   ;
  34:  IF (DI[63:Spare]) THEN ;
  35:  F[1]=(ON) ;
  36:  ENDIF ;
  37:   ;
  38:  DO[99:Robot 2 Vac On]=(RO[3:Vacuum ON 2]) ;
  39:   ;
  40:   ;
  41:  !Grip1 Blow On ;
  42:  DO[15:Gripper 1 Blow On]=(RO[2:Blowoff ON 1]) ;
  43:   ;
  44:  !Grip1 Vacuum On ;
  45:  DO[17:Gripper 1 Vacuum ON]=(RO[1:Vacuum ON 1]) ;
  46:   ;
  47:  !Grip2 Blow On ;
  48:  DO[16:Gripper 2 Blow On]=(RO[4:Blowoff ON 2]) ;
  49:   ;
  50:  !Grip2 Vacuum On ;
  51:  DO[19:Gripper 2 Vacuum ON]=(RO[3:Vacuum ON 2]) ;
  52:   ;
  53:  !------------------------------- ;
  54:  LBL[30:Complete signals] ;
  55:  !------------------------------- ;
  56:   ;
  57:  !Handle Misc handshake Complete ;
  58:   ;
  59:  !------------------------------- ;
  60:  !User Input Required Output ;
  61:   ;
  62:  !------------------------------- ;
  63:  !Robot override speed ;
  64:  !------------------------------- ;
  65:   ;
  66:  LBL[99] ;
  67:  IF R[130]=1,JMP LBL[100] ;
  68:  WAIT    .20(sec) ;
  69:  JMP LBL[2] ;
  70:  LBL[100] ;
  71:  CALL KCL_CMD('SET VAR [START]','TASKS[1].START_','TRYS=2') ;
  72:  WAIT    .20(sec) ;
/POS
/END
