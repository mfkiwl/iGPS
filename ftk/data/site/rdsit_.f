c$$$;Return sites list from sites files.
c$$$;Conform to SOPAC site file format (by guess):
c$$$;	Site start with # is commented out.
c$$$;	?? What does ++++ stands for?

      subroutine rdsit_(file,sites,nmaxsite,nsite)
c     Read new version of sites list file.
c     For old format site list file should use rdsite_old.

C     TITLE site_read
CCC   Description:

CCC   MOD JUL-17-2007 TIAN@BEIJING.CHINA
CCC   site_read cannot deal with Tab separated sites names now.
CCC   trimlead subroutine can delete the leading blanks/spaces; however,
CCC   it cannot delete TABs.
CCC   Thus, it is important to avoid using TAB in sites file.

C     ---
      implicit none
      integer*4 nmaxsite,nsite
      character*(*) file
      character*(*) sites(nmaxsite)
c     ---
      character*10230 bufline,bufstr
      character*4 tmpsites(nmaxsite)
      character*1 sep
      integer*4 fid, i,ioerr,ntmp
      integer*4 nblen,iargc
c     ---
      nsite=0
      sep=' '
      call getlun(fid)
c      fid=90
      open(unit=fid,file=file,iostat=ioerr)
      if (ioerr.ne.0) then
         write(*,'(3a)') '[rdsit_]FATAL: cannot open input file ',
     &        file(1:nblen(file)),'.'
         stop
      endif
 800  read(fid,'(a10230)',end=899) bufline
c      write(*,*) bufline(1:nblen(bufline))
      if (nblen(bufline).lt.2.or.bufline(1:1).ne.' ') then
         goto 800
      endif
      ntmp=0
c      write(*,*) ntest2,n1site
c      goto 800
      call strsplit(bufline,sep,ntmp,tmpsites)
c     the above code changed the value of nsite !!!
c      write(*,*) ntmp,bufline(1:nblen(bufline))
      
c      goto 800
      do i=1,ntmp
c         write(*,'(a4,i5)') tmpsites(i),len(tmpsites(i))
         
         bufstr=tmpsites(i)
         call trimlead(bufstr)
         if (bufstr(1:1).eq.'#'.or.bufstr(1:4).eq.'++++') then
            goto 801
         endif 
         nsite=nsite+1
c            write(*,*) nblen(tmpsites(i))
         call lowers(bufstr)
         sites(nsite)=bufstr
 801     continue
      enddo

      goto 800
 899  continue
      close(fid)

      return
      do i=1,nsite
         write(*,'(a4)') sites(i)
      enddo
      

      end
