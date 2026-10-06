/PROG  MST2PRID	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Map STA To PR ";
PROG_SIZE	= 2212;
CREATE		= DATE 22-03-13  TIME 11:57:14;
MODIFIED	= DATE 22-03-13  TIME 11:57:14;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 87;
MEMORY_SIZE	= 2640;
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
   4:  !PROJECT project_number ;
   5:  !customer ;
   6:  !Robot_Description ;
   7:   ;
   8:  !Map to Station ID To PR ID. ;
   9:   ;
  10:  !Inputs: ;
  11:  !AR[1] - Station ID ;
  12:  !AR[2] - Pos Reg# for Sta Perch ;
  13:  ! ;
  14:  !Stations: ;
  15:  ! 1 = Move to Home ;
  16:  ! 2 = Move to Maintenance ;
  17:  ! 3 = In Machine (NA) ;
  18:  ! 4 = Mach 1 ;
  19:  ! 5 = Mach 2 ;
  20:  ! 6 = Mach 3 ;
  21:  ! 7 = Mach 4 ;
  22:  ! 8 = Mach 5 ;
  23:  ! 9 = Mach 6 ;
  24:  !10 = In Conveyor (NA) ;
  25:  !11 = Infeed Conveyor ;
  26:  !12 = Exit Conv ;
  27:  !13 = Carriage 1 ;
  28:  !14 = Carriage 2 ;
  29:  !15 = Handoff ;
  30:  !16 = Reject/Shuttle ;
  31:  !17 = Part Stand ;
  32:  !******************************** ;
  33:  LBL[1] ;
  34:  CALL GRPSTAT1    ;
  35:   ;
  36:  R[AR[2]]=0    ;
  37:  IF (AR[1]=1),R[AR[2]]=1 ;
  38:  IF (AR[1]=2),R[AR[2]]=2 ;
  39:  IF (AR[1]=3),R[AR[2]]=16 ;
  40:  IF (AR[1]=4),R[AR[2]]=4 ;
  41:  IF (AR[1]=5),R[AR[2]]=5 ;
  42:  IF (AR[1]=6),R[AR[2]]=6 ;
  43:  IF (AR[1]=7),R[AR[2]]=7 ;
  44:  IF (AR[1]=8),R[AR[2]]=8 ;
  45:  IF (AR[1]=9),R[AR[2]]=9 ;
  46:  IF (AR[1]=10),R[AR[2]]=15 ;
  47:  IF (AR[1]=11),R[AR[2]]=3 ;
  48:  IF (AR[1]=12),R[AR[2]]=3 ;
  49:  IF (AR[1]=13),R[AR[2]]=10 ;
  50:  IF (AR[1]=14),R[AR[2]]=11 ;
  51:  IF (AR[1]=15),R[AR[2]]=13 ;
  52:  IF (AR[1]=16),R[AR[2]]=14 ;
  53:  IF (AR[1]=17),R[AR[2]]=17 ;
  54:   ;
  55:  IF R[AR[2]]<>0,JMP LBL[999] ;
  56:   ;
  57:  LBL[500:no match] ;
  58:  Clear User Page    ;
  59:  IF AR[1]=0,JMP LBL[510] ;
  60:  DO[198]=ON ;
  61:  !No PReg assgnd for Statn ;
  62:  !CALL DICT_ALM('CUST_182','WARN') ;
  63:  CALL ALRM_LOG('No PReg assgnd for Statn','WARN') ;
  64:  !CALL DICT_MSG('PGMABORT') ;
  65:  MESSAGE[PROGRAM ABORTED] ;
  66:  ABORT ;
  67:   ;
  68:  LBL[510] ;
  69:  !CALL DICT_MSG('STANOTSET') ;
  70:  macro_14(' ---  LOGIC ERROR ---') ;
  71:  macro_14('Prog MST2PRID Has been called') ;
  72:  macro_14('with a bad value for AR[1]') ;
  73:  macro_14('AR[1] is the station number ') ;
  74:  IF SO[7:TP enabled]=ON,JMP LBL[520] ;
  75:  DO[198]=ON ;
  76:  !Invalid Station ID ;
  77:  !CALL DICT_ALM('CUST_173','WARN') ;
  78:  CALL ALRM_LOG('Invalid Station ID','WARN') ;
  79:  !CALL DICT_MSG('PGMABORT') ;
  80:  MESSAGE[PROGRAM ABORTED] ;
  81:  ABORT ;
  82:   ;
  83:  LBL[520] ;
  84:  PAUSE ;
  85:  ABORT ;
  86:   ;
  87:  LBL[999] ;
/POS
/END
