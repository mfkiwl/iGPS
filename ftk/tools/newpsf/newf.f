      PROGRAM newf
c     --PURPOSE--

c     --INPUT--
c     ofile: output filename

c     --OUTPUT--

c     --OUTPUT--

c     --EXAMPLE--

c     --MODIFICATIONS--

c     >>VAR_DEC
c     --Global Variables--
      IMPLICIT NONE

c     --Command-line Parameters--

c     --Local Parameters--
      character*1000 file,ofile
      integer*4 fid,fido,ioerr
      integer iargc,nblen
      character*512 strbuf,strtmp,home
      integer*4 i,j,k

c     <<VAR_DEC

c     check command-line parameters

c     check help
c      write(*,*) '#param:',iargc()
      if (iargc().gt.2) goto 800
      if (iargc().lt.1) goto 801
      do i=1,iargc()
         call getarg(i,strbuf)
         if (strbuf(1:2).eq.'-h'.or.strbuf(1:6).eq.'--help') goto 800
      enddo
      goto 801
 800  write(*,*) 'Syntax: newp [filename] [--file=~/.../doc/func.f]'
      write(*,*) '        newp [--file=~/.../doc/func.f] [filename]'
      stop

 801  continue
      file='~/gpsf/cgps/doc/func.f'
      file='/export/home/tianyf/gpsf/cgps/doc/func.f'
      
      call getenv('HOME',home)
      file=home(1:nblen(home))//'/gpsf/cgps/doc/func.f'
      fido=6
      ofile=' '
      do i=1,iargc()
         call getarg(i,strbuf)
         if (index(strbuf,'--file=').gt.0) then
            strtmp=strbuf(index(strbuf,'--file=')+7:)
            read(strtmp,*) file
         else
            read(strbuf,*) ofile
         endif
      enddo
      
c      write(*,*) file(1:nblen(file))
c      write(*,*) ofile(1:nblen(ofile))

c     open files
      call getlun(fid)
      open(unit=fid,file=file,iostat=ioerr,status='old')
      if (ioerr.ne.0) then
         write(*,*) 'NEWF: Error in opening ',
     &        file(1:nblen(file))
         stop
      endif

      if (nblen(ofile).gt.0) then
         call getlun(fido)
         open(unit=fido,file=ofile,iostat=ioerr)
         if (ioerr.ne.0) then
            write(*,*) 'NEWF: Error in opening output: ',
     &           ofile(1:nblen(ofile))
            close(fid)
            stop
         endif
      endif

 802  read(fid,'(a512)',end=899) strbuf
      write(fido,'(a)') strbuf(1:nblen(strbuf))
      goto 802

 899  continue
      
c     close files
      close(fid)
      if (fido.ne.6) then
         close(fido)
      endif

c     That's all.
      END
