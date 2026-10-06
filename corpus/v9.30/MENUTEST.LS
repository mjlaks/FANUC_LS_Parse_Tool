/PROG  MENUTEST
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Example menus";
PROG_SIZE	= 546;
CREATE		= DATE 98-06-16  TIME 21:05:02;
MODIFIED	= DATE 05-04-28  TIME 15:49:04;
FILE_NAME	= MENUNANE;
VERSION		= 0;
LINE_COUNT	= 21;
MEMORY_SIZE	= 974;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 7;
DEFAULT_GROUP	= 1,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/APPL
/MN
   1:  !MENUTEST ;
   2:  Clear User Page    ;
   3:   ;
   4:  Prompt Box Msg('NotAtPerch') ;
   5:   ;
   6:  Op. Entry Menu('Chute') ;
   7:   ;
   8:  Prompt Box YN('IsItSafe',21) ;
   9:  IF R[21:Production speed]=0,CALL ABORTIT ;
  10:   ;
  11:  LBL[1] ;
  12:  List Menu('CycleInterup',21) ;
  13:  SELECT R[21:Production speed]=1,JMP LBL[2] ;
  14:         =2,JMP LBL[2] ;
  15:         ELSE,CALL ABORTIT ;
  16:   ;
  17:  LBL[2] ;
  18:  Status Menu('ProductionStatus') ;
  19:   ;
  20:  WAIT  20.00(sec) ;
  21:  JMP LBL[1] ;
/POS
/END
