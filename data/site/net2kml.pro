PRO NET2KML, FILE, $ ;input, QOCA a priori sites coordiantes (Network file format).
    OFILE  ;output [optional]. if not given, a filename with kml as suffix will be used automatically.
    
  PROG=(STRSPLIT(LAST(SCOPE_TRACEBACK()),/EXTRACT))[0]
  
  IF N_ELEMENTS(file) EQ 0 THEN BEGIN
    file='D:\gsar\asc\mila1\asc_F1\SBAS4\nc.detrend\outp\sites.net'
    file='D:\gsar\des\mila4\des_F1\SBAS4\sites.net'
    file='D:\ICD\projects\DirectorFund\Application.2012\Field\2017sep\pre-field\sites\tibet.icd.net'
  ENDIF
  
  IF N_ELEMENTS(OFILE) EQ 0 THEN BEGIN
    OFILE=DESUFFIX(FILE)+'.kml'
    PRINT,'['+PROG+']WARNING: no output filename given! Using default ('+ofile+').'
  ENDIF
  
  READ_NET, FILE, SITE=SITES,LLH=LLHS
  ;stop
  ;SITES=SITES+'_14gg'
  ;SITES=SITES+'_2015gg'
  ;SITES=SITES+'_b'
  POS=WHERE(LLHS[0,*] NE 0 AND LLHS[1,*] NE 0)
  IF POS[0] EQ -1 THEN BEGIN
    PRINT,'['+PROG+']ERROR: no valid output!!'
    RETURN
  ENDIF
  LLHS=LLHS[*,POS]
  SITES=SITES[POS]
  ;
  WRITE_SITE_KML,OFILE,SITES=SITES,LLH=LLHS
  
END