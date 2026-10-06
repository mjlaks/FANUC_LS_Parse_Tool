/PROG  IRV_SYNTH
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "synthetic vision";
PROG_SIZE	= 0;
CREATE		= DATE 26-10-06  TIME 12:00:00;
MODIFIED	= DATE 26-10-06  TIME 12:00:00;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 16;
MEMORY_SIZE	= 0;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= 1,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/MN
   1:  !Synthetic fixture: iRVision syntax is taken from the project brief ;
   2:  !and is UNVERIFIED against the V9.x iRVision manual. ;
   3:  UFRAME_NUM=1 ;
   4:  UTOOL_NUM=1 ;
   5:  VISION RUN_FIND 'FIND_PART' ;
   6:  VISION GET_NFOUND 'FIND_PART' R[10:found] ;
   7:  IF R[10:found]=0,JMP LBL[99] ;
   8:  VISION GET_OFFSET 'FIND_PART' VR[1] JMP LBL[99] ;
   9:  J P[1] 50% FINE ;
  10:  L P[2] 250mm/sec FINE VOFFSET,VR[1]    ;
  11:  R[11:model]=VR[1].MODELID ;
  12:  PR[5:offs]=VR[1].OFFSET ;
  13:  JMP LBL[100] ;
  14:  LBL[99:not found] ;
  15:  R[12:err]=1 ;
  16:  LBL[100:end] ;
/POS
P[1]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =   100.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[2]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 0',
	X =     0.000  mm,	Y =     0.000  mm,	Z =     0.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
/END
