!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                       INITIALISE                         !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Initial conditions for the treepm code are set here.  This routine
! sets up some arrays and look up tables that are used by the PM part
! of the code.  It reads the parameters of the model to be studied
! and then generates the gaussian random field representing the
! initial potential in Fourier space.  The routine GRADPSI computes
! the negative gradient of this potential, and that is used to set
! the epoch at which the treepm code starts evolving the system.  The
! routine INIT_DISP sets up the initial positions and velocities at
! this epoch.

program initialise


  USE treedefs
  IMPLICIT NONE

  INTEGER :: i,j,k,l,i1,i2,i3
  REAL :: fmax,dfmag
  real :: sum, sum2, avg, stdev, a, x, y


  pi=4.e0 * ATAN(1.e0)

  CALL settrig()
  CALL setswap()
  CALL setiperi(nbox,iperi)
  CALL setk()

  seed = 832406179
  CALL gaussranfield()

  t = f
  ti = fi

  call fft(nbox,ntrig,t,ti,iswap,ft1,ft2)

  do j=0,nbox-1
     do i=0,nbox-1
        df(1,i,j) = 0.5 * (t(iperi(i+1),j) - t(iperi(i-1),j))
        df(2,i,j) = 0.5 * (t(i,iperi(j+1)) - t(i,iperi(j-1)))
        r(1,i,j) = i
        r(2,i,j) = j
     end do
  end do

  a = 1.0
  do k = 1, 5
     do j=0,nbox-1
        do i=0,nbox-1
	   x = r(1,i,j)-a*df(1,i,j)
	   y = r(2,i,j)-a*df(2,i,j)
	   if (x .gt. nbox) then
		x = x - nbox
	   else if (x .lt. 0.0) then
		x = x + nbox
	   end if
          if (y .gt. nbox) then
                y = y - nbox
           else if (y .lt. 0.0) then
                y = y + nbox
           end if
           write(10+k,*)x,y
        end do
     end do
     close(10+k)
     a = a + 1.0
  end do
  

end program initialise



!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         SETTRIG                          !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! These are trignometric functions used by the FFT.  We compute it
! before the first call to FFT and use these from the arrays ft1 and
! ft2 instead of computing them again and again during each fft call. 

SUBROUTINE settrig()


  USE treedefs
  IMPLICIT NONE

  INTEGER :: i
  DOUBLE PRECISION :: phi


  phi=-4.d0*datan(1.d0)
  DO i=1,ntrig
     ft1(i)=-2.d0 * (DSIN(.5d0*phi) * DSIN(.5d0*phi))
     ft2(i)=DSIN(phi)
     phi=phi/2.d0
  END DO 


END SUBROUTINE settrig




!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         SETSWAP                          !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! This subroutine makes a lookup table, ISWAP(0:NBOX-1), which
! specifies the elements that need to be swapped by the fast fourier
! transform routine.  Essentially, for each I, ISWAP(I) is the number
! you get if you invert the bits of I written in binary.  
!
! The calculation of the bit intverted number is done by a method
! used by Press et al. in Numerical Recipes.  This method works if
! one does bit inversion of numbers in ascending order starting with
! unity. 
!
! By setting up this look up table, we avoid redoing this calculation
! for each fft - and we do fourier transform four times in each time
! step and a typical simulation goes through a few hundred steps.


SUBROUTINE setswap()


  USE treedefs

  IMPLICIT NONE

  INTEGER :: i,j,k,m


  k=1

  FORALL (i=0:nbox-1)
     iswap(i)=i
  END FORALL

  !  This is the bit inversion part.

  DO i=1,nbox-2
    m=nbox
    DO WHILE ((m .GE. 2) .AND. (k .GT. m))
      k=k-m
      m=m/2
    END DO
    k=k+m
    j=k/2
    IF (j .NE. i) THEN
      iswap(i)=j
    END IF
  END DO

END SUBROUTINE setswap

      


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                        SETIPERI                          !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! set up the look up table iperi, which is used to locate the correct
! index inside the root box for any integer.  Used for interpolation
! etc. when one of the grid cells may be on the other side of the
! box. 

SUBROUTINE setiperi(n,peri)


  IMPLICIT NONE

  INTEGER :: i,n
  INTEGER, DIMENSION(-2:n+2) :: peri


  DO i=0,n-1
     peri(i)=i
  END DO
  DO i=n,n+1
     peri(i)=peri(i-n)
  END DO
  DO i=-2,-1,1
     peri(i)=peri(i+n)
  END DO


END SUBROUTINE setiperi


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                          SETK                            !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! Compute the look up table for wave number k for any index in the
! box according to the convention used by FFT.  Positive wave numbers
! from index 0 to nbox/2.  Negative ones from nbox/2 to nbox-1.

SUBROUTINE setk()


  USE treedefs

  IMPLICIT NONE

  INTEGER :: i,iw
  REAL :: bb


  bb=2.e0*pi/float(nbox)

  DO i=0,nbox-1
     IF (i .GT. nbox/2) THEN
        iw=i-nbox
     ELSE
        iw=i
     END IF 
     w(i)=bb*float(iw)
  END DO 


END SUBROUTINE setk


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                      GAUSSRANFIELD                       !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! This program sets up a Gaussian random field with the given power
! spectrum.  Specifically, it generates the Fourier components of the
! initial gravitational potential.  The power spectrum is supplied by
! the routine SPECTRUM and the random numbers (zero mean, and unit
! variance for the sum of the two random numbers that it returns,
! with normal distribution) are supplied by the routine NORMAL.
!
! The gravitational potential is a real field and so we make use of
! the reality condition to relate Fourier components at wave vectors
! K and -K.
!
! Lastly, the number NORM supplies the normalisation of the power
! spectrum in case it is different from the one supplied by the
! routine SPECTRUM.

SUBROUTINE gaussranfield()


  USE treedefs
  IMPLICIT NONE
  
  INTEGER :: i2,j2,i,j,nhalf,in,jn,k,kn,i1,j1
  REAL :: sp,kmod
  REAL, DIMENSION(2) :: aran

  
  nhalf=nbox/2 
  
  f(:,:)=0.e0
  fi(:,:)=0.e0

  ! Loop over all the points in the octant K_x, K_y, K_z > 0

  do j=1,nhalf - 1
     DO i=1,nhalf -1
        
        kmod=SQRT(w(i)*w(i) + w(j)*w(j))
     
        ! we are choosing a white noise spectrum, i.e., P(k) = constant

        !    sp = 1.0

        !        sp = 1.0 / ( 1.0 + kmod*kmod)
     
        ! if (kmod .gt. w(nbox/8)) then
        ! sp = 0.0
        ! end if

        sp = 10.0 * exp(-4.0*kmod*kmod)
        
        sp = - sp / (kmod*kmod)

        CALL normal(aran,seed,pi)
     
        f(i,j)=sp*aran(1)
        fi(i,j)=sp*aran(2)
     
        f(nbox-i,nbox-j)=f(i,j)
        fi(nbox-i,nbox-j)=-fi(i,j)


	call normal(aran,seed,pi)

	f(nbox-i,j) = sp * aran(1)
	fi(nbox-i,j) = sp * aran(2)

	f(i,nbox-j) = f(nbox-i,j)
	fi(i,nbox-j) = f(nbox-i,j)

     end do
  END DO
  
END SUBROUTINE gaussranfield




!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         NORMAL                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! This routine takes two random numbers, between 0 and 1, and
! computes two numbers with a normal distribution.  The normal
! distribution has zero mean and the variance of the sum of the two
! numbers computed here is unity.


SUBROUTINE normal(x,seed,pi)

  IMPLICIT NONE
  
  INTEGER :: seed
  REAL :: theta,r,uniform,pi
  REAL, DIMENSION(2) :: x,y


  y(1)=uniform(seed)
  y(2)=uniform(seed)
  theta=y(1) * pi * 2.0
  r=SQRT( - LOG(1.e0 - y(2)))
  x(1)=r * COS(theta)
  x(2)=r * SIN(theta)

     
END SUBROUTINE normal



!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                        UNIFORM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! This routine generates a random number - one at a time.  These
! numbers are uniformly distributed between 0.0 and 1.0. The routine
! has been taken from Antia's book. 

! See page 252-253 of that book for a discussion of the algorithm.

REAL FUNCTION uniform(iseed)


  IMPLICIT NONE
  INTEGER, PARAMETER :: m1=714025
  INTEGER, PARAMETER :: ia1=1366
  INTEGER, PARAMETER :: ic1=150889
  INTEGER, PARAMETER :: m2=214326
  INTEGER, PARAMETER :: ia2=3613
  INTEGER, PARAMETER :: ic2=45289
  INTEGER, PARAMETER :: m3=139968
  INTEGER, PARAMETER :: ia3=3877
  INTEGER, PARAMETER :: ic3=29573
  INTEGER, PARAMETER :: ish=43
  INTEGER :: is1,is2,is3,j,i,iflg
  INTEGER :: iseed
  REAL :: rm1,rm2
  REAL, DIMENSION(ish) :: ran

  SAVE is1,is2,is3,j,i,iflg,rm1,rm2,ran


  IF (iflg.EQ.0) THEN

    iflg=1
    rm1=1./m1
    rm2=1./m2
    is1=MOD(iseed,m1)
    is2=MOD(ia1*is1+ic1,m1)
    is3=MOD(ia2*is2+ic2,m2)
    iseed=1
    DO j=1,ish
      is1=MOD(ia1*is1+ic1,m1)
      is2=MOD(ia2*is2+ic2,m2)
      ran(j)=(float(is1)+float(is2)*rm2)*rm1
    END DO
  END IF
  
  is1=MOD(ia1*is1+ic1,m1)
  is2=MOD(ia2*is2+ic2,m2)
  is3=MOD(ia3*is3+ic3,m3)
  i=1+(ish*is3)/m3
  uniform=ran(i)
  ran(i)=(float(is1)+float(is2)*rm2)*rm1


END FUNCTION uniform


