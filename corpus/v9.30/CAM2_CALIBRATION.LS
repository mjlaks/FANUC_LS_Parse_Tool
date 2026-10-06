/PROG  CAM2_CALIBRATION	  Job
/ATTR
OWNER		= MNEDITOR;
COMMENT		= "CCRG grp:1";
PROG_SIZE	= 6602;
CREATE		= DATE 22-03-26  TIME 08:39:30;
MODIFIED	= DATE 22-03-26  TIME 08:39:30;
FILE_NAME	= INVISIBL;
VERSION		= 0;
LINE_COUNT	= 166;
MEMORY_SIZE	= 6966;
PROTECT		= READ_WRITE;
TCD:  STACK_SIZE	= 0,
      TASK_PRIORITY	= 50,
      TIME_SLICE	= 0,
      BUSY_LAMP_OFF	= 0,
      ABORT_REQUEST	= 0,
      PAUSE_REQUEST	= 0;
DEFAULT_GROUP	= 1,*,*,*,*;
CONTROL_CODE	= 00000000 00000000;
/APPL
/APPL
/MN
   1:  CALL IRVRGUTL(1) ;
   2:L P[1] 1000mm/sec FINE    ;
   3:  VISION CAMERA_CALIB 'CAM2' Request=1 ;
   4:L P[1001] 1000mm/sec FINE    ;
   5:  CALL IRVBKLSH(1) ;
   6:  VISION CAMERA_CALIB 'CAM2' Request=1001 ;
   7:L P[1002] 1000mm/sec FINE    ;
   8:  CALL IRVBKLSH(1) ;
   9:  VISION CAMERA_CALIB 'CAM2' Request=1002 ;
  10:L P[1003] 1000mm/sec FINE    ;
  11:  CALL IRVBKLSH(1) ;
  12:  VISION CAMERA_CALIB 'CAM2' Request=1003 ;
  13:L P[1004] 1000mm/sec FINE    ;
  14:  CALL IRVBKLSH(1) ;
  15:  VISION CAMERA_CALIB 'CAM2' Request=1004 ;
  16:L P[1005] 1000mm/sec FINE    ;
  17:  CALL IRVBKLSH(1) ;
  18:  VISION CAMERA_CALIB 'CAM2' Request=1005 ;
  19:  CALL IRVRGUTL(2) ;
  20:L P[1006] 1000mm/sec FINE    ;
  21:  CALL IRVBKLSH(1) ;
  22:  VISION CAMERA_CALIB 'CAM2' Request=1006 ;
  23:L P[1007] 1000mm/sec FINE    ;
  24:  CALL IRVBKLSH(1) ;
  25:  VISION CAMERA_CALIB 'CAM2' Request=1007 ;
  26:L P[1008] 1000mm/sec FINE    ;
  27:  CALL IRVBKLSH(1) ;
  28:  VISION CAMERA_CALIB 'CAM2' Request=1008 ;
  29:L P[1009] 1000mm/sec FINE    ;
  30:  CALL IRVBKLSH(1) ;
  31:  VISION CAMERA_CALIB 'CAM2' Request=1009 ;
  32:L P[1010] 1000mm/sec FINE    ;
  33:  CALL IRVBKLSH(1) ;
  34:  VISION CAMERA_CALIB 'CAM2' Request=1010 ;
  35:  CALL IRVRGUTL(3) ;
  36:L P[1011] 1000mm/sec FINE    ;
  37:  CALL IRVBKLSH(1) ;
  38:  VISION CAMERA_CALIB 'CAM2' Request=1011 ;
  39:L P[1012] 1000mm/sec FINE    ;
  40:  CALL IRVBKLSH(1) ;
  41:  VISION CAMERA_CALIB 'CAM2' Request=1012 ;
  42:L P[1013] 1000mm/sec FINE    ;
  43:  CALL IRVBKLSH(1) ;
  44:  VISION CAMERA_CALIB 'CAM2' Request=1013 ;
  45:L P[1014] 1000mm/sec FINE    ;
  46:  CALL IRVBKLSH(1) ;
  47:  VISION CAMERA_CALIB 'CAM2' Request=1014 ;
  48:L P[1015] 1000mm/sec FINE    ;
  49:  CALL IRVBKLSH(1) ;
  50:  VISION CAMERA_CALIB 'CAM2' Request=1015 ;
  51:  CALL IRVRGUTL(4) ;
  52:L P[1016] 1000mm/sec FINE    ;
  53:  CALL IRVBKLSH(1) ;
  54:  VISION CAMERA_CALIB 'CAM2' Request=1016 ;
  55:L P[1017] 1000mm/sec FINE    ;
  56:  CALL IRVBKLSH(1) ;
  57:  VISION CAMERA_CALIB 'CAM2' Request=1017 ;
  58:L P[1018] 1000mm/sec FINE    ;
  59:  CALL IRVBKLSH(1) ;
  60:  VISION CAMERA_CALIB 'CAM2' Request=1018 ;
  61:L P[1019] 1000mm/sec FINE    ;
  62:  CALL IRVBKLSH(1) ;
  63:  VISION CAMERA_CALIB 'CAM2' Request=1019 ;
  64:L P[1020] 1000mm/sec FINE    ;
  65:  CALL IRVBKLSH(1) ;
  66:  VISION CAMERA_CALIB 'CAM2' Request=1020 ;
  67:  CALL IRVRGUTL(5) ;
  68:L P[1021] 1000mm/sec FINE    ;
  69:  CALL IRVBKLSH(1) ;
  70:  VISION CAMERA_CALIB 'CAM2' Request=1021 ;
  71:L P[1022] 1000mm/sec FINE    ;
  72:  CALL IRVBKLSH(1) ;
  73:  VISION CAMERA_CALIB 'CAM2' Request=1022 ;
  74:L P[1023] 1000mm/sec FINE    ;
  75:  CALL IRVBKLSH(1) ;
  76:  VISION CAMERA_CALIB 'CAM2' Request=1023 ;
  77:L P[1024] 1000mm/sec FINE    ;
  78:  CALL IRVBKLSH(1) ;
  79:  VISION CAMERA_CALIB 'CAM2' Request=1024 ;
  80:L P[1025] 1000mm/sec FINE    ;
  81:  CALL IRVBKLSH(1) ;
  82:  VISION CAMERA_CALIB 'CAM2' Request=1025 ;
  83:  CALL IRVRGUTL(6) ;
  84:L P[2001] 1000mm/sec FINE    ;
  85:  CALL IRVBKLSH(1) ;
  86:  VISION CAMERA_CALIB 'CAM2' Request=2001 ;
  87:L P[2002] 1000mm/sec FINE    ;
  88:  CALL IRVBKLSH(1) ;
  89:  VISION CAMERA_CALIB 'CAM2' Request=2002 ;
  90:L P[2003] 1000mm/sec FINE    ;
  91:  CALL IRVBKLSH(1) ;
  92:  VISION CAMERA_CALIB 'CAM2' Request=2003 ;
  93:L P[2004] 1000mm/sec FINE    ;
  94:  CALL IRVBKLSH(1) ;
  95:  VISION CAMERA_CALIB 'CAM2' Request=2004 ;
  96:L P[2005] 1000mm/sec FINE    ;
  97:  CALL IRVBKLSH(1) ;
  98:  VISION CAMERA_CALIB 'CAM2' Request=2005 ;
  99:  CALL IRVRGUTL(7) ;
 100:L P[2006] 1000mm/sec FINE    ;
 101:  CALL IRVBKLSH(1) ;
 102:  VISION CAMERA_CALIB 'CAM2' Request=2006 ;
 103:L P[2007] 1000mm/sec FINE    ;
 104:  CALL IRVBKLSH(1) ;
 105:  VISION CAMERA_CALIB 'CAM2' Request=2007 ;
 106:L P[2008] 1000mm/sec FINE    ;
 107:  CALL IRVBKLSH(1) ;
 108:  VISION CAMERA_CALIB 'CAM2' Request=2008 ;
 109:L P[2009] 1000mm/sec FINE    ;
 110:  CALL IRVBKLSH(1) ;
 111:  VISION CAMERA_CALIB 'CAM2' Request=2009 ;
 112:L P[2010] 1000mm/sec FINE    ;
 113:  CALL IRVBKLSH(1) ;
 114:  VISION CAMERA_CALIB 'CAM2' Request=2010 ;
 115:  CALL IRVRGUTL(8) ;
 116:L P[2011] 1000mm/sec FINE    ;
 117:  CALL IRVBKLSH(1) ;
 118:  VISION CAMERA_CALIB 'CAM2' Request=2011 ;
 119:L P[2012] 1000mm/sec FINE    ;
 120:  CALL IRVBKLSH(1) ;
 121:  VISION CAMERA_CALIB 'CAM2' Request=2012 ;
 122:L P[2013] 1000mm/sec FINE    ;
 123:  CALL IRVBKLSH(1) ;
 124:  VISION CAMERA_CALIB 'CAM2' Request=2013 ;
 125:L P[2014] 1000mm/sec FINE    ;
 126:  CALL IRVBKLSH(1) ;
 127:  VISION CAMERA_CALIB 'CAM2' Request=2014 ;
 128:L P[2015] 1000mm/sec FINE    ;
 129:  CALL IRVBKLSH(1) ;
 130:  VISION CAMERA_CALIB 'CAM2' Request=2015 ;
 131:  CALL IRVRGUTL(9) ;
 132:L P[2016] 1000mm/sec FINE    ;
 133:  CALL IRVBKLSH(1) ;
 134:  VISION CAMERA_CALIB 'CAM2' Request=2016 ;
 135:L P[2017] 1000mm/sec FINE    ;
 136:  CALL IRVBKLSH(1) ;
 137:  VISION CAMERA_CALIB 'CAM2' Request=2017 ;
 138:L P[2018] 1000mm/sec FINE    ;
 139:  CALL IRVBKLSH(1) ;
 140:  VISION CAMERA_CALIB 'CAM2' Request=2018 ;
 141:L P[2019] 1000mm/sec FINE    ;
 142:  CALL IRVBKLSH(1) ;
 143:  VISION CAMERA_CALIB 'CAM2' Request=2019 ;
 144:L P[2020] 1000mm/sec FINE    ;
 145:  CALL IRVBKLSH(1) ;
 146:  VISION CAMERA_CALIB 'CAM2' Request=2020 ;
 147:  CALL IRVRGUTL(10) ;
 148:L P[2021] 1000mm/sec FINE    ;
 149:  CALL IRVBKLSH(1) ;
 150:  VISION CAMERA_CALIB 'CAM2' Request=2021 ;
 151:L P[2022] 1000mm/sec FINE    ;
 152:  CALL IRVBKLSH(1) ;
 153:  VISION CAMERA_CALIB 'CAM2' Request=2022 ;
 154:L P[2023] 1000mm/sec FINE    ;
 155:  CALL IRVBKLSH(1) ;
 156:  VISION CAMERA_CALIB 'CAM2' Request=2023 ;
 157:L P[2024] 1000mm/sec FINE    ;
 158:  CALL IRVBKLSH(1) ;
 159:  VISION CAMERA_CALIB 'CAM2' Request=2024 ;
 160:L P[2025] 1000mm/sec FINE    ;
 161:  CALL IRVBKLSH(1) ;
 162:  VISION CAMERA_CALIB 'CAM2' Request=2025 ;
 163:  CALL IRVRGUTL(11) ;
 164:L P[2] 1000mm/sec FINE    ;
 165:  VISION CAMERA_CALIB 'CAM2' Request=2 ;
 166:  CALL IRVRGUTL(12) ;
/POS
P[1]{
   GP1:
	UF : 1, UT : 1,	
	J1=    39.131 deg,	J2=     -.805 deg,	J3=    -4.537 deg,
	J4=      .000 deg,	J5=    94.537 deg,	J6=     -.869 deg
};
P[2]{
   GP1:
	UF : 1, UT : 1,	
	J1=    39.131 deg,	J2=     -.805 deg,	J3=    -4.537 deg,
	J4=      .000 deg,	J5=    94.537 deg,	J6=     -.869 deg
};
P[1001]{
   GP1:
	UF : 1, UT : 1,	
	J1=    27.775 deg,	J2=     3.387 deg,	J3=    -4.438 deg,
	J4=      .000 deg,	J5=    94.438 deg,	J6=   -12.225 deg
};
P[1002]{
   GP1:
	UF : 1, UT : 1,	
	J1=    30.030 deg,	J2=     -.698 deg,	J3=    -4.538 deg,
	J4=      .000 deg,	J5=    94.538 deg,	J6=    -9.970 deg
};
P[1003]{
   GP1:
	UF : 1, UT : 1,	
	J1=    32.606 deg,	J2=    -4.678 deg,	J3=    -4.343 deg,
	J4=      .000 deg,	J5=    94.343 deg,	J6=    -7.394 deg
};
P[1004]{
   GP1:
	UF : 1, UT : 1,	
	J1=    35.563 deg,	J2=    -8.543 deg,	J3=    -3.879 deg,
	J4=      .000 deg,	J5=    93.879 deg,	J6=    -4.437 deg
};
P[1005]{
   GP1:
	UF : 1, UT : 1,	
	J1=    38.974 deg,	J2=   -12.272 deg,	J3=    -3.176 deg,
	J4=      .000 deg,	J5=    93.176 deg,	J6=    -1.027 deg
};
P[1006]{
   GP1:
	UF : 1, UT : 1,	
	J1=    43.830 deg,	J2=   -11.562 deg,	J3=    -3.329 deg,
	J4=      .000 deg,	J5=    93.329 deg,	J6=     3.830 deg
};
P[1007]{
   GP1:
	UF : 1, UT : 1,	
	J1=    40.131 deg,	J2=    -8.104 deg,	J3=    -3.945 deg,
	J4=      .000 deg,	J5=    93.945 deg,	J6=      .131 deg
};
P[1008]{
   GP1:
	UF : 1, UT : 1,	
	J1=    36.890 deg,	J2=    -4.472 deg,	J3=    -4.361 deg,
	J4=      .000 deg,	J5=    94.361 deg,	J6=    -3.110 deg
};
P[1009]{
   GP1:
	UF : 1, UT : 1,	
	J1=    34.044 deg,	J2=     -.694 deg,	J3=    -4.538 deg,
	J4=      .000 deg,	J5=    94.538 deg,	J6=    -5.956 deg
};
P[1010]{
   GP1:
	UF : 1, UT : 1,	
	J1=    31.536 deg,	J2=     3.214 deg,	J3=    -4.449 deg,
	J4=      .000 deg,	J5=    94.449 deg,	J6=    -8.464 deg
};
P[1011]{
   GP1:
	UF : 1, UT : 1,	
	J1=    32.869 deg,	J2=     7.184 deg,	J3=    -4.073 deg,
	J4=      .000 deg,	J5=    94.073 deg,	J6=    -7.131 deg
};
P[1012]{
   GP1:
	UF : 1, UT : 1,	
	J1=    35.303 deg,	J2=     3.321 deg,	J3=    -4.442 deg,
	J4=      .000 deg,	J5=    94.442 deg,	J6=    -4.697 deg
};
P[1013]{
   GP1:
	UF : 1, UT : 1,	
	J1=    38.039 deg,	J2=     -.392 deg,	J3=    -4.541 deg,
	J4=      .000 deg,	J5=    94.541 deg,	J6=    -1.961 deg
};
P[1014]{
   GP1:
	UF : 1, UT : 1,	
	J1=    41.121 deg,	J2=    -3.950 deg,	J3=    -4.401 deg,
	J4=      .000 deg,	J5=    94.401 deg,	J6=     1.121 deg
};
P[1015]{
   GP1:
	UF : 1, UT : 1,	
	J1=    44.598 deg,	J2=    -7.330 deg,	J3=    -4.054 deg,
	J4=      .000 deg,	J5=    94.054 deg,	J6=     4.598 deg
};
P[1016]{
   GP1:
	UF : 1, UT : 1,	
	J1=    48.916 deg,	J2=    -6.237 deg,	J3=    -4.189 deg,
	J4=      .000 deg,	J5=    94.189 deg,	J6=     8.916 deg
};
P[1017]{
   GP1:
	UF : 1, UT : 1,	
	J1=    45.255 deg,	J2=    -3.120 deg,	J3=    -4.454 deg,
	J4=      .000 deg,	J5=    94.454 deg,	J6=     5.255 deg
};
P[1018]{
   GP1:
	UF : 1, UT : 1,	
	J1=    41.977 deg,	J2=      .202 deg,	J3=    -4.542 deg,
	J4=      .000 deg,	J5=    94.542 deg,	J6=     1.977 deg
};
P[1019]{
   GP1:
	UF : 1, UT : 1,	
	J1=    39.043 deg,	J2=     3.707 deg,	J3=    -4.418 deg,
	J4=      .000 deg,	J5=    94.418 deg,	J6=     -.957 deg
};
P[1020]{
   GP1:
	UF : 1, UT : 1,	
	J1=    36.414 deg,	J2=     7.383 deg,	J3=    -4.047 deg,
	J4=      .000 deg,	J5=    94.047 deg,	J6=    -3.586 deg
};
P[1021]{
   GP1:
	UF : 1, UT : 1,	
	J1=    37.400 deg,	J2=    11.516 deg,	J3=    -3.338 deg,
	J4=      .000 deg,	J5=    93.338 deg,	J6=    -2.600 deg
};
P[1022]{
   GP1:
	UF : 1, UT : 1,	
	J1=    39.926 deg,	J2=     7.847 deg,	J3=    -3.983 deg,
	J4=      .000 deg,	J5=    93.983 deg,	J6=     -.074 deg
};
P[1023]{
   GP1:
	UF : 1, UT : 1,	
	J1=    42.724 deg,	J2=     4.368 deg,	J3=    -4.369 deg,
	J4=      .000 deg,	J5=    94.369 deg,	J6=     2.724 deg
};
P[1024]{
   GP1:
	UF : 1, UT : 1,	
	J1=    45.823 deg,	J2=     1.082 deg,	J3=    -4.532 deg,
	J4=      .000 deg,	J5=    94.532 deg,	J6=     5.823 deg
};
P[1025]{
   GP1:
	UF : 1, UT : 1,	
	J1=    49.255 deg,	J2=    -1.997 deg,	J3=    -4.506 deg,
	J4=      .000 deg,	J5=    94.506 deg,	J6=     9.255 deg
};
P[2001]{
   GP1:
	UF : 1, UT : 1,	
	J1=    47.778 deg,	J2=    -1.751 deg,	J3=     9.218 deg,
	J4=      .000 deg,	J5=    80.782 deg,	J6=     7.778 deg
};
P[2002]{
   GP1:
	UF : 1, UT : 1,	
	J1=    45.155 deg,	J2=      .615 deg,	J3=     9.193 deg,
	J4=      .000 deg,	J5=    80.807 deg,	J6=     5.155 deg
};
P[2003]{
   GP1:
	UF : 1, UT : 1,	
	J1=    42.736 deg,	J2=     3.127 deg,	J3=     9.281 deg,
	J4=      .000 deg,	J5=    80.719 deg,	J6=     2.735 deg
};
P[2004]{
   GP1:
	UF : 1, UT : 1,	
	J1=    40.504 deg,	J2=     5.780 deg,	J3=     9.503 deg,
	J4=      .000 deg,	J5=    80.497 deg,	J6=      .503 deg
};
P[2005]{
   GP1:
	UF : 1, UT : 1,	
	J1=    38.445 deg,	J2=     8.577 deg,	J3=     9.880 deg,
	J4=      .000 deg,	J5=    80.120 deg,	J6=    -1.555 deg
};
P[2006]{
   GP1:
	UF : 1, UT : 1,	
	J1=    35.870 deg,	J2=     8.392 deg,	J3=     9.850 deg,
	J4=      .000 deg,	J5=    80.150 deg,	J6=    -4.130 deg
};
P[2007]{
   GP1:
	UF : 1, UT : 1,	
	J1=    37.828 deg,	J2=     5.489 deg,	J3=     9.472 deg,
	J4=      .000 deg,	J5=    80.528 deg,	J6=    -2.173 deg
};
P[2008]{
   GP1:
	UF : 1, UT : 1,	
	J1=    39.958 deg,	J2=     2.724 deg,	J3=     9.259 deg,
	J4=      .000 deg,	J5=    80.741 deg,	J6=     -.042 deg
};
P[2009]{
   GP1:
	UF : 1, UT : 1,	
	J1=    42.277 deg,	J2=      .092 deg,	J3=     9.190 deg,
	J4=      .000 deg,	J5=    80.810 deg,	J6=     2.277 deg
};
P[2010]{
   GP1:
	UF : 1, UT : 1,	
	J1=    44.804 deg,	J2=    -2.403 deg,	J3=     9.244 deg,
	J4=      .000 deg,	J5=    80.756 deg,	J6=     4.804 deg
};
P[2011]{
   GP1:
	UF : 1, UT : 1,	
	J1=    44.413 deg,	J2=    -5.386 deg,	J3=     9.462 deg,
	J4=      .000 deg,	J5=    80.538 deg,	J6=     4.413 deg
};
P[2012]{
   GP1:
	UF : 1, UT : 1,	
	J1=    41.770 deg,	J2=    -2.897 deg,	J3=     9.268 deg,
	J4=      .000 deg,	J5=    80.732 deg,	J6=     1.769 deg
};
P[2013]{
   GP1:
	UF : 1, UT : 1,	
	J1=    39.356 deg,	J2=     -.277 deg,	J3=     9.190 deg,
	J4=      .000 deg,	J5=    80.810 deg,	J6=     -.644 deg
};
P[2014]{
   GP1:
	UF : 1, UT : 1,	
	J1=    37.151 deg,	J2=     2.471 deg,	J3=     9.247 deg,
	J4=      .000 deg,	J5=    80.753 deg,	J6=    -2.849 deg
};
P[2015]{
   GP1:
	UF : 1, UT : 1,	
	J1=    35.134 deg,	J2=     5.345 deg,	J3=     9.458 deg,
	J4=      .000 deg,	J5=    80.542 deg,	J6=    -4.866 deg
};
P[2016]{
   GP1:
	UF : 1, UT : 1,	
	J1=    32.436 deg,	J2=     5.349 deg,	J3=     9.458 deg,
	J4=      .000 deg,	J5=    80.542 deg,	J6=    -7.564 deg
};
P[2017]{
   GP1:
	UF : 1, UT : 1,	
	J1=    34.329 deg,	J2=     2.369 deg,	J3=     9.242 deg,
	J4=      .000 deg,	J5=    80.758 deg,	J6=    -5.671 deg
};
P[2018]{
   GP1:
	UF : 1, UT : 1,	
	J1=    36.407 deg,	J2=     -.490 deg,	J3=     9.192 deg,
	J4=      .000 deg,	J5=    80.808 deg,	J6=    -3.593 deg
};
P[2019]{
   GP1:
	UF : 1, UT : 1,	
	J1=    38.691 deg,	J2=    -3.232 deg,	J3=     9.288 deg,
	J4=      .000 deg,	J5=    80.712 deg,	J6=    -1.309 deg
};
P[2020]{
   GP1:
	UF : 1, UT : 1,	
	J1=    41.205 deg,	J2=    -5.851 deg,	J3=     9.511 deg,
	J4=      .000 deg,	J5=    80.489 deg,	J6=     1.205 deg
};
P[2021]{
   GP1:
	UF : 1, UT : 1,	
	J1=    40.573 deg,	J2=    -8.774 deg,	J3=     9.912 deg,
	J4=      .000 deg,	J5=    80.088 deg,	J6=      .573 deg
};
P[2022]{
   GP1:
	UF : 1, UT : 1,	
	J1=    37.951 deg,	J2=    -6.148 deg,	J3=     9.544 deg,
	J4=      .000 deg,	J5=    80.456 deg,	J6=    -2.049 deg
};
P[2023]{
   GP1:
	UF : 1, UT : 1,	
	J1=    35.585 deg,	J2=    -3.404 deg,	J3=     9.298 deg,
	J4=      .000 deg,	J5=    80.702 deg,	J6=    -4.416 deg
};
P[2024]{
   GP1:
	UF : 1, UT : 1,	
	J1=    33.445 deg,	J2=     -.547 deg,	J3=     9.192 deg,
	J4=      .000 deg,	J5=    80.808 deg,	J6=    -6.556 deg
};
P[2025]{
   GP1:
	UF : 1, UT : 1,	
	J1=    31.506 deg,	J2=     2.420 deg,	J3=     9.244 deg,
	J4=      .000 deg,	J5=    80.756 deg,	J6=    -8.495 deg
};
/END
