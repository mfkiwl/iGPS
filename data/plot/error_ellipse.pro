;+
; :DESCRIPTION:
;    Calculate error ellipse vertices for plotting GPS velocities in Google Earth (KML).
;
; :PARAMS:
;    SIGX - one sigma uncertainty for the longitude (X) direction
;    SIGY - one sigma uncertainty for the latitude (Y) direction
;    CORRXY - the correlation between SigX and SigY
;
; :KEYWORDS:
;    EEXYS  - Output vertices of rotated and scaled error ellipse
;    NPT  - number of vertices
;    XYS  - original ellipse
;    SF - scaling factor
;
; :AUTHOR: tianyf
;    Crated on Thu, May 12, 2016 10:17:12 PM
;-
PRO ERROR_ELLIPSE, SIGX, SIGY, CORRXY, EEXYS=EEXYS, $
    NPT=NPT, $ ;NUMBER OF POINTS TO DRAW AN ELLIPSE
    XYS=XYS1, $
    SF=SF ;SCALE FACTOR (DEFAULT TO BE A STANDARD ERROR ELLIPSE (39.4% CONFIDENCE)
    
  IF N_PARAMS() LT 3 THEN BEGIN
    SIGY=2.D0
    SIGX=1.D0
    CORRXY=-.8D0
    
    SIGX=1.24800D0
    SIGY=      2.00527D0
    CORRXY=      -.80000000D0
  ENDIF
  
  IF N_ELEMENTS(NPT) EQ 0 THEN NPT=37
  ANG_STEP=360D0/(NPT-1)
  ;PRINT,NPT,ANG_STEP
  ANGS=INDGEN(NPT)*10D0
  
  IF N_ELEMENTS(SF) EQ 0 THEN SF=1
  
  ;THE REFERENCE ELLIPSE
  XS=SIGX*COS(ANGS*!DPI/180)
  YS=SIGY*SIN(ANGS*!DPI/180)
  XYS1=TRANSPOSE([[XS],[YS]])
  
  ;VARIABLE TO STORE THE OUTPUT (ROTATED AND SCALED) ERROR ELLIPSE
  EEXYS=DBLARR(2,NPT)
  
  QXY=CORRXY*SIGX*SIGY
  QXX=SIGX^2
  QYY=SIGY^2
  
  IF (QYY-QXX) GT 1D-6 THEN BEGIN
    THETA=ATAN(2*QXY/(QYY-QXX))
    ;IF THETA LT 0 THEN THETA=THETA+!DPI*2
    
    IF QXY LT 0 AND QYY-QXX GT 0 THEN THETA=THETA+!DPI*2
    IF QXY GT 0 AND QYY-QXX LT 0 THEN THETA=THETA+!DPI
    IF QXY LT 0 AND QYY-QXX LT 0 THEN THETA=THETA+!DPI
    
    THETA=THETA*1D0/2
  ENDIF ELSE BEGIN
    THETA=0D0
  ENDELSE
  ;PRINT,'THETA:',THETA*180/!DPI
  
  QUU=QXX*(SIN(THETA))^2+2*QXY*COS(THETA)*SIN(THETA)+QYY*(COS(THETA))^2
  QVV=QXX*(COS(THETA))^2-2*QXY*SIN(THETA)*COS(THETA)+QYY*(SIN(THETA))^2
  ;PRINT,'QUU,QVV:',QUU,QVV
  
  SV=SQRT(QUU)
  SU=SQRT(QVV)
  
  ;PRINT,'SU:,SV:',SU,SV
  
  US=SU*COS(ANGS*!DPI/180)
  VS=SV*SIN(ANGS*!DPI/180)
  ;PRINT,'US,VS:',US,VS
   
  FOR I=0,N_ELEMENTS(XS)-1 DO BEGIN
    XY1=[US[I],VS[I]]
    TMP2=[XY1[0]*COS(THETA)+XY1[1]*SIN(THETA), -1D0*XY1[0]*SIN(THETA)+XY1[1]*COS(THETA)]
    EEXYS[*,I]=TMP2
  ENDFOR
  
  EEXYS=EEXYS*SF
  
  IF N_PARAMS() LT 3 THEN BEGIN
    WINDOW,2
    PLOT,XS,YS,BACKGROUND='FFFFFF'X,COLOR='0'X,PSYM='-3',XSTYLE=1,YSTYLE=1,  $
      ;XRANGE=[-10,10],YRANGE=[-10,10],  $
      /ISO
    OPLOT,EEXYS[0,*],EEXYS[1,*],COLOR='0000FF'X
  ENDIF
  
END