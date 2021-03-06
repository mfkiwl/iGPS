PRO GET_IGPS_ROOT, IGPS_ROOT=IGPS_ROOT, PROG=PROG
  IF N_ELEMENTS(PROG) EQ 0 THEN BEGIN
    PROG='START_IGPS'
  ENDIF
  
  RELE=FLOAT(!VERSION.RELEASE)
  IF RELE LT 7.0 THEN BEGIN
    HELP,/SOURCE_FILE,OUTPUT=LINES
    FOR I=0,N_ELEMENTS(LINES)-1 DO BEGIN
      POS=STRPOS(LINES[I],PROG)
      IF POS[0] LT 0 THEN CONTINUE
      ;FILE=(STRSPLIT(LINES[I],/EXTRACT))[1]      
      FILE=(STRSPLIT(LINES[I],/EXTRACT))[N_ELEMENTS(STRSPLIT(LINES[I],/EXTRACT))-1]
      BREAK
    ENDFOR
  ENDIF ELSE BEGIN
    FILE=ROUTINE_FILEPATH(PROG) ;NOT AVAILABLE IN IDL VERSION < 7.0
  ENDELSE
  ;STOP
  IF RELE LT 6.4 THEN BEGIN
    IGPS_ROOT=''
    RETURN
  ENDIF ELSE BEGIN
    PATH=FILE_DIRNAME(FILE)
    IGPS_ROOT=FILE_DIRNAME(PATH)
  ENDELSE
  ;PRINT,PATH
  ;PRINT,IGPS_ROOT 

END