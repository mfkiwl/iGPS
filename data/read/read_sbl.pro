PRO READ_SBL, FILE, DATA=DATA
  IF N_PARAMS() LT 1 THEN BEGIN
    FILE='sbl\ITRF2000_GPS\ITRF2000_GPS\ECMWF_CME_ITRF2000_GPS_BELL_48622_53186.TXT'
  ENDIF
  ;
  READ_COLS, FILE, DATA=DATA, SKIP=15, HEADERS=HDR
  ;HELP, HDR, DATA
  ;PRINT, HDR
END