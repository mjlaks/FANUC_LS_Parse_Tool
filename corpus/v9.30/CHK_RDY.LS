/PROG  CHK_RDY	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Check Input Rdy";
PROG_SIZE	= 1668;
CREATE		= DATE 22-03-13  TIME 11:22:24;
MODIFIED	= DATE 22-03-13  TIME 11:22:24;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 60;
MEMORY_SIZE	= 2116;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
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
   2:  !******************************** ;
   3:  !COMPANY ;
   4:  !VENDOR Module ;
   5:  ! Wait for input to commence ;
   6:  ! operation (passed in by AR[1]) ;
   7:  ! or Request to enter or ;
   8:  ! Clear data inputs ;
   9:  !******************************** ;
  10:  LBL[1:Top of Program] ;
  11:   ;
  12:  !Set Register to input to Check ;
  13:  R[164]=AR[1]    ;
  14:  R[6:GRD Ld & UL Time]=0    ;
  15:  IF R[96]=1 AND DO[12:Spare]=OFF,JMP LBL[99] ;
  16:  !Check if pendant enabled ;
  17:  !IF SO[7:TP enb]=ON,JMP LBL[99] ;
  18:   ;
  19:  !Start wait timer ;
  20:  TIMER[5]=RESET ;
  21:  TIMER[5]=START ;
  22:  $WAITTMOUT=100 ;
  23:   ;
  24:  LBL[2] ;
  25:  IF R[164]<>16,JMP LBL[4] ;
  26:  CALL STAT_MSG('OP Command',' from PLC') ;
  27:  IF DI[11:Spare]=OFF,CALL NO_AUTO ;
  28:   ;
  29:  LBL[4: DIWait] ;
  30:  IF R[164]=17,CALL STAT_MSG('Rdy UnLoad',' Station') ;
  31:  IF R[164]=19,CALL STAT_MSG('Clamp Cmplt','Ack ') ;
  32:  IF R[164]=20,CALL STAT_MSG('Rdy Load',' Station') ;
  33:  IF R[164]=22,CALL STAT_MSG('UnClmp Cmplt',' Station') ;
  34:   ;
  35:  !Check for un/clamp req and do no ;
  36:  !respond to enter cell req ;
  37:  IF R[164]<>19 AND R[164]<>22,JMP LBL[6] ;
  38:  WAIT DI[R[164]]=ON OR DI[15:Gripper 2 Vacuum Off]=ON TIMEOUT,LBL[2] ;
  39:  JMP LBL[20] ;
  40:   ;
  41:  LBL[6] ;
  42:  !Wait for inputs ;
  43:  !Including enter cell req ;
  44:  WAIT DI[R[164]]=ON OR DI[10:Manual Mode]=ON OR DI[15:Gripper 2 Vacuum Off]=ON TIMEOUT,LBL[2] ;
  45:  LBL[8] ;
  46:  IF DI[10:Manual Mode]=OFF AND DI[15:Gripper 2 Vacuum Off]=OFF,JMP LBL[20] ;
  47:  IF DI[10:Manual Mode]=OFF,JMP LBL[15] ;
  48:  ! Enter requested ;
  49:  IF SO[7:TP enabled]=ON,JMP LBL[20] ;
  50:  PAUSE ;
  51:  JMP LBL[1] ;
  52:  LBL[15:clear data] ;
  53:  ! set R[6] if not the ;
  54:  ! operation ready signal ;
  55:  R[6:GRD Ld & UL Time]=1    ;
  56:  LBL[20] ;
  57:   ;
  58:  TIMER[5]=STOP ;
  59:  CALL STAT_CLR    ;
  60:  LBL[99:Input is ON] ;
/POS
/END
