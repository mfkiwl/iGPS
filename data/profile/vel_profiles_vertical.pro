PRO VEL_PROFILEs_VERTICAL, vfile, pfile, opath
    
  PROG=(STRSPLIT(LAST(SCOPE_TRACEBACK()),/EXTRACT))[0]
  
  IF N_PARAMS() LT 3 THEN BEGIN
    vfile='D:\gpse\rerun.lutai\comb\trnsLTCM\gsoln\qmap.tibet.cgps.tseri\lsq_velo.cgps'
    pfile='D:\Papers\uplift.himalaya\figure\uplift.himalaya.profile\lll_p.txt'
    opath='D:\Papers\uplift.himalaya\figure\uplift.himalaya.profile\profiles'
    opath_t=opath
    
    ;for bj
    vfile='D:\gpse\rerun.lutai\comb\trnsLTCM2\gsoln\pos.neu.bj\velpot\VEL.MODEL_U'
    ;ffile='D:\gpse\rerun.lutai\comb\trnsLTCM2\gsoln\pos.neu.bj\profile\fa_bj.txt'
    pfile='D:\gpse\rerun.lutai\comb\trnsLTCM2\gsoln\pos.neu.bj\profile\p_bj_ew.txt'
    opath='D:\gpse\rerun.lutai\comb\trnsLTCM2\gsoln\pos.neu.bj\profile\pv.u'
    
    ;for mht
    vfile='D:\ICD\相关课题\IAA\figure\1.nepal.interseismic\pv\VEL.MODEL_U.cgps_sgps'
    fa='mft'
    opath='D:\ICD\相关课题\IAA\figure\1.nepal.interseismic\pv'
    
    vfile='D:\ICD\相关课题\IAA\figure\3.wenchuan.interseismic\vel_up.txt'
    fa='longmenshan'
    opath='D:\ICD\相关课题\IAA\figure\3.wenchuan.interseismic\pv'
    
    PROFILE_NAME2VECTORFILE,   $
      fa,   $ ;input, fault name
      ffile=ffile,  $ ;output, fault file
      pfile=pfile ;output, profile file
  ENDIF
  
  IF FILE_TEST(opath,/directory) NE 1 THEN FILE_MKDIR,opath
  IF N_ELEMENTS(out_plot) EQ 0 THEN out_plot=0
  
  ;first,
  ;read profiles
  lines=read_txt(pfile)
  np=0
  pxys=-9999d0
  MaxDist=180d0 ;maximum searching distance beside the profile line, in kilometers
  
  FOR li=0, N_ELEMENTS(lines)-1 DO BEGIN
    line=lines[li]
    line=STRTRIM(line,2)
    
    ;if strmid(line,0,1) ne ' ' && strmid(line,0,1) ne '>' then begin  ;skip comment lines
    ;  continue
    ;endif
    
    ;separator
    IF STRMID(line,0,1) EQ '>' THEN BEGIN
      CONTINUE
    ENDIF
    
    ;starting point
    line_p1=STRSPLIT(line,/extract)
    IF N_ELEMENTS(line_p1) LT 2 THEN BEGIN
      CONTINUE
    ENDIF
    xy1=DOUBLE(line_p1)
    
    ;ending point
    line=lines[li+1]
    line_p2=STRSPLIT(line,/extract)
    xy2=DOUBLE(line_p2)
    
    IF pxys[0] EQ -9999 THEN BEGIN
      pxys=[[xy1],[xy2]]
    ENDIF ELSE BEGIN
      pxys=[[[pxys]], [[[[xy1],[xy2]]]] ]
    ENDELSE
    
    li=li+1
    np=np+1
    
  ENDFOR
  
  
  
  ;read fault vector (if specified)
  IF N_ELEMENTS(ffile) GT 0 && ffile NE '' THEN BEGIN
    lines_fvec=read_txt(ffile)
    lines_fvec2=STRTRIM(lines_fvec,2)
    pos=WHERE(strmids(lines_fvec2,0,1) NE '>')
    IF N_ELEMENTS(pos) LT 2 THEN BEGIN
      PRINT,'['+prog+']ERROR: invalid fault line vector file <'+ffile+'>!!'
      RETURN
    ENDIF
    xys_fvec=DOUBLE(str_lines2arr(lines_fvec2[pos]))
    OPLOT,xys_fvec[0,*],xys_fvec[1,*],psym='-4',color='0000ff'x
  ;stop
  ENDIF
  
  ;read velocity field
  ;Site Long  Lat Vn  Sn  Ve  Se  Cne
  ;H095  102.232 27.8745 -10.8 1.3 10.5  1.3 0.0064
  ;stop
  lines=read_txt(vfile,comment='~ ')
  lines1=lines[0:*]
  ;pos=WHERE(strmids(lines,0,1) EQ ' ')
  ;lines1=lines[pos]
  lines1=str_lines2arr(lines1)
  ;
  ;  ;for qoca velo output format
  ;  sites=strmids(lines1[11,*],0,4)
  ;  lls=DOUBLE(lines1[0:1,*])
  ;  vels=DOUBLE(lines1[7:8,*])  ;stop
  ;
  ;for qmap velocity format
  sites=strmids(lines1[0,*],0,4)
  lls=DOUBLE(lines1[1:2,*])
  vels=DOUBLE(lines1[3:4,*])  ;stop
  
  nsit=N_ELEMENTS(sites)
  ;STOP
  
  xmin=MIN(lls[0,*],max=xmax)
  ymin=MIN(lls[1,*],max=ymax)
  rect=[Xmin, Ymin, Xmax, Ymax]
  ;  rect=[Xmin-1, Ymin-1, Xmax+1, Ymax+1] ;enlarge the rect range
  ;stop
  ;loop for each profile
  WINDOW,2,xsize=800,ysize=600,title='Map';,/pixmap
  !p.MULTI=-1
  DEVICE,decomposed=1
  PLOT,lls[0,*],lls[1,*],psym=1,background='ffffff'x,color='0'x, $
    ;title=sites[si], $
    /ynozero,/iso
  IF N_ELEMENTS(ffile) GT 0 && ffile NE '' THEN BEGIN
    OPLOT,xys_fvec[0,*],xys_fvec[1,*],psym='-4',color='0000ff'x
  ;stop
  ENDIF
  
  FOR pi=0,np-1 DO BEGIN
    xys=REFORM(pxys[*,*,pi])
    xy1=xys[*,0]
    xy2=xys[*,1]
    
    a1=xy1
    b1=xy2
    
    OPLOT,[xy1[0],xy2[0]], [xy1[1],xy2[1]], color='ff0000'x
    ;

    
    ;get the intersect point of fault lines (xys_fvec) and current profile (a1,b1)
    IF N_ELEMENTS(ffile) NE 0 && ffile NE '' THEN BEGIN
      xy3=GET_INTERSECT_POINT_BETWEEN_FAULT_AND_PROFILE(xys_fvec,a1,b1)
    ;if no intersection between profile and fault line, it returns null result.
    ;stop
    ENDIF ELSE BEGIN
      ;find the central point of current fault line
      xy3=(xy1+xy2)*.5d0
      IF N_ELEMENTS(flon) NE 0 THEN xy3[0]=flon
      IF N_ELEMENTS(flat) NE 0 THEN xy3[1]=flat
    ENDELSE

    ;get the azimuth, positive: from east, ccw(counter-clockwise)
    alpha=ATAN(b1[1]-a1[1], b1[0]-a1[0])
    IF alpha LT 0 THEN BEGIN
      alpha=alpha+!dpi
    ENDIF
    PRINT,'profile ',pi+1,' angle:',alpha*180d0/!dpi
    
    XYOUTS,(a1[0]+b1[0])*.5d0,(a1[1]+b1[1])*.5d0, $
      STRTRIM(alpha*180d0/!dpi,2),color='0000ff'x
    ;stop
      
    ;CONTINUE
      
      
    ;find adjacent stations
    dists=DBLARR(nsit)
    p_lls=DBLARR(2,nsit)
    dists_fault=DBLARR(nsit)
    FOR si=0, nsit-1 DO BEGIN
      c1=lls[*,si]
      
      POINT_PERP_LINE,  a1,b1, c1, d1
      x0=d1[0]
      y0=d1[1]
      IF x0 EQ c1[0] AND y0 EQ c1[1] THEN BEGIN
        ;no intersect found?
        STOP
        CONTINUE
      ENDIF
      d1=[x0,y0]
      ;LINT, a1, b1, c1, d1, i1, i2
      POINT_CROSS_LINE, a1, b1, c1, (d1[1]-c1[1])/(d1[0]-c1[0]),i1
      
      IF N_ELEMENTS(out_plot) NE 0 && Out_Plot EQ 1 THEN BEGIN
        WINDOW,1,xsize=800,ysize=600,title='Map',/pixmap
        ;stop
        DEVICE,decomposed=1
        PLOT,vels[0,*],vels[1,*],psym=1,background='ffffff'x,color='0'x, $
          title=sites[si], $
          /ynozero,/iso
        OPLOT,[a1[0],b1[0]], [a1[1],b1[1]], color='ff0000'x
        OPLOT,[c1[0],d1[0]],[c1[1],d1[1]],color='0000ff'x
        PLOTS,c1[0],c1[1],psym=6,color='0000ff'x,symsize=1
        PLOTS,d1[0],d1[1],psym=6,color='ff00ff'x,symsize=1
        PLOTS,a1[0],a1[1],psym=2,color='0000ff'x,symsize=1
        PLOTS,b1[0],b1[1],psym=2,color='0000ff'x,symsize=1
        PLOTS,i1[0],i1[1],psym=5,color='0000ff'x,symsize=2
        ;PLOTS,i2[0],i2[1],psym=5,color='ff00ff'x,symsize=2
        XYOUTS,c1[0],c1[1],sites[si],color='0'x
        OPLOT,[c1[0],i1[0]],[c1[1],i1[1]],color='00ff00'x,linestyle=2,thick=2
        ofile=opath_t+PATH_SEP()+sites[si]+'_dist.jpg'
        WRITE_JPEG, ofile, TVRD(true=1),true=1,quality=100
      ENDIF
      
      IF i1[0] LT MIN([a1[0],b1[0]]) || i1[0] GT MAX([a1[0],b1[0]]) THEN BEGIN  ;outside profile
        ;stop
        CONTINUE
      ENDIF
      
      tmp=MAP_2POINTS(c1[0],c1[1],i1[0],i1[1],/meters)
      dists[si]=tmp*1d-3  ;in km
      p_lls[*,si]=i1
      
      ;distance from gps site to fault line
      tmp=MAP_2POINTS(xy3[0],xy3[1],i1[0],i1[1],/meter)
      dists_fault[si]=tmp*1d-3*(i1[0]-xy3[0])/ABS(i1[0]-xy3[0])
    ;stop
      
    ENDFOR
    
    pos=WHERE(dists GT 0 AND dists LE MaxDist)
    IF pos[0] EQ -1 THEN BEGIN  ;no velocity
      CONTINUE
    ENDIF
    
    WINDOW,1,xsize=800,ysize=600,title='Map';,/pixmap
    DEVICE,decomposed=1
    PLOT,lls[0,*],lls[1,*],psym=1,background='ffffff'x,color='0'x, $
      ;title=sites[si], $
      /ynozero,/iso
    OPLOT,[a1[0],b1[0]], [a1[1],b1[1]], color='ff0000'x
    PLOTS,lls[0,pos],lls[1,pos],psym=1,color='ff0000'x
        
    vel_up_all=DBLARR(N_ELEMENTS(pos))
    vele_up_all=DBLARR(N_ELEMENTS(pos))
    
    FOR vi=0, N_ELEMENTS(pos)-1 DO BEGIN
      vel=REFORM(vels[*,pos[vi]])
      
      vel_up_all[vi]=vel[0]
      vele_up_all[vi]=vel[1]
      
      IF N_ELEMENTS(out_plot) NE 0 && Out_Plot EQ 1 THEN BEGIN
        WINDOW,3,/pixmap
        DEVICE,decomposed=1
        PLOT,lls[0,*],lls[1,*],psym=1,background='ffffff'x,color='0'x, $
          /nodata, xrange=[-20,20],yrange=[-20,20], $
          title=sites[pos[vi]],$
          /ynozero,/iso
        OPLOT,[0,vel[4]],[0,0],color='0'x
        OPLOT,[0,0],[0,vel[3]],color='0'x
        OPLOT,[0,vel[4]],[0,vel[3]],color='0'x,thick=2
        x=INDGEN(100)*40d0-20
        y=x*TAN(alpha)
        OPLOT,x,y,color='0'x,linestyle=2
        OPLOT,[0,vel_ss],[0,vel_st],color='ff0000'x,thick=2,linestyle=3
        ofile=opath_t+PATH_SEP()+sites[pos[vi]]+'_vel_components.jpg'
        WRITE_JPEG, ofile, TVRD(true=1),true=1,quality=100
      ENDIF
    ;STOP
    ENDFOR
    ;STOP
    lls_used=p_lls[*,pos]
    ind=SORT(lls_used[0,*])
    
    x0=REFORM(p_lls[1,pos[ind]])
    y0=REFORM(vel_up_all[ind])
    y0s=SMOOTH(y0,5,/edge_tru)
    
    ofile=opath+PATH_SEP()+'profile_'+STRING(pi+1,format='(i02)')+'_vel.psxy'
    OPENW,fid,ofile,/get_lun
    WRITE_SYS_INFO,fid,prog='GPS_VEL_PROFILES',src=[vfile,pfile],user=user
    ;output profile vertex
    PRINTF,fid,a1,format='("# PSXY_PROFILE",2f10.3)'
    PRINTF,fid,b1,format='("# PSXY_PROFILE",2f10.3)'
    ;output stations
    PRINTF,fid,'site','p_long','p_lati','dist','v_up','ve_up',$
      'long','lati','dist_to_fault', $
      format='("*",a4,1x,2a10,1x,a10,1x,1a10,1x,1a10,1x,2a10,1x,a13)'
    FOR j=0, N_ELEMENTS(ind)-1 DO BEGIN
      PRINTF,fid,sites[pos[ind[j]]],p_lls[*,pos[ind[j]]],dists[pos[ind[j]]],vel_up_all[ind[j]],$
        vele_up_all[ind[j]], $
        lls[*,pos[ind[j]]], $
        dists_fault[pos[ind[j]]],y0s[j], $
        format='(1x,a4,1x,2f10.3,1x,f10.2,1x,1f10.2,1x,1f10.2,1x,2f10.3,1x,f13.6,1x,f10.2)'
    ENDFOR
    FREE_LUN,fid
    
    WINDOW,4
    yrange=[-20,20]
    yrange=[-12,12]
    PLOT,lls_used[1,ind],vel_up_all[ind],background='ffffff'x,color='0'x, $
      /ynozero,psym=2,yrange=yrange
    FOR j=0,N_ELEMENTS(ind)-1 DO BEGIN
      OPLOT,[lls_used[1,ind[j]], lls_used[1,ind[j]] ], $
        [vel_up_all[ind[j]]+ABS(vele_up_all[ind[j]]),vel_up_all[ind[j]]-ABS(vele_up_all[ind[j]]) ], $
        color='0000ff'x,thick=2
    ENDFOR
    ;    OPLOT,lls_used[0,ind],vel_tang_all[ind],color='0000ff'x, $
    ;      psym=5
    ;    FOR j=0,N_ELEMENTS(ind)-1 DO BEGIN
    ;      OPLOT,[lls_used[0,ind[j]], lls_used[0,ind[j]] ], $
    ;        [vel_tang_all[ind[j]]+ABS(vele_tang_all[ind[j]]),vel_tang_all[ind[j]]-ABS(vele_tang_all[ind[j]]) ], $
    ;        color='0000ff'x,thick=2
    ;    ENDFOR
    
    ofile=opath+PATH_SEP()+'profile_'+STRING(pi+1,format='(i02)')+'_vel.jpg'
    WRITE_JPEG, ofile, TVRD(true=1),true=1,quality=100
    
    PRINT,'a1:',a1
    PRINT,'b1:',b1
  ;STOP
  ENDFOR
  
END