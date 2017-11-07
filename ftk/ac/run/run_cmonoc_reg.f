CTITLE
      PROGRAM run_cmonoc_reg

      IMPLICIT NONE
C      INCLUDE '../../inc/cgps.h'

c     --PURPOSE--

c     --ALGORITHM--
c     Given a expt directory:
c     /home/tianyf/gpse/rerun.cmonoc/solut/gmf.survey.mode/reg
c     and a STAT file
c     /home/tianyf/gpse/rerun.cmonoc/solut/gmf.survey.mode/reg/sh/STAT ,
c                   a001 a002 a003 
c     1998 240   78    0    0    1 
c     1998 241   81    1    1    0 
c     1998 242   81    0    1    1 
c     1998 243   81    1    1    1 
c     this program can run sh_gamit for each day, splitting sessions
c     automatically.
c
c     It requires ${root}/tables files.
c     Also reqiures:
c     + fiducial cGPS sites
c     + maximum number of sites in each sub-network
c

c     --EXAMPLE--

c     --MODIFICATIONS--
c     + On Tue Oct 27 10:00:34 CST 2015 by tianyf
c     Add the update station.info option.
c
c

c     >>VAR_DEC
c     --INPUT--
c     --Command-line Parameters--
      character*1023 path,obs_stat_file,stable_file
      integer*4 nmaxproc

c     --OUTPUT--

c     --EXTERNAL--
      integer*4 iargc,nblen

c     --Local Parameters--
      character*70000 tmpstr
      character*100 fmtstr
      integer*4 nmax,nmaxday
      parameter(nmax=3000,nmaxday=5000)
      character*4 sites(NMAX),site,sitestable(NMAX)
      character*4 sitesref(NMAX),sitesort(NMAX)
      integer*4 nsiteref,nsite,nstable,nproc
      integer*4 years(NMAX),doys(NMAX),stats(NMAXDAY,NMAX)
      integer*4 nday,stat(NMAX)
      integer*4 nsites(NMAXDAY)
      integer*4 i,j,di,nsiteday,sind
      integer*4 fid,ioerr

c     executable temporary shell script file name
      character*1023 shfile
      integer*4 fidsh
      character*1023 cmdstr

c     sessions
      integer*4 nsess,si

c     experiment name
      character*4 expt

c     sites.default
      character*1023 sdfile,tdir
      integer*4 fidsd

c     whether update station.info file
      integer*4 isUpdStinf

c     call system routines
      integer*4 system,status

      real*8 tmp
      

c     <<VAR_DEC
      if (iargc().lt.1) then
         write(*,'(a)') 'Usage: run_cmonoc_reg --path=PATH'
         write(*,'(8x,a)') '--obstat=OBS_STAT_FILE'
         write(*,'(8x,a)') '--stable=FIDUCIAL_SITE_FILE'
         write(*,'(8x,a)') '--xstinfo=y|n'
      endif

c     maximum number of sites to process in individual session.
      nmaxproc=55
      nmaxproc=35

c     Do not update station.info by default
      isUpdStinf=0

      write(*,'(a)') '[i]Starting run_cmonoc_reg ...________________'
      do i=1,iargc()
         call getarg(i,tmpstr)
c         write(*,*) tmpstr(1:nblen(tmpstr))
         if (tmpstr(1:7).eq.'--path=') then
            write(*,'(2a)') '[i]Working in path: ',
     &           tmpstr(8:nblen(tmpstr))
            path=tmpstr(8:nblen(tmpstr))
         else if (tmpstr(1:9).eq.'--obstat=') then
            write(*,'(2a)') '[i]Statistics: ',
     &           tmpstr(10:nblen(tmpstr))
            obs_stat_file=tmpstr(10:nblen(tmpstr))
         else if (tmpstr(1:9).eq.'--stable=') then
            write(*,'(2a)') '[i]Stable sites: ',
     &           tmpstr(10:nblen(tmpstr))
            stable_file=tmpstr(10:nblen(tmpstr))
            call site_read(stable_file,sitesref,sitestable,5000,
     &           nsiteref,nstable)
            write(*,'(a,i9)') '[i]#Stable sites:',nstable
         else if (tmpstr(1:10).eq.'--xstinfo=') then
            write(*,'(2a)') '[i]xstinfo: ',
     &           tmpstr(11:nblen(tmpstr))
            if (tmpstr(11:nblen(tmpstr)).eq.'y'.or.
     &           tmpstr(11:nblen(tmpstr)).eq.'Y') then
               isUpdStinf=1
            endif
         else
            write(*,'(2a)') '[E]Invalid input: ',
     &           tmpstr(1:nblen(tmpstr))
            stop
         endif
      enddo

c      stop
      nproc=nmaxproc-nstable

      call getlun(fid)
      open(unit=fid,file=obs_stat_file,iostat=ioerr)
      if (ioerr.ne.0) then
         write(*,'(2a)') 'Error opening file ',
     &        obs_stat_file(1:nblen(obs_stat_file))
         stop
      endif
c     read the first line (sites)
      write(*,'(a)') '[i]reading sites...'
      read(fid,'(a70000)',end=801) tmpstr
c      write(*,'(a)') tmpstr
      call strsplit(tmpstr,' ',nsite,sites)
      write(*,'(a,i9)') '[i]#site:',nsite
c      write(*,'(1x,8a5)') (sites(i),i=1,nsite)
      write(fmtstr,'("(i5,i4,i5,",i9,"i5)")'),nsite
c      write(*,*) fmtstr(1:nblen(fmtstr))
c      goto 801

      write(tdir,'(2a)') path(1:nblen(path)),'/tables/sites.defaults'

      call getlun(fidsh)
      write(*,*) 'fids:',fid,fidsh

      di=0
 800  read(fid,'(a70000)',end=801) tmpstr
      if (tmpstr(1:1).ne.' ') then
         goto 800
      endif
c     1998 240   78    0    0
c     1998 241   81    0    0
c     1998 242   81    0    0
c     1998 243   81    0    0
c     1998 244   80    0    0
c      write(*,*) tmpstr(1:nblen(tmpstr))
      di=di+1
      read(tmpstr,fmtstr) years(di),doys(di),nsites(di),
     &     (stat(i),i=1,nsite)
c      read(tmpstr,fmtstr) stat
      write(*,*) years(di),doys(di),nsites(di),(stat(i),i=1,2)
      sind=0
      do i=1,nsite
         stats(di,i)=stat(i)
c         write(*,*) stat(i)
         if (stat(i).eq.1) then
            sind=sind+1
            sitesort(sind)=sites(i)
c            write(*,'(a,i,i)') sitesort(sind),sind,stat(i)
         endif
      enddo
c      read(tmpstr,fmtstr) stat

c      nsess=ceiling(nsites(di)*1d0/nproc)
      tmp=nsites(di)*1d0/nproc
      nsess=int(tmp)
      if ((tmp-int(tmp)).gt.0) then
         nsess=nsess+1
      endif
c      nsess=d_ceil(nsites(di)*1d0/nproc)
c      write(*,*) nsess,nsites(di),nproc

      do si=1,nsess
         write(expt,'(a2,i2.2)') 'cr',si
c     create sites.default
c     yakt_gps jbg1 ftprnx xstinfo  glreps
c     bjfs_gps jbg1 ftprnx
         write(sdfile,'(3a,i4.4,a1,i3.3,a1,i3.3,a)') 
     &        path(1:nblen(path)),
     &        '/sh/',
     &        'sh_run_cmonoc_surveymode_reg_',years(di),'_',
     &        doys(di),'_',si,'_sites_defaults'
         write(*,'(a)') sdfile(1:nblen(sdfile))
c     use the same fid usd shell script file
         fidsh=fidsh
c     write fiducial sites
         open(unit=fidsd,file=sdfile,iostat=ioerr)
         do j=1,nstable
            write(fidsd,'(1x,a4,a,1x,a4,1x,a)') sitestable(j),'_gps',
     &           expt,'ftprnx xstinfo glreps'
         enddo
            
         do j=1,nproc
            if ((j+nproc*(si-1)).gt.nsites(di)) then
               goto 802
            endif
c     if update station.info for survey-mode sites
            if (isUpdStinf.eq.1) then
               write(fidsd,'(1x,a4,a,1x,a4,1x,a)') 
     &              sitesort(j+nproc*(si-1)),
     &           '_gps',expt,'ftprnx'
            else
c     if not update station.info
               write(fidsd,'(1x,a4,a,1x,a4,1x,a)') 
     &              sitesort(j+nproc*(si-1)),
     &           '_gps',expt,'ftprnx xstinfo'
            endif

         enddo
 802     continue
         close(fidsd)
         write(cmdstr,'(2a,1x,a)') '/bin/cp -f ',
     &        sdfile(1:nblen(sdfile)),
     &        tdir(1:nblen(tdir)) 
         write(*,'(a)') cmdstr(1:nblen(cmdstr))
         status=system(cmdstr)
c         stop

         write(shfile,'(3a,i4.4,a1,i3.3,a1,i3.3)') 
     &        path(1:nblen(path)),
     &        '/sh/',
     &        'sh_run_cmonoc_surveymode_reg_',years(di),'_',
     &        doys(di),'_',si
c      write(*,'(a)') shfile(1:nblen(shfile))
         open(unit=fidsh,file=shfile,iostat=ioerr)
         write(fidsh,'(a)') '#!/bin/sh'
         write(fidsh,'(2a)') 'EXPT_DIR=',path(1:nblen(path))
         write(fidsh,'(a)') 'HFILE_DIR=/acd0/igs/pub/hfilesi.gmf'
         write(fidsh,'(a)') 'HFILE_DIR=/home/hfilesi.gmf'
         write(fidsh,'(a)') 'HFILE_DIR=/home/hfilesi.gmf_v2'
         write(fidsh,'(a)') 'HFILE_DIR=/home/hfilesi.gmf.v3'
c         write(fidsh,'(a)') 'HFILE_DIR=/home/hfilesi.gmf.v3.cmonoc'
         write(fidsh,'(a)') 'orbt=IGSF'
         write(fidsh,'(a)') 'DC_FTP_SERVER=gpsdc'
c         write(fidsh,'(a)') 'DC_FTP_SERVER=homew'
c         write(fidsh,'(a)') 'DC_FTP_SERVER=gpsac2'
         write(fidsh,'(a,a4)') 'EXPT=',expt
         write(fidsh,'(a,i4.4)') 'YEAR=',years(di)
         write(fidsh,'(a,i3.3)') 'DOY=',doys(di)
         write(fidsh,'(a)') 'NDAYS=1'
c         write(fidsh,'(a)') 'sh_rerun_ftp_cmonoc_survey_mode'//
         write(fidsh,'(a)') 'sh_run_gamit -reg '//
     &        'CMONOC_SURVEY_MODE,CMONOC_CONT,LUTAI_CONT,LUTAI_REG '//
     &        ' -dir $EXPT_DIR'//
     &        ' -hdir $HFILE_DIR -orbit $orbt -host $DC_FTP_SERVER'//
     &        ' -expt $EXPT -yr $YEAR -doy $DOY -ndays $NDAYS'
         close(fidsh)
         write(cmdstr,'(2a)') '/bin/chmod +x ',shfile(1:nblen(shfile))
         status=system(cmdstr)
c         write(cmdstr,'(2a)') 'chmod +x ',shfile(1:nblen(shfile))

c     execute the sh_gamit for each day each session
         status=system(shfile(1:nblen(shfile)))
c         goto 801
      enddo
c      goto 801
      goto 800

 801  continue

      close(fid)

      STOP
      END
