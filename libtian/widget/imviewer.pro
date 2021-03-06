 
 ;+
 ; :Author: tianyf
 ;-
 ; Some functions are still under developement.
 
 PRO IMVIEWER_DRAW_OVERLAY_RECT, EV
   WIDGET_CONTROL,EV.TOP,GET_UVALUE=ST
   IF ST.XM NE -9999D0 THEN BEGIN
     ;PRINT,ABS(ST.XMOLD-ST.XM)
     IF ABS(ST.XMOLD-ST.XM) LT 180 THEN BEGIN
       OPLOT,[ST.XMOLD,ST.XM,ST.XM,ST.XMOLD,ST.XMOLD], $
         [ST.YMOLD,ST.YMOLD,ST.YM,ST.YM,ST.YMOLD],COLOR='00ffFF'X,THICK=2
     ENDIF ELSE BEGIN
       XMID=(ST.XMOLD+ST.XM)/2D0
       OPLOT,[ST.XMOLD,ST.XMOLD,XMID], $
         [ST.YMOLD,ST.YM,ST.YM],COLOR='00ffFF'X,THICK=2
         
       OPLOT,[XMID,ST.XMOLD], $
         [ST.YMOLD,ST.YMOLD],COLOR='00ffFF'X,THICK=2
       OPLOT,[XMID,ST.XM,ST.XM,XMID], $
         [ST.YM,ST.YM,ST.YMOLD,ST.YMOLD],COLOR='00ffFF'X,THICK=2
     ENDELSE
   ENDIF
 END
 
 
 PRO ON_IMVIEWER_SHOW_GEOG, TLB
   ;HELP, TLB
   WIDGET_CONTROL,TLB,GET_UVALUE=ST;,/NO_COPY
   
   ;GET AND SET CURRENT VIEW
   IF ST.ZOOM_LEVEL EQ 1 THEN BEGIN
     XMIN=ST.XMIN
     YMIN=ST.YMIN
     XMAX=ST.XMAX
     YMAX=ST.YMAX
   ENDIF ELSE BEGIN
     XMIN=ST.XC-((ST.VIEW_XMAX-ST.VIEW_XMIN)/ST.ZOOM_LEVEL)/2
     XMAX=ST.XC+((ST.VIEW_XMAX-ST.VIEW_XMIN)/ST.ZOOM_LEVEL)/2
     YMIN=ST.YC-((ST.VIEW_YMAX-ST.VIEW_YMIN)/ST.ZOOM_LEVEL)/2
     YMAX=ST.YC+((ST.VIEW_YMAX-ST.VIEW_YMIN)/ST.ZOOM_LEVEL)/2
     
     
   ENDELSE
   
   ST.VIEW_XMIN=XMIN
   ST.VIEW_XMAX=XMAX
   ST.VIEW_YMIN=YMIN
   ST.VIEW_YMAX=YMAX
   WIDGET_CONTROL,TLB,SET_UVALUE=ST
   ;PRINT,ST.ZOOM_LEVEL,ST.XC,ST.YC, XMIN,XMAX,YMIN,YMAX
   ;RETURN
   
   OLD_WIN=!D.WINDOW
   ;
   ;HELP,ST,/ST
   WINDOW,0,XSIZE=ST.X_DRAW_SZ,YSIZE=ST.Y_DRAW_SZ,/PIXMAP
   PIXWIN=!D.WINDOW
   ST.WIN_PIXMAP=PIXWIN
   ;PRINT,ST.WIN_PIXMAP
   
   TV,MAKE_ARRAY(VALUE=255^3+255^2+255^1,ST.X_DRAW_SZ,ST.Y_DRAW_SZ)
   ;HELP,GEOG,/ST
   DEVICE, DECOMPOSED=1
   
   
   
   
   ;PRINT,(YMAX+YMIN)/2D0,(XMAX+XMIN)/2D0, YMAX-YMIN,XMAX-XMIN
   ;   IF (YMAX-YMIN) GT 730 || XMAX-XMIN GT 730 THEN BEGIN
   ;     MAP_SET, /LAMBERT, (YMAX+YMIN)/2D0,(XMAX+XMIN)/2D0, 0, $
   ;       LIMIT= [YMIN,XMIN,YMAX,XMAX], $
   ;       COLOR='FFFFFF'X, $
   ;       XMARGIN=3, $
   ;       YMARGIN=2, $
   ;       /NOBORDER, $
   ;       /NOERASE ;, $
   ;   ;POSITION=[.01,.01,.99,.99]
   ;   ENDIF ELSE BEGIN
   MAP_SET, /MERCATOR, (YMAX+YMIN)/2D0,(XMAX+XMIN)/2D0, 0, $
     LIMIT= [YMIN,XMIN,YMAX,XMAX], $
     /GRID, LABEL=1, $
     COLOR='FFFF00'X, $
     XMARGIN=3, $
     YMARGIN=2, $
     CHARSIZE=1.2, $
     /NOERASE
     
   ;   ENDELSE
     
   MAP_HORIZON, COLOR='EE5C0C'X, FILL=1,/HIRES
   ; OVERPLOT COASTLINE DATA:
   MAP_CONTINENTS, /COASTS, COLOR='AAAAAA'X, /FILL_CONTINENTS
   MAP_GRID, /BOX_AXES, COLOR='000000'X,/LABEL,CHARSIZE=.8
   
   ; SHOW NATIONAL BORDERS:
   MAP_CONTINENTS, /COUNTRIES, COLOR='0000FF'X, MLINETHICK=2 $
     ,NLINESTYLE=3
     
     
   WSET,ST.WIN_DIRECT
   DEVICE,COPY=[0,0,ST.X_DRAW_SZ,ST.Y_DRAW_SZ,0,0,PIXWIN]
   
   WIDGET_CONTROL,TLB,SET_UVALUE=ST,/NO_COPY
   
 END
 
 ;-----------------------------------------------------------------
 PRO ON_IMVIEWER_BTN_OK, EV
   WIDGET_CONTROL,EV.TOP,GET_UVALUE=ST,/NO_COPY
   ST.IS_RETURN=1
   WIDGET_CONTROL,EV.TOP,SET_UVALUE=ST,/NO_COPY
   WIDGET_CONTROL,EV.TOP,/DES
 END
 ;-----------------------------------------------------------------
 
 ;-----------------------------------------------------------------
 PRO ON_IMVIEWER_SYS_QUIT, EV
   WIDGET_CONTROL,EV.TOP,GET_UVALUE=ST,/NO_COPY
   ST.IS_RETURN=0
   WIDGET_CONTROL,EV.TOP,SET_UVALUE=ST,/NO_COPY
   WIDGET_CONTROL,EV.TOP,/DES
 END
 ;-----------------------------------------------------------------
 ;
 ;-----------------------------------------------------------------
 FUNCTION ON_IMVIEWER_DRAW_AREA, EV
   ;help,ev,/st
 
   RETURN, EV ; BY DEFAULT, RETURN THE EV.
   
 END
 ;-----------------------------------------------------------------
 
 ;-----------------------------------------------------------------
 PRO ON_IMVIEWER_DRAW_AREA_BTN, EV
   DATAC = CONVERT_COORD(EV.X, EV.Y, /DEVICE, /TO_DATA, /DOUBLE)
   IF EV.PRESS EQ 1 THEN BEGIN
     WIDGET_CONTROL,EV.TOP,GET_UVALUE=ST
     ;PRINT,ST.TOOL_TYPE
     IF ST.TOOL_TYPE EQ 4 THEN BEGIN
       ST.XMOLD=DATAC[0]
       ST.YMOLD=DATAC[1]
       ST.TOOL_DRAW=1
       XM=ST.XM
       WIDGET_CONTROL,EV.TOP,SET_UVALUE=ST,/NO_COPY
       ;PRINT,XM
       IF XM NE -9999D0 THEN BEGIN
         ON_IMVIEWER_SHOW_GEOG,EV.TOP
       ENDIF
     ENDIF
     
   ENDIF
   
   IF EV.RELEASE EQ 1 THEN BEGIN
     WIDGET_CONTROL,EV.TOP,GET_UVALUE=ST
     IF ST.TOOL_TYPE EQ 4 THEN BEGIN
       IMVIEWER_DRAW_OVERLAY_RECT, EV
     ENDIF
     ST.TOOL_DRAW=0
     WIDGET_CONTROL,EV.TOP,SET_UVALUE=ST,/NO_COPY
   ENDIF
 END
 ;-----------------------------------------------------------------
 
 ;-----------------------------------------------------------------
 PRO ON_IMVIEWER_DRAW_AREA_MOTION, EV
   DATAC = CONVERT_COORD(EV.X, EV.Y, /DEVICE, /TO_DATA, /DOUBLE)
   ;PRINT,!ORDER
   IF !ORDER THEN BEGIN
     ;GET CURRENT DRAW WIDGET HEIGHT.
     WDRAWID=WIDGET_INFO(EV.TOP,FIND_BY_UNAME='WID_DRAW_AREA')
     GEO=WIDGET_INFO(WDRAWID,/GEOMETRY)
     ;HELP,GEO,/ST
     EY=GEO.SCR_YSIZE-EV.Y
   ENDIF ELSE BEGIN
     EY=EV.Y
   ENDELSE
   EX=FLOAT(EV.X)
   LL=CONVERT_COORD(EX,EY,/DEV,/TO_DATA,/DOUBLE)
   ;PRINT,EX,EY
   WLABSTA=WIDGET_INFO(EV.TOP,FIND_BY_UNAME='WID_LABEL_STATUS')
   WIDGET_CONTROL, WLABSTA, SET_VALUE='Longitude: '+ $
     STRTRIM(LL(0),2)+'; Latitude: '+STRTRIM(LL(1),2)
     
   ;
   WIDGET_CONTROL, EV.TOP, GET_UVALUE=ST
   CASE ST.TOOL_TYPE OF
     4: BEGIN
       IF ST.TOOL_DRAW EQ 1 THEN BEGIN
         ;STOP
         ;PRINT,ST.XM
         ;STOP
         IF ST.XM NE -9999D0 THEN BEGIN
           WSET, ST.WIN_DIRECT
           DEVICE,COPY=[0,0,ST.X_DRAW_SZ,ST.Y_DRAW_SZ,0,0,ST.WIN_PIXMAP]
         ;PRINT,ST.WIN_PIXMAP
         ;STOP
         ENDIF
         ST.XM=DATAC[0]
         ST.YM=DATAC[1]
         ;ON_IMVIEWER_SHOW_GEOG, EV.TOP
         IF ABS(ST.XMOLD-ST.XM) LT 180 THEN BEGIN
           OPLOT,[ST.XMOLD,ST.XM,ST.XM,ST.XMOLD,ST.XMOLD], $
             [ST.YMOLD,ST.YMOLD,ST.YM,ST.YM,ST.YMOLD],COLOR='00ffFF'X
         ENDIF ELSE BEGIN
           XMID=(ST.XMOLD+ST.XM)/2D0
           OPLOT,[ST.XMOLD,ST.XMOLD,XMID], $
             [ST.YMOLD,ST.YM,ST.YM],COLOR='00ffFF'X
             
           OPLOT,[XMID,ST.XMOLD], $
             [ST.YMOLD,ST.YMOLD],COLOR='00ffFF'X
           OPLOT,[XMID,ST.XM,ST.XM,XMID], $
             [ST.YM,ST.YM,ST.YMOLD,ST.YMOLD],COLOR='00ffFF'X
         ENDELSE
       ENDIF
     END
     ELSE: BEGIN
     END
   ENDCASE
   WIDGET_CONTROL,EV.TOP,SET_UVALUE=ST,/NO_C
 END
 
 
 ;-----------------------------------------------------------------
 PRO ON_IMVIEWER_DRAW_AREA_WHEEL, EV
   ;HELP,EV,/ST
   WIDGET_CONTROL, EV.TOP, GET_UVALUE=ST, /NO_COPY
   ;PRINT,'BEFORE:',ST.ZOOM_LEVEL,EV.CLICKS
   ST.ZOOM_LEVEL=ST.ZOOM_LEVEL*(2D0^EV.CLICKS)
   ST.ZOOM_LEVEL=1 ;;FORCE NO ZOOM NOW
   
   DATAC = CONVERT_COORD(EV.X, EV.Y, /DEVICE, /TO_DATA, /DOUBLE)
   ;PRINT,!ORDER
   IF !ORDER THEN BEGIN
     ;GET CURRENT DRAW WIDGET HEIGHT.
     WDRAWID=WIDGET_INFO(EV.TOP,FIND_BY_UNAME='WID_DRAW_AREA')
     GEO=WIDGET_INFO(WDRAWID,/GEOMETRY)
     ;HELP,GEO,/ST
     EY=GEO.SCR_YSIZE-EV.Y
   ENDIF ELSE BEGIN
     EY=EV.Y
   ENDELSE
   EX=FLOAT(EV.X)
   LL=CONVERT_COORD(EX,EY,/DEV,/TO_DATA,/DOUBLE)
   
   ST.XC=LL[0]
   ST.YC=LL[1]
   ;PRINT,LL
   ;PRINT,'AFTER:',ST.ZOOM_LEVEL
   WIDGET_CONTROL, EV.TOP, SET_UVALUE=ST, /NO_COPY
   
   ON_IMVIEWER_SHOW_GEOG, EV.TOP
   IMVIEWER_DRAW_OVERLAY_RECT, EV
   
 END
 
 ;
 PRO ON_IMVIEWER_RESIZE, EV
   ;STOP
   WIDGET_CONTROL,EV.TOP,GET_UVALUE=INFO
   GEOG=WIDGET_INFO(INFO.BTN_QUIT,/GEOMETRY)
   YOFF=GEOG.SCR_YSIZE
   GEOG=WIDGET_INFO(INFO.LABEL_STATUS,/GEOMETRY)
   YOFF=YOFF*1+GEOG.SCR_YSIZE ;NO TOOL BUTTONS NOW
   WIDGET_CONTROL,INFO.WIN_DIRECT_ID,SCR_XSIZE=EV.X,SCR_YSIZE=EV.Y-YOFF
   INFO.X_DRAW_SZ=EV.X
   INFO.Y_DRAW_SZ=EV.Y-YOFF
   WIDGET_CONTROL,EV.TOP,SET_UVALUE=INFO,/NO_COPY
   ;stop
   ON_IMVIEWER_SHOW_GEOG, EV.TOP
   IMVIEWER_DRAW_OVERLAY_RECT, EV
 END
 
 ;+
 ;
 PRO ON_IMVIEWER_REALIZED, TLB
   WIDGET_CONTROL,TLB,GET_UVALUE=ST
   ;
   WIDGET_CONTROL, ST.WIN_DIRECT_ID, GET_VALUE=WIN_TEMP
   ST.WIN_DIRECT = WIN_TEMP[0]
   ;
   GEOG=ST.GEOG
   WIDGET_CONTROL,TLB,SET_UVALUE=ST,/NO_COPY
   IF GEOG EQ 1 THEN BEGIN
     ON_IMVIEWER_SHOW_GEOG, TLB
   ;
   ;BUGS:
   ;  THE MAP PLOT WILL NOT SHOW UNTIL THE LEFT MOUSE BUTTON HAS BEEN PRESSED AND MOVED.
   ;  OR RESIZE THE WINDOW TO SHOW THE MAP.
   ;   MAYBE THE PROBLEM OF IDL IN LINUX/UNIX.
   ;   IN WINDOWS, THERE IS NO PROBLEMS.
   ;
   ENDIF
   
 END
 ;
 PRO ON_IMVIEWER_KILLED, TLB
   ;COMMON COMM
   WIDGET_CONTROL, TLB, GET_UVALUE=ST, /NO_COPY
   IF ST.IS_RETURN EQ 1 THEN BEGIN
     XMIN=MIN([ST.XMOLD,ST.XM],MAX=XMAX)
     YMIN=MIN([ST.YMOLD,ST.YM],MAX=YMAX)
     !IMVIEWER.RECT=[XMIN,XMAX,YMIN,YMAX]
   ENDIF
 END
 
 PRO IMVIEWER_EVENT, EV
   ;HELP,EV,/ST
   WWIDGET =  EV.TOP
   
   CASE EV.ID OF
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='WID_BASE_IMVIEWER'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BASE' )THEN BEGIN
         ;HELP, EV,/ST
         ON_IMVIEWER_RESIZE, EV
       ENDIF
     END
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='W_MENU_1'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
         ON_IMVIEWER_OPEN_IMG, EV
     END
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='W_MENU_2'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
         ON_IMVIEWER_OPEN_VEC, EV
     END
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='W_MENU_5'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
         ON_IMVIEWER_DISP_EXPORT, EV
     END
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='W_MENU_3'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
         ON_IMVIEWER_DISP_PRINT, EV
     END
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='W_MENU_6'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
         ON_IMVIEWER_SYS_QUIT, EV
     END
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='W_MENU_9'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
         ON_IMVIEWER_ABOUT, EV
     END
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='W_MENU_10'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_BUTTON' )THEN $
         ON_IMVIEWER_HELP, EV
     END
     WIDGET_INFO(WWIDGET, FIND_BY_UNAME='WID_DRAW_AREA'): BEGIN
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_DRAW' )THEN $
         IF( EV.TYPE EQ 0 )THEN $
         ON_IMVIEWER_DRAW_AREA_BTN, EV
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_DRAW' )THEN $
         IF( EV.TYPE EQ 1 )THEN $
         ON_IMVIEWER_DRAW_AREA_BTN, EV
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_DRAW' )THEN $
         IF( EV.TYPE EQ 2 )THEN $
         ON_IMVIEWER_DRAW_AREA_MOTION, EV
       IF( TAG_NAMES(EV, /STRUCTURE_NAME) EQ 'WIDGET_DRAW' )THEN $
         IF( EV.TYPE EQ 7 )THEN $ ;WHELL MOUSE BUTTON
         ON_IMVIEWER_DRAW_AREA_WHEEL, EV
     END
     ELSE:
   ENDCASE
   
 END
 
 PRO IMVIEWER, FILE=IMFNAME, $
     VFILE=VECFNAME, $
     GEOG=GEOG, $
     RECT=RECT, $
     TOOL=TOOL, $
     GROUP_LEADER=WGROUP, $
     _EXTRA=_VWBEXTRA_
   ;
   ;COMMON COMM, RECT
   IMVIEWER={IMVIEWER, RECT: REPLICATE(-9999D0,4)}
   DEFSYSV,'!IMVIEWER',IMVIEWER
   ;SET !ORDER TO 1, WHICH AFFECT THE Y-AXIS START POINT.
   ;OLDORDER=!ORDER
   ;!ORDER=1
   ;
   ;DEFINE SYSTEM PATH VARIABLE
   CD, CURRENT=CURDIR
   ;DEFSYSV, '!VIEWER_PATH',CURDIR
   ;
   ; DRAW WINDOW'S ORIGINAL SIZE
   X_DRAW_SZ=780.
   Y_DRAW_SZ=500.
   IMGDATA=BYTARR(X_DRAW_SZ,Y_DRAW_SZ,3)
   IMGDATA[*,*,*]=255
   
   ;GEOGRAPHIC POSITION CENTER OF THE DRAW AREA
   XC=0D0
   YC=0D0
   ;
   ; CHECH IF FILENAME PRESENTED
   ; FILE NAMES SETTING
   IF N_ELEMENTS(IMFNAME) NE 0 && FILE_TEST(IMFNAME,/REGULAR) EQ 1 THEN BEGIN		; READ IMAGE
     ;
     DUMMY=0
   ENDIF ELSE BEGIN
     FID=-1
     IMFNAME=''
   ENDELSE
   ;
   ;CHECH IF VECTOR FILE PRESENTED ?
   IF N_ELEMENTS(VECFNAME) EQ 0 THEN VECFNAME=''
   ;
   WID_BASE_IMVIEWER = WIDGET_BASE( GROUP_LEADER=WGROUP,  $
     UNAME='WID_BASE_IMVIEWER' ,  $
     TITLE='Map Viewer (Draw a rectangle and hit OK to return; or Cancel to abort)', $
   SPACE=0 ,XPAD=0 ,YPAD=0  $
     ,MBAR=WID_BASE_0_MBAR, $
     NOTIFY_REALIZE='ON_IMVIEWER_REALIZED',MAP=0,/COLUMN, $
     KILL_NOTIFY='ON_IMVIEWER_KILLED', $
     /TLB_SIZE_EVENTS )
     
   ;MENU  DEFINITION
   W_MENU_0 = WIDGET_BUTTON(WID_BASE_0_MBAR, UNAME='W_MENU_0' ,/MENU  $
     ,VALUE='File')
   W_MENU_1 = WIDGET_BUTTON(W_MENU_0, UNAME='W_MENU_1'  $
     ,VALUE='Open Image', SENSITIVE=0)
   W_MENU_2 = WIDGET_BUTTON(W_MENU_0, UNAME='W_MENU_2'  $
     ,VALUE='Open Vector', SENSITIVE=0)
   W_MENU_5 = WIDGET_BUTTON(W_MENU_0, UNAME='W_MENU_5' , $
     VALUE='Export Display', SENSITIVE=0)
   W_MENU_3 = WIDGET_BUTTON(W_MENU_0, UNAME='W_MENU_3' ,/SEPARATOR  $
     ,VALUE='Print', SENSITIVE=0)
   W_MENU_6 = WIDGET_BUTTON(W_MENU_0, UNAME='W_MENU_6' ,/SEPARATOR  $
     ,VALUE='Quit')
   W_MENU_8 = WIDGET_BUTTON(WID_BASE_0_MBAR, UNAME='W_MENU_8' ,/MENU  $
     ,VALUE='Help', SENSITIVE=0)
   W_MENU_9 = WIDGET_BUTTON(W_MENU_8, UNAME='W_MENU_9' ,VALUE='About')
   W_MENU_10 = WIDGET_BUTTON(W_MENU_8, UNAME='W_MENU_10'  $
     ,VALUE='Online Help')
     
   IF N_ELEMENTS(TOOL) EQ 0 THEN TOOL=4
   TOOL_ID=-1
   
   LABEL_STATUS = WIDGET_LABEL(WID_BASE_IMVIEWER,  $
     UNAME='WID_LABEL_STATUS' , $
     SCR_XSIZE=Y_DRAW_SZ,  $
     /ALIGN_RIGHT ,VALUE='Ready.')
   ;DRAWS
   WID_BASE_DRAW = WIDGET_BASE(WID_BASE_IMVIEWER, UNAME='WID_BASE_DRAW'  $
     ,SPACE=0 ,XPAD=0 ,YPAD=0)
     
     
   WID_DRAW_AREA = WIDGET_DRAW(WID_BASE_DRAW, UNAME='WID_DRAW_AREA'  $
     ,SCR_XSIZE=X_DRAW_SZ ,SCR_YSIZE=Y_DRAW_SZ  $
     ,EVENT_FUNC='ON_IMVIEWER_DRAW_AREA' $
     ,/WHEEL_EVENTS ,/BUTTON_EVENTS ,/MOTION_EVENTS, RETAIN=1)
     
     
   BASE_BTNS = WIDGET_BASE(WID_BASE_IMVIEWER,  $
     SPACE=0 ,XPAD=0 ,YPAD=0,/ALIGN_RIGHT,/ROW,UNAME='BASE_BTNS')
   BTN_QUIT=WIDGET_BUTTON(BASE_BTNS,VALUE=' O K ',EVENT_PRO='on_imviewer_btn_ok')
   BTN_QUIT=WIDGET_BUTTON(BASE_BTNS,VALUE='Cancel',EVENT_PRO='ON_IMVIEWER_SYS_QUIT')
   ;STATUS BAR
   
   ;DEFINE ST STRUCT
   VECFNAME=''
   GEOG=1
   IF KEYWORD_SET(GEOG) || (N_ELEMENTS(GEOG) GT 0 && GEOG EQ 1 ) THEN GEOG=1 ELSE GEOG=0
   
   ST={IMGDATA: 	PTR_NEW(IMGDATA),	$
     SCALE:	0L,	$
     ZOOM_LEVEL: 1D0, $     ;CURRENT ZOOM LEVEL
     X:	1L,	$
     Y:	1L,	$
     XC: XC, $  ;CENTER OF CURRENT VIEW
     YC: YC, $
     TOOL_TYPE: TOOL, $
     TOOL_ID:	TOOL_ID	,	$
     TOOL_DRAW: 0, $
     WIN_DIRECT_ID:	WID_DRAW_AREA	,	$
     WIN_OBJECT_ID:	-1	,	$
     STATUS_ID:	LABEL_STATUS	,		$
     WIN_DIRECT:	-1L	,	$
     WIN_PIXMAP: -1L, $
     WIN_OBJECT:	-1L, $
     X_DRAW_SZ:	X_DRAW_SZ,	$
     Y_DRAW_SZ:	Y_DRAW_SZ,	$
     X_IM_SZ:	0L,	$
     Y_IM_SZ:	0L,	$
     ISMAP:	0,	$ ;IS/NOT MAPPED
     FID:	FID,	$
     IMFNAME:	IMFNAME, $
     VECFNAME:	VECFNAME,	$
     CURSOR_MODE:	-1,	$
     GEOG: GEOG, $
     XMOLD: -9999D0, $
     YMOLD: -9999D0, $
     XM:-9999D0, $
     YM:-9999D0, $
     PMAP:PTR_NEW(), $
     LABEL_STATUS: LABEL_STATUS, $
     BTN_QUIT: BTN_QUIT, $
     IS_RETURN: 0, $
     XMIN: -180, $  ;THE WHOLE MAP VIEW
     YMIN: -90, $
     XMAX: 180, $
     YMAX: 90, $
     VIEW_XMIN: -180, $   ;CURRENT MAP VIEW
     VIEW_XMAX: 180, $
     VIEW_YMIN: -90, $
     VIEW_YMAX: 90, $
     DUMMY:	0}
   ;STOP
   WIDGET_CONTROL,WID_BASE_IMVIEWER, SET_UVALUE=ST
   WIDGET_CONTROL,WID_BASE_IMVIEWER, /REALIZE
   
   ;WIDGET_CONTROL,WID_DRAW_AREA_OBJECT,MAP=0
   ;CENTERBASE,WID_BASE_IMVIEWER
   WIDGET_CONTROL,WID_DRAW_AREA,MAP=1
   WIDGET_CONTROL,WID_BASE_IMVIEWER,/MAP
   
   IF ARG_PRESENT(RECT) EQ 1 THEN BEGIN
     XMANAGER, 'IMVIEWER', WID_BASE_IMVIEWER;, /NO_BLOCK
     RECT=!IMVIEWER.RECT
   ENDIF ELSE BEGIN
     XMANAGER, 'IMVIEWER', WID_BASE_IMVIEWER, /NO_BLOCK
   ENDELSE
   
   
 END
