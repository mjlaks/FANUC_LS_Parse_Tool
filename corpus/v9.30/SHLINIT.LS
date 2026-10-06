/PROG  SHLINIT	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Custom Cold Init";
PROG_SIZE	= 900;
CREATE		= DATE 22-03-26  TIME 13:12:14;
MODIFIED	= DATE 22-03-26  TIME 13:12:14;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 33;
MEMORY_SIZE	= 1448;
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
   8:  !NO MOTION ALLOWED ;
   9:  !This program is called ;
  10:  !after power up to initialize ;
  11:  !registers, markers, etc. ;
  12:  !******************************* ;
  13:  LBL[1:Begin] ;
  14:  !Gripper IO ;
  15:  !If the robot grippers are not ;
  16:  !open, clamp the grippers ;
  17:   ;
  18:  !Gripper 1 ;
  19:  CALL GRPSTAT1    ;
  20:  IF R[143:Grip1_Status]=1,JMP LBL[42] ;
  21:  CALL GRP1_CLMP    ;
  22:  LBL[42] ;
  23:   ;
  24:  !Gripper 2 ;
  25:  CALL GRPSTAT2    ;
  26:  IF R[148:Grip2_Status]=1,JMP LBL[43] ;
  27:  CALL GRP2_CLMP    ;
  28:  LBL[43] ;
  29:   ;
  30:  !Set Clears if at perch ;
  31:  R[104:Curr Perch PR#]=0    ;
  32:  CALL GET_POS    ;
  33:  IF R[104:Curr Perch PR#]<>0,CALL ALL_CLR ;
/POS
/END
