;MODIFICATIONS:
;   + Mon, Feb 24, 2014 10:38:25 AM BY TIANYF
;     o_ FIX A BUG WHEN DERIVING AMPLITUDE SIGMA (OUTPUT MULTIPLIED BY SIN(!DPI/4))
;
PRO ANNSEMI2PSVELO,PATH,OPATH, $
    NEUSTR=NEUSTR, $
    FILES=FILES
    
  IF N_PARAMS() LT 2 && N_ELEMENTS(FILES) EQ 0 THEN BEGIN
    PATH=DIALOG_PICKFILE(/READ,/DIRECTORY)
    IF PATH EQ '' THEN RETURN
    CD,PATH
    OPATH=DIALOG_PICKFILE(/WRITE,/DIRECTORY)
    IF OPATH EQ '' THEN RETURN
    CD,OPATH
    
  ENDIF
  
  
  IF N_ELEMENTS(NEUSTR) EQ 0 THEN NEUSTR=STRUPCASE(['n','e','u'])
  IF N_ELEMENTS(FILES) EQ 0 THEN BEGIN
    FILES=FILE_SEARCH(PATH+PATH_SEP()+'STAT.MODEL.plot.?',COUNT=NF)
  ENDIF ELSE BEGIN
    NF=N_ELEMENTS(FILES)
    OPATH=GETPATHNAME(FILES[0])
  ENDELSE
  ;PRINT,'NF:',NF
  ;PRINT,FILES
  IF NF LE 0 THEN RETURN
  
  FOR FI=0,NF-1 DO BEGIN
    DATA=READ_TXT(FILES[FI],COMMENT='~ ')
    DATA=STR_LINES2ARR(DATA)
    ;HELP,DATA
    ;STOP
    OFILE=OPATH+PATH_SEP()+GETFILENAME(FILES[FI])+'_PSVELO'
    ;OPENW,FID,OFILE,/GET_LUN
    OPENW,FID,OFILE,/GET_LUN
    WRITE_SYS_INFO,FID,PROG='ANNSEMI2PSVELO',SRC=[FILES[FI]],USER=USER
    PRINTF,FID,'longitude','latitude','east_amp','north_amp','east_sig','north_sig','corr','site', $
      FORMAT='("*",2(1X,A20),1X,4(1X,A10),1X,A10,1X,A4)'
    FOR SI=0,N_ELEMENTS(DATA[0,*])-1 DO BEGIN
      AMP=DOUBLE(DATA[3,SI])
      PHA=DOUBLE(DATA[2,SI])*!DPI/180D0
      IF PHA LT 0 THEN PHA=PHA+!DPI*2
      ERRAMP=0
      ERRAMP=DOUBLE(DATA[5,SI])
      IF PHA GE 0 && PHA LT !DPI/2 THEN BEGIN
        NAMP=AMP*SIN(PHA)
        EAMP=AMP*COS(PHA)
        ERRNAMP=ERRAMP*SIN(PHA)
        ERREAMP=ERRAMP*COS(PHA)
      ENDIF
      IF PHA GE !DPI/2 && PHA LT !DPI THEN BEGIN
        NAMP=AMP*SIN(!DPI-PHA)
        EAMP=-1*AMP*COS(!DPI-PHA)
        ERRNAMP=ERRAMP*SIN(!DPI-PHA)
        ERREAMP=-1*ERRAMP*COS(!DPI-PHA)
      ENDIF
      IF PHA GE !DPI && PHA LT !DPI*3/2 THEN BEGIN
        NAMP=-1*AMP*SIN(PHA-!DPI)
        EAMP=-1*AMP*COS(PHA-!DPI)
        ERRNAMP=-1*ERRAMP*SIN(PHA-!DPI)
        ERREAMP=-1*ERRAMP*COS(PHA-!DPI)
      ENDIF
      IF PHA GE !DPI*3/2 && PHA LT !DPI*2 THEN BEGIN
        NAMP=-1*AMP*SIN(!DPI*2-PHA)
        EAMP=AMP*COS(!DPI*2-PHA)
        ERRNAMP=-1*ERRAMP*SIN(!DPI*2-PHA)
        ERREAMP=ERRAMP*COS(!DPI*2-PHA)
      ENDIF
      ;ERRAMP=0
      ;PRINTF,FID,DATA[0:1,SI],EAMP*1D3,NAMP*1D3,ERRAMP*1D3*SIN(!DPI/4),ERRAMP*1D3*SIN(!DPI/4),0.,DATA[4,SI],$
      PRINTF,FID,DATA[0:1,SI],EAMP*1D0,NAMP*1D0,ERRAMP*1D0*SIN(!DPI/4),ERRAMP*1D0*SIN(!DPI/4),0.,DATA[6,SI],$
        ;;PRINTF,FID,LLH[0],LLH[1],EAMP,NAMP,ERRAMP*SIN(!DPI/4),ERRAMP*SIN(!DPI/4),0.,SITE,$
        ;PRINTF,FID,DATA[0:1,SI],EAMP*1D3,NAMP*1D3,ERRAMP*SIN(!DPI/4),ERRAMP*SIN(!DPI/4),0.,DATA[4,SI],$
        ;PRINTF,FID,DATA[0:1,SI],EAMP*1D3,NAMP*1D3,ERRAMP*SIN(!DPI/4),ERRAMP*SIN(!DPI/4),0.,'',$
        FORMAT='(1X,2(1X,A20),1X,4(1X,F10.5),1X,F10.5,1X,A4)'
    ENDFOR
    FREE_LUN,FID
  ENDFOR
  PRINT,'[ANNSEMI2PSVELO]Normal end.',$
    FORMAT='(A)'
    
END