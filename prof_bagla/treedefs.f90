!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                         TREEPM                           !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!                                                          !!!!
!!!!                        TREEDEFS                          !!!!
!!!!                                                          !!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! this program contains declarations for all the global variables.

MODULE treedefs

  
  INTEGER, PARAMETER :: nbox = 256
  integer, parameter :: ndim = 2
  REAL, PARAMETER :: box = nbox
  REAL, PARAMETER :: boxhalf = 0.5 * box

  INTEGER, PARAMETER :: ntrig=15

  ! seed           seed for generating random numbers

!  INTEGER :: seed=891574621
  INTEGER :: seed


  INTEGER, DIMENSION(-2:nbox+2) :: iperi
  INTEGER, DIMENSION(0:nbox-1) :: iswap
  REAL, DIMENSION(0:nbox-1) :: w
  DOUBLE PRECISION, DIMENSION(ntrig) :: ft1,ft2

  ! df             force on the grid (long range after initial
  !                 conditions have been set up) 
  ! f,fi,ti        temporary arrays used to compute the long range
  !                 force and also to set up the initial conditions.

  REAL, DIMENSION(0:nbox-1,0:nbox-1) :: f,fi,t,ti
  real, dimension(ndim,0:nbox-1,0:nbox-1) :: df,r

  ! pi             pi=4 * atan(1)
  ! sc             scaling between box and particles
  ! mass0          mass of each particle

  REAL :: pi



END MODULE treedefs


