      subroutine read_neuxyz(file,site,xyz,llh)
C     ---
      character*(*) file,site
      real*8 xyz(3),llh(3)
      character*512 buf,tmpstr(7)
      character*4 cursite,siteupper
      integer*4 fid,ioerr,ntmp
C     ---
      siteupper=site
      call casefold(siteupper)
c      fid=11
      call getlun(fid)
      open(unit=fid,file=file)
 800  read(fid,'(a512)',end=899) buf
      if (buf(1:1).ne.' ')  goto 800
c      write(*,*) buf(1:nblen(buf))
      call trimlead(buf)
      read(buf,'(a)') cursite
      call casefold(cursite)
c      write(*,*) cursite, siteupper
c      stop
      if (cursite.eq.siteupper(1:4)) then
         call strsplit(buf,' ',ntmp,tmpstr)
c         write(*,*) (tmpstr(i),i=1,6)
         read(tmpstr(2),*) llh(1)
c         write(*,*) ll(1)
         read(tmpstr(3),*) llh(2)
         read(tmpstr(4),*) llh(3)
         read(tmpstr(5),*) xyz(1)
         read(tmpstr(6),*) xyz(2)
         read(tmpstr(7),*) xyz(3)
c         write(*,'(a20,i6)') tmpstr(6),ntmp
c         write(*,*) cursite, siteupper
         goto 899
      endif
      goto 800
      llh(1)=-9999
      llh(2)=-9999
      llh(3)=-9999

      xyz(1)=-9999
      xyz(2)=-9999
      xyz(3)=-9999

 899  continue
      close(fid)
      return
      end
