PRO LLHXYZ_TO_QOCA_LLH, FILE, OFILE
  IF N_PARAMS() LT 2 THEN BEGIN
    FILE=FILEPATH(ROOT_DIR=!IGPS_ROOT,SUBDIRECTORY=['tables'],'SOPAC.site.log.llhxyz')
    OFILE=DESUFFIX(FILE)+'.list'
  ENDIF
  
  LINES=READ_TXT(FILE)
  NOL=0
  OLINES=''
  FOR LI=0, N_ELEMENTS(LINES)-1 DO BEGIN
    LINE=LINES[LI]
    IF STRMID(LINE,0,1) NE ' ' THEN CONTINUE
  ;*Site            Longitude            Latitude              Height                    X                   Y                   Z
  ; JB01 113.322012035137     38.744997812186   1220.478561137803       -1972383.41921       4574984.13640       3971041.40320
    LINE_P=STRSPLIT(LINE, /EXTRACT)
    SITE=STRUPCASE(LINE_P[0])
    LON=DOUBLE(LINE_P[1])
    LAT=DOUBLE(LINE_P[2])
    HEIGHT=DOUBLE(LINE_P[3])
    OLINE=STRING(SITE,LON,LAT,HEIGHT,FORMAT='(A4,"_GPS",3F20.12)')
    NOL=NOL+1
    IF NOL EQ 1 THEN BEGIN
      OLINES=OLINE
    ENDIF ELSE  BEGIN
      OLINES=[OLINES, OLINE]
    ENDELSE
  ENDFOR
  
  OPENW, FID, OFILE, /GET_LUN
  PRINTF, FID, NOL, FORMAT='(I5)'
  PRINTF, FID, OLINES, FORMAT='(A)'
  FREE_LUN, FID
  
  PRINT,'[LLHXYZ_TO_QOCA_LLH]Normal end.'
END