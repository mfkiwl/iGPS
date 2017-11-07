;+
;
;Modifications:
;  +Tue, Apr 15, 2014  5:47:50 PM; tianyf
;    Update the string processing to speed up the searching for coordinates when
;    the site list is large (e.g. >1000).
;  
;Sample File Format:
;
;*site    longtitude     latitude      height        X             Y               Z
; SUMM    321.5427429631 72.5791880718 3255.10727    1500643.58987 -1191839.08414  6066453.23337   -1.30404 -1.12186 -0.64955 0.00155 0.00162 0.00372 -0.123  0.295 -0.380    0.11276 -1.68952 -0.71680 0.00148 0.00149 0.00379 -0.025  0.162 -0.132 20060521000000 20070805000000  SummitCMP_GL2006
; KELY    309.0551617136 66.9874184175  229.81538    1575559.10260 -1941827.93717  5848076.48520    0.00005  0.00022 -0.00062 0.00042 0.00046 0.00097 -0.515  0.525 -0.552   -0.00012  0.00018 -0.00062 0.00040 0.00031 0.00104 -0.001  0.020  0.044 20040101000000 20070805000000  Kangerlussuaq
; STJO    307.3222504586 47.5952397720  152.84644    2612631.09980 -3426807.04683  4686757.87441    0.00072  0.00094 -0.00034 0.00055 0.00065 0.00080 -0.690  0.620 -0.655    0.00000  0.00114 -0.00046 0.00044 0.00033 0.00103  0.016 -0.049  0.030 20040101000000 20070805000000  St._John's
;-
PRO READ_LLHXYZ, FILE, SITE=SITES, XYZ=XYZS, LLH=LLHS, LINES=LINES_OUT
  ;PRO READ_NEUXYZ, FILE, SITE=SITE, XYZ=XYZ, LLH=LLH
  IF N_PARAMS() LT 1 THEN BEGIN
    FILE=!igps_root+path_sep()+'tables'+path_sep()+'sio.llhxyz'
  ENDIF
  
  ;READ IN ALL LINES
  LINES=READ_TXT(FILE,COMMENT='~ ')
  
  IF N_ELEMENTS(LINES) EQ 1 && LINES[0] EQ '' THEN BEGIN
    PRINT,'[READ_LLHXYZ]WARNING:no content in file <'+FILE+'>!!'
    LLHS=REPLICATE(!VALUES.D_NAN,3)
    XYZS=LLHS
    RETURN
  ENDIF
  
  IF N_ELEMENTS(SITES) GT 0 && STRTRIM(STRJOIN(SITES),2) NE '' THEN BEGIN
    XYZS=DBLARR(3,N_ELEMENTS(SITES))
    LLHS=DBLARR(3,N_ELEMENTS(SITES))
    LINES_OUT=STRARR(N_ELEMENTS(SITES))
    
    ;commented out by tianyf on Tue, Apr 15, 2014  5:47:50 PM
    ;stop
;    FOR SI=0,N_ELEMENTS(SITES)-1 DO BEGIN
;      POS=STRPOS(STRUPCASE(LINES),' '+STRUPCASE(SITES[SI])+' ')
;      IND=WHERE(POS NE -1)
;      IF IND[0] EQ -1 THEN CONTINUE
;      TMP=STRSPLIT(LINES[LAST(IND)],/EXTRACT)
;      LLH=DOUBLE(TMP[1:3])
;      XYZ=DOUBLE(TMP[4:6])
;      XYZS[*,SI]=XYZ
;      LLHS[*,SI]=LLH
;      LINES_OUT[SI]=LINES[LAST(IND)]
;    ENDFOR
;    

    ;edited by tianyf on Tue, Apr 15, 2014  5:47:50 PM
    FOR LI=0ULL,N_ELEMENTS(LINES)-1 DO BEGIN
      LINE=LINES[LI]
      IF STRMID(LINE,0,1) NE ' ' THEN CONTINUE  ;SKIP COMMENT LINES
      LINE_S=STRSPLIT(LINE,/EXTRACT)
      IF N_ELEMENTS(LINE_S) LT 7 THEN CONTINUE  ;SKIP SHORT LINES
      LLH=DOUBLE(LINE_S[1:3])
      XYZ=DOUBLE(LINE_S[4:6])
      SITE=STRMID(LINE_S[0],0,4)
      SI=WHERE(STRUPCASE(SITES) EQ STRUPCASE(SITE))
      IF SI[0] EQ -1 THEN CONTINUE
      XYZS[*,SI]=XYZ
      LLHS[*,SI]=LLH
      LINES_OUT[SI]=LINES[LI]      
    ENDFOR
    
    LLHS=REFORM(LLHS)
    XYZS=REFORM(XYZS)
  ENDIF ELSE BEGIN
    ;STOP
    NL=N_ELEMENTS(LINES)
    SITES=STRARR(NL)
    XYZS=DBLARR(3,NL)
    LLHS=DBLARR(3,NL)
    FOR LI=0, NL-1 DO BEGIN
      LINE=STRSPLIT(LINES[LI],/EXTRACT)
      SITES[LI]=LINE[0]
      LLHS[*,LI]=DOUBLE(LINE[1:3])
      XYZS[*,LI]=DOUBLE(LINE[4:6])
    ENDFOR
    LINES_OUT=LINES
  ENDELSE
  
  ;HELP, SITES, LINES_OUT, XYZS, LLHS
  IF (NOT ARG_PRESENT(SITE)) AND (NOT ARG_PRESENT(FILE)) THEN BEGIN
    HELP,FILE,SITES,LLHS
    ;PRINT,SITES,LLHS
  ENDIF
  
  
END