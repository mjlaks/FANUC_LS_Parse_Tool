/PROG  SET_SLOT_OUT
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Set Slot";
PROG_SIZE	= 1571;
CREATE		= DATE 22-06-20  TIME 10:15:32;
MODIFIED	= DATE 22-06-22  TIME 10:52:30;
FILE_NAME	= SET_SLOT;
VERSION		= 0;
LINE_COUNT	= 64;
MEMORY_SIZE	= 2075;
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
  10:  !tray LD position offsets. ;
  11:  ! ;
  12:  !******************************* ;
  13:  LBL[1:Begin] ;
  14:  !******************************* ;
  15:   ;
  16:  !******************************* ;
  17:  LBL[5:Set X/Y values] ;
  18:  !******************************* ;
  19:   ;
  20:  //R[49:Curr Outfd Cnt]=GI[4:Outfeed Prt Cont]    ;
  21:   ;
  22:  IF (R[49:Curr Outfd Cnt]>=1 AND R[49:Curr Outfd Cnt]<=12) THEN ;
  23:  R[42:Temp Outfeed X]=((R[49:Curr Outfd Cnt]-1)*R[37:Outfeed X Offset]) ;
  24:  R[43:Temp Outfeed Y]=R[38:Outfeed Y Offset]*0    ;
  25:  ENDIF ;
  26:   ;
  27:   ;
  28:  IF (R[49:Curr Outfd Cnt]>=13 AND R[49:Curr Outfd Cnt]<=24) THEN ;
  29:  R[42:Temp Outfeed X]=((R[49:Curr Outfd Cnt]-13)*R[37:Outfeed X Offset]) ;
  30:  R[43:Temp Outfeed Y]=R[38:Outfeed Y Offset]*1    ;
  31:  ENDIF ;
  32:   ;
  33:  IF (R[49:Curr Outfd Cnt]>=25 AND R[49:Curr Outfd Cnt]<=36) THEN ;
  34:  R[42:Temp Outfeed X]=((R[49:Curr Outfd Cnt]-25)*R[37:Outfeed X Offset]) ;
  35:  R[43:Temp Outfeed Y]=R[38:Outfeed Y Offset]*2    ;
  36:  ENDIF ;
  37:   ;
  38:  IF (R[49:Curr Outfd Cnt]>=37 AND R[49:Curr Outfd Cnt]<=48) THEN ;
  39:  R[42:Temp Outfeed X]=((R[49:Curr Outfd Cnt]-37)*R[37:Outfeed X Offset]) ;
  40:  R[43:Temp Outfeed Y]=R[38:Outfeed Y Offset]*3    ;
  41:  ENDIF ;
  42:   ;
  43:   ;
  44:  IF (R[49:Curr Outfd Cnt]>=49 AND R[49:Curr Outfd Cnt]<=60) THEN ;
  45:  R[42:Temp Outfeed X]=((R[49:Curr Outfd Cnt]-49)*R[37:Outfeed X Offset]) ;
  46:  R[43:Temp Outfeed Y]=R[38:Outfeed Y Offset]*4    ;
  47:  ENDIF ;
  48:   ;
  49:  IF R[49:Curr Outfd Cnt]<=0,JMP LBL[900] ;
  50:  IF R[49:Curr Outfd Cnt]>=61,JMP LBL[900] ;
  51:   ;
  52:  !******************************* ;
  53:  LBL[999:End] ;
  54:  !******************************* ;
  55:  END ;
  56:   ;
  57:  !******************************* ;
  58:  LBL[900:Invalid Slot] ;
  59:  !******************************* ;
  60:   ;
  61:  GO[2:Application Fault]=10 ;
  62:  PAUSE ;
  63:  JMP LBL[1] ;
  64:   ;
/POS
/END
