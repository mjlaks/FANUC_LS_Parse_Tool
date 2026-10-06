/PROG  CHK1_UCLMP	  Macro
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Chk Grip unclamp";
PROG_SIZE	= 1732;
CREATE		= DATE 22-03-13  TIME 11:22:38;
MODIFIED	= DATE 22-03-13  TIME 11:22:38;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 66;
MEMORY_SIZE	= 2260;
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
   8:  !Check for gripper(s) Unclamp ;
   9:  !and empty ;
  10:   ;
  11:  !R[143] for grip status ;
  12:  !0 = undefined ;
  13:  !1 = gripper is Unclamp ;
  14:  !2 = grippr clampd, part present ;
  15:  !3 = grippr past clampd, no part ;
  16:  !4 = grip not op/clampd, w/part ;
  17:  !5 = grip clampd, w/part ;
  18:  !******************************* ;
  19:  LBL[1:Begin] ;
  20:   ;
  21:  CALL GRPSTAT1    ;
  22:   ;
  23:  IF R[143:Grip1_Status]<>1,JMP LBL[500] ;
  24:   ;
  25:  LBL[100:End] ;
  26:  END ;
  27:   ;
  28:   ;
  29:  !******************************* ;
  30:  !******* FAULT HANDLING ******** ;
  31:  !******************************* ;
  32:  LBL[500] ;
  33:  Clear User Page    ;
  34:   ;
  35:  R[137:Gripper Num]=1    ;
  36:  IF R[143:Grip1_Status]=2,JMP LBL[520] ;
  37:  JMP LBL[510] ;
  38:   ;
  39:   ;
  40:  ! Check for parts ;
  41:  LBL[510:Grip Not Unclamp] ;
  42:  CALL ALRM_LOG('Gripper not Unclamped',' as expected ','WARN',137,9) ;
  43:  DO[198]=ON ;
  44:  GO[7]=28 ;
  45:  !Question: Unclamp gripper? ;
  46:  CALL PROMPTYN_PSG('CONF_EMPTY2',117) ;
  47:  WAIT R[116]=1    ;
  48:  IF R[117]<>1,JMP LBL[950] ;
  49:  GO[7]=0 ;
  50:  DO[198]=OFF ;
  51:  CALL GRP1_RELS    ;
  52:  JMP LBL[1] ;
  53:   ;
  54:  LBL[520:Grip Not Empty] ;
  55:  !Gripper %s should be empty but ;
  56:  !part was detected ;
  57:  CALL ALRM_LOG('Gripper should be ','empty but ','APPEND',137,9) ;
  58:  CALL ALRM_LOG('part was ','detected ','WARN') ;
  59:  !Gripper is FULL in unload progra ;
  60:  macro_14('Gripper is FULL in unload program') ;
  61:  DO[198]=ON ;
  62:  GO[7]=28 ;
  63:   ;
  64:  LBL[950] ;
  65:  MESSAGE[  Program  Aborting] ;
  66:  ABORT ;
/POS
/END
