!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                          FFT                             !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! This is a 3D FFT routine.  It takes two real arrays - the real and
! imaginary parts of a complex array - and returns the Fourier
! transform in the same arrays.  Each of the real arrays is a three
! indexed array with dimension 0:N-1 for each subscript.  FT1 and FT2
! are arrays with dimension NTRIG and contain values of trignometric
! functions needed for computing the FFT.  We store these as arrays
! to save CPU cycles which will otherwise be wasted in recomputing
! the same numbers every time we do an FT.  Similarly, ISWAP(0:N-1)
! is a lookup table which is used to swap elements of arrays F and
! FI.  This is also computed during initialisation of the code.
!
! To take inverse transform, change the sign of the imaginary part of
! the input - FI  BEFORE and AFTER taking the transform.  
!
! Both the forward and the inverse transform are normalised by
! dividing the fourier transform by N^{3/2}.
!
! The method we follow here is to simply do 3 * N^2 1D transforms,
! N^2 transforms for each dimension.

SUBROUTINE fft(n,ntrig,f,fi,iswap,ft1,ft2)


  IMPLICIT NONE
  
  INTEGER, INTENT(IN) :: n,ntrig
  INTEGER, DIMENSION(0:n-1), INTENT(IN) :: iswap
  INTEGER :: i,j,m,mmax,i1,j1,k,istep,nd
  REAL :: tmpi,tmpr,amp
  REAL, DIMENSION(0:n-1,0:n-1) :: f,fi
  DOUBLE PRECISION :: wi,wpr,wr,wtmp,wpi
  DOUBLE PRECISION, DIMENSION(ntrig), INTENT(IN) :: ft1,ft2


  ! Swap array elements.

  do j=0,n-1
     f(:,j)=f(iswap(:),j)
     fi(:,j)=fi(iswap(:),j)
  end do
  
  ! Do the fourier transform.

  mmax=1
  nd=1
  
  DO WHILE (mmax.LT.n)
     istep=2*mmax
     wpr=ft1(nd)
     wpi=ft2(nd)
     nd=nd+1
     wr=1.d0
     wi=0.d0
     DO m=0,mmax-1
        DO i=m,n-1,istep
           j=i+mmax
           do j1=0,n-1
              tmpr=sngl(wr)*f(j,j1)-sngl(wi)*fi(j,j1)
              tmpi=sngl(wr)*fi(j,j1)+sngl(wi)*f(j,j1)
              f(j,j1)=f(i,j1)-tmpr
              fi(j,j1)=fi(i,j1)-tmpi
              f(i,j1)=f(i,j1)+tmpr
              fi(i,j1)=fi(i,j1)+tmpi
           end do
        END DO
        wtmp=wr
        wr=wr*(1.d0+wpr)-wi*wpi
        wi=wi*(1.d0+wpr)+wtmp*wpi
     END DO
     mmax=istep
  END DO

    ! Swap array elements.

  do j=0,n-1
     f(j,:)=f(j,iswap(:))
     fi(j,:)=fi(j,iswap(:))
  end do
  
  ! Do the fourier transform.

  mmax=1
  nd=1
  
  DO WHILE (mmax.LT.n)
     istep=2*mmax
     wpr=ft1(nd)
     wpi=ft2(nd)
     nd=nd+1
     wr=1.d0
     wi=0.d0
     DO m=0,mmax-1
        DO i=m,n-1,istep
           j=i+mmax
           do j1=0,n-1
              tmpr=sngl(wr)*f(j1,j)-sngl(wi)*fi(j1,j)
              tmpi=sngl(wr)*fi(j1,j)+sngl(wi)*f(j1,j)
              f(j1,j)=f(j1,i)-tmpr
              fi(j1,j)=fi(j1,i)-tmpi
              f(j1,i)=f(j1,i)+tmpr
              fi(j1,i)=fi(j1,i)+tmpi
           end do
        END DO
        wtmp=wr
        wr=wr*(1.d0+wpr)-wi*wpi
        wi=wi*(1.d0+wpr)+wtmp*wpi
     END DO
     mmax=istep
  END DO


  amp=1./(float(n))

  do j=0,n-1
     do i=0,n-1
        f(i,j)=f(i,j)*amp
        fi(i,j)=fi(i,j)*amp
     END do
  end do

END SUBROUTINE fft
      
      
      
