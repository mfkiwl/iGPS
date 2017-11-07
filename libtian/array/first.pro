;+
; NAME:
;		FIRST
;
; PURPOSE:
;		GET THE FIRST ELEMENT OF VECTOR.
;
; CALLING SEQUENCE:
;		X=FIRST(ARR [,N])
;
; PARAMETERS:
;		ARR	-	ONE-DIMENSION VECTOR TO EXTRACT.
;
; KEYWORDS:
;		N	-	OPTIONAL. USED FOR RETURN FIRST N ELEMENTS.
;
; MODIFICATION HISTORY:
;		WRITTEN BY YUNFENG, TIAN. FRI JUN 13 2003.
;   MOD MAY-07-2008 TIAN
;     FIXED A BUG: THE FIRST() ALWAYS RETURN THE LAST ELEMENT.
;
;-
;+++
FUNCTION FIRST, ARRAY, N, LAST=LAST
  ;HELP, LAST
  ;PRINT,ARG_PRESENT(LAST)
  ;PRINT,KEYWORD_SET(LAST)
  IF N_PARAMS() EQ 1 THEN BEGIN
    IF KEYWORD_SET(LAST) NE 1 THEN BEGIN
      ;PRINT,'RETURN FIRST ELEMENT'
      RETURN,ARRAY(0)
    ENDIF ELSE BEGIN
      ;PRINT,'RETURN LAST ELEMENT'
      RETURN, ARRAY[N_ELEMENTS(ARRAY)-1]
    ENDELSE
  ENDIF
  ;
  IF N_PARAMS() EQ 2 THEN BEGIN
    IF N LT 0 THEN N=0
    NN=N_ELEMENTS(ARRAY)
    IF N GT NN THEN N=NN
    RETURN, ARRAY(0:N-1)
  ENDIF
  ;
  RETURN,-1
END
;///
PRO FIRST
  PRINT,'FIRST IS A FUNCTION.'
  PRINT,'USAGE: RET=FIRST(ARRAY)'
  PRINT,'EXAMPLE:'
  PRINT,'	PRINT,FIRST(INDGEN(3)) '
  PRINT,'YOU WILL GET:'
  PRINT,FIRST(INDGEN(3))
  PRINT,''
  PRINT,FIRST(INDGEN(3),/LAST)
  PRINT,FIRST(INDGEN(3),LAST=1)
  PRINT,FIRST(INDGEN(3),LAST=0)
END