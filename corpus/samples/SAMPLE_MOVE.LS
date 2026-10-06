/PROG  SAMPLE_MOVE
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "Sample moves";
PROG_SIZE	= 0;
CREATE		= DATE 22-03-13  TIME 11:56:56;
MODIFIED	= DATE 22-03-13  TIME 11:56:56;
FILE_NAME	= ;
VERSION		= 0;
LINE_COUNT	= 6;
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
   1:  UFRAME_NUM=1 ;
   2:  UTOOL_NUM=1 ;
   3:J P[1] 100% FINE    ;
   4:L P[2] 500mm/sec CNT50 VOFFSET,VR[1]    ;
   5:J PR[1:Home] 50% CNT100 ACC80    ;
   6:C P[2] 200mm/sec CNT20
    :  P[1] 200mm/sec FINE    ;
/POS
P[1:"Start"]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 0',
	X =   100.000  mm,	Y =     0.000  mm,	Z =   200.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
P[2]{
   GP1:
	UF : 1, UT : 1,		CONFIG : 'N U T, 0, 0, 0',
	X =   150.000  mm,	Y =    50.000  mm,	Z =   200.000  mm,
	W =     0.000 deg,	P =     0.000 deg,	R =     0.000 deg
};
/END
