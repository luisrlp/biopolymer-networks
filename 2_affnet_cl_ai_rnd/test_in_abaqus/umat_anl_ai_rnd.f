module global


!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! Set the control parameters to run the material-related routines
! FACTOR | NUM DIRECTIONS
!   3    |      180
!   4    |      320
!   5    |      500
!   6    |      720
!   7    |      980
INTEGER NELEM, NSDV, NTERM, FACTOR ! added NTERM and FACTOR
PARAMETER (NELEM=1)
!PARAMETER (NSDV=1)
PARAMETER (NSDV=11)
PARAMETER (NTERM=60) ! 60
PARAMETER (FACTOR=6)
DOUBLE PRECISION  ONE, TWO, THREE, FOUR, SIX, ZERO
PARAMETER (ZERO=0.D0, ONE=1.0D0,TWO=2.0D0)
PARAMETER (THREE=3.0D0,FOUR=4.0D0,SIX=6.0D0)
DOUBLE PRECISION HALF,THIRD
PARAMETER (HALF=0.5d0,THIRD=1.d0/3.d0)
CHARACTER(256) DIR2
PARAMETER (DIR2='prefdir.inp')


END module global
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SUBROUTINE indexx(stress,ddsdde,sig,tng,ntens,ndi)



!>    INDEXATION: FULL SIMMETRY  IN STRESSES AND ELASTICITY TENSORS
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: ndi
INTEGER, INTENT(IN)                      :: ntens
DOUBLE PRECISION, INTENT(OUT)            :: stress(ntens)
DOUBLE PRECISION, INTENT(OUT)            :: ddsdde(ntens,ntens)
DOUBLE PRECISION, INTENT(IN)             :: sig(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: tng(ndi,ndi,ndi,ndi)



INTEGER :: ii1(6),ii2(6), i1,j1


DOUBLE PRECISION :: pp1,pp2

ii1(1)=1
ii1(2)=2
ii1(3)=3
ii1(4)=1
ii1(5)=1
ii1(6)=2

ii2(1)=1
ii2(2)=2
ii2(3)=3
ii2(4)=2
ii2(5)=3
ii2(6)=3

DO i1=1,ntens
!       STRESS VECTOR
  stress(i1)=sig(ii1(i1),ii2(i1))
  DO j1=1,ntens
!       DDSDDE - FULLY SIMMETRY IMPOSED
    pp1=tng(ii1(i1),ii2(i1),ii1(j1),ii2(j1))
    pp2=tng(ii1(i1),ii2(i1),ii2(j1),ii1(j1))
    ddsdde(i1,j1)=(one/two)*(pp1+pp2)
  END DO
END DO

RETURN

END SUBROUTINE indexx
SUBROUTINE pull2(pk,sig,finv,det,ndi)



!>       PULL-BACK TIMES DET OF A 2ND ORDER TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: pk(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: sig(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: finv(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: det



INTEGER :: i1,j1,ii1,jj1


DOUBLE PRECISION :: aux


DO i1=1,ndi
  DO j1=1,ndi
    aux=zero
    DO ii1=1,ndi
      DO jj1=1,ndi
        aux=aux+det*finv(i1,ii1)*finv(j1,jj1)*sig(ii1,jj1)
      END DO
    END DO
    pk(i1,j1)=aux
  END DO
END DO

RETURN
END SUBROUTINE pull2
SUBROUTINE csfilfic(cfic,rho,lambda,dw,ddw,m,rw,ndi)



!>    AFFINE NETWORK: 'FICTICIOUS' ELASTICITY TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: cfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: rho
DOUBLE PRECISION, INTENT(IN OUT)         :: lambda
DOUBLE PRECISION, INTENT(IN)             :: dw
DOUBLE PRECISION, INTENT(IN)             :: ddw
DOUBLE PRECISION, INTENT(IN)             :: m(ndi)
DOUBLE PRECISION, INTENT(IN)             :: rw



INTEGER :: i1,j1,k1,l1

DOUBLE PRECISION :: aux, aux0

aux0=ddw-(lambda**(-one))*dw
aux=rho*aux0*rw*(lambda**(-two))
DO i1=1,ndi
  DO j1=1,ndi
    DO k1=1,ndi
      DO l1=1,ndi
        cfic(i1,j1,k1,l1)=aux*m(i1)*m(j1)*m(k1)*m(l1)
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE csfilfic
SUBROUTINE setjr(cjr,sigma,unit2,ndi)


use global
IMPLICIT NONE
!>    JAUMAN RATE CONTRIBUTION FOR THE SPATIAL ELASTICITY TENSOR

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: cjr(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: sigma(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: unit2(ndi,ndi)



INTEGER :: i1,j1,k1,l1


DO i1 = 1, ndi
  DO j1 = 1, ndi
    DO k1 = 1, ndi
      DO l1 = 1, ndi
        
        cjr(i1,j1,k1,l1)= (one/two)*(unit2(i1,k1)*sigma(j1,l1)  &
            +sigma(i1,k1)*unit2(j1,l1)+unit2(i1,l1)*sigma(j1,k1)  &
            +sigma(i1,l1)*unit2(j1,k1))
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE setjr
SUBROUTINE spectral(a,d,v)



!>    EIGENVALUES AND EIGENVECTOR OF A 3X3 MATRIX
!     THIS SUBROUTINE CALCULATES THE EIGENVALUES AND EIGENVECTORS OF
!     A SYMMETRIC 3X3 MATRIX A.

!     THE OUTPUT CONSISTS OF A VECTOR D CONTAINING THE THREE
!     EIGENVALUES IN ASCENDING ORDER, AND A MATRIX V WHOSE
!     COLUMNS CONTAIN THE CORRESPONDING EIGENVECTORS.

use global

DOUBLE PRECISION, INTENT(IN OUT)         :: a(3,3)
DOUBLE PRECISION                         :: e(3,3)
DOUBLE PRECISION, INTENT(IN OUT)         :: d(3)
DOUBLE PRECISION, INTENT(IN OUT)         :: v(3,3)

INTEGER :: nrot
INTEGER :: np=3



e = a

CALL jacobi(e,3,np,d,v,nrot)
CALL eigsrt(d,v,3,np)

RETURN
END SUBROUTINE spectral

!***********************************************************************

SUBROUTINE jacobi(a,n,np,d,v,nrot)

! COMPUTES ALL EIGENVALUES AND EIGENVECTORS OF A REAL SYMMETRIC
!  MATRIX A, WHICH IS OF SIZE N BY N, STORED IN A PHYSICAL
!  NP BY NP ARRAY.  ON OUTPUT, ELEMENTS OF A ABOVE THE DIAGONAL
!  ARE DESTROYED, BUT THE DIAGONAL AND SUB-DIAGONAL ARE UNCHANGED
!  AND GIVE FULL INFORMATION ABOUT THE ORIGINAL SYMMETRIC MATRIX.
!  VECTOR D RETURNS THE EIGENVALUES OF A IN ITS FIRST N ELEMENTS.
!  V IS A MATRIX WITH THE SAME LOGICAL AND PHYSICAL DIMENSIONS AS
!  A WHOSE COLUMNS CONTAIN, UPON OUTPUT, THE NORMALIZED
!  EIGENVECTORS OF A.  NROT RETURNS THE NUMBER OF JACOBI ROTATION
!  WHICH WERE REQUIRED.

! THIS SUBROUTINE IS TAKEN FROM 'NUMERICAL RECIPES.'
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: np
DOUBLE PRECISION, INTENT(IN OUT)         :: a(np,np)
INTEGER, INTENT(IN)                      :: n
DOUBLE PRECISION, INTENT(OUT)            :: d(np)
DOUBLE PRECISION, INTENT(OUT)            :: v(np,np)
INTEGER, INTENT(OUT)                     :: nrot

INTEGER :: ip,iq,  i,j
INTEGER, PARAMETER :: nmax=100

DOUBLE PRECISION :: b(nmax),z(nmax), sm,tresh,g,t,h,theta,s,c,tau


! INITIALIZE V TO THE IDENTITY MATRIX
DO i=1,3
  v(i,i)=one
  DO j=1,3
    IF (i /= j)THEN
      v(i,j)=zero
    END IF
  END DO
END DO
! INITIALIZE B AND D TO THE DIAGONAL OF A, AND Z TO ZERO.
!  THE VECTOR Z WILL ACCUMULATE TERMS OF THE FORM T*A_PQ AS
!  IN EQUATION (11.1.14)

DO ip = 1,n
  b(ip) = a(ip,ip)
  d(ip) = b(ip)
  z(ip) = 0.d0
END DO


! BEGIN ITERATION

nrot = 0
DO i=1,50
  
!         SUM OFF-DIAGONAL ELEMENTS
  
  sm = 0.d0
  DO ip=1,n-1
    DO iq=ip+1,n
      sm = sm + DABS(a(ip,iq))
    END DO
  END DO
  
!          IF SM = 0., THEN RETURN.  THIS IS THE NORMAL RETURN,
!          WHICH RELIES ON QUADRATIC CONVERGENCE TO MACHINE
!          UNDERFLOW.
  
  IF (sm == 0.d0) RETURN
  
!          IN THE FIRST THREE SWEEPS CARRY OUT THE PQ ROTATION ONLY IF
!           |A_PQ| > TRESH, WHERE TRESH IS SOME THRESHOLD VALUE,
!           SEE EQUATION (11.1.25).  THEREAFTER TRESH = 0.
  
  IF (i < 4) THEN
    tresh = 0.2D0*sm/n**2
  ELSE
    tresh = 0.d0
  END IF
  
  DO ip=1,n-1
    DO iq=ip+1,n
      g = 100.d0*DABS(a(ip,iq))
      
!              AFTER FOUR SWEEPS, SKIP THE ROTATION IF THE
!               OFF-DIAGONAL ELEMENT IS SMALL.
      
      IF ((i > 4).AND.(DABS(d(ip))+g == DABS(d(ip)))  &
            .AND.(DABS(d(iq))+g == DABS(d(iq)))) THEN
        a(ip,iq) = 0.d0
      ELSE IF (DABS(a(ip,iq)) > tresh) THEN
        h = d(iq) - d(ip)
        IF (DABS(h)+g == DABS(h)) THEN
          
!                  T = 1./(2.*THETA), EQUATION (11.1.10)
          
          t =a(ip,iq)/h
        ELSE
          theta = 0.5D0*h/a(ip,iq)
          t =1.d0/(DABS(theta)+DSQRT(1.d0+theta**2.d0))
          IF (theta < 0.d0) t = -t
        END IF
        c = 1.d0/DSQRT(1.d0 + t**2.d0)
        s = t*c
        tau = s/(1.d0 + c)
        h = t*a(ip,iq)
        z(ip) = z(ip) - h
        z(iq) = z(iq) + h
        d(ip) = d(ip) - h
        d(iq) = d(iq) + h
        a(ip,iq) = 0.d0
        
!               CASE OF ROTATIONS 1 <= J < P
        
        DO j=1,ip-1
          g = a(j,ip)
          h = a(j,iq)
          a(j,ip) = g - s*(h + g*tau)
          a(j,iq) = h + s*(g - h*tau)
        END DO
        
!                CASE OF ROTATIONS P < J < Q
        
        DO j=ip+1,iq-1
          g = a(ip,j)
          h = a(j,iq)
          a(ip,j) = g - s*(h + g*tau)
          a(j,iq) = h + s*(g - h*tau)
        END DO
        
!                 CASE OF ROTATIONS Q < J <= N
        
        DO j=iq+1,n
          g = a(ip,j)
          h = a(iq,j)
          a(ip,j) = g - s*(h + g*tau)
          a(iq,j) = h + s*(g - h*tau)
        END DO
        DO j = 1,n
          g = v(j,ip)
          h = v(j,iq)
          v(j,ip) = g - s*(h + g*tau)
          v(j,iq) = h + s*(g - h*tau)
        END DO
        nrot = nrot + 1
      END IF
    END DO
  END DO
  
!          UPDATE D WITH THE SUM OF T*A_PQ, AND REINITIALIZE Z
  
  DO ip=1,n
    b(ip) = b(ip) + z(ip)
    d(ip) = b(ip)
    z(ip) = 0.d0
  END DO
END DO

! IF THE ALGORITHM HAS REACHED THIS STAGE, THEN THERE
!  ARE TOO MANY SWEEPS.  PRINT A DIAGNOSTIC AND CUT THE
!  TIME INCREMENT.

WRITE (*,'(/1X,A/)') '50 ITERATIONS IN JACOBI SHOULD NEVER HAPPEN'

RETURN
END SUBROUTINE jacobi

!**********************************************************************

SUBROUTINE eigsrt(d,v,n,np)

!     GIVEN THE EIGENVALUES D AND EIGENVECTORS V AS OUTPUT FROM
!     JACOBI, THIS SUBROUTINE SORTS THE EIGENVALUES INTO ASCENDING
!     ORDER AND REARRANGES THE COLMNS OF V ACCORDINGLY.

!     THE SUBROUTINE WAS TAKEN FROM 'NUMERICAL RECIPES.'
use global

DOUBLE PRECISION, INTENT(IN OUT)         :: d(np)
DOUBLE PRECISION, INTENT(IN OUT)         :: v(np,np)
INTEGER, INTENT(IN)                      :: n
INTEGER, INTENT(IN OUT)                  :: np


INTEGER :: i,j,k

DOUBLE PRECISION :: p

DO i=1,n-1
  k = i
  p = d(i)
  DO j=i+1,n
    IF (d(j) >= p) THEN
      k = j
      p = d(j)
    END IF
  END DO
  IF (k /= i) THEN
    d(k) = d(i)
    d(i) = p
    DO j=1,n
      p = v(j,i)
      v(j,i) = v(j,k)
      v(j,k) = p
    END DO
  END IF
END DO

RETURN
END SUBROUTINE eigsrt
SUBROUTINE invariants(a,inv1,inv2,ndi)



!>    1ST AND 2ND INVARIANTS OF A TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(IN)             :: a(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: inv1
DOUBLE PRECISION, INTENT(OUT)            :: inv2



INTEGER :: i1
DOUBLE PRECISION :: aa(ndi,ndi)
DOUBLE PRECISION :: inv1aa

inv1=zero
inv1aa=zero
aa=matmul(a,a)
DO i1=1,ndi
  inv1=inv1+a(i1,i1)
  inv1aa=inv1aa+aa(i1,i1)
END DO
inv2=(one/two)*(inv1*inv1-inv1aa)

RETURN
END SUBROUTINE invariants
SUBROUTINE pk2isomatfic(fic,diso,cbar,cbari1,unit2,ndi)



!>     ISOTROPIC MATRIX: 2PK 'FICTICIOUS' STRESS TENSOR
!      INPUT:
!       DISO - STRAIN-ENERGY DERIVATIVES
!       CBAR - DEVIATORIC LEFT CAUCHY-GREEN TENSOR
!       CBARI1,CBARI2 - CBAR INVARIANTS
!       UNIT2 - 2ND ORDER IDENTITY TENSOR
!      OUTPUT:
!       FIC - 2ND PIOLA KIRCHOOF 'FICTICIOUS' STRESS TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: fic(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: diso(5)
DOUBLE PRECISION, INTENT(IN)             :: cbar(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: cbari1
DOUBLE PRECISION, INTENT(IN)             :: unit2(ndi,ndi)



INTEGER :: i1,j1

DOUBLE PRECISION :: dudi1,dudi2
DOUBLE PRECISION :: aux1,aux2

dudi1=diso(1)
dudi2=diso(2)

aux1=two*(dudi1+cbari1*dudi2)
aux2=-two*dudi2

DO i1=1,ndi
  DO j1=1,ndi
    fic(i1,j1)=aux1*unit2(i1,j1)+aux2*cbar(i1,j1)
  END DO
END DO

RETURN
END SUBROUTINE pk2isomatfic
SUBROUTINE deffil(lambda,m,m0,f,ndi)



!>      SINGLE FILAMENT: STRETCH AND DEFORMED DIRECTION
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: lambda
DOUBLE PRECISION, INTENT(OUT)            :: m(ndi)
DOUBLE PRECISION, INTENT(IN)             :: m0(ndi)
DOUBLE PRECISION, INTENT(IN)             :: f(ndi,ndi)


INTEGER :: i1,j1

DOUBLE PRECISION :: aux

lambda=zero
DO i1=1,ndi
  aux=zero
  DO j1=1,ndi
    aux=aux+f(i1,j1)*m0(j1)
  END DO
  m(i1)=aux
END DO
lambda=dot_product(m,m)
lambda=SQRT(lambda)

RETURN
END SUBROUTINE deffil
SUBROUTINE fslip(f,fbar,det,ndi)



!>     DISTORTION GRADIENT
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(IN)             :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: fbar(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: det


INTEGER :: i1,j1

DOUBLE PRECISION :: scale1

!     JACOBIAN DETERMINANT/VOLUME RATIO (J = det(F))
det = f(1,1) * f(2,2) * f(3,3) - f(1,2) * f(2,1) * f(3,3)

IF (ndi == 3) THEN
  det = det + f(1,2) * f(2,3) * f(3,1) + f(1,3) * f(3,2) * f(2,1)  &
      - f(1,3) * f(3,1) * f(2,2) - f(2,3) * f(3,2) * f(1,1)
END IF

scale1=det**(-one /three)

DO i1=1,ndi
  DO j1=1,ndi
    fbar(i1,j1)=scale1*f(i1,j1)
  END DO
END DO

RETURN
END SUBROUTINE fslip
SUBROUTINE sdvread(statev)
use global
implicit none
!>    VISCOUS DISSIPATION: READ STATE VARS
DOUBLE PRECISION, INTENT(IN)             :: statev(nsdv)




RETURN

END SUBROUTINE sdvread
SUBROUTINE isomat(sseiso,diso,c10,c01,cbari1,cbari2)



!>     ISOTROPIC MATRIX : ISOCHORIC SEF AND DERIVATIVES
use global
IMPLICIT NONE


DOUBLE PRECISION, INTENT(OUT)            :: sseiso
DOUBLE PRECISION, INTENT(OUT)            :: diso(5)
DOUBLE PRECISION, INTENT(IN)             :: c10
DOUBLE PRECISION, INTENT(IN)             :: c01
DOUBLE PRECISION, INTENT(IN OUT)         :: cbari1
DOUBLE PRECISION, INTENT(IN OUT)         :: cbari2


sseiso=c10*(cbari1-three)+c01*(cbari2-three)

diso(1)=c10
diso(2)=c01
diso(3)=zero
diso(4)=zero
diso(5)=zero

RETURN
END SUBROUTINE isomat
SUBROUTINE setvol(cvol,pv,ppv,unit2,unit4s,ndi)



!>    VOLUMETRIC SPATIAL ELASTICITY TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: cvol(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: pv
DOUBLE PRECISION, INTENT(IN OUT)         :: ppv
DOUBLE PRECISION, INTENT(IN OUT)         :: unit2(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: unit4s(ndi,ndi,ndi,ndi)


INTEGER :: i1,j1,k1,l1



DO i1 = 1, ndi
  DO j1 = 1, ndi
    DO k1 = 1, ndi
      DO l1 = 1, ndi
        cvol(i1,j1,k1,l1)= ppv*unit2(i1,j1)*unit2(k1,l1)  &
            -two*pv*unit4s(i1,j1,k1,l1)
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE setvol
SUBROUTINE bangle(ang,f,mf,noel,pdir,ndi)

!>    ANGLE BETWEEN FILAMENT AND PREFERED DIRECTION

use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: ang
DOUBLE PRECISION, INTENT(IN OUT)         :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: mf(ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: pdir(ndi)
INTEGER, INTENT(IN OUT)                  :: noel
!
!
INTEGER :: inoel,i,j
DOUBLE PRECISION :: dnorm, mfa(ndi),aux
DOUBLE PRECISION :: c(ndi,ndi),egvc(ndi,ndi),egvl(ndi)
!
inoel=0
i=0
!DO i=1,nelem
!               ELEMENT IDENTIFICATION
!  IF(noel == INT(prefdir(i,1))) THEN
!    inoel=i
!  END IF
!END DO
!
!DO i=1,ndi
!  j=i+1
!       PREFERED ORIENTATION  ORIENTATION NORMALIZED
!  pdir(i)=prefdir(inoel,j)
!END DO
!        ALTERNATIVE APPROACH: BUNDLES FOLLOW PRINCIPAL DIRECTIONS
!c=matmul(transpose(f),f)
!CALL spectral(c,egvl,egvc)
!       WRITE(*,*) EGVC
!pdir(1)=egvc(1,1)
!pdir(2)=egvc(2,1)
!pdir(3)=egvc(3,1)
!        END OF ALTERNATIVE

!     PREFERED ORIENTATION
dnorm=dot_product(pdir,pdir)
dnorm=DSQRT(dnorm)
!     PREFERED ORIENTATION  NORMALIZED
pdir=pdir/dnorm

!       FILAMENT ORIENTATION
mfa=mf
dnorm=dot_product(mfa,mfa)
dnorm=dsqrt(dnorm)

!       FILAMENT ORIENTATION  NORMALIZED
mfa=mfa/dnorm
!        ANGLE BETWEEN PREFERED ORIENTATION AND FILAMENT - BANGLE
aux=dot_product(mfa,pdir)
!        if AUX.GT.ONE
!        endif
!        write(*,*) aux
ang=acos(aux)

RETURN
END SUBROUTINE bangle

function genbet ( aa, bb )

  !*****************************************************************************80
  !
  !! GENBET generates a beta random deviate.
  !
  !  Discussion:
  !
  !    This procedure returns a single random deviate from the beta distribution
  !    with parameters A and B.  The density is
  !
  !      x^(a-1) * (1-x)^(b-1) / Beta(a,b) for 0 < x < 1
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    19 September 2014
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Russell Cheng,
  !    Generating Beta Variates with Nonintegral Shape Parameters,
  !    Communications of the ACM,
  !    Volume 21, Number 4, April 1978, pages 317-322.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) AA, the first parameter of the beta distribution.
  !    0.0 < AA.
  !
  !    Input, real ( kind = 4 ) BB, the second parameter of the beta distribution.
  !    0.0 < BB.
  !
  !    Output, real ( kind = 4 ) GENBET, a beta random variate.
  !
    implicit none
  
    real ( kind = 4 ) a
    real ( kind = 4 ) aa
    real ( kind = 4 ) alpha
    real ( kind = 4 ) b
    real ( kind = 4 ) bb
    real ( kind = 4 ) beta
    real ( kind = 4 ) delta
    real ( kind = 4 ) gamma
    real ( kind = 4 ) genbet
    real ( kind = 4 ) k1
    real ( kind = 4 ) k2
    real ( kind = 4 ), parameter :: log4 = 1.3862943611198906188E+00
    real ( kind = 4 ), parameter :: log5 = 1.6094379124341003746E+00
    real ( kind = 4 ) r
    real ( kind = 4 ) r4_exp
    real ( kind = 4 ) r4_uni_01
    real ( kind = 4 ) s
    real ( kind = 4 ) t
    real ( kind = 4 ) u1
    real ( kind = 4 ) u2
    real ( kind = 4 ) v
    real ( kind = 4 ) w
    real ( kind = 4 ) y
    real ( kind = 4 ) z
  
    if ( aa <= 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENBET - Fatal error!'
      write ( *, '(a)' ) '  AA <= 0.0'
      stop 1
    end if
  
    if ( bb <= 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENBET - Fatal error!'
      write ( *, '(a)' ) '  BB <= 0.0'
      stop 1
    end if
  !
  !  Algorithm BB
  !
    if ( 1.0E+00 < aa .and. 1.0E+00 < bb ) then
  
      a = min ( aa, bb )
      b = max ( aa, bb )
      alpha = a + b
      beta = sqrt ( ( alpha - 2.0E+00 ) / ( 2.0E+00 * a * b - alpha ) )
      gamma = a + 1.0E+00 / beta
  
      do
  
        u1 = r4_uni_01 ( )
        u2 = r4_uni_01 ( )
        v = beta * log ( u1 / ( 1.0E+00 - u1 ) )
  !
  !  exp ( v ) replaced by r4_exp ( v )
  !
        w = a * r4_exp ( v )
  
        z = u1 ** 2 * u2
        r = gamma * v - log4
        s = a + r - w
  
        if ( 5.0E+00 * z <= s + 1.0E+00 + log5 ) then
          exit
        end if
  
        t = log ( z )
        if ( t <= s ) then
          exit
        end if
  
        if ( t <= ( r + alpha * log ( alpha / ( b + w ) ) ) ) then
          exit
        end if
  
      end do
  !
  !  Algorithm BC
  !
    else
  
      a = max ( aa, bb )
      b = min ( aa, bb )
      alpha = a + b
      beta = 1.0E+00 / b
      delta = 1.0E+00 + a - b
      k1 = delta * ( 1.0E+00 / 72.0E+00 + b / 24.0E+00 ) &
        / ( a / b - 7.0E+00 / 9.0E+00 )
      k2 = 0.25E+00 + ( 0.5E+00 + 0.25E+00 / delta ) * b
  
      do
  
        u1 = r4_uni_01 ( )
        u2 = r4_uni_01 ( )
  
        if ( u1 < 0.5E+00 ) then
  
          y = u1 * u2
          z = u1 * y
  
          if ( k1 <= 0.25E+00 * u2 + z - y ) then
            cycle
          end if
  
        else
  
          z = u1 ** 2 * u2
  
          if ( z <= 0.25E+00 ) then
  
            v = beta * log ( u1 / ( 1.0E+00 - u1 ) )
            w = a * exp ( v )
  
            if ( aa == a ) then
              genbet = w / ( b + w )
            else
              genbet = b / ( b + w )
            end if
  
            return
  
          end if
  
          if ( k2 < z ) then
            cycle
          end if
  
        end if
  
        v = beta * log ( u1 / ( 1.0E+00 - u1 ) )
        w = a * exp ( v )
  
        if ( log ( z ) <= alpha * ( log ( alpha / ( b + w ) ) + v ) - log4 ) then
          exit
        end if
  
      end do
  
    end if
  
    if ( aa == a ) then
      genbet = w / ( b + w )
    else
      genbet = b / ( b + w )
    end if
  
    return
  end
  function genchi ( df )
  
  !*****************************************************************************80
  !
  !! GENCHI generates a Chi-Square random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a random deviate from the chi square distribution
  !    with DF degrees of freedom random variable.
  !
  !    The algorithm exploits the relation between chisquare and gamma.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) DF, the degrees of freedom.
  !    0.0 < DF.
  !
  !    Output, real ( kind = 4 ) GENCHI, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) arg1
    real ( kind = 4 ) arg2
    real ( kind = 4 ) df
    real ( kind = 4 ) genchi
    real ( kind = 4 ) gengam
  
    if ( df <= 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENCHI - Fatal error!'
      write ( *, '(a)' ) '  DF <= 0.'
      write ( *, '(a,g14.6)' ) '  Value of DF: ', df
      stop 1
    end if
  
    arg1 = 1.0E+00
    arg2 = df / 2.0E+00
  
    genchi = 2.0E+00 * gengam ( arg1, arg2 )
  
    return
  end
  function genexp ( av )
  
  !*****************************************************************************80
  !
  !! GENEXP generates an exponential random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a single random deviate from an exponential
  !    distribution with mean AV.
  !
  !    See also the function R4_EXPONENTIAL_SAMPLE.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Joachim Ahrens, Ulrich Dieter,
  !    Computer Methods for Sampling From the
  !    Exponential and Normal Distributions,
  !    Communications of the ACM,
  !    Volume 15, Number 10, October 1972, pages 873-882.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) AV, the mean of the exponential distribution 
  !    from which a random deviate is to be generated.
  !
  !    Output, real ( kind = 4 ) GENEXP, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) av
    real ( kind = 4 ) genexp
    real ( kind = 4 ) sexpo
  
    genexp = sexpo ( ) * av
  
    return
  end
  function genf ( dfn, dfd )
  
  !*****************************************************************************80
  !
  !! GENF generates an F random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a random deviate from the F (variance ratio)
  !    distribution with DFN degrees of freedom in the numerator
  !    and DFD degrees of freedom in the denominator.
  !
  !    It directly generates the ratio of chisquare variates
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) DFN, the numerator degrees of freedom.
  !    0.0 < DFN.
  !
  !    Input, real ( kind = 4 ) DFD, the denominator degrees of freedom.
  !    0.0 < DFD.
  !
  !    Output, real ( kind = 4 ) GENF, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) dfd
    real ( kind = 4 ) dfn
    real ( kind = 4 ) genchi
    real ( kind = 4 ) genf
    real ( kind = 4 ) xden
    real ( kind = 4 ) xnum
  
    if ( dfn <= 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENF - Fatal error!'
      write ( *, '(a)' ) '  DFN <= 0.0'
      stop 1
    end if
  
    if ( dfd <= 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENF - Fatal error!'
      write ( *, '(a)' ) '  DFD <= 0.0'
      stop 1
    end if
  
    xnum = genchi ( dfn ) / dfn
    xden = genchi ( dfd ) / dfd
    genf = xnum / xden
  
    return
  end
  function gengam ( a, r )
  
  !*****************************************************************************80
  !
  !! GENGAM generates a Gamma random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates random deviates from the gamma distribution whose
  !    density is (A^R)/Gamma(R) * X^(R-1) * Exp(-A*X)
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Joachim Ahrens, Ulrich Dieter,
  !    Generating Gamma Variates by a Modified Rejection Technique,
  !    Communications of the ACM,
  !    Volume 25, Number 1, January 1982, pages 47-54.
  !
  !    Joachim Ahrens, Ulrich Dieter,
  !    Computer Methods for Sampling from Gamma, Beta, Poisson and
  !    Binomial Distributions,
  !    Computing,
  !    Volume 12, Number 3, September 1974, pages 223-246.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) A, the location parameter.
  !
  !    Input, real ( kind = 4 ) R, the shape parameter.
  !
  !    Output, real ( kind = 4 ) GENGAM, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) a
    real ( kind = 4 ) gengam
    real ( kind = 4 ) r
    real ( kind = 4 ) sgamma
  
    gengam = sgamma ( r ) / a
  
    return
  end
  subroutine genmn ( parm, x, work )
  
  !*****************************************************************************80
  !
  !! GENMN generates a multivariate normal deviate.
  !
  !  Discussion:
  !
  !    The method is:
  !    1) Generate P independent standard normal deviates - Ei ~ N(0,1)
  !    2) Using Cholesky decomposition find A so that A'*A = COVM
  !    3) A' * E + MEANV ~ N(MEANV,COVM)
  !
  !    Note that PARM contains information needed to generate the
  !    deviates, and is set up by SETGMN.
  !
  !    PARM(1) contains the size of the deviates, P
  !    PARM(2:P+1) contains the mean vector.
  !    PARM(P+2:P*(P+3)/2+1) contains the upper half of the Cholesky
  !    decomposition of the covariance matrix.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) PARM(P*(P+3)/2+1), parameters set by SETGMN.
  !
  !    Output, real ( kind = 4 ) X(P), a random deviate from the distribution.
  !
  !    Workspace, real ( kind = 4 ) WORK(P).
  !
    implicit none
  
    real ( kind = 4 ) ae
    integer ( kind = 4 ) i
    integer ( kind = 4 ) icount
    integer ( kind = 4 ) j
    integer ( kind = 4 ) p
    real ( kind = 4 ) parm(*)
    real ( kind = 4 ) snorm
    real ( kind = 4 ) work(*)
    real ( kind = 4 ) x(*)
  
    p = int ( parm(1) )
  !
  !  Generate P independent normal deviates.
  !
    do i = 1, p
      work(i) = snorm ( )
    end do
  !
  !  Compute X = MEANV + A' * WORK
  !
    do i = 1, p
      icount = 0
      ae = 0.0E+00
      do j = 1, i
        icount = icount + j - 1
        ae = ae + parm(i+(j-1)*p-icount+p+1) * work(j)
      end do
  
      x(i) = ae + parm(i+1)
  
    end do
  
    return
  end
  subroutine genmul ( n, p, ncat, ix )
  
  !*****************************************************************************80
  !
  !! GENMUL generates a multinomial random deviate.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Luc Devroye,
  !    Non-Uniform Random Variate Generation,
  !    Springer, 1986,
  !    ISBN: 0387963057,
  !    LC: QA274.D48.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) N, the number of events, which will be
  !    classified into one of the NCAT categories.
  !
  !    Input, real ( kind = 4 ) P(NCAT-1).  P(I) is the probability that an event
  !    will be classified into category I.  Thus, each P(I) must be between 
  !    0.0 and 1.0.  Only the first NCAT-1 values of P must be defined since 
  !    P(NCAT) would be 1.0 minus the sum of the first NCAT-1 P's.
  !
  !    Input, integer ( kind = 4 ) NCAT, the number of categories.
  !
  !    Output, integer ( kind = 4 ) IX(NCAT), a random observation from 
  !    the multinomial distribution.  All IX(i) will be nonnegative and their 
  !    sum will be N.
  !
    implicit none
  
    integer ( kind = 4 ) n
    integer ( kind = 4 ) ncat
  
    integer ( kind = 4 ) i
    integer ( kind = 4 ) icat
    integer ( kind = 4 ) ignbin
    integer ( kind = 4 ) ix(ncat)
    integer ( kind = 4 ) ntot
    real ( kind = 4 ) p(ncat-1)
    real ( kind = 4 ) prob
    real ( kind = 4 ) ptot
  
    if ( n < 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENMUL - Fatal error!'
      write ( *, '(a)' ) '  N < 0'
      stop 1
    end if
  
    if ( ncat <= 1 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENMUL - Fatal error!'
      write ( *, '(a)' ) '  NCAT <= 1'
      stop 1
    end if
  
    do i = 1, ncat - 1
  
      if ( p(i) < 0.0E+00 ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) 'GENMUL - Fatal error!'
        write ( *, '(a)' ) '  Some P(i) < 0.'
        stop 1
      end if
  
      if ( 1.0E+00 < p(i) ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) 'GENMUL - Fatal error!'
        write ( *, '(a)' ) '  Some 1 < P(i).'
        stop 1
      end if
  
    end do
  
    ptot = 0.0E+00
    do i = 1, ncat - 1
      ptot = ptot + p(i)
    end do
  
    if ( 0.99999E+00 < ptot ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENMUL - Fatal error!'
      write ( *, '(a)' ) '  1 < Sum of P().'
      stop 1
    end if
  !
  !  Initialize variables.
  !
    ntot = n
    ptot = 1.0E+00
    do i = 1, ncat
      ix(i) = 0
    end do
  !
  !  Generate the observation.
  !
    do icat = 1, ncat - 1
      prob = p(icat) / ptot
      ix(icat) = ignbin ( ntot, prob )
      ntot = ntot - ix(icat)
      if ( ntot <= 0 ) then
        return
      end if
      ptot = ptot - p(icat)
    end do
  
    ix(ncat) = ntot
  
    return
  end
  function gennch ( df, xnonc )
  
  !*****************************************************************************80
  !
  !! GENNCH generates a noncentral Chi-Square random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a random deviate from the  distribution of a
  !    noncentral chisquare with DF degrees of freedom and noncentrality parameter
  !    XNONC.
  !
  !    It uses the fact that the noncentral chisquare is the sum of a chisquare
  !    deviate with DF-1 degrees of freedom plus the square of a normal
  !    deviate with mean XNONC and standard deviation 1.
  !
  !    A subtle ambiguity arises in the original formulation:
  !
  !      gennch = genchi ( arg1 ) + ( gennor ( arg2, arg3 ) ) ^ 2
  !
  !    because the compiler is free to invoke either genchi or gennor
  !    first, both of which alter the random number generator state,
  !    resulting in two distinct possible results.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) DF, the degrees of freedom.
  !    1.0 < DF.
  !
  !    Input, real ( kind = 4 ) XNONC, the noncentrality parameter.
  !    0.0 <= XNONC.
  !
  !    Output, real ( kind = 4 ) GENNCH, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) arg1
    real ( kind = 4 ) arg2
    real ( kind = 4 ) arg3
    real ( kind = 4 ) df
    real ( kind = 4 ) genchi
    real ( kind = 4 ) gennch
    real ( kind = 4 ) gennor
    real ( kind = 4 ) t1
    real ( kind = 4 ) t2
    real ( kind = 4 ) xnonc
  
    if ( df <= 1.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENNCH - Fatal error!'
      write ( *, '(a)' ) '  DF <= 1.'
      stop 1
    end if
  
    if ( xnonc < 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENNCH - Fatal error!'
      write ( *, '(a)' ) '  XNONC < 0.0.'
      stop 1
    end if
  
    arg1 = df - 1.0E+00
    arg2 = sqrt ( xnonc )
    arg3 = 1.0E+00
  
    t1 = genchi ( arg1 )
    t2 = gennor ( arg2, arg3 )
  
    gennch = t1 + t2 * t2
  
    return
  end
  function gennf ( dfn, dfd, xnonc )
  
  !*****************************************************************************80
  !
  !! GENNF generates a noncentral F random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a random deviate from the noncentral F
  !    (variance ratio) distribution with DFN degrees of freedom in the
  !    numerator, and DFD degrees of freedom in the denominator, and
  !    noncentrality parameter XNONC.
  !
  !    It directly generates the ratio of noncentral numerator chisquare variate
  !    to central denominator chisquare variate.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) DFN, the numerator degrees of freedom.
  !    1.0 < DFN.
  !
  !    Input, real ( kind = 4 ) DFD, the denominator degrees of freedom.
  !    0.0 < DFD.
  !
  !    Input, real ( kind = 4 ) XNONC, the noncentrality parameter.
  !    0.0 <= XNONC.
  !
  !    Output, real ( kind = 4 ) GENNF, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) dfd
    real ( kind = 4 ) dfn
    real ( kind = 4 ) genchi
    real ( kind = 4 ) gennch
    real ( kind = 4 ) gennf
    real ( kind = 4 ) xden
    real ( kind = 4 ) xnonc
    real ( kind = 4 ) xnum
  
    if ( dfn <= 1.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENNF - Fatal error!'
      write ( *, '(a)' ) '  DFN <= 1.0'
      stop 1
    end if
  
    if ( dfd <= 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENNF - Fatal error!'
      write ( *, '(a)' ) '  DFD <= 0.0'
      stop 1
    end if
  
    if ( xnonc < 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GENNF - Fatal error!'
      write ( *, '(a)' ) '  XNONC < 0.0'
      stop 1
    end if
  
    xnum = gennch ( dfn, xnonc ) / dfn
    xden = genchi ( dfd ) / dfd
  
    gennf = xnum / xden
  
    return
  end
  function gennor ( av, sd )
  
  !*****************************************************************************80
  !
  !! GENNOR generates a normal random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a single random deviate from a normal distribution
  !    with mean AV, and standard deviation SD.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Joachim Ahrens, Ulrich Dieter,
  !    Extensions of Forsythe's Method for Random
  !    Sampling from the Normal Distribution,
  !    Mathematics of Computation,
  !    Volume 27, Number 124, October 1973, page 927-937.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) AV, the mean.
  !
  !    Input, real ( kind = 4 ) SD, the standard deviation.
  !
  !    Output, real ( kind = 4 ) GENNOR, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) av
    real ( kind = 4 ) gennor
    real ( kind = 4 ) sd
    real ( kind = 4 ) snorm
  
    gennor = sd * snorm ( ) + av
  
    return
  end
  subroutine genprm ( iarray, n )
  
  !*****************************************************************************80
  !
  !! GENPRM generates and applies a random permutation to an array.
  !
  !  Discussion:
  !
  !    To see the permutation explicitly, let the input array be
  !    1, 2, ..., N.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    20 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input/output, integer ( kind = 4 ) IARRAY(N), an array to be permuted.
  !
  !    Input, integer ( kind = 4 ) N, the number of entries in the array.
  !
    implicit none
  
    integer ( kind = 4 ) n
  
    integer ( kind = 4 ) i
    integer ( kind = 4 ) iarray(n)
    integer ( kind = 4 ) ignuin
    integer ( kind = 4 ) itmp
    integer ( kind = 4 ) iwhich
  
    do i = 1, n
      iwhich = ignuin ( i, n )
      itmp = iarray(iwhich)
      iarray(iwhich) = iarray(i)
      iarray(i) = itmp
    end do
  
    return
  end
  function genunf ( low, high )
  
  !*****************************************************************************80
  !
  !! GENUNF generates a uniform random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a real deviate uniformly distributed between
  !    LOW and HIGH.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) LOW, HIGH, the lower and upper bounds.
  !
  !    Output, real ( kind = 4 ) GENUNF, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) genunf
    real ( kind = 4 ) high
    real ( kind = 4 ) low
    real ( kind = 4 ) r4_uni_01
  
    genunf = low + ( high - low ) * r4_uni_01 ( )
  
    return
  end
  function ignbin ( n, pp )
  
  !*****************************************************************************80
  !
  !! IGNBIN generates a binomial random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a single random deviate from a binomial
  !    distribution whose number of trials is N and whose
  !    probability of an event in each trial is P.
  !
  !    The previous version of this program relied on the assumption that
  !    local memory would be preserved between calls.  It set up data
  !    one time to be preserved for use over multiple calls.  In the
  !    interests of portability, this assumption has been removed, and
  !    the "setup" data is recomputed on every call.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Voratas Kachitvichyanukul, Bruce Schmeiser,
  !    Binomial Random Variate Generation,
  !    Communications of the ACM,
  !    Volume 31, Number 2, February 1988, pages 216-222.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) N, the number of binomial trials, from which a
  !    random deviate will be generated.
  !    0 < N.
  !
  !    Input, real ( kind = 4 ) PP, the probability of an event in each trial of
  !    the binomial distribution from which a random deviate is to be generated.
  !    0.0 < PP < 1.0.
  !
  !    Output, integer ( kind = 4 ) IGNBIN, a random deviate from the
  !    distribution.
  !
    implicit none
  
    real ( kind = 4 ) al
    real ( kind = 4 ) alv
    real ( kind = 4 ) amaxp
    real ( kind = 4 ) c
    real ( kind = 4 ) f
    real ( kind = 4 ) f1
    real ( kind = 4 ) f2
    real ( kind = 4 ) ffm
    real ( kind = 4 ) fm
    real ( kind = 4 ) g
    integer ( kind = 4 ) i
    integer ( kind = 4 ) ignbin
    integer ( kind = 4 ) ix
    integer ( kind = 4 ) ix1
    integer ( kind = 4 ) k
    integer ( kind = 4 ) m
    integer ( kind = 4 ) mp
    real ( kind = 4 ) pp
    integer ( kind = 4 ) n
    real ( kind = 4 ) p
    real ( kind = 4 ) p1
    real ( kind = 4 ) p2
    real ( kind = 4 ) p3
    real ( kind = 4 ) p4
    real ( kind = 4 ) q
    real ( kind = 4 ) qn
    real ( kind = 4 ) r
    real ( kind = 4 ) r4_uni_01
    real ( kind = 4 ) t
    real ( kind = 4 ) u
    real ( kind = 4 ) v
    real ( kind = 4 ) w
    real ( kind = 4 ) w2
    real ( kind = 4 ) x
    real ( kind = 4 ) x1
    real ( kind = 4 ) x2
    real ( kind = 4 ) xl
    real ( kind = 4 ) xll
    real ( kind = 4 ) xlr
    real ( kind = 4 ) xm
    real ( kind = 4 ) xnp
    real ( kind = 4 ) xnpq
    real ( kind = 4 ) xr
    real ( kind = 4 ) ynorm
    real ( kind = 4 ) z
    real ( kind = 4 ) z2
  
    if ( pp <= 0.0E+00 .or. 1.0E+00 <= pp ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'IGNBIN - Fatal error!'
      write ( *, '(a)' ) '  PP is out of range.'
      stop 1
    end if
  
    p = min ( pp, 1.0E+00 - pp )
    q = 1.0E+00 - p
    xnp = real ( n, kind = 4 ) * p
  
    if ( xnp < 30.0E+00 ) then
  
      qn = q ** n
      r = p / q
      g = r * real ( n + 1, kind = 4 )
  
      do
  
        ix = 0
        f = qn
        u = r4_uni_01 ( )
  
        do
  
          if ( u < f ) then
            if ( 0.5E+00 < pp ) then
              ix = n - ix
            end if
            ignbin = ix
            return
          end if
  
          if ( 110 < ix ) then
            exit
          end if
  
          u = u - f
          ix = ix + 1
          f = f * ( g / real ( ix, kind = 4 ) - r )
  
        end do
  
      end do
  
    end if
  
    ffm = xnp + p
    m = ffm
    fm = m
    xnpq = xnp * q
    p1 = int ( 2.195E+00 * sqrt ( xnpq ) - 4.6E+00 * q ) + 0.5E+00
    xm = fm + 0.5E+00
    xl = xm - p1
    xr = xm + p1
    c = 0.134E+00 + 20.5E+00 / ( 15.3E+00 + fm )
    al = ( ffm - xl ) / ( ffm - xl * p )
    xll = al * ( 1.0E+00 + 0.5E+00 * al )
    al = ( xr - ffm ) / ( xr * q )
    xlr = al * ( 1.0E+00 + 0.5E+00 * al )
    p2 = p1 * ( 1.0E+00 + c + c )
    p3 = p2 + c / xll
    p4 = p3 + c / xlr
  !
  !  Generate a variate.
  !
    do
  
      u = r4_uni_01 ( ) * p4
      v = r4_uni_01 ( )
  !
  !  Triangle
  !
      if ( u < p1 ) then
        ix = xm - p1 * v + u
        if ( 0.5E+00 < pp ) then
          ix = n - ix
        end if
        ignbin = ix
        return
      end if
  !
  !  Parallelogram
  !
      if ( u <= p2 ) then
  
        x = xl + ( u - p1 ) / c
        v = v * c + 1.0E+00 - abs ( xm - x ) / p1
  
        if ( v <= 0.0E+00 .or. 1.0E+00 < v ) then
          cycle
        end if
  
        ix = x
  
      else if ( u <= p3 ) then
  
        ix = xl + log ( v ) / xll
        if ( ix < 0 ) then
          cycle
        end if
        v = v * ( u - p2 ) * xll
  
      else
  
        ix = xr - log ( v ) / xlr
        if ( n < ix ) then
          cycle
        end if
        v = v * ( u - p3 ) * xlr
  
      end if
  
      k = abs ( ix - m )
  
      if ( k <= 20 .or. xnpq / 2.0 - 1.0 <= k ) then
  
        f = 1.0E+00
        r = p / q
        g = ( n + 1 ) * r
  
        if ( m < ix ) then
          mp = m + 1
          do i = m + 1, ix
            f = f * ( g / i - r )
          end do
        else if ( ix < m ) then
          ix1 = ix + 1
          do i = ix + 1, m
            f = f / ( g / real ( i, kind = 4 ) - r )
          end do
        end if
  
        if ( v <= f ) then
          if ( 0.5E+00 < pp ) then
            ix = n - ix
          end if
          ignbin = ix
          return
        end if
  
      else
  
        amaxp = ( k / xnpq ) * ( ( k * ( k / 3.0E+00 &
          + 0.625E+00 ) + 0.1666666666666E+00 ) / xnpq + 0.5E+00 )
        ynorm = - real ( k * k, kind = 4 ) / ( 2.0E+00 * xnpq )
        alv = log ( v )
  
        if ( alv < ynorm - amaxp ) then
          if ( 0.5E+00 < pp ) then
            ix = n - ix
          end if
          ignbin = ix
          return
        end if
  
        if ( ynorm + amaxp < alv ) then
          cycle
        end if
  
        x1 = real ( ix + 1, kind = 4 )
        f1 = fm + 1.0E+00
        z = real ( n + 1, kind = 4 ) - fm
        w = real ( n - ix + 1, kind = 4 )
        z2 = z * z
        x2 = x1 * x1
        f2 = f1 * f1
        w2 = w * w
  
        t = xm * log ( f1 / x1 ) + ( n - m + 0.5E+00 ) * log ( z / w ) &
          + real ( ix - m, kind = 4 ) * log ( w * p / ( x1 * q ) ) &
          + ( 13860.0E+00 - ( 462.0E+00 - ( 132.0E+00 - ( 99.0E+00 - 140.0E+00 &
          / f2 ) / f2 ) / f2 ) / f2 ) / f1 / 166320.0E+00 &
          + ( 13860.0E+00 - ( 462.0E+00 - ( 132.0E+00 - ( 99.0E+00 - 140.0E+00 &
          / z2 ) / z2 ) / z2 ) / z2 ) / z / 166320.0E+00 &
          + ( 13860.0E+00 - ( 462.0E+00 - ( 132.0E+00 - ( 99.0E+00 - 140.0E+00 &
          / x2 ) / x2 ) / x2 ) / x2 ) / x1 / 166320.0E+00 &
          + ( 13860.0E+00 - ( 462.0E+00 - ( 132.0E+00 - ( 99.0E+00 - 140.0E+00 &
          / w2 ) / w2 ) / w2 ) / w2 ) / w / 166320.0E+00
  
        if ( alv <= t ) then
          if ( 0.5E+00 < pp ) then
            ix = n - ix
          end if
          ignbin = ix
          return
        end if
  
      end if
  
    end do
  
    return
  end
  function ignnbn ( n, p )
  
  !*****************************************************************************80
  !
  !! IGNNBN generates a negative binomial random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a single random deviate from a negative binomial
  !    distribution.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Luc Devroye,
  !    Non-Uniform Random Variate Generation,
  !    Springer, 1986,
  !    ISBN: 0387963057,
  !    LC: QA274.D48.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) N, the required number of events.
  !    0 <= N.
  !
  !    Input, real ( kind = 4 ) P, the probability of an event during a 
  !    Bernoulli trial.  0.0 < P < 1.0.
  !
  !    Output, integer ( kind = 4 ) IGNNBN, a random deviate from 
  !    the distribution.
  !
    implicit none
  
    real ( kind = 4 ) a
    real ( kind = 4 ) gengam
    integer ( kind = 4 ) ignnbn
    integer ( kind = 4 ) ignpoi
    integer ( kind = 4 ) n
    real ( kind = 4 ) p
    real ( kind = 4 ) r
    real ( kind = 4 ) y
  
    if ( n < 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'IGNNBN - Fatal error!'
      write ( *, '(a)' ) '  N < 0.'
      stop 1
    end if
  
    if ( p <= 0.0E+00 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'IGNNBN - Fatal error!'
      write ( *, '(a)' ) '  P <= 0.0'
      stop 1
    end if
  
    if ( 1.0E+00 <= p ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'IGNNBN - Fatal error!'
      write ( *, '(a)' ) '  1.0 <= P'
      stop 1
    end if
  !
  !  Generate Y, a random gamma (n,(1-p)/p) variable.
  !
    r = real ( n )
    a = p / ( 1.0E+00 - p )
    y = gengam ( a, r )
  !
  !  Generate a random Poisson ( y ) variable.
  !
    ignnbn = ignpoi ( y )
  
    return
  end
  function ignpoi ( mu )
  
  !*****************************************************************************80
  !
  !! IGNPOI generates a Poisson random deviate.
  !
  !  Discussion:
  !
  !    This procedure generates a single random deviate from a Poisson
  !    distribution with given mean.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    02 September 2018
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Joachim Ahrens, Ulrich Dieter,
  !    Computer Generation of Poisson Deviates
  !    From Modified Normal Distributions,
  !    ACM Transactions on Mathematical Software,
  !    Volume 8, Number 2, June 1982, pages 163-179.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) MU, the mean of the Poisson distribution 
  !    from which a random deviate is to be generated.
  !
  !    Output, integer ( kind = 4 ) IGNPOI, a random deviate from
  !    the distribution.
  !
    implicit none
  
    real ( kind = 4 ), parameter :: a0 = -0.5E+00
    real ( kind = 4 ), parameter :: a1 =  0.3333333E+00
    real ( kind = 4 ), parameter :: a2 = -0.2500068E+00
    real ( kind = 4 ), parameter :: a3 =  0.2000118E+00
    real ( kind = 4 ), parameter :: a4 = -0.1661269E+00
    real ( kind = 4 ), parameter :: a5 =  0.1421878E+00
    real ( kind = 4 ), parameter :: a6 = -0.1384794E+00
    real ( kind = 4 ), parameter :: a7 =  0.1250060E+00
    real ( kind = 4 ) b1
    real ( kind = 4 ) b2
    real ( kind = 4 ) c
    real ( kind = 4 ) c0
    real ( kind = 4 ) c1
    real ( kind = 4 ) c2
    real ( kind = 4 ) c3
    real ( kind = 4 ) d
    real ( kind = 4 ) del
    real ( kind = 4 ) difmuk
    real ( kind = 4 ) e
    real ( kind = 4 ) fact(10)
    real ( kind = 4 ) fk
    real ( kind = 4 ) fx
    real ( kind = 4 ) fy
    real ( kind = 4 ) g
    integer ( kind = 4 ) ignpoi
    integer ( kind = 4 ) j
    integer ( kind = 4 ) k
    integer ( kind = 4 ) kflag
    integer ( kind = 4 ) l
    integer ( kind = 4 ) m
    real ( kind = 4 ) mu
    real ( kind = 4 ) muold
    real ( kind = 4 ) muprev
    real ( kind = 4 ) omega
    real ( kind = 4 ) p
    real ( kind = 4 ) p0
    real ( kind = 4 ) px
    real ( kind = 4 ) py
    real ( kind = 4 ) q
    real ( kind = 4 ) r4_uni_01
    real ( kind = 4 ) s
    real ( kind = 4 ) sexpo
    real ( kind = 4 ) snorm
    real ( kind = 4 ) t
    real ( kind = 4 ) u
    real ( kind = 4 ) v
    real ( kind = 4 ) x
    real ( kind = 4 ) xx
  
    save fact
  
    data fact / 1.0E+00, 1.0E+00, 2.0E+00, 6.0E+00, 24.0E+00, &
      120.0E+00, 720.0E+00, 5040.0E+00, 40320.0E+00, 362880.0E+00 /
  !
  !  MU < 10
  !
    if ( mu < 10.0E+00 ) then
  
      m = max ( 1, int ( mu ) )
      l = 0
      p = exp ( - mu )
      q = p
      p0 = p
  !
  !  Uniform sample for inversion method.
  !
      do
  
        u = r4_uni_01 ( )
        ignpoi = 0
  
        if ( u <= p0 ) then
          return
        end if
  !
  !  Creation of new Poisson probabilities.
  !
        do k = 1, 35
          p = p * mu / real ( k )
          q = q + p
          if ( u <= q ) then
            ignpoi = k
            return
          end if
        end do
  
      end do
  !
  !  10 <= MU
  !
    else
  
      s = sqrt ( mu )
      d = 6.0E+00 * mu * mu
      l = int ( mu - 1.1484E+00 )
  !
  !  Normal sample.
  !
      g = mu + s * snorm ( )
  
      if ( 0.0E+00 <= g ) then
  
        ignpoi = int ( g )
  !
  !  Immediate acceptance if large enough.
  !
        if ( l <= ignpoi ) then
          return
        end if
  !
  !  Squeeze acceptance.
  !
        fk = real ( ignpoi )
        difmuk = mu - fk
        u = r4_uni_01 ( )
  
        if ( difmuk * difmuk * difmuk <= d * u ) then
          return
        end if
  
      end if
  !
  !  Preparation for steps P and Q.
  !
      omega = 0.3989423E+00 / s
      b1 = 0.04166667E+00 / mu
      b2 = 0.3E+00 * b1 * b1
      c3 = 0.1428571E+00 * b1 * b2
      c2 = b2 - 15.0E+00 * c3
      c1 = b1 - 6.0E+00 * b2 + 45.0E+00 * c3
      c0 = 1.0E+00 - b1 + 3.0E+00 * b2 - 15.0E+00 * c3
      c = 0.1069E+00 / mu
  
      if ( 0.0E+00 <= g ) then
  
        kflag = 0
  
        if ( ignpoi < 10 ) then
  
          px = - mu
          py = mu ** ignpoi / fact(ignpoi+1)
  
        else
  
          del = 0.8333333E-01 / fk
          del = del - 4.8E+00 * del * del * del
          v = difmuk / fk
  
          if ( 0.25E+00 < abs ( v ) ) then
            px = fk * log ( 1.0E+00 + v ) - difmuk - del
          else
            px = fk * v * v * ((((((( a7 &
              * v + a6 ) &
              * v + a5 ) &
              * v + a4 ) &
              * v + a3 ) &
              * v + a2 ) &
              * v + a1 ) &
              * v + a0 ) - del
          end if
  
          py = 0.3989423E+00 / sqrt ( fk )
  
        end if
  
        x = ( 0.5E+00 - difmuk ) / s
        xx = x * x
        fx = -0.5E+00 * xx
        fy = omega * ((( c3 * xx + c2 ) * xx + c1 ) * xx + c0 )
  
        if ( fy - u * fy <= py * exp ( px - fx ) ) then
          return
        end if
  
      end if
  !
  !  Exponential sample.
  !
      do
  
        e = sexpo ( )
        u = 2.0E+00 * r4_uni_01 ( ) - 1.0E+00
        if ( u < 0.0E+00 ) then
          t = 1.8E+00 - abs ( e )
        else
          t = 1.8E+00 + abs ( e )
        end if
  
        if ( t <= -0.6744E+00 ) then
          cycle
        end if
  
        ignpoi = int ( mu + s * t )
        fk = real ( ignpoi )
        difmuk = mu - fk
  
        kflag = 1
  !
  !  Calculation of PX, PY, FX, FY.
  !
        if ( ignpoi < 10 ) then
  
          px = -mu
          py = mu ** ignpoi / fact(ignpoi+1)
    
        else
  
          del = 0.8333333E-01 / fk
          del = del - 4.8E+00 * del * del * del
          v = difmuk / fk
  
          if ( 0.25E+00 < abs ( v ) ) then
            px = fk * log ( 1.0E+00 + v ) - difmuk - del
          else
            px = fk * v * v * ((((((( a7 &
              * v + a6 ) &
              * v + a5 ) &
              * v + a4 ) &
              * v + a3 ) &
              * v + a2 ) &
              * v + a1 ) &
              * v + a0 ) - del
          end if
  
          py = 0.3989423E+00 / sqrt ( fk )
  
        end if
  
        x = ( 0.5E+00 - difmuk ) / s
        xx = x * x
        fx = -0.5E+00 * xx
        fy = omega * ((( c3 * xx + c2 ) * xx + c1 ) * xx + c0 )
  
        if ( kflag <= 0 ) then
  
          if ( fy - u * fy <= py * exp ( px - fx ) ) then
            return
          end if
  
        else
  
          if ( c * abs ( u ) <= py * exp ( px + e ) - fy * exp ( fx + e ) ) then
            return
          end if
  
        end if
  
      end do
  
    end if
  
  end
  function ignuin ( low, high )
  
  !*****************************************************************************80
  !
  !! IGNUIN generates a random integer in a given range.
  !
  !  Discussion:
  !
  !    Each deviate K satisfies LOW <= K <= HIGH.
  !
  !    If (HIGH-LOW) > 2,147,483,561, this procedure prints an error message
  !    and stops the program.
  !
  !    IGNLGI generates integer ( kind = 4 )s between 1 and 2147483562.
  !
  !    MAXNUM is 1 less than the maximum generatable value.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) LOW, HIGH, the lower and upper bounds.
  !
  !    Output, integer ( kind = 4 ) IGNUIN, a random deviate from 
  !    the distribution.
  !
    implicit none
  
    integer ( kind = 4 ) err
    integer ( kind = 4 ) high
    integer ( kind = 4 ) i4_uni
    integer ( kind = 4 ) ign
    integer ( kind = 4 ) ignuin
    integer ( kind = 4 ) low
    integer ( kind = 4 ) maxnow
    integer ( kind = 4 ) maxnum
    parameter ( maxnum = 2147483561 )
    integer ( kind = 4 ) ranp1
    integer ( kind = 4 ) width
  
    if ( high < low ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'IGNUIN - Fatal error!'
      write ( *, '(a)' ) '  HIGH < LOW.'
      stop 1
    end if
  
    width = high - low
  
    if ( maxnum < width ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'IGNUIN - Fatal error!'
      write ( *, '(a)' ) '  Range HIGH-LOW is too large.'
      stop 1
    end if
  
    if ( low == high ) then
      ignuin = low
      return
    end if
  
    ranp1 = width + 1
    maxnow = ( maxnum / ranp1 ) * ranp1
  
    do
  
      ign = i4_uni ( ) - 1
  
      if ( ign <= maxnow ) then
        exit
      end if
  
    end do
  
    ignuin = low + mod ( ign, ranp1 )
  
    return
  end
  function lennob ( s )
  
  !*****************************************************************************80
  !
  !! LENNOB counts the length of a string, ignoring trailing blanks.
  !
  !  Discussion:
  !
  !    This procedure returns the length of a string up to and including
  !    the last non-blank character.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, character * ( * ) S, the string.
  !
  !    Output, integer ( kind = 4 ) LENNOB, the length of the string to the last
  !    nonblank.
  !
    implicit none
  
    integer ( kind = 4 ) i
    integer ( kind = 4 ) lennob
    character ( len=* ) s
    integer ( kind = 4 ) s_max
  
    s_max = len ( s )
  
    do i = s_max, 1, -1
      if ( s(i:i) /= ' ' ) then
        lennob = i
        return
      end if
    end do
  
    lennob = 0
  
    return
  end
  subroutine phrtsd ( phrase, seed1, seed2 )
  
  !*****************************************************************************80
  !
  !! PHRTST converts a phrase to a pair of random number generator seeds.
  !
  !  Discussion:
  !
  !    This procedure uses a character string to generate two seeds for the RGN
  !    random number generator.
  !
  !    Trailing blanks are eliminated before the seeds are generated.
  !
  !    Generated seed values will fall in the range 1 to 2^30 = 1,073,741,824.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, character * ( * ) PHRASE, a phrase to be used for the
  !    random number generation.
  !
  !    Output, integer ( kind = 4 ) SEED1, SEED2, the two seeds for the
  !    random number generator, based on PHRASE.
  !
    implicit none
  
    integer ( kind = 4 ) i
    integer ( kind = 4 ) ichr
    integer ( kind = 4 ) j
    integer ( kind = 4 ) lennob
    integer ( kind = 4 ) lphr
    character ( len=* ) phrase
    integer ( kind = 4 ) seed1
    integer ( kind = 4 ) seed2
    integer ( kind = 4 ) shift(0:4)
    character * ( 86 ) table
    parameter ( table = &
      'abcdefghijklmnopqrstuvwxyz'// &
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'// &
      '0123456789'// &
      '!@#$%^&*()_+[];:''"<>?,./' )
    integer ( kind = 4 ) twop30
    parameter ( twop30 = 1073741824 )
    integer ( kind = 4 ) values(5)
  
    save shift
  
    data shift / 1, 64, 4096, 262144, 16777216 /
  
    seed1 = 1234567890
    seed2 = 123456789
  
    lphr = lennob ( phrase )
  
    do i = 1, lphr
  
      ichr = index ( table, phrase(i:i) )
  !
  !  If the character does not occur, ICHR is returned as 0.
  !
      ichr = mod ( ichr, 64 )
  
      if ( ichr == 0 ) then
        ichr = 63
      end if
  
      do j = 1, 5
        values(j) = ichr - j
        if ( values(j) < 1 ) then
          values(j) = values(j) + 63
        end if
      end do
  
      do j = 1, 5
        seed1 = mod ( seed1 + shift(j-1) * values(j), twop30 )
        seed2 = mod ( seed2 + shift(j-1) * values(6-j), twop30 )
      end do
  
    end do
    !write ( *, '(a)' ) ' phrtsd '
    return
  end
  subroutine prcomp ( maxobs, p, mean, xcovar, answer )
  
  !*****************************************************************************80
  !
  !! PRCOMP prints covariance information.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    03 September 2018
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) MAXOBS, the number of observations.
  !
  !    Input, integer ( kind = 4 ) P, the number of variables.
  !
  !    Input, real ( kind = 4 ) MEAN(P), the mean for each column.
  !
  !    Input, real ( kind = 4 ) XCOVAR(P,P), the variance/covariance matrix.
  !
  !    Input, real ( kind = 4 ) ANSWER(MAXOBS,P), the observed values.
  !
    implicit none
  
    integer ( kind = 4 ) p
    integer ( kind = 4 ) maxobs
  
    real ( kind = 4 ) answer(maxobs,p)
    real ( kind = 4 ) dum1
    real ( kind = 4 ) dum2
    integer ( kind = 4 ) i
    integer ( kind = 4 ) j
    real ( kind = 4 ) mean(p)
    real ( kind = 4 ) r4vec_covar
    real ( kind = 4 ) rcovar(p,p)
    real ( kind = 4 ) rmean(p)
    real ( kind = 4 ) rvar(p)
    real ( kind = 4 ) xcovar(p,p)
  
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'PRCOMP:'
    write ( *, '(a)' ) '  Print and compare covariance information'
    write ( *, '(a)' ) ' '
  
    do j = 1, p
      call stats ( answer(1,j), maxobs, rmean(j), rvar(j), &
        dum1, dum2 )
      write ( *, '(a,i4)' ) '  Variable Number ', j
      write ( *, '(a,g14.6,a,g14.6)' ) &
        '  Mean ', mean(j), ' Generated ', rmean(j)
      write ( *, '(a,g14.6,a,g14.6)' ) &
        '  Variance ', xcovar(j,j), ' Generated ', rvar(j)
    end do
  
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) '  Covariances:'
    write ( *, '(a)' ) ' '
  
    do i = 1, p
      do j = 1, i - 1
        write ( *, '(a,i4,a,i4)' ) '  I = ', i, ' J = ', j
        rcovar(i,j) = r4vec_covar ( maxobs, answer(1,i), answer(1,j) )
        write ( *, '(a,g14.6,a,g14.6)' ) &
          '  Covariance ', xcovar(i,j), ' Generated ', rcovar(i,j)
      end do
    end do
  
    return
  end
  function r4_exp ( x )
  
  !*****************************************************************************80
  !
  !! R4_EXP computes the exponential of an R8, avoiding overflow and underflow.
  !
  !  Discussion:
  !
  !    For arguments of very large magnitude, the evaluation of the
  !    exponential function can cause computational problems.  Some languages
  !    and compilers may return an infinite value or a "Not-a-Number".  
  !    An alternative, when dealing with a wide range of inputs, is simply
  !    to truncate the calculation for arguments whose magnitude is too large.
  !    Whether this is the right or convenient approach depends on the problem
  !    you are dealing with, and whether or not you really need accurate
  !    results for large magnitude inputs, or you just want your code to
  !    stop crashing.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    19 September 2014
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) X, the argument of the exponential function.
  !
  !    Output, real ( kind = 4 ) R4_EXP, the value of exp ( X ).
  !
    implicit none
  
    real ( kind = 4 ) r4_exp
    real ( kind = 4 ), parameter :: r4_huge = 1.0E+30
    real ( kind = 4 ), parameter :: r4_log_max = +69.0776E+00
    real ( kind = 4 ), parameter :: r4_log_min = -69.0776E+00
    real ( kind = 4 ) value
    real ( kind = 4 ) x
  
    if ( x <= r4_log_min ) then
      value = 0.0E+00
    else if ( x < r4_log_max ) then
      value = exp ( x )
    else
      value = r4_huge
    end if
  
    r4_exp = value
  
    return
  end
  function r4_exponential_sample ( lambda )
  
  !*****************************************************************************80
  !
  !! R4_EXPONENTIAL_SAMPLE samples the exponential PDF.
  !
  !  Discussion:
  !
  !    Note that the parameter LAMBDA is a multiplier.  In some formulations,
  !    it is used as a divisor instead.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    18 April 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) LAMBDA, the parameter of the PDF.
  !
  !    Output, real ( kind = 4 ) R4_EXPONENTIAL_SAMPLE, a sample of the PDF.
  !
    implicit none
  
    real ( kind = 4 ) lambda
    real ( kind = 4 ) r
    real ( kind = 4 ) r4_exponential_sample
    real ( kind = 4 ) r4_uni_01
  
    r = r4_uni_01 ( )
  
    r4_exponential_sample = - log ( r ) * lambda
  
    return
  end
  function r4vec_covar ( n, x, y )
  
  !*****************************************************************************80
  !
  !! R4VEC_COVAR computes the covariance of two vectors.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    20 April 2013
  !
  !  Author:
  !
  !    John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) X(N), Y(N), the two vectors.
  !
  !    Input, integer ( kind = 4 ) N, the dimension of the two vectors.
  !
  !    Output, real ( kind = 4 ) R4VEC_COVAR, the covariance of the vectors.
  !
    implicit none
  
    integer ( kind = 4 ) n
  
    integer ( kind = 4 ) i
    real ( kind = 4 ) r4vec_covar
    real ( kind = 4 ) value
    real ( kind = 4 ) x(n)
    real ( kind = 4 ) x_average
    real ( kind = 4 ) y(n)
    real ( kind = 4 ) y_average
  
    x_average = sum ( x(1:n) ) / real ( n, kind = 4 )
    y_average = sum ( y(1:n) ) / real ( n, kind = 4 )
   
    value = 0.0E+00
    do i = 1, n
      value = value + ( x(i) - x_average ) * ( y(i) - y_average )
    end do
  
    r4vec_covar = value / real ( n - 1, kind = 4 )
  
    return
  end
  function r8_exponential_sample ( lambda )
  
  !*****************************************************************************80
  !
  !! R8_EXPONENTIAL_SAMPLE samples the exponential PDF.
  !
  !  Discussion:
  !
  !    Note that the parameter LAMBDA is a multiplier.  In some formulations,
  !    it is used as a divisor instead.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    20 April 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, real ( kind = 8 ) LAMBDA, the parameter of the PDF.
  !
  !    Output, real ( kind = 8 ) R8_EXPONENTIAL_SAMPLE, a sample of the PDF.
  !
    implicit none
  
    real ( kind = 8 ) lambda
    real ( kind = 8 ) r
    real ( kind = 8 ) r8_exponential_sample
    real ( kind = 8 ) r8_uni_01
  
    r = r8_uni_01 ( )
  
    r8_exponential_sample = - log ( r ) * lambda
  
    return
  end
  function r8vec_covar ( n, x, y )
  
  !*****************************************************************************80
  !
  !! R8VEC_COVAR computes the covariance of two vectors.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    20 April 2013
  !
  !  Author:
  !
  !    John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 8 ) X(N), Y(N), the two vectors.
  !
  !    Input, integer ( kind = 4 ) N, the dimension of the two vectors.
  !
  !    Output, real ( kind = 8 ) R4VEC_COVAR, the covariance of the vectors.
  !
    implicit none
  
    integer ( kind = 4 ) n
  
    integer ( kind = 4 ) i
    real ( kind = 8 ) r8vec_covar
    real ( kind = 8 ) value
    real ( kind = 8 ) x(n)
    real ( kind = 8 ) x_average
    real ( kind = 8 ) y(n)
    real ( kind = 8 ) y_average
  
    x_average = sum ( x(1:n) ) / real ( n, kind = 8 )
    y_average = sum ( y(1:n) ) / real ( n, kind = 8 )
   
    value = 0.0D+00
    do i = 1, n
      value = value + ( x(i) - x_average ) * ( y(i) - y_average )
    end do
  
    r8vec_covar = value / real ( n - 1, kind = 8 )
  
    return
  end
  function sdot ( n, sx, incx, sy, incy )
  
  !*****************************************************************************80
  !
  !! SDOT forms the dot product of two vectors.
  !
  !  Discussion:
  !
  !    This routine uses single precision real ( kind = 4 ) arithmetic.
  !
  !    This routine uses unrolled loops for increments equal to one.
  !
  !  Modified:
  !
  !    07 July 2007
  !
  !  Author:
  !
  !    Charles Lawson, Richard Hanson, David Kincaid, Fred Krogh
  !
  !  Reference:
  !
  !    Jack Dongarra, Jim Bunch, Cleve Moler, Pete Stewart,
  !    LINPACK User's Guide,
  !    SIAM, 1979,
  !    ISBN13: 978-0-898711-72-1,
  !    LC: QA214.L56.
  !
  !    Charles Lawson, Richard Hanson, David Kincaid, Fred Krogh,
  !    Basic Linear Algebra Subprograms for FORTRAN usage,
  !    ACM Transactions on Mathematical Software,
  !    Volume 5, Number 3, pages 308-323, 1979.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) N, the number of entries in the vectors.
  !
  !    Input, real ( kind = 4 ) X(*), one of the vectors to be multiplied.
  !
  !    Input, integer ( kind = 4 ) INCX, the increment between successive 
  !    entries of X.
  !
  !    Input, real ( kind = 4 ) Y(*), one of the vectors to be multiplied.
  !
  !    Input, integer ( kind = 4 ) INCY, the increment between successive
  !    elements of Y.
  !
  !    Output, real ( kind = 4 ) SDOT, the dot product of X and Y.
  !
    implicit none
  
    integer ( kind = 4 ) i
    integer ( kind = 4 ) incx
    integer ( kind = 4 ) incy
    integer ( kind = 4 ) ix
    integer ( kind = 4 ) iy
    integer ( kind = 4 ) m
    integer ( kind = 4 ) n
    real ( kind = 4 ) sdot
    real ( kind = 4 ) stemp
    real ( kind = 4 ) sx(*)
    real ( kind = 4 ) sy(*)
  
    sdot = 0.0E+00
  
    if ( n <= 0 ) then
      return
    end if
  
    stemp = 0.0E+00
  !
  !  Code for unequal increments or equal increments not equal to 1.
  !
    if ( incx /= 1 .or. incy /= 1 ) then
  
      if ( incx < 0 ) then
        ix = ( - n + 1 ) * incx + 1
      else
        ix = 1
      end if
  
      if ( incy < 0 ) then
        iy = ( - n + 1 ) * incy + 1
      else
        iy = 1
      end if
  
      do i = 1, n
        stemp = stemp + sx(ix) * sy(iy)
        ix = ix + incx
        iy = iy + incy
      end do
  !
  !  Code for both increments equal to 1.
  !
    else
  
      m = mod ( n, 5 )
  
      do i = 1, m
        stemp = stemp + sx(i) * sy(i)
      end do
  
      do i = m + 1, n, 5
        stemp = stemp &
         + sx(i)     * sy(i) &
         + sx(i + 1) * sy(i + 1) &
         + sx(i + 2) * sy(i + 2) &
         + sx(i + 3) * sy(i + 3) &
         + sx(i + 4) * sy(i + 4)
      end do
  
    end if
  
    sdot = stemp
  
    return
  end
  subroutine setcov ( p, var, corr, covar )
  
  !*****************************************************************************80
  !
  !! SETCOV sets a covariance matrix from variance and common correlation.
  !
  !  Discussion:
  !
  !    This procedure sets the covariance matrix from the variance and
  !    common correlation.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) P, the number of variables.
  !
  !    Input, real ( kind = 4 ) VAR(P), the variances.
  !
  !    Input, real ( kind = 4 ) CORR, the common correlaton.
  !
  !    Output, real ( kind = 4 ) COVAR(P,P), the covariance matrix.
  !
    implicit none
  
    integer ( kind = 4 ) p
  
    real ( kind = 4 ) corr
    real ( kind = 4 ) covar(p,p)
    integer ( kind = 4 ) i
    integer ( kind = 4 ) j
    real ( kind = 4 ) var(p)
  
    do i = 1, p
      do  j = 1, p
        if ( i == j ) then
          covar(i,j) = var(i)
        else
          covar(i,j) = corr * sqrt ( var(i) * var(j) )
        end if
      end do
    end do
  
    return
  end
  subroutine setgmn ( meanv, covm, p, parm )
  
  !*****************************************************************************80
  !
  !! SETGMN sets data for the generation of multivariate normal deviates.
  !
  !  Discussion:
  !
  !    This procedure places P, MEANV, and the Cholesky factorization of
  !    COVM in GENMN.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) MEANV(P), the means of the multivariate 
  !    normal distribution.
  !
  !    Input/output, real ( kind = 4 ) COVM(P,P).  On input, the covariance
  !    matrix of the multivariate distribution.  On output, the information 
  !    in COVM has been overwritten.
  !
  !    Input, integer ( kind = 4 ) P, the number of dimensions.
  !
  !    Output, real ( kind = 4 ) PARM(P*(P+3)/2+1), parameters needed to generate
  !    multivariate normal deviates.
  !
    implicit none
  
    integer ( kind = 4 ) p
  
    real ( kind = 4 ) covm(p,p)
    integer ( kind = 4 ) i
    integer ( kind = 4 ) icount
    integer ( kind = 4 ) info
    integer ( kind = 4 ) j
    real ( kind = 4 ) meanv(p)
    real ( kind = 4 ) parm(p*(p+3)/2+1)
  
    if ( p <= 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'SETGMN - Fatal error!'
      write ( *, '(a)' ) '  P was not positive.'
      stop 1
    end if 
  !
  !  Store P.
  !
    parm(1) = p
  !
  !  Store MEANV.
  !
    do i = 2, p + 1
      parm(i) = meanv(i-1)
    end do
  !
  !  Compute the Cholesky decomposition.
  !
    call spofa ( covm, p, p, info )
  
    if ( info /= 0) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'SETGMN - Fatal error!'
      write ( *, '(a)' ) '  SPOFA finds COVM not positive definite.'
      stop 1
    end if
  !
  !  Store the upper half of the Cholesky factor.
  !
    icount = p + 1
  
    do i = 1, p
      do j = i, p
        icount = icount + 1
        parm(icount) = covm(i,j)
      end do
    end do
  
    return
  end
  function sexpo ( )
  
  !*****************************************************************************80
  !
  !! SEXPO samples the standard exponential distribution.
  !
  !  Discussion:
  !
  !   This procedure corresponds to algorithm SA in the reference.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Joachim Ahrens, Ulrich Dieter,
  !    Computer Methods for Sampling From the
  !    Exponential and Normal Distributions,
  !    Communications of the ACM,
  !    Volume 15, Number 10, October 1972, pages 873-882.
  !
  !  Parameters:
  !
  !    Output, real ( kind = 4 ) SEXPO, a random deviate from the standard
  !    exponential distribution.
  !
    implicit none
  
    real ( kind = 4 ) a
    integer ( kind = 4 ) i
    real ( kind = 4 ) q(8)
    real ( kind = 4 ) r4_uni_01
    real ( kind = 4 ) sexpo
    real ( kind = 4 ) u
    real ( kind = 4 ) umin
    real ( kind = 4 ) ustar
  
    save q
  
    data q / &
         0.6931472E+00, &
         0.9333737E+00, &
         0.9888778E+00, &
         0.9984959E+00, &
         0.9998293E+00, &
         0.9999833E+00, &
         0.9999986E+00, &
         0.9999999E+00 /
  
    a = 0.0E+00
    u = r4_uni_01 ( )
  
    do
  
      u = u + u
  
      if ( 1.0E+00 < u ) then
        exit
      end if
  
      a = a + q(1)
  
    end do
  
    u = u - 1.0E+00
  
    if ( u <= q(1) ) then
      sexpo = a + u
      return
    end if
  
    i = 1
    ustar = r4_uni_01 ( )
    umin = ustar
  
    do
  
      ustar = r4_uni_01 ( )
      umin = min ( umin, ustar )
      i = i + 1
  
      if ( u <= q(i) ) then
        exit
      end if
  
    end do
  
    sexpo = a + umin * q(1)
  
    return
  end
  function sgamma ( a )
  
  !*****************************************************************************80
  !
  !! SGAMMA samples the standard Gamma distribution.
  !
  !  Discussion:
  !
  !    This procedure corresponds to algorithm GD in the reference.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    01 April 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Joachim Ahrens, Ulrich Dieter,
  !    Generating Gamma Variates by a Modified Rejection Technique,
  !    Communications of the ACM,
  !    Volume 25, Number 1, January 1982, pages 47-54.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) A, the parameter of the standard gamma
  !    distribution.  0.0 < A < 1.0.
  !
  !    Output, real ( kind = 4 ) SGAMMA, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) a
    real ( kind = 4 ), parameter :: a1 =  0.3333333E+00
    real ( kind = 4 ), parameter :: a2 = -0.2500030E+00
    real ( kind = 4 ), parameter :: a3 =  0.2000062E+00
    real ( kind = 4 ), parameter :: a4 = -0.1662921E+00
    real ( kind = 4 ), parameter :: a5 =  0.1423657E+00
    real ( kind = 4 ), parameter :: a6 = -0.1367177E+00
    real ( kind = 4 ), parameter :: a7 =  0.1233795E+00
    real ( kind = 4 ) b
    real ( kind = 4 ) c
    real ( kind = 4 ) d
    real ( kind = 4 ) e
    real ( kind = 4 ), parameter :: e1 = 1.0E+00
    real ( kind = 4 ), parameter :: e2 = 0.4999897E+00
    real ( kind = 4 ), parameter :: e3 = 0.1668290E+00
    real ( kind = 4 ), parameter :: e4 = 0.0407753E+00
    real ( kind = 4 ), parameter :: e5 = 0.0102930E+00
    real ( kind = 4 ) p
    real ( kind = 4 ) q
    real ( kind = 4 ) q0
    real ( kind = 4 ), parameter :: q1 =  0.04166669E+00
    real ( kind = 4 ), parameter :: q2 =  0.02083148E+00
    real ( kind = 4 ), parameter :: q3 =  0.00801191E+00
    real ( kind = 4 ), parameter :: q4 =  0.00144121E+00
    real ( kind = 4 ), parameter :: q5 = -0.00007388E+00
    real ( kind = 4 ), parameter :: q6 =  0.00024511E+00
    real ( kind = 4 ), parameter :: q7 =  0.00024240E+00
    real ( kind = 4 ) r
    real ( kind = 4 ) r4_uni_01
    real ( kind = 4 ) s
    real ( kind = 4 ) s2
    real ( kind = 4 ) sexpo
    real ( kind = 4 ) si
    real ( kind = 4 ) sgamma
    real ( kind = 4 ) snorm
    real ( kind = 4 ), parameter :: sqrt32 = 5.656854E+00
    real ( kind = 4 ) t
    real ( kind = 4 ) u
    real ( kind = 4 ) v
    real ( kind = 4 ) w
    real ( kind = 4 ) x
  
    if ( 1.0E+00 <= a ) then
  
      s2 = a - 0.5E+00
      s = sqrt ( s2 )
      d = sqrt32 - 12.0E+00 * s
  !
  !  Immediate acceptance.
  !
      t = snorm ( )
      x = s + 0.5E+00 * t
      sgamma = x * x
  
      if ( 0.0E+00 <= t ) then
        return
      end if
  !
  !  Squeeze acceptance.
  !
      u = r4_uni_01 ( )
      if ( d * u <= t * t * t ) then
        return
      end if
  
      r = 1.0E+00 / a
      q0 = (((((( q7 &
        * r + q6 ) &
        * r + q5 ) &
        * r + q4 ) &
        * r + q3 ) &
        * r + q2 ) &
        * r + q1 ) &
        * r
  !
  !  Approximation depending on size of parameter A.
  !
      if ( 13.022E+00 < a ) then
        b = 1.77E+00
        si = 0.75E+00
        c = 0.1515E+00 / s
      else if ( 3.686E+00 < a ) then
        b = 1.654E+00 + 0.0076E+00 * s2
        si = 1.68E+00 / s + 0.275E+00
        c = 0.062E+00 / s + 0.024E+00
      else
        b = 0.463E+00 + s + 0.178E+00 * s2
        si = 1.235E+00
        c = 0.195E+00 / s - 0.079E+00 + 0.16E+00 * s
      end if
  !
  !  Quotient test.
  !
      if ( 0.0E+00 < x ) then
  
        v = 0.5E+00 * t / s
  
        if ( 0.25E+00 < abs ( v ) ) then
          q = q0 - s * t + 0.25E+00 * t * t + 2.0E+00 * s2 * log ( 1.0E+00 + v )
        else
          q = q0 + 0.5E+00 * t * t * (((((( a7 &
            * v + a6 ) &
            * v + a5 ) &
            * v + a4 ) &
            * v + a3 ) &
            * v + a2 ) &
            * v + a1 ) &
            * v
        end if
  
        if ( log ( 1.0E+00 - u ) <= q ) then
          return
        end if
  
      end if
  
      do
  
        e = sexpo ( )
        u = 2.0E+00 * r4_uni_01 ( ) - 1.0E+00
   
        if ( 0.0E+00 <= u ) then
          t = b + abs ( si * e )
        else
          t = b - abs ( si * e )
        end if
  !
  !  Possible rejection.
  !
        if ( t < -0.7187449E+00 ) then
          cycle
        end if
  !
  !  Calculate V and quotient Q.
  !
        v = 0.5E+00 * t / s
  
        if ( 0.25E+00 < abs ( v ) ) then
          q = q0 - s * t + 0.25E+00 * t * t + 2.0E+00 * s2 * log ( 1.0E+00 + v )
        else
          q = q0 + 0.5E+00 * t * t * (((((( a7 &
            * v + a6 ) &
            * v + a5 ) &
            * v + a4 ) &
            * v + a3 ) &
            * v + a2 ) &
            * v + a1 ) &
            *  v
        end if
  !
  !  Hat acceptance.
  !
        if ( q <= 0.0E+00 ) then
          cycle
        end if
  
        if ( 0.5E+00 < q ) then
          w = exp ( q ) - 1.0E+00
        else
          w = (((( e5 * q + e4 ) * q + e3 ) * q + e2 ) * q + e1 ) * q
        end if
  !
  !  May have to sample again.
  !
        if ( c * abs ( u ) <= w * exp ( e - 0.5E+00 * t * t ) ) then
          exit
        end if
  
      end do
  
      x = s + 0.5E+00 * t
      sgamma = x * x
  
      return
  !
  !  Method for A < 1.
  !
    else
  
      b = 1.0E+00 + 0.3678794E+00 * a
  
      do
  
        p = b * r4_uni_01 ( )
  
        if ( p < 1.0E+00 ) then
  
          sgamma = exp ( log ( p ) / a )
  
          if ( sgamma <= sexpo ( ) ) then
            return
          end if
  
          cycle
  
        end if
  
        sgamma = - log ( ( b - p ) / a )
  
        if ( ( 1.0E+00 - a ) * log ( sgamma ) <= sexpo ( ) ) then
          exit
        end if
  
      end do
  
    end if
  
    return
  end
  function snorm ( )
  
  !*****************************************************************************80
  !
  !! SNORM samples the standard normal distribution.
  !
  !  Discussion:
  !
  !    This procedure corresponds to algorithm FL, with M = 5, in the reference.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Joachim Ahrens, Ulrich Dieter,
  !    Extensions of Forsythe's Method for Random
  !    Sampling from the Normal Distribution,
  !    Mathematics of Computation,
  !    Volume 27, Number 124, October 1973, page 927-937.
  !
  !  Parameters:
  !
  !    Output, real ( kind = 4 ) SNORM, a random deviate from the distribution.
  !
    implicit none
  
    real ( kind = 4 ) a(32)
    real ( kind = 4 ) aa
    real ( kind = 4 ) d(31)
    real ( kind = 4 ) h(31)
    integer ( kind = 4 ) i
    real ( kind = 4 ) r4_uni_01
    real ( kind = 4 ) s
    real ( kind = 4 ) snorm
    real ( kind = 4 ) t(31)
    real ( kind = 4 ) tt
    real ( kind = 4 ) u
    real ( kind = 4 ) ustar
    real ( kind = 4 ) w
    real ( kind = 4 ) y
  
    save a
    save d
    save h
    save t
  
    data a / &
          0.0000000E+00, 0.3917609E-01, 0.7841241E-01, 0.1177699E+00, &
          0.1573107E+00, 0.1970991E+00, 0.2372021E+00, 0.2776904E+00, &
          0.3186394E+00, 0.3601299E+00, 0.4022501E+00, 0.4450965E+00, &
          0.4887764E+00, 0.5334097E+00, 0.5791322E+00, 0.6260990E+00, &
          0.6744898E+00, 0.7245144E+00, 0.7764218E+00, 0.8305109E+00, &
          0.8871466E+00, 0.9467818E+00, 1.009990E+00,  1.077516E+00, &
          1.150349E+00,  1.229859E+00,  1.318011E+00,  1.417797E+00, &
          1.534121E+00,  1.675940E+00,  1.862732E+00,  2.153875E+00 /
  
    data d / &
          0.0000000E+00, 0.0000000E+00, 0.0000000E+00, 0.0000000E+00, &
          0.0000000E+00, 0.2636843E+00, 0.2425085E+00, 0.2255674E+00, &
          0.2116342E+00, 0.1999243E+00, 0.1899108E+00, 0.1812252E+00, &
          0.1736014E+00, 0.1668419E+00, 0.1607967E+00, 0.1553497E+00, &
          0.1504094E+00, 0.1459026E+00, 0.1417700E+00, 0.1379632E+00, &
          0.1344418E+00, 0.1311722E+00, 0.1281260E+00, 0.1252791E+00, &
          0.1226109E+00, 0.1201036E+00, 0.1177417E+00, 0.1155119E+00, &
          0.1134023E+00, 0.1114027E+00, 0.1095039E+00 /
  
    data h / &
          0.3920617E-01, 0.3932705E-01, 0.3950999E-01, 0.3975703E-01, &
          0.4007093E-01, 0.4045533E-01, 0.4091481E-01, 0.4145507E-01, &
          0.4208311E-01, 0.4280748E-01, 0.4363863E-01, 0.4458932E-01, &
          0.4567523E-01, 0.4691571E-01, 0.4833487E-01, 0.4996298E-01, &
          0.5183859E-01, 0.5401138E-01, 0.5654656E-01, 0.5953130E-01, &
          0.6308489E-01, 0.6737503E-01, 0.7264544E-01, 0.7926471E-01, &
          0.8781922E-01, 0.9930398E-01, 0.1155599E+00, 0.1404344E+00, &
          0.1836142E+00, 0.2790016E+00, 0.7010474E+00 /
  
    data t / &
          0.7673828E-03, 0.2306870E-02, 0.3860618E-02, 0.5438454E-02, &
          0.7050699E-02, 0.8708396E-02, 0.1042357E-01, 0.1220953E-01, &
          0.1408125E-01, 0.1605579E-01, 0.1815290E-01, 0.2039573E-01, &
          0.2281177E-01, 0.2543407E-01, 0.2830296E-01, 0.3146822E-01, &
          0.3499233E-01, 0.3895483E-01, 0.4345878E-01, 0.4864035E-01, &
          0.5468334E-01, 0.6184222E-01, 0.7047983E-01, 0.8113195E-01, &
          0.9462444E-01, 0.1123001E+00, 0.1364980E+00, 0.1716886E+00, &
          0.2276241E+00, 0.3304980E+00, 0.5847031E+00 /
  
    u = r4_uni_01 ( )
    if ( u <= 0.5E+00 ) then
      s = 0.0E+00
    else
      s = 1.0E+00
    end if
    u = 2.0E+00 * u - s
    u = 32.0E+00 * u
    i = int ( u )
    if ( i == 32 ) then
      i = 31
    end if
  !
  !  Center
  !
    if ( i /= 0 ) then
  
      ustar = u - real ( i )
      aa = a(i)
  
      do
  
        if ( t(i) < ustar ) then
  
          w = ( ustar - t(i) ) * h(i)
  
          y = aa + w
  
          if ( s /= 1.0E+00 ) then
            snorm = y
          else
            snorm = -y
          end if
  
          return
  
        end if
  
        u = r4_uni_01 ( )
        w = u * ( a(i+1) - aa )
        tt = ( 0.5E+00 * w + aa ) * w
  
        do
  
          if ( tt < ustar ) then
            y = aa + w
            if ( s /= 1.0E+00 ) then
              snorm = y
            else
              snorm = -y
            end if
            return
          end if
  
          u = r4_uni_01 ( )
  
          if ( ustar < u ) then
            exit
          end if
  
          tt = u
          ustar = r4_uni_01 ( )
  
        end do
  
        ustar = r4_uni_01 ( )
  
      end do
  !
  !  Tail
  !
    else
  
      i = 6
      aa = a(32)
  
      do
  
        u = u + u
  
        if ( 1.0E+00 <= u ) then
          exit
        end if
  
        aa = aa + d(i)
        i = i + 1
  
      end do
  
      u = u - 1.0E+00
      w = u * d(i)
      tt = ( 0.5E+00 * w + aa ) * w
  
      do
  
        ustar = r4_uni_01 ( )
  
        if ( tt < ustar ) then
          y = aa + w
          if ( s /= 1.0E+00 ) then
            snorm = y
          else
            snorm = -y
          end if
          return
        end if
  
        u = r4_uni_01 ( )
  
        if ( u <= ustar ) then
          tt = u
        else
          u = r4_uni_01 ( )
          w = u * d(i)
          tt = ( 0.5E+00 * w + aa ) * w
        end if
  
      end do
  
    end if
  
  end
  subroutine spofa ( a, lda, n, info )
  
  !*****************************************************************************80
  !
  !! SPOFA factors a real symmetric positive definite matrix.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    20 March 2013
  !
  !  Author:
  !
  !    Cleve Moler
  !
  !  Parameters:
  !
  !    Input/output, real ( kind = 4 ) A(LDA,N).  On input, the symmetric matrix
  !    to be factored.  Only the diagonal and upper triangle are accessed.  
  !    On output, the strict lower triangle has not been changed.  The diagonal
  !    and upper triangle contain an upper triangular matrix R such that 
  !    A = R' * R.  If INFO is nonzero, the factorization was not completed.
  !
  !    Input, integer ( kind = 4 ) LDA, the leading dimension of the array A.
  !    N <= LDA.
  !
  !    Input, integer ( kind = 4 ) N, the order of the matrix.
  !
  !    Output, integer ( kind = 4 ) INFO, error flag.
  !    0, no error was detected.
  !    K, the leading minor of order K is not positive definite.
  !
    implicit none
  
    integer ( kind = 4 ) lda
    integer ( kind = 4 ) n
  
    real ( kind = 4 ) a(lda,n)
    integer ( kind = 4 ) info
    integer ( kind = 4 ) j
    integer ( kind = 4 ) jm1
    integer ( kind = 4 ) k
    real ( kind = 4 ) s
    real ( kind = 4 ) sdot
    real ( kind = 4 ) t
  
    info = 0
  
    do j = 1, n
      info = j
      s = 0.0E+00
      jm1 = j - 1
      do k = 1, jm1
        t = a(k,j) - sdot ( k-1, a(1,k), 1, a(1,j), 1 )
        t = t / a(k,k)
        a(k,j) = t
        s = s + t * t
      end do
      s = a(j,j) - s
      if ( s <= 0.0E+00 ) then
        info = j
        return
      end if
      a(j,j) = sqrt ( s )
    end do
  
    return
  end
  subroutine stats ( x, n, av, var, xmin, xmax )
  
  !*****************************************************************************80
  !
  !! STATS computes statistics for a given array.
  !
  !  Discussion:
  !
  !    This procedure computes the average and variance of an array.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, real ( kind = 4 ) X(N), the array to be analyzed.
  !
  !    Input, integer ( kind = 4 ) N, the dimension of the array.
  !
  !    Output, real ( kind = 4 ) AV, the average value.
  !
  !    Output, real ( kind = 4 ) VAR, the variance.
  !
  !    Output, real ( kind = 4 ) XMIN, XMAX, the minimum and maximum entries.
  !
    implicit none
  
    integer ( kind = 4 ) n
  
    real ( kind = 4 ) av
    integer ( kind = 4 ) i
    real ( kind = 4 ) total
    real ( kind = 4 ) var
    real ( kind = 4 ) x(n)
    real ( kind = 4 ) xmax
    real ( kind = 4 ) xmin
  
    xmin = x(1)
    xmax = x(1)
    total = 0.0E+00
    do i = 1, n
      total = total + x(i)
      xmin = min ( xmin, x(i) )
      xmax = max ( xmax, x(i) )
    end do
  
    av = total / real ( n )
  
    total = 0.0E+00
    do i = 1, n
      total = total + ( x(i) - av ) ** 2
    end do
    var = total / real ( n - 1 )
  
    return
  end
  subroutine trstat ( pdf, parin, av, var )
  
  !*****************************************************************************80
  !
  !! TRSTAT returns the mean and variance for distributions.
  !
  !  Discussion:
  !
  !    This procedure returns the mean and variance for a number of statistical
  !    distributions as a function of their parameters.
  !
  !    The input vector PARIN is used to pass in the parameters necessary
  !    to specify the distribution.  The number of these parameters varies
  !    per distribution, and it is necessary to specify an ordering for the
  !    parameters used to a given distribution.  The ordering chosen here
  !    is as follows:
  !
  !    bet
  !      PARIN(1) is A
  !      PARIN(2) is B
  !    bin
  !      PARIN(1) is Number of trials
  !      PARIN(2) is Prob Event at Each Trial
  !    chi
  !      PARIN(1) = df
  !    exp
  !      PARIN(1) = mu
  !    f
  !      PARIN(1) is df numerator
  !      PARIN(2) is df denominator
  !    gam
  !      PARIN(1) is A
  !      PARIN(2) is R
  !    nbn
  !      PARIN(1) is N
  !      PARIN(2) is P
  !    nch
  !      PARIN(1) is df
  !      PARIN(2) is noncentrality parameter
  !    nf
  !      PARIN(1) is df numerator
  !      PARIN(2) is df denominator
  !      PARIN(3) is noncentrality parameter
  !    nor
  !      PARIN(1) is mean
  !      PARIN(2) is standard deviation
  !    poi
  !      PARIN(1) is Mean
  !    unf
  !      PARIN(1) is LOW bound
  !      PARIN(2) is HIGH bound
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    01 April 2013
  !
  !  Author:
  !
  !    Original FORTRAN77 version by Barry Brown, James Lovato.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Parameters:
  !
  !    Input, character * ( 4 ) PDF, indicates the distribution:
  !    'bet'  beta distribution
  !    'bin'  binomial
  !    'chi'  chisquare
  !    'exp'  exponential
  !    'f'    F (variance ratio)
  !    'gam'  gamma
  !    'nbn'  negative binomial
  !    'nch'  noncentral chisquare
  !    'nf'   noncentral f
  !    'nor'  normal
  !    'poi'  Poisson
  !    'unf'  uniform
  !
  !    Input, real ( kind = 4 ) PARIN(*), the parameters of the distribution.
  !
  !    Output, real ( kind = 4 ) AV, the mean of the specified distribution.
  !
  !    Output, real ( kind = 4 ) VAR, the variance of the specified distribuion.
  !
    implicit none
  
    real ( kind = 4 ) a
    real ( kind = 4 ) av
    real ( kind = 4 ) b
    integer ( kind = 4 ) n
    real ( kind = 4 ) p
    real ( kind = 4 ) parin(*)
    character ( len=* ) pdf
    real ( kind = 4 ) r
    real ( kind = 4 ) var
    real ( kind = 4 ) width
  
    if ( pdf == 'bet' ) then
  
      av = parin(1) / ( parin(1) + parin(2) )
      var = ( av * parin(2) ) / ( ( parin(1) + parin(2) ) * &
        ( parin(1) + parin(2) + 1.0E+00 ) )
  
    else if ( pdf == 'bin' ) then
  
      n = int ( parin(1) )
      p = parin(2)
      av = real ( n ) * p
      var = real ( n ) * p * ( 1.0E+00 - p )
  
    else if ( pdf == 'chi' ) then
  
      av = parin(1)
      var = 2.0E+00 * parin(1)
  
    else if ( pdf == 'exp' ) then
  
      av = parin(1)
      var = av ** 2
  
    else if ( pdf == 'f' ) then
  
      if ( parin(2) <= 2.0001E+00 ) then
        av = -1.0E+00
      else
        av = parin(2) / ( parin(2) - 2.0E+00 )
      end if
  
      if ( parin(2) <= 4.0001E+00 ) then
        var = -1.0E+00
      else
        var = ( 2.0E+00 * parin(2) ** 2 * ( parin(1) + parin(2) - 2.0E+00 ) ) / &
          ( parin(1) * ( parin(2) - 2.0E+00 ) ** 2 * ( parin(2) - 4.0E+00 ) )
      end if
  
    else if ( pdf == 'gam' ) then
  
      a = parin(1)
      r = parin(2)
      av = r / a
      var = r / a ** 2
  
    else if ( pdf == 'nbn' ) then
  
      n = int ( parin(1) )
      p = parin(2)
      av = n * ( 1.0E+00 - p ) / p
      var = n * ( 1.0E+00 - p ) / p ** 2
  
    else if ( pdf == 'nch' ) then
  
      a = parin(1) + parin(2)
      b = parin(2) / a
      av = a
      var = 2.0E+00 * a * ( 1.0E+00 + b )
  
    else if ( pdf == 'nf' ) then
  
      if ( parin(2) <= 2.0001E+00 ) then
        av = -1.0E+00
      else
        av = ( parin(2) * ( parin(1) + parin(3) ) ) &
          / ( ( parin(2) - 2.0E+00 ) * parin(1) )
      end if
  
      if ( parin(2) <= 4.0001E+00 ) then
        var = -1.0E+00
      else
        a = ( parin(1) + parin(3) ) ** 2 &
          + ( parin(1) + 2.0E+00 * parin(3) ) * ( parin(2) - 2.0E+00 )
        b = ( parin(2) - 2.0E+00 ) ** 2 * ( parin(2) - 4.0E+00 )
        var = 2.0E+00 * ( parin(2) / parin(1) ) ** 2 * ( a / b )
      end if
  
    else if ( pdf == 'nor' ) then
  
      av = parin(1)
      var = parin(2) ** 2
  
    else if ( pdf == 'poi' ) then
  
      av = parin(1)
      var = parin(1)
  
    else if ( pdf == 'unf' ) then
  
      width = parin(2) - parin(1)
      av = parin(1) + width / 2.0E+00
      var = width ** 2 / 12.0E+00
  
    else
  
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'TRSTAT - Fatal error!'
      write ( *, '(a)' ) '  Illegal input value for PDF.'
      stop 1
  
    end if
  
    return
  end
  
  subroutine advance_state ( k )
  
  !*****************************************************************************80
  !
  !! ADVANCE_STATE advances the state of the current generator.
  !
  !  Discussion:
  !
  !    This procedure advances the state of the current generator by 2^K 
  !    values and resets the initial seed to that value.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    30 March 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) K, indicates that the generator is to be 
  !    advanced by 2^K values.
  !    0 <= K.
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: a1 = 40014
    integer ( kind = 4 ), parameter :: a2 = 40692
    integer ( kind = 4 ) b1
    integer ( kind = 4 ) b2
    integer ( kind = 4 ) cg1
    integer ( kind = 4 ) cg2
    integer ( kind = 4 ) cgn_get
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    logical initialized_get
    integer ( kind = 4 ) k
    integer ( kind = 4 ), parameter :: m1 = 2147483563
    integer ( kind = 4 ), parameter :: m2 = 2147483399
    integer ( kind = 4 ) multmod
  
    if ( k < 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'ADVANCE_STATE - Fatal error!'
      write ( *, '(a)' ) '  Input exponent K is out of bounds.'
      stop 1
    end if
  !
  !  Check whether the package must be initialized.
  !
    if ( .not. initialized_get ( ) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'ADVANCE_STATE - Note:'
      write ( *, '(a)' ) '  Initializing RNGLIB package.'
      call initialize_gen ( )
    end if
  !
  !  Get the current generator index.
  !
    g = cgn_get ( )
  
    b1 = a1
    b2 = a2
  
    do i = 1, k
      b1 = multmod ( b1, b1, m1 )
      b2 = multmod ( b2, b2, m2 )
    end do
  
    call cg_get ( g, cg1, cg2 )
    cg1 = multmod ( b1, cg1, m1 )
    cg2 = multmod ( b2, cg2, m2 )
    call cg_set ( g, cg1, cg2 )
  
    return
  end
  function antithetic_get ( )
  
  !*****************************************************************************80
  !
  !! ANTITHETIC_GET queries the antithetic value for a given generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Output, logical ANTITHETIC_GET, is TRUE if generator G is antithetic.
  !
    implicit none
  
    logical antithetic_get
    integer ( kind = 4 ) i
    logical value
  
    i = -1
    call antithetic_memory ( i, value )
  
    antithetic_get = value
  
    return
  end
  subroutine antithetic_memory ( i, value )
  
  !*****************************************************************************80
  !
  !! ANTITHETIC_MEMORY stores the antithetic value for all generators.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) I, the desired action.
  !    -1, get a value.
  !    0, initialize all values.
  !    1, set a value.
  !
  !    Input/output, logical VALUE.  For I = -1, VALUE is an output
  !    quantity, for I = +1, an input quantity.
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: g_max = 32
  
    logical a_save(g_max)
    integer ( kind = 4 ) cgn_get
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    logical value
  
    save a_save
  
    data a_save / 32 * .false. /
  
    if ( i < 0 ) then
      g = cgn_get ( )
      value = a_save(g)
    else if ( i == 0 ) then
      a_save(1:g_max) = .false.
    else if ( 0 < i ) then
      g = cgn_get ( )
      a_save(g) = value
    end if
  
    return
  end
  subroutine antithetic_set ( value )
  
  !*****************************************************************************80
  !
  !! ANTITHETIC_SET sets the antithetic value for a given generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, logical VALUE, is TRUE if generator G is to be antithetic.
  !
    implicit none
  
    integer ( kind = 4 ) i
    logical value
  
    i = +1
    call antithetic_memory ( i, value )
  
    return
  end
  subroutine cg_get ( g, cg1, cg2 )
  
  !*****************************************************************************80
  !
  !! CG_GET queries the CG values for a given generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    26 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) G, the index of the generator.
  !    1 <= G <= 32.
  !
  !    Output, integer ( kind = 4 ) CG1, CG2, the CG values for generator G.
  !
    implicit none
  
    integer ( kind = 4 ) cg1
    integer ( kind = 4 ) cg2
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
  
    i = -1
    call cg_memory ( i, g, cg1, cg2 )
  
    return
  end
  subroutine cg_memory ( i, g, cg1, cg2 )
  
  !*****************************************************************************80
  !
  !! CG_MEMORY stores the CG values for all generators.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    30 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) I, the desired action.
  !    -1, get a value.
  !    0, initialize all values.
  !    1, set a value.
  !
  !    Input, integer ( kind = 4 ) G, for I = -1 or +1, the index of 
  !    the generator, with 1 <= G <= 32.
  !
  !    Input/output, integer ( kind = 4 ) CG1, CG2.  For I = -1, 
  !    these are output, for I = +1, these are input, for I = 0,
  !    these arguments are ignored.  When used, the arguments are
  !    old or new values of the CG parameter for generator G.
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: g_max = 32
  
    integer ( kind = 4 ) cg1
    integer ( kind = 4 ) cg1_save(g_max)
    integer ( kind = 4 ) cg2
    integer ( kind = 4 ) cg2_save(g_max)
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
  
    save cg1_save
    save cg2_save
  
    data cg1_save / 32 * 0 /
    data cg2_save / 32 * 0 /
  
    if ( g < 1 .or. g_max < g ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'CG_MEMORY - Fatal error!'
      write ( *, '(a)' ) '  Input generator index G is out of bounds.'
      stop 1
    end if
  
    if ( i < 0 ) then
      cg1 = cg1_save(g)
      cg2 = cg2_save(g)
    else if ( i == 0 ) then
      cg1_save(1:g_max) = 0
      cg2_save(1:g_max) = 0
    else if ( 0 < i ) then
      cg1_save(g) = cg1
      cg2_save(g) = cg2
    end if
  
    return
  end
  subroutine cg_set ( g, cg1, cg2 )
  
  !*****************************************************************************80
  !
  !! CG_SET sets the CG values for a given generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    26 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) G, the index of the generator.
  !    1 <= G <= 32.
  !
  !    Input, integer ( kind = 4 ) CG1, CG2, the CG values for generator G.
  !
    implicit none
  
    integer ( kind = 4 ) cg1
    integer ( kind = 4 ) cg2
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
  
    i = +1
    call cg_memory ( i, g, cg1, cg2 )
  
    return
  end
  function cgn_get ( )
  
  !*****************************************************************************80
  !
  !! CGN_GET gets the current generator index.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    30 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Output, integer ( kind = 4 ) CGN_GET, the current generator index.
  !    1 <= CGN_GET <= 32.
  !
    implicit none
  
    integer ( kind = 4 ) cgn_get
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
  
    i = -1
    call cgn_memory ( i, g )
  
    cgn_get = g
  
    return
  end
  subroutine cgn_memory ( i, g )
  
  !*****************************************************************************80
  !
  !! CGN_MEMORY stores the current generator index.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    30 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) I, the desired action.
  !    -1, get the value.
  !    0, initialize the value.
  !    1, set the value.
  !
  !    Input/output, integer ( kind = 4 ) G.  For I = -1 or 0,
  !    this is output, for I = +1, this is input.
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: g_max = 32
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ) g_save
    integer ( kind = 4 ) i
  
    save g_save
  
    data g_save / 1 /
  
    if ( i < 0 ) then
  
      g = g_save
  
    else if ( i == 0 ) then
  
      g_save = 1
      g = g_save
  
    else if ( 0 < i ) then
  
      if ( g < 1 .or. g_max < g ) then
        write ( *, '(a)' ) ' '
        write ( *, '(a)' ) 'CGN_MEMORY - Fatal error!'
        write ( *, '(a)' ) '  Generator index G is out of bounds.'
        stop 1
      end if
  
      g_save = g
  
    end if
  
    return
  end
  subroutine cgn_set ( g )
  
  !*****************************************************************************80
  !
  !! CGN_SET sets the current generator index.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    30 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) G, the index of the generator.
  !    1 <= G <= 32.
  !
    implicit none
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
  
    i = +1
    call cgn_memory ( i, g )
  
    return
  end
  subroutine get_state ( cg1, cg2 )
  
  !*****************************************************************************80
  !
  !! GET_STATE returns the state of the current generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    30 March 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Output, integer ( kind = 4 ) CG1, CG2, the CG values for the
  !    current generator.
  !
    implicit none
  
    integer ( kind = 4 ) cg1
    integer ( kind = 4 ) cg2
    integer ( kind = 4 ) cgn_get
    integer ( kind = 4 ) g
    logical initialized_get
  !
  !  Check whether the package must be initialized.
  !
    if ( .not. initialized_get ( ) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'GET_STATE - Note:'
      write ( *, '(a)' ) '  Initializing RNGLIB package.'
      call initialize_gen ( )
    end if
  !
  !  Get the current generator index.
  !
    g = cgn_get ( )
  !
  !  Retrieve the seed values for this generator.
  !
    call cg_get ( g, cg1, cg2 )
  
    return
  end
  function i4_uni ( )
  
  !*****************************************************************************80
  !
  !! I4_UNI generates a random positive integer.
  !
  !  Discussion:
  !
  !    This procedure returns a random integer following a uniform distribution 
  !    over (1, 2147483562) using the current generator.
  !
  !    The original name of this function was "random()", but this conflicts
  !    with a standard library function name in C.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    05 August 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Output, integer ( kind = 4 ) I4_UNI, the random integer.
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: a1 = 40014
    integer ( kind = 4 ), parameter :: a2 = 40692
    logical antithetic_get
    integer ( kind = 4 ) cg1
    integer ( kind = 4 ) cg2
    integer ( kind = 4 ) cgn_get
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i4_uni
    logical initialized_get
    integer ( kind = 4 ) k
    integer ( kind = 4 ), parameter :: m1 = 2147483563
    integer ( kind = 4 ), parameter :: m2 = 2147483399
    logical value
    integer ( kind = 4 ) z
  !
  !  Check whether the package must be initialized.
  !
    if ( .not. initialized_get ( ) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'I4_UNI - Note:'
      write ( *, '(a)' ) '  Initializing RNGLIB package.'
      call initialize_gen ( )
    end if
  !
  !  Get the current generator index.
  !
    g = cgn_get ( )
  !
  !  Retrieve the seeds for the current generator.
  !
    call cg_get ( g, cg1, cg2 )
  !
  !  Update the seeds.
  !
    k = cg1 / 53668
    cg1 = a1 * ( cg1 - k * 53668 ) - k * 12211
  
    if ( cg1 < 0 ) then
      cg1 = cg1 + m1
    end if
  
    k = cg2 / 52774
    cg2 = a2 * ( cg2 - k * 52774 ) - k * 3791
  
    if ( cg2 < 0 ) then
      cg2 = cg2 + m2
    end if
  !
  !  Store the updated seeds.
  !
    call cg_set ( g, cg1, cg2 )
  !
  !  Construct the random integer from the seeds.
  !
    z = cg1 - cg2
  
    if ( z < 1 ) then
      z = z + m1 - 1
    end if
  !
  !  If the generator is in antithetic mode, we must reflect the value.
  !
    value = antithetic_get ( )
  
    if ( value ) then
      z = m1 - z
    end if
  
    i4_uni = z
  
    return
  end
  subroutine ig_get ( g, ig1, ig2 )
  
  !*****************************************************************************80
  !
  !! IG_GET queries the IG values for a given generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    26 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) G, the index of the generator.
  !    1 <= G <= 32.
  !
  !    Output, integer ( kind = 4 ) IG1, IG2, the IG values for generator G.
  !
    implicit none
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    integer ( kind = 4 ) ig1
    integer ( kind = 4 ) ig2
  
    i = -1
    call ig_memory ( i, g, ig1, ig2 )
  
    return
  end
  subroutine ig_memory ( i, g, ig1, ig2 )
  
  !*****************************************************************************80
  !
  !! IG_MEMORY stores the IG values for all generators.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    30 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) I, the desired action.
  !    -1, get a value.
  !    0, initialize all values.
  !    1, set a value.
  !
  !    Input, integer ( kind = 4 ) G, for I = -1 or +1, the index of 
  !    the generator, with 1 <= G <= 32.
  !
  !    Input/output, integer ( kind = 4 ) IG1, IG2.  For I = -1, 
  !    these are output, for I = +1, these are input, for I = 0,
  !    these arguments are ignored.  When used, the arguments are
  !    old or new values of the IG parameter for generator G.
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: g_max = 32
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    integer ( kind = 4 ) ig1
    integer ( kind = 4 ) ig1_save(g_max)
    integer ( kind = 4 ) ig2
    integer ( kind = 4 ) ig2_save(g_max)
  
    save ig1_save
    save ig2_save
  
    data ig1_save / 32 * 0 /
    data ig2_save / 32 * 0 /
  
    if ( g < 1 .or. g_max < g ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'IG_MEMORY - Fatal error!'
      write ( *, '(a)' ) '  Input generator index G is out of bounds.'
      stop 1
    end if
  
    if ( i < 0 ) then
      ig1 = ig1_save(g)
      ig2 = ig2_save(g)
    else if ( i == 0 ) then
      ig1_save(1:g_max) = 0
      ig2_save(1:g_max) = 0
    else if ( 0 < i ) then
      ig1_save(g) = ig1
      ig2_save(g) = ig2
    end if
  
    return
  end
  subroutine ig_set ( g, ig1, ig2 )
  
  !*****************************************************************************80
  !
  !! IG_SET sets the IG values for a given generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    26 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) G, the index of the generator.
  !    1 <= G <= 32.
  !
  !    Input, integer ( kind = 4 ) IG1, IG2, the IG values for generator G.
  !
    implicit none
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    integer ( kind = 4 ) ig1
    integer ( kind = 4 ) ig2
  
    i = +1
    call ig_memory ( i, g, ig1, ig2 )
  
    return
  end
  subroutine init_generator ( t )
  
  !*****************************************************************************80
  !
  !! INIT_GENERATOR sets the current generator to initial, last or new seed.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) T, the seed type:
  !    0, use the seed chosen at initialization time.
  !    1, use the last seed.
  !    2, use a new seed set 2^30 values away.
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: a1_w = 1033780774
    integer ( kind = 4 ), parameter :: a2_w = 1494757890
    integer ( kind = 4 ) cg1
    integer ( kind = 4 ) cg2
    integer ( kind = 4 ) cgn_get
    integer ( kind = 4 ) g
    integer ( kind = 4 ) ig1
    integer ( kind = 4 ) ig2
    logical initialized_get
    integer ( kind = 4 ) lg1
    integer ( kind = 4 ) lg2
    integer ( kind = 4 ), parameter :: m1 = 2147483563
    integer ( kind = 4 ), parameter :: m2 = 2147483399
    integer ( kind = 4 ) multmod
    integer ( kind = 4 ) t
  !
  !  Check whether the package must be initialized.
  !
    if ( .not. initialized_get ( ) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'INIT_GENERATOR - Note:'
      write ( *, '(a)' ) '  Initializing RNGLIB package.'
      call initialize_gen ( )
    end if
  !
  !  Get the current generator index.
  !
    g = cgn_get ( )
  !
  !  0: restore the initial seed.
  !
    if ( t == 0 ) then
  
      call ig_get ( g, ig1, ig2 )
      lg1 = ig1
      lg2 = ig2
      call lg_set ( g, lg1, lg2 )
  !
  !  1: restore the last seed.
  !
    else if ( t == 1 ) then
  
      call lg_get ( g, lg1, lg2 )
  !
  !  2: advance to a new seed.
  !
    else if ( t == 2 ) then
  
      call lg_get ( g, lg1, lg2 )
      lg1 = multmod ( a1_w, lg1, m1 )
      lg2 = multmod ( a2_w, lg2, m2 )
      call lg_set ( g, lg1, lg2 )
  
    else
  
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'INIT_GENERATOR - Fatal error!'
      write ( *, '(a)' ) '  Input parameter T out of bounds.'
      stop 1
  
    end if
  !
  !  Store the new seed.
  !
    cg1 = lg1
    cg2 = lg2
    call cg_set ( g, cg1, cg2 )
  
    return
  end
  subroutine initialize_gen ( )
  
  !*****************************************************************************80
  !
  !! INITIALIZE initializes the random number generator library.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    30 March 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    None
  !
    implicit none
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ), parameter :: g_max = 32
    integer ( kind = 4 ) ig1
    integer ( kind = 4 ) ig2
    logical value
  !
  !  Remember that we have called INITIALIZE().
  !
    call initialized_set ( )
  !
  !  Initialize all generators to have FALSE antithetic value.
  !
    value = .false.
    do g = 1, g_max
      call cgn_set ( g )
      call antithetic_set ( value )
    end do
  !
  !  Set the initial seeds.
  !
    ig1 = 1234567890
    ig2 = 123456789
    call set_initial_seed ( ig1, ig2 )
  !
  !  Initialize the current generator index to the first one.
  !
    g = 1
    call cgn_set ( g )
    
    !write ( *, '(a)' ) ' '
    !write ( *, '(a)' ) 'INITIALIZE - Note:'
    !write ( *, '(a)' ) '  The RNGLIB package has been initialized.'
  
    return
  end
  function initialized_get ( )
  
  !*****************************************************************************80
  !
  !! INITIALIZED_GET queries the INITIALIZED value.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    28 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Output, logical INITIALIZED_GET, is TRUE if the package has 
  !    been initialized.
  !
    implicit none
  
    integer ( kind = 4 ) i
    logical initialized
    logical initialized_get
  
    i = -1
    call initialized_memory ( i, initialized )
  
    initialized_get = initialized
  
    return
  end
  subroutine initialized_memory ( i, initialized )
  
  !*****************************************************************************80
  !
  !! INITIALIZED_MEMORY stores the INITIALIZED value for the package.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    28 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) I, the desired action.
  !    -1, get the value.
  !    0, initialize the value.
  !    1, set the value.
  !
  !    Input/output, logical INITIALIZED.  For I = -1, 
  !    this is output, for I = +1, this is input, for I = 0,
  !    this argument is ignored.  
  !
    implicit none
  
    integer ( kind = 4 ) i
    logical initialized
    logical initialized_save
  
    save initialized_save
  
    data initialized_save / .false. /
  
    if ( i < 0 ) then
      initialized = initialized_save
    else if ( i == 0 ) then
      initialized_save = .false.
    else if ( 0 < i ) then
      initialized_save = initialized
    end if
  
    return
  end
  subroutine initialized_set ( )
  
  !*****************************************************************************80
  !
  !! INITIALIZED_SET sets the INITIALIZED value true.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    28 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    None
  !
    implicit none
  
    integer ( kind = 4 ) i
    logical initialized
    
    i = +1
    initialized = .true.
    call initialized_memory ( i, initialized )
    !write ( *, '(a)' ) ' initialized_set '
    return
  end
  subroutine lg_get ( g, lg1, lg2 )
  
  !*****************************************************************************80
  !
  !! LG_GET queries the LG values for a given generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    26 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) G, the index of the generator.
  !    1 <= G <= 32.
  !
  !    Output, integer ( kind = 4 ) LG1, LG2, the LG values for generator G.
  !
    implicit none
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    integer ( kind = 4 ) lg1
    integer ( kind = 4 ) lg2
  
    i = -1
    call lg_memory ( i, g, lg1, lg2 )
  
    return
  end
  subroutine lg_memory ( i, g, lg1, lg2 )
  
  !*****************************************************************************80
  !
  !! LG_MEMORY stores the LG values for all generators.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    26 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) I, the desired action.
  !    -1, get a value.
  !    0, initialize all values.
  !    1, set a value.
  !
  !    Input, integer ( kind = 4 ) G, for I = -1 or +1, the index of 
  !    the generator, with 1 <= G <= 32.
  !
  !    Input/output, integer ( kind = 4 ) LG1, LG2.  For I = -1, 
  !    these are output, for I = +1, these are input, for I = 0,
  !    these arguments are ignored.  When used, the arguments are
  !    old or new values of the LG parameter for generator G.
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: g_max = 32
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    integer ( kind = 4 ) lg1
    integer ( kind = 4 ) lg1_save(g_max)
    integer ( kind = 4 ) lg2
    integer ( kind = 4 ) lg2_save(g_max)
  
    save lg1_save
    save lg2_save
  
    data lg1_save / 32 * 0 /
    data lg2_save / 32 * 0 /
  
    if ( g < 1 .or. g_max < g ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'LG_MEMORY - Fatal error!'
      write ( *, '(a)' ) '  Input generator index G is out of bounds.'
      stop 1
    end if
  
    if ( i < 0 ) then
      lg1 = lg1_save(g)
      lg2 = lg2_save(g)
    else if ( i == 0 ) then
      lg1_save(1:g_max) = 0
      lg2_save(1:g_max) = 0
    else if ( 0 < i ) then
      lg1_save(g) = lg1
      lg2_save(g) = lg2
    end if
  
    return
  end
  subroutine lg_set ( g, lg1, lg2 )
  
  !*****************************************************************************80
  !
  !! LG_SET sets the LG values for a given generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    26 March 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) G, the index of the generator.
  !    1 <= G <= 32.
  !
  !    Input, integer ( kind = 4 ) LG1, LG2, the LG values for generator G.
  !
    implicit none
  
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    integer ( kind = 4 ) lg1
    integer ( kind = 4 ) lg2
  
    i = +1
    call lg_memory ( i, g, lg1, lg2 )
  
    return
  end
  function multmod ( a, s, m )
  
  !*****************************************************************************80
  !
  !! MULTMOD carries out modular multiplication.
  !
  !  Discussion:
  !
  !    This procedure returns 
  !
  !      ( A * S ) mod M
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    26 March 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) A, S, M, the arguments.
  !
  !    Output, integer ( kind = 4 ) MULTMOD, the value of the product of A and S, 
  !    modulo M.
  !
    implicit none
  
    integer ( kind = 4 ) a
    integer ( kind = 4 ) a0
    integer ( kind = 4 ) a1
    integer ( kind = 4 ), parameter :: h = 32768
    integer ( kind = 4 ) k
    integer ( kind = 4 ) m
    integer ( kind = 4 ) multmod
    integer ( kind = 4 ) p
    integer ( kind = 4 ) q
    integer ( kind = 4 ) qh
    integer ( kind = 4 ) rh
    integer ( kind = 4 ) s
  
    if ( a <= 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'MULTMOD - Fatal error!'
      write ( *, '(a)' ) '  A <= 0.'
      stop 1
    end if
  
    if ( m <= a ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'MULTMOD - Fatal error!'
      write ( *, '(a)' ) '  M <= A.'
      stop 1
    end if
  
    if ( s <= 0 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'MULTMOD - Fatal error!'
      write ( *, '(a)' ) '  S <= 0.'
      stop 1
    end if
  
    if ( m <= s ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'MULTMOD - Fatal error!'
      write ( *, '(a)' ) '  M <= S.'
      stop 1
    end if
  
    if ( a < h ) then
  
      a0 = a
      p = 0
  
    else
  
      a1 = a / h
      a0 = a - h * a1
      qh = m / h
      rh = m - h * qh
  
      if ( h <= a1 ) then
     
        a1 = a1 - h
        k = s / qh
        p = h * ( s - k * qh ) - k * rh
  
        do while ( p < 0 )
          p = p + m
        end do
  
      else
  
        p = 0
  
      end if
  
      if ( a1 /= 0 ) then
  
        q = m / a1
        k = s / q
        p = p - k * ( m - a1 * q )
  
        if ( 0 < p ) then
          p = p - m
        end if
  
        p = p + a1 * ( s - k * q )
  
        do while ( p < 0 )
          p = p + m
        end do
  
      end if
  
      k = p / qh
      p = h * ( p - k * qh ) - k * rh
  
      do while ( p < 0 )
        p = p + m
      end do
  
    end if
  
    if ( a0 /= 0 ) then
  
      q = m / a0
      k = s / q
      p = p - k * ( m - a0 * q )
  
      if ( 0 < p ) then
        p = p - m
      end if
  
      p = p + a0 * ( s - k * q )
  
      do while ( p < 0 )
        p = p + m
      end do
  
    end if
  
    multmod = p
  
    return
  end
  function r4_uni_01 ( )
  
  !*****************************************************************************80
  !
  !! R4_UNI_01 returns a uniform random real number in [0,1].
  !
  !  Discussion:
  !
  !    This procedure returns a random floating point number from a uniform 
  !    distribution over (0,1), not including the endpoint values, using the
  !    current random number generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    05 August 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Output, real ( kind = 4 ) R4_UNI_01, a uniform random value in [0,1].
  !
    implicit none
  
    integer ( kind = 4 ) i
    integer ( kind = 4 ) i4_uni
    logical initialized_get
    real ( kind = 4 ) r4_uni_01
  !
  !  Check whether the package must be initialized.
  !
    if ( .not. initialized_get ( ) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'R4_UNI_01 - Note:'
      write ( *, '(a)' ) '  Initializing RNGLIB package.'
      call initialize_gen ( )
    end if
  !
  !  Get a random positive integer.
  !
    i = i4_uni ( )
  !
  !  Scale it to a random real in [0,1].
  !
    r4_uni_01 = real ( i, kind = 4 ) * 4.656613057E-10
  
    return
  end
  function r8_uni_01 ( )
  
  !*****************************************************************************80
  !
  !! R8_UNI_01 returns a uniform random double precision number in [0,1].
  !
  !  Discussion:
  !
  !    This procedure returns a random floating point number from a uniform 
  !    distribution over (0,1), not including the endpoint values, using the
  !    current random number generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    05 August 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Output, real ( kind = 8 ) R8_UNI_01, a uniform random value in [0,1].
  !
    implicit none
  
    integer ( kind = 4 ) i
    integer ( kind = 4 ) i4_uni
    logical initialized_get
    real ( kind = 8 ) r8_uni_01
  !
  !  Check whether the package must be initialized.
  !
    if ( .not. initialized_get ( ) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'R8_UNI_01 - Note:'
      write ( *, '(a)' ) '  Initializing RNGLIB package.'
      call initialize_gen ( )
    end if
  !
  !  Get a random positive integer.
  !
    i = i4_uni ( )
  !
  !  Scale it to a random real in [0,1].
  !
    r8_uni_01 = real ( i, kind = 8 ) * 4.656613057D-10
  
    return
  end
  subroutine set_initial_seed ( ig1, ig2 )
  
  !*****************************************************************************80
  !
  !! SET_INITIAL_SEED resets the initial seed and state for all generators.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    28 March 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) IG1, IG2, the initial seed values 
  !    for the first generator.
  !    1 <= IG1 < 2147483563
  !    1 <= IG2 < 2147483399
  !
    implicit none
  
    integer ( kind = 4 ), parameter :: a1_vw = 2082007225
    integer ( kind = 4 ), parameter :: a2_vw = 784306273
    integer ( kind = 4 ) g
    integer ( kind = 4 ), parameter :: g_max = 32
    integer ( kind = 4 ) i
    integer ( kind = 4 ) ig1
    integer ( kind = 4 ) ig2
    logical initialized_get
    integer ( kind = 4 ), parameter :: m1 = 2147483563
    integer ( kind = 4 ), parameter :: m2 = 2147483399
    integer ( kind = 4 ) multmod
    integer ( kind = 4 ) t
  
    if ( ig1 < 1 .or. m1 <= ig1 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'SET_INITIAL_SEED - Fatal error!'
      write ( *, '(a)' ) '  Input parameter IG1 out of bounds.'
      stop 1
    end if
  
    if ( ig2 < 1 .or. m2 <= ig2 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'SET_INITIAL_SEED - Fatal error!'
      write ( *, '(a)' ) '  Input parameter IG2 out of bounds.'
      stop 1
    end if
  !
  !  Because INITIALIZE calls SET_INITIAL_SEED, it's not easy to correct
  !  the error that arises if SET_INITIAL_SEED is called before INITIALIZE.
  !  So don't bother trying.
  !
    if ( .not. initialized_get ( ) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'SET_INITIAL_SEED - Fatal error!'
      write ( *, '(a)' ) '  The RNGLIB package has not been initialized.'
      stop 1
    end if
  !
  !  Set the initial seed, then initialize the first generator.
  !
    g = 1
    call cgn_set ( g )
  
    call ig_set ( g, ig1, ig2 )
  
    t = 0
    call init_generator ( t )
  !
  !  Now do similar operations for the other generators.
  !
    do g = 2, g_max
  
      call cgn_set ( g )
      ig1 = multmod ( a1_vw, ig1, m1 )
      ig2 = multmod ( a2_vw, ig2, m2 )
      call ig_set ( g, ig1, ig2 )
      call init_generator ( t )
  
    end do
  !
  !  Now choose the first generator.
  !
    g = 1
    call cgn_set ( g )
  
    return
  end
  subroutine set_seed ( cg1, cg2 )
  
  !*****************************************************************************80
  !
  !! SET_SEED resets the initial seed and state of the current generator.
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    31 March 2013
  !
  !  Author:
  !
  !    Original Pascal version by Pierre L'Ecuyer, Serge Cote.
  !    FORTRAN90 version by John Burkardt.
  !
  !  Reference:
  !
  !    Pierre LEcuyer, Serge Cote,
  !    Implementing a Random Number Package with Splitting Facilities,
  !    ACM Transactions on Mathematical Software,
  !    Volume 17, Number 1, March 1991, pages 98-111.
  !
  !  Parameters:
  !
  !    Input, integer ( kind = 4 ) CG1, CG2, the CG values for generator G.
  !    1 <= CG1 < 2147483563
  !    1 <= CG2 < 2147483399
  !
    implicit none
  
    integer ( kind = 4 ) cg1
    integer ( kind = 4 ) cg2
    integer ( kind = 4 ) cgn_get
    integer ( kind = 4 ) g
    integer ( kind = 4 ) i
    logical initialized_get
    integer ( kind = 4 ), parameter :: m1 = 2147483563
    integer ( kind = 4 ), parameter :: m2 = 2147483399
    integer ( kind = 4 ) t
  
    if ( cg1 < 1 .or. m1 <= cg1 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'SET_SEED - Fatal error!'
      write ( *, '(a)' ) '  Input parameter CG1 out of bounds.'
      stop 1
    end if
  
    if ( cg2 < 1 .or. m2 <= cg2 ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'SET_SEED - Fatal error!'
      write ( *, '(a)' ) '  Input parameter CG2 out of bounds.'
      stop 1
    end if
  !
  !  Check whether the package must be initialized.
  !
    if ( .not. initialized_get ( ) ) then
      write ( *, '(a)' ) ' '
      write ( *, '(a)' ) 'SET_SEED - Note:'
      write ( *, '(a)' ) '  Initializing RNGLIB package.'
      call initialize_gen ( )
    end if
  !
  !  Retrieve the current generator index.
  !
    g = cgn_get ( )
  !
  !  Set the seeds.
  !
    call cg_set ( g, cg1, cg2 )
  !
  !  Initialize the generator.
  !
    t = 0
    call init_generator ( t )
  
    return
  end
  subroutine timestamp ( o)
  
  !*****************************************************************************80
  !
  !! TIMESTAMP prints the current YMDHMS date as a time stamp.
  !
  !  Example:
  !
  !    31 May 2001   9:45:54.872 AM
  !
  !  Licensing:
  !
  !    This code is distributed under the GNU LGPL license.
  !
  !  Modified:
  !
  !    18 May 2013
  !
  !  Author:
  !
  !    John Burkardt
  !
  !  Parameters:
  !
  !    None
  !
    implicit none
  
    character ( len = 8 ) ampm
    integer ( kind = 4 ) d
    integer ( kind = 4 ) h
    integer ( kind = 4 ) m
    integer ( kind = 4 ) mm
    character ( len = 9 ), parameter, dimension(12) :: month = (/ &
      'January  ', 'February ', 'March    ', 'April    ', &
      'May      ', 'June     ', 'July     ', 'August   ', &
      'September', 'October  ', 'November ', 'December ' /)
    integer ( kind = 4 ) n
    integer ( kind = 4 ) s
    integer ( kind = 4 ) values(8)
    integer ( kind = 4 ) y
  
    character ( len = 100 ) o
  
    call date_and_time ( values = values )
  
    y = values(1)
    m = values(2)
    d = values(3)
    h = values(5)
    n = values(6)
    s = values(7)
    mm = values(8)
  
    if ( h < 12 ) then
      ampm = 'AM'
    else if ( h == 12 ) then
      if ( n == 0 .and. s == 0 ) then
        ampm = 'Noon'
      else
        ampm = 'PM'
      end if
    else
      h = h - 12
      if ( h < 12 ) then
        ampm = 'PM'
      else if ( h == 12 ) then
        if ( n == 0 .and. s == 0 ) then
          ampm = 'Midnight'
        else
          ampm = 'AM'
        end if
      end if
    end if
  
    write ( o, '(i2,1x,a,1x,i4,2x,i2,a1,i2.2,a1,i2.2,a1,i3.3,1x,a)' ) &
      d, trim ( month(m) ), y, h, ':', n, ':', s, '.', mm, trim ( ampm )
      
    return
  end

  SUBROUTINE contraction42(s,LT,rt,ndi)



!>       DOUBLE CONTRACTION BETWEEN 4TH ORDER AND 2ND ORDER  TENSOR
!>      INPUT:
!>       LT - left 4TH ORDER TENSOR
!>       RT - right  2ND ODER TENSOR
!>      OUTPUT:
!>       S - DOUBLE CONTRACTED TENSOR (2ND ORDER)
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: s(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: LT(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: rt(ndi,ndi)


INTEGER :: i1,j1,k1,l1


DOUBLE PRECISION :: aux



DO i1=1,ndi
  DO j1=1,ndi
    aux=zero
    DO k1=1,ndi
      DO l1=1,ndi
        aux=aux+LT(i1,j1,k1,l1)*rt(k1,l1)
      END DO
    END DO
    s(i1,j1)=aux
  END DO
END DO
RETURN
END SUBROUTINE contraction42
SUBROUTINE sliding(ffc,ru,ffc0,ru0,ffcmax,fric,frac,dtime)

use global
implicit none

DOUBLE PRECISION, INTENT(OUT)            :: ffc
DOUBLE PRECISION, INTENT(OUT)            :: ru
DOUBLE PRECISION, INTENT(IN)             :: ffc0
DOUBLE PRECISION, INTENT(IN OUT)         :: ru0
DOUBLE PRECISION, INTENT(IN)             :: ffcmax
DOUBLE PRECISION, INTENT(IN)         :: fric
DOUBLE PRECISION, INTENT(IN)             :: frac(4)
DOUBLE PRECISION, INTENT(IN)             :: dtime





DOUBLE PRECISION :: aux0,aux1,aux2, arg
!      INTEGER STATE

aux1=frac(3)
aux0=aux1+frac(4)
aux2=aux0
arg=ffc0/ffcmax

IF(arg < aux1) THEN
  ffc=aux1*ffcmax
ELSE IF (arg > aux2)THEN
  ffc=aux2*ffcmax
ELSE
  ffc=ffc0
END IF

ru=ru0+dtime*(fric**(-one))*(ffc-ffc0)
ru0=ru

RETURN

END SUBROUTINE sliding
SUBROUTINE onem(a,aa,aas,ndi)



!>      THIS SUBROUTINE GIVES:
!>          2ND ORDER IDENTITY TENSORS - A
!>          4TH ORDER IDENTITY TENSOR - AA
!>          4TH ORDER SYMMETRIC IDENTITY TENSOR - AAS
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: a(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: aa(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: aas(ndi,ndi,ndi,ndi)



INTEGER :: i,j,k,l

a = zero
aa = zero
aas = zero

DO i = 1, ndi
  a(i,i) = one
END DO

DO i=1,ndi
  DO j=1,ndi
    DO k=1,ndi
      DO l=1,ndi
        IF (i == k .and. j == l) then
          aa(i,j,k,l) = one
        END IF
        aas(i,j,k,l) = (one/two)*(a(i,k)*a(j,l)+a(i,l)*a(j,k))
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE onem
SUBROUTINE factorial(fact,term)



!>    FACTORIAL
use global
IMPLICIT NONE

DOUBLE PRECISION, INTENT(OUT)            :: fact
INTEGER, INTENT(IN)                      :: term



INTEGER :: m

fact = 1

DO  m = 1, term
  fact = fact * m
END DO

RETURN
END SUBROUTINE factorial
SUBROUTINE csisomatfic(cisomatfic,cmisomatfic,distgr,det,ndi)



!>    ISOTROPIC MATRIX: SPATIAL 'FICTICIOUS' ELASTICITY TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: ndi
DOUBLE PRECISION, INTENT(IN OUT)         :: cisomatfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: cmisomatfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: distgr(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: det



call push4(cisomatfic,cmisomatfic,distgr,det,ndi)

RETURN
END SUBROUTINE csisomatfic
SUBROUTINE hfilfic(h,hh,pp,lambda,m,rw,ndi)



!>      NON-AFFINE NETWORK: STRUCTURE TENSORS
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: h(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: hh(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: pp
DOUBLE PRECISION, INTENT(IN OUT)         :: lambda
DOUBLE PRECISION, INTENT(IN)             :: m(ndi)
DOUBLE PRECISION, INTENT(IN)             :: rw



INTEGER :: i1,j1,k1,l1

DOUBLE PRECISION :: aux0,aux, pi,aux1

pi=four*ATAN(one)
aux0=four*pi
aux=(lambda**(pp-two))*rw
aux1=(pp-two)*(lambda**(pp-four))*rw

DO i1=1,ndi
  DO j1=1,ndi
    h(i1,j1)=aux*m(i1)*m(j1)
    DO k1=1,ndi
      DO l1=1,ndi
        hh(i1,j1,k1,l1)=aux1*m(i1)*m(j1)*m(k1)*m(l1)
      END DO
    END DO
  END DO
END DO

RETURN

END SUBROUTINE hfilfic
SUBROUTINE pull4(mat,spatial,finv,det,ndi)



!>        PULL-BACK TIMES DET OF 4TH ORDER TENSOR

use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: mat(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: spatial(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: finv(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: det



INTEGER :: i1,j1,k1,l1,ii1,jj1,kk1,ll1


DOUBLE PRECISION :: aux


DO i1=1,ndi
  DO j1=1,ndi
    DO k1=1,ndi
      DO l1=1,ndi
        aux=zero
        DO ii1=1,ndi
          DO jj1=1,ndi
            DO kk1=1,ndi
              DO ll1=1,ndi
                aux=aux+det* finv(i1,ii1)*finv(j1,jj1)*  &
                    finv(k1,kk1)*finv(l1,ll1)*spatial(ii1,jj1,kk1,ll1)
              END DO
            END DO
          END DO
        END DO
        mat(i1,j1,k1,l1)=aux
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE pull4
SUBROUTINE metiso(cmiso,cmfic,pl,pkiso,pkfic,c,unit2,det,ndi)



!>    ISOCHORIC MATERIAL ELASTICITY TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: cmiso(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: cmfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pl(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pkiso(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pkfic(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: c(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: unit2(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: det



INTEGER :: i1,j1,k1,l1
DOUBLE PRECISION :: cisoaux(ndi,ndi,ndi,ndi), cisoaux1(ndi,ndi,ndi,ndi),  &
    plt(ndi,ndi,ndi,ndi),cinv(ndi,ndi), pll(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: trfic,xx,yy,zz, aux,aux1

CALL matinv3d(c,cinv,ndi)
cisoaux1=zero
cisoaux=zero
CALL contraction44(cisoaux1,pl,cmfic,ndi)
DO i1=1,ndi
  DO j1=1,ndi
    DO k1=1,ndi
      DO l1=1,ndi
        plt(i1,j1,k1,l1)=pl(k1,l1,i1,j1)
      END DO
    END DO
  END DO
END DO

CALL contraction44(cisoaux,cisoaux1,plt,ndi)

trfic=zero
aux=det**(-two/three)
aux1=aux**two
CALL contraction22(trfic,aux*pkfic,c,ndi)

DO i1=1,ndi
  DO j1=1,ndi
    DO k1=1,ndi
      DO l1=1,ndi
        xx=aux1*cisoaux(i1,j1,k1,l1)
        pll(i1,j1,k1,l1)=(one/two)*(cinv(i1,k1)*cinv(j1,l1)+  &
            cinv(i1,l1)*cinv(j1,k1))- (one/three)*cinv(i1,j1)*cinv(k1,l1)
        yy=trfic*pll(i1,j1,k1,l1)
        zz=pkiso(i1,j1)*cinv(k1,l1)+cinv(i1,j1)*pkiso(k1,l1)
        
        cmiso(i1,j1,k1,l1)=xx+(two/three)*yy-(two/three)*zz
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE metiso
SUBROUTINE sdvwrite(det,etac_sdv,statev)
!>    VISCOUS DISSIPATION: WRITE STATE VARS
use global
implicit none

INTEGER :: pos1, i
!
DOUBLE PRECISION, INTENT(IN)             :: det
DOUBLE PRECISION, INTENT(IN)             :: etac_sdv(nsdv-1)
DOUBLE PRECISION, INTENT(OUT)            :: statev(nsdv)
!
pos1=0
statev(pos1+1)=det
IF (nsdv .GE. 2) THEN
    DO i = pos1+2, nsdv
        statev(i)=etac_sdv(i-1)
    END DO
END IF

RETURN

END SUBROUTINE sdvwrite
SUBROUTINE matinv3d(a,a_inv,ndi)
!>    INVERSE OF A 3X3 MATRIX
!     RETURN THE INVERSE OF A(3,3) - A_INV
use global

INTEGER, INTENT(IN OUT)                  :: ndi
DOUBLE PRECISION, INTENT(IN)             :: a(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: a_inv(ndi,ndi)

DOUBLE PRECISION :: det_a,det_a_inv

det_a = a(1,1)*(a(2,2)*a(3,3) - a(3,2)*a(2,3)) -  &
    a(2,1)*(a(1,2)*a(3,3) - a(3,2)*a(1,3)) +  &
    a(3,1)*(a(1,2)*a(2,3) - a(2,2)*a(1,3))

IF (det_a <= 0.d0) THEN
  WRITE(*,*) 'WARNING: SUBROUTINE MATINV3D:'
  WRITE(*,*) 'WARNING: DET OF MAT=',det_a
  RETURN
END IF

det_a_inv = 1.d0/det_a

a_inv(1,1) = det_a_inv*(a(2,2)*a(3,3)-a(3,2)*a(2,3))
a_inv(1,2) = det_a_inv*(a(3,2)*a(1,3)-a(1,2)*a(3,3))
a_inv(1,3) = det_a_inv*(a(1,2)*a(2,3)-a(2,2)*a(1,3))
a_inv(2,1) = det_a_inv*(a(3,1)*a(2,3)-a(2,1)*a(3,3))
a_inv(2,2) = det_a_inv*(a(1,1)*a(3,3)-a(3,1)*a(1,3))
a_inv(2,3) = det_a_inv*(a(2,1)*a(1,3)-a(1,1)*a(2,3))
a_inv(3,1) = det_a_inv*(a(2,1)*a(3,2)-a(3,1)*a(2,2))
a_inv(3,2) = det_a_inv*(a(3,1)*a(1,2)-a(1,1)*a(3,2))
a_inv(3,3) = det_a_inv*(a(1,1)*a(2,2)-a(2,1)*a(1,2))

RETURN
END SUBROUTINE matinv3d
SUBROUTINE uexternaldb(lop,lrestart,time,dtime,kstep,kinc)



!>    READ FILAMENTS ORIENTATION AND PREFERED DIRECTIONS
use global
INCLUDE 'aba_param.inc'
!       this subroutine get the directions and weights for
!      the numerical integration

!     UEXTERNAL just called once; work in parallel computing

INTEGER, INTENT(IN OUT)                  :: lop
INTEGER, INTENT(IN OUT)                  :: lrestart
REAL, INTENT(IN OUT)                     :: time(2)
real(8), INTENT(IN OUT)                   :: dtime
INTEGER, INTENT(IN OUT)                  :: kstep
INTEGER, INTENT(IN OUT)                  :: kinc

COMMON /kfilp/prefdir


DOUBLE PRECISION :: prefdir(nelem,4)     
CHARACTER (LEN=256) ::  filename, jobdir
INTEGER :: lenjobdir,i,j,k

!     LOP=0 --> START OF THE ANALYSIS
IF(lop == 0.OR.lop == 4) THEN
  
  CALL getoutdir(jobdir,lenjobdir)
  
  !preferential direction
  filename=jobdir(:lenjobdir)//'/'//dir2
  OPEN(16,FILE=filename)
  DO i=1,nelem
    READ(16,*) (prefdir(i,j),j=1,4)
  END DO
  CLOSE(16)
END IF

RETURN

END SUBROUTINE uexternaldb
SUBROUTINE projeul(a,aa,pe,ndi)



!>    EULERIAN PROJECTION TENSOR
!      INPUTS:
!          IDENTITY TENSORS - A, AA
!      OUTPUTS:
!          4TH ORDER SYMMETRIC EULERIAN PROJECTION TENSOR - PE
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(IN)             :: a(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: aa(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: pe(ndi,ndi,ndi,ndi)



INTEGER :: i,j,k,l



DO i=1,ndi
  DO j=1,ndi
    DO k=1,ndi
      DO l=1,ndi
        pe(i,j,k,l)=aa(i,j,k,l)-(one/three)*(a(i,j)*a(k,l))
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE projeul
SUBROUTINE sigiso(siso,sfic,pe,ndi)



!>    ISOCHORIC CAUCHY STRESS
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: ndi
DOUBLE PRECISION, INTENT(IN OUT)         :: siso(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: sfic(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: pe(ndi,ndi,ndi,ndi)


CALL contraction42(siso,pe,sfic,ndi)

RETURN
END SUBROUTINE sigiso
SUBROUTINE projlag(c,aa,pl,ndi)



!>    LAGRANGIAN PROJECTION TENSOR
!      INPUTS:
!          IDENTITY TENSORS - A, AA
!          ISOCHORIC LEFT CAUCHY GREEN TENSOR - C
!          INVERSE OF C - CINV
!      OUTPUTS:
!          4TH ORDER SYMMETRIC LAGRANGIAN PROJECTION TENSOR - PL
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                      :: ndi
DOUBLE PRECISION, INTENT(IN)             :: c(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: aa(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: pl(ndi,ndi,ndi,ndi)



INTEGER :: i,j,k,l

DOUBLE PRECISION :: cinv(ndi,ndi)

CALL matinv3d(c,cinv,ndi)

DO i=1,ndi
  DO j=1,ndi
    DO k=1,ndi
      DO l=1,ndi
        pl(i,j,k,l)=aa(i,j,k,l)-(one/three)*(cinv(i,j)*c(k,l))
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE projlag
SUBROUTINE relax(qv,hv,aux1,hv0,pkiso,dtime,tau,teta,ndi)



!>    VISCOUS DISSIPATION: STRESS RELAXATION TENSORS
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: qv(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: hv(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: aux1
DOUBLE PRECISION, INTENT(IN)             :: hv0(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pkiso(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: dtime
DOUBLE PRECISION, INTENT(IN OUT)         :: tau
DOUBLE PRECISION, INTENT(IN)             :: teta



INTEGER :: i1,j1

DOUBLE PRECISION :: aux

qv=zero
hv=zero

aux=DEXP(-dtime*((two*tau)**(-one)))
aux1=teta*aux
DO i1=1,ndi
  DO j1=1,ndi
    qv(i1,j1)=hv0(i1,j1)+aux1*pkiso(i1,j1)
    hv(i1,j1)=aux*(aux*qv(i1,j1)-teta*pkiso(i1,j1))
  END DO
END DO

RETURN
END SUBROUTINE relax
SUBROUTINE vol(ssev,pv,ppv,k,det)

! Code converted using TO_F90 by Alan Miller
! Date: 2020-12-12  Time: 12:08:12

!>     VOLUMETRIC CONTRIBUTION :STRAIN ENERGY FUNCTION AND DERIVATIVES
use global
implicit none


DOUBLE PRECISION :: g, aux
DOUBLE PRECISION, INTENT(OUT)            :: ssev
DOUBLE PRECISION, INTENT(OUT)            :: pv
DOUBLE PRECISION, INTENT(OUT)            :: ppv
DOUBLE PRECISION, INTENT(IN)             :: k
DOUBLE PRECISION, INTENT(IN)             :: det


g=(one/four)*(det*det-one-two*LOG(det))

ssev=k*g

pv=k*(one/two)*(det-one/det)
aux=k*(one/two)*(one+one/(det*det))
ppv=pv+det*aux

RETURN
END SUBROUTINE vol
!>********************************************************************
!> Record of revisions:                                              |
!>        Date        Programmer        Description of change        |
!>        ====        ==========        =====================        |
!>     05/11/2016    Joao Ferreira      full network model           |
!>--------------------------------------------------------------------
!>     Description:
!C>     UMAT: USER MATERIAL FOR THE FULL NETWORK MODEL.
!C>                 AFFINE DEFORMATIONS
!C>     UEXTERNALDB: READ FILAMENTS ORIENTATION AND PREFERED DIRECTION
!>--------------------------------------------------------------------
!>---------------------------------------------------------------------

SUBROUTINE umat(stress,statev,ddsdde,sse,spd,scd, rpl,ddsddt,drplde,drpldt,  &
    stran,dstran,time,dtime,temp,dtemp,predef,dpred,cmname,  &
    ndi,nshr,ntens,nstatev,props,nprops,coords,drot,pnewdt,  &
    celent,dfgrd0,dfgrd1,noel,npt,layer,kspt,kstep,kinc)
!
use global  
IMPLICIT NONE
!----------------------------------------------------------------------
!--------------------------- DECLARATIONS -----------------------------
!----------------------------------------------------------------------
INTEGER, INTENT(IN OUT)                  :: noel
INTEGER, INTENT(IN OUT)                  :: npt
INTEGER, INTENT(IN OUT)                  :: layer
INTEGER, INTENT(IN OUT)                  :: kspt
INTEGER, INTENT(IN OUT)                  :: kstep
INTEGER, INTENT(IN OUT)                  :: kinc
INTEGER, INTENT(IN OUT)                  :: ndi
INTEGER, INTENT(IN OUT)                  :: nshr
INTEGER, INTENT(IN OUT)                  :: ntens
INTEGER, INTENT(IN OUT)                  :: nstatev
INTEGER, INTENT(IN OUT)                  :: nprops
DOUBLE PRECISION, INTENT(IN OUT)         :: sse
DOUBLE PRECISION, INTENT(IN OUT)         :: spd
DOUBLE PRECISION, INTENT(IN OUT)         :: scd
DOUBLE PRECISION, INTENT(IN OUT)         :: rpl
DOUBLE PRECISION, INTENT(IN OUT)         :: dtime
DOUBLE PRECISION, INTENT(IN OUT)         :: drpldt
DOUBLE PRECISION, INTENT(IN OUT)         :: temp
DOUBLE PRECISION, INTENT(IN OUT)         :: dtemp
CHARACTER (LEN=8), INTENT(IN OUT)        :: cmname
DOUBLE PRECISION, INTENT(IN OUT)         :: pnewdt
DOUBLE PRECISION, INTENT(IN OUT)         :: celent

DOUBLE PRECISION, INTENT(IN OUT)         :: stress(ntens)
DOUBLE PRECISION, INTENT(IN OUT)         :: statev(nstatev)
DOUBLE PRECISION, INTENT(IN OUT)         :: ddsdde(ntens,ntens)
DOUBLE PRECISION, INTENT(IN OUT)         :: ddsddt(ntens)
DOUBLE PRECISION, INTENT(IN OUT)         :: drplde(ntens)
DOUBLE PRECISION, INTENT(IN OUT)         :: stran(ntens)
DOUBLE PRECISION, INTENT(IN OUT)         :: dstran(ntens)
DOUBLE PRECISION, INTENT(IN OUT)         :: time(2)
DOUBLE PRECISION, INTENT(IN OUT)         :: predef(1)
DOUBLE PRECISION, INTENT(IN OUT)         :: dpred(1)
DOUBLE PRECISION, INTENT(IN OUT)         :: props(nprops) !!! Added OUT
DOUBLE PRECISION, INTENT(IN OUT)         :: coords(3)
DOUBLE PRECISION, INTENT(IN OUT)         :: drot(3,3)
DOUBLE PRECISION, INTENT(IN OUT)         :: dfgrd0(3,3)
DOUBLE PRECISION, INTENT(IN OUT)         :: dfgrd1(3,3)

COMMON /kfilp/prefdir
DOUBLE PRECISION :: prefdir(nelem,4)

!
!     FLAGS
!      INTEGER FLAG1
!     UTILITY TENSORS
DOUBLE PRECISION :: unit2(ndi,ndi),unit4(ndi,ndi,ndi,ndi),  &
    unit4s(ndi,ndi,ndi,ndi), proje(ndi,ndi,ndi,ndi),projl(ndi,ndi,ndi,ndi)
!     KINEMATICS
DOUBLE PRECISION :: distgr(ndi,ndi),c(ndi,ndi),b(ndi,ndi),  &
    cbar(ndi,ndi),bbar(ndi,ndi),distgrinv(ndi,ndi),  &
    ubar(ndi,ndi),vbar(ndi,ndi),rot(ndi,ndi), dfgrd1inv(ndi,ndi)
DOUBLE PRECISION :: det,cbari1,cbari2
!     VOLUMETRIC CONTRIBUTION
DOUBLE PRECISION :: pkvol(ndi,ndi),svol(ndi,ndi),  &
    cvol(ndi,ndi,ndi,ndi),cmvol(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: k,pv,ppv,ssev
!     ISOCHORIC CONTRIBUTION
DOUBLE PRECISION :: siso(ndi,ndi),pkiso(ndi,ndi),pk2(ndi,ndi),  &
    ciso(ndi,ndi,ndi,ndi),cmiso(ndi,ndi,ndi,ndi),  &
    sfic(ndi,ndi),cfic(ndi,ndi,ndi,ndi), pkfic(ndi,ndi),cmfic(ndi,ndi,ndi,ndi)
!     ISOCHORIC ISOTROPIC CONTRIBUTION
DOUBLE PRECISION :: c10,c01,sseiso,diso(5),pkmatfic(ndi,ndi),  &
    smatfic(ndi,ndi),sisomatfic(ndi,ndi), cmisomatfic(ndi,ndi,ndi,ndi),  &
    cisomatfic(ndi,ndi,ndi,ndi)
!     FILAMENTS NETWORK CONTRIBUTION
DOUBLE PRECISION :: filprops(8), affprops(2)
DOUBLE PRECISION :: ll,lambda0,mu0,beta,nn,b0,bb
DOUBLE PRECISION :: phi,r0,r0c,r0f,p,etac
DOUBLE PRECISION :: pknetfic(ndi,ndi),cmnetfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: snetfic(ndi,ndi),cnetfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: pknetficaf(ndi,ndi),pknetficnaf(ndi,ndi)
DOUBLE PRECISION :: snetficaf(ndi,ndi),snetficnaf(ndi,ndi)
DOUBLE PRECISION :: cmnetficaf(ndi,ndi,ndi,ndi), cmnetficnaf(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: cnetficaf(ndi,ndi,ndi,ndi), cnetficnaf(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: efi
! INTEGER :: nterm,factor ! (originally uncommented)
!
!     JAUMMAN RATE CONTRIBUTION (REQUIRED FOR ABAQUS UMAT)
DOUBLE PRECISION :: cjr(ndi,ndi,ndi,ndi)
!     CAUCHY STRESS AND ELASTICITY TENSOR
DOUBLE PRECISION :: sigma(ndi,ndi),ddsigdde(ndi,ndi,ndi,ndi),  &
    ddpkdde(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: stest(ndi,ndi), ctest(ndi,ndi,ndi,ndi)

! DECLARATIONS FOR RANDOM GENERATION
INTEGER (kind=4) :: seed1, seed2
INTEGER (kind=4) :: test, test_num
CHARACTER(len=100) :: phrase
!REAL(kind=4) , allocatable :: etac_array(:), array(:)
DOUBLE PRECISION :: etac_sdv(nsdv-1)
REAL(kind=4) :: l_bound, h_bound
REAL(kind=4) :: mean, sd
!----------------------------------------------------------------------
!-------------------------- INITIALIZATIONS ---------------------------
!----------------------------------------------------------------------
!     IDENTITY AND PROJECTION TENSORS
unit2=zero
unit4=zero
unit4s=zero
proje=zero
projl=zero
!     KINEMATICS
distgr=zero
c=zero
b=zero
cbar=zero
bbar=zero
ubar=zero
vbar=zero
rot=zero
det=zero
cbari1=zero
cbari2=zero
!     VOLUMETRIC
pkvol=zero
svol=zero
cvol=zero
k=zero
pv=zero
ppv=zero
ssev=zero
!     ISOCHORIC
siso=zero
pkiso=zero
pk2=zero
ciso=zero
cfic=zero
sfic=zero
pkfic=zero
!     ISOTROPIC
c10=zero
c01=zero
sseiso=zero
diso=zero
pkmatfic=zero
smatfic=zero
sisomatfic=zero
cmisomatfic=zero
cisomatfic=zero
!     FILAMENTS NETWORK
snetfic=zero
cnetfic=zero
pknetfic=zero
pknetficaf=zero
pknetficnaf=zero
snetficaf=zero
snetficnaf=zero
cmnetfic=zero
cmnetficaf=zero
cmnetficnaf=zero
cnetficaf=zero
cnetficnaf=zero
!     JAUMANN RATE
cjr=zero
!     TOTAL CAUCHY STRESS AND ELASTICITY TENSORS
sigma=zero
ddsigdde=zero
!----------------------------------------------------------------------
!------------------------ IDENTITY TENSORS ----------------------------
!----------------------------------------------------------------------
CALL onem(unit2,unit4,unit4s,ndi)
!----------------------------------------------------------------------
!------------------------ RANDOM GENERATION ---------------------------
!----------------------------------------------------------------------
!test_num = 50
!l_bound = 0.2
!h_bound = 0.8
!allocate (array(test_num))
!allocate (y(test_num))
!CALL timestamp(phrase)
!CALL phrtsd(phrase, seed1, seed2)
!CALL test_gennor(mean, sd, phrase, test_num, array)
!DO test=1, test_num 
!  y(test) = l_bound + (array(test) - minval(array))/(maxval(array) - minval(array)) * (h_bound-l_bound)
!END DO
!props(8) = y(1)
!write (*,*) props(8)
!----------------------------------------------------------------------
!------------------- MATERIAL CONSTANTS AND DATA ----------------------
!----------------------------------------------------------------------
!     VOLUMETRIC
k        = props(1)
!     ISOCHORIC ISOTROPIC
c10      = props(2)
c01      = props(3)
phi      = props(4)
!     FILAMENT
ll       = props(5)
r0f      = props(6)
r0c      = props(7)
etac     = props(8)
mu0      = props(9)
beta     = props(10)
b0       = props(11)
lambda0  = props(12)
filprops = props(5:12)
!     NONAFFINE NETWORK
nn       = props(13)
bb        = props(14)
affprops= props(13:14)


!     NUMERICAL COMPUTATIONS (nterm and factor were previously defined here - now in global)

!        STATE VARIABLES AND CHEMICAL PARAMETERS
IF ((time(1) == zero).AND.(kstep == 1)) THEN
  CALL initialize(statev)
END IF
!        READ STATEV
CALL sdvread(statev)
!----------------------------------------------------------------------
!---------------------------- KINEMATICS ------------------------------
!----------------------------------------------------------------------
!     DISTORTION GRADIENT
CALL fslip(dfgrd1,distgr,det,ndi)
!     INVERSE OF DEFORMATION GRADIENT
CALL matinv3d(dfgrd1,dfgrd1inv,ndi)
!     INVERSE OF DISTORTION GRADIENT
CALL matinv3d(distgr,distgrinv,ndi)
!     CAUCHY-GREEN DEFORMATION TENSORS
CALL deformation(dfgrd1,c,b,ndi)
CALL deformation(distgr,cbar,bbar,ndi)
!     INVARIANTS OF DEVIATORIC DEFORMATION TENSORS
CALL invariants(cbar,cbari1,cbari2,ndi)
!     STRETCH TENSORS
CALL stretch(cbar,bbar,ubar,vbar,ndi)
!     ROTATION TENSORS
CALL rotation(distgr,rot,ubar,ndi)
!----------------------------------------------------------------------
!--------------------- CONSTITUTIVE RELATIONS  ------------------------
!----------------------------------------------------------------------
!     DEVIATORIC PROJECTION TENSORS
CALL projeul(unit2,unit4s,proje,ndi)

CALL projlag(c,unit4,projl,ndi)

!---- VOLUMETRIC ------------------------------------------------------
!     STRAIN-ENERGY
CALL vol(ssev,pv,ppv,k,det)

!---- ISOCHORIC ISOTROPIC ---------------------------------------------
IF (phi < one) THEN
!     STRAIN-ENERGY
  CALL isomat(sseiso,diso,c10,c01,cbari1,cbari2)
!     PK2 'FICTICIOUS' STRESS TENSOR
  CALL pk2isomatfic(pkmatfic,diso,cbar,cbari1,unit2,ndi)
!     CAUCHY 'FICTICIOUS' STRESS TENSOR
  CALL sigisomatfic(sisomatfic,pkmatfic,distgr,det,ndi)
!     'FICTICIOUS' MATERIAL ELASTICITY TENSOR
  CALL cmatisomatfic(cmisomatfic,cbar,cbari1,cbari2, diso,unit2,unit4,det,ndi)
!     'FICTICIOUS' SPATIAL ELASTICITY TENSOR
  CALL csisomatfic(cisomatfic,cmisomatfic,distgr,det,ndi)
  
END IF
!---- FILAMENTS NETWORK -----------------------------------------------
!     IMAGINARY ERROR FUNCTION BASED ON DISPERSION PARAMETER
! CALL erfi(efi,bb,nterm) ! (original)
CALL erfi(efi,bb)
!     'FICTICIOUS' PK2 STRESS AND MATERIAL ELASTICITY TENSORS
!------------ AFFINE NETWORK --------------
IF (nn > zero) THEN
  ! CALL affclnetfic_discrete(snetficaf,cnetficaf,distgr,filprops,  &
  !     affprops,efi,noel,det,prefdir,ndi)
  CALL affclnetfic_discrete(snetficaf,cnetficaf,distgr,filprops,  &
      affprops,efi,noel,det,prefdir,ndi,etac_sdv)
END IF
!      PKNETFIC=PKNETFICNAF+PKNETFICAF
snetfic=snetficnaf+snetficaf
!      CMNETFIC=CMNETFICNAF+CMNETFICAF
cnetfic=cnetficnaf+cnetficaf
!----------------------------------------------------------------------
!     STRAIN-ENERGY
!      SSE=SSEV+SSEISO
!     PK2 'FICTICIOUS' STRESS
pkfic=(one-phi)*pkmatfic+pknetfic
!     CAUCHY 'FICTICIOUS' STRESS
sfic=(one-phi)*sisomatfic+snetfic
!     MATERIAL 'FICTICIOUS' ELASTICITY TENSOR
cmfic=(one-phi)*cmisomatfic+cmnetfic
!     SPATIAL 'FICTICIOUS' ELASTICITY TENSOR
cfic=(one-phi)*cisomatfic+cnetfic

!----------------------------------------------------------------------
!-------------------------- STRESS MEASURES ---------------------------
!----------------------------------------------------------------------

!---- VOLUMETRIC ------------------------------------------------------
!      PK2 STRESS
! CALL pk2vol(pkvol,pv,c,ndi)
CALL pk2vol(pkvol,pv,c,ndi,det)
!      CAUCHY STRESS
CALL sigvol(svol,pv,unit2,ndi)

!---- ISOCHORIC -------------------------------------------------------
!      PK2 STRESS
CALL pk2iso(pkiso,pkfic,projl,det,ndi)
!      CAUCHY STRESS
CALL sigiso(siso,sfic,proje,ndi)
!      ACTIVE CAUCHY STRESS
!      CALL SIGISO(SACTISO,SNETFICAF,PROJE,NDI)

!      CALL SPECTRAL(SACTISO,SACTVL,SACTVC)

!---- VOLUMETRIC + ISOCHORIC ------------------------------------------
!      PK2 STRESS
pk2 = pkvol + pkiso
!      CAUCHY STRESS
sigma = svol + siso

!----------------------------------------------------------------------
!-------------------- MATERIAL ELASTICITY TENSOR ----------------------
!----------------------------------------------------------------------

!---- VOLUMETRIC ------------------------------------------------------

!      CALL METVOL(CMVOL,C,PV,PPV,DET,NDI)

!---- ISOCHORIC -------------------------------------------------------

!      CALL METISO(CMISO,CMFIC,PROJL,PKISO,PKFIC,C,UNIT2,DET,NDI)

!----------------------------------------------------------------------

!      DDPKDDE=CMVOL+CMISO

!----------------------------------------------------------------------
!--------------------- SPATIAL ELASTICITY TENSOR ----------------------
!----------------------------------------------------------------------

!---- VOLUMETRIC ------------------------------------------------------

CALL setvol(cvol,pv,ppv,unit2,unit4s,ndi)

!---- ISOCHORIC -------------------------------------------------------

CALL setiso(ciso,cfic,proje,siso,sfic,unit2,ndi)

!-----JAUMMAN RATE ----------------------------------------------------

CALL setjr(cjr,sigma,unit2,ndi)

!----------------------------------------------------------------------

!     ELASTICITY TENSOR
ddsigdde=cvol+ciso+cjr


!----------------------------------------------------------------------
!------------------------- INDEX ALLOCATION ---------------------------
!----------------------------------------------------------------------
!     VOIGT NOTATION  - FULLY SIMMETRY IMPOSED
CALL indexx(stress,ddsdde,sigma,ddsigdde,ntens,ndi)

!----------------------------------------------------------------------
!--------------------------- STATE VARIABLES --------------------------
!----------------------------------------------------------------------
!     DO K1 = 1, NTENS
!      STATEV(1:27) = VISCOUS TENSORS
!CALL sdvwrite(det,statev)
CALL sdvwrite(det,etac_sdv,statev)
!     END DO
!----------------------------------------------------------------------
RETURN
END SUBROUTINE umat
!----------------------------------------------------------------------
!--------------------------- END OF UMAT ------------------------------
!----------------------------------------------------------------------

!----------------------------------------------------------------------
!----------------------- AUXILIAR SUBROUTINES -------------------------
!----------------------------------------------------------------------
!                         INPUT FILES
!----------------------------------------------------------------------

!----------------------------------------------------------------------
!                         KINEMATIC QUANTITIES
!----------------------------------------------------------------------
!----------------------------------------------------------------------
!                         STRESS TENSORS
!----------------------------------------------------------------------
!----------------------------------------------------------------------
!                   LINEARISED ELASTICITY TENSORS
!----------------------------------------------------------------------


!----------------------------------------------------------------------
!----------------------------------------------------------------------
!----------------------------------------------------------------------
!----------------------- UTILITY SUBROUTINES --------------------------
!----------------------------------------------------------------------

SUBROUTINE stretch(c,b,u,v,ndi)



!>    STRETCH TENSORS

use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: ndi

DOUBLE PRECISION, INTENT(IN OUT)         :: c(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: b(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: u(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: v(ndi,ndi)




DOUBLE PRECISION :: eigval(ndi),omega(ndi),eigvec(ndi,ndi)

CALL spectral(c,omega,eigvec)

eigval(1) = DSQRT(omega(1))
eigval(2) = DSQRT(omega(2))
eigval(3) = DSQRT(omega(3))

u(1,1) = eigval(1)
u(2,2) = eigval(2)
u(3,3) = eigval(3)

u = matmul(matmul(eigvec,u),transpose(eigvec))

CALL spectral(b,omega,eigvec)

eigval(1) = DSQRT(omega(1))
eigval(2) = DSQRT(omega(2))
eigval(3) = DSQRT(omega(3))
!      write(*,*) eigvec(1,1),eigvec(2,1),eigvec(3,1)

v(1,1) = eigval(1)
v(2,2) = eigval(2)
v(3,3) = eigval(3)

v = matmul(matmul(eigvec,v),transpose(eigvec))
RETURN
END SUBROUTINE stretch
SUBROUTINE initialize(statev)
use global
IMPLICIT NONE

!      DOUBLE PRECISION TIME(2),KSTEP
INTEGER :: pos1, i
DOUBLE PRECISION, INTENT(OUT)            :: statev(nsdv)


pos1=0
!       DETERMINANT
statev(pos1+1)=one
!       CL RELATIVE STIFFNESS
DO i = pos1+2, nsdv
    statev(i)=zero
END DO
!        CONTRACTION VARIANCE
!statev(pos1+2)=zero

RETURN

END SUBROUTINE initialize
!****************************************************************************



!     Utility subroutines
!****************************************************************************
!***************************************************************************

SUBROUTINE matinv3dd(a,a_inv,det_a,istat)
!
! Returns A_inv, the inverse and det_A, the determinant
! Note that the det is of the original matrix, not the
! inverse
!
use global

real(8), INTENT(IN)                       :: a(3,3)
real(8), INTENT(OUT)                      :: a_inv(3,3)
real(8), INTENT(OUT)                      :: det_a
INTEGER, INTENT(OUT)                     :: istat

!

!
real(8)  det_a_inv
!
istat = 1

det_a = a(1,1)*(a(2,2)*a(3,3) - a(3,2)*a(2,3)) -  &
    a(2,1)*(a(1,2)*a(3,3) - a(3,2)*a(1,3)) +  &
    a(3,1)*(a(1,2)*a(2,3) - a(2,2)*a(1,3))

IF (det_a <= 0.d0) THEN
  WRITE(*,*) 'WARNING: subroutine matInv3Dd:'
  WRITE(*,*) 'WARNING: det of mat=',det_a
  istat = 0
  RETURN
END IF
!
det_a_inv = 1.d0/det_a
!
a_inv(1,1) = det_a_inv*(a(2,2)*a(3,3)-a(3,2)*a(2,3))
a_inv(1,2) = det_a_inv*(a(3,2)*a(1,3)-a(1,2)*a(3,3))
a_inv(1,3) = det_a_inv*(a(1,2)*a(2,3)-a(2,2)*a(1,3))
a_inv(2,1) = det_a_inv*(a(3,1)*a(2,3)-a(2,1)*a(3,3))
a_inv(2,2) = det_a_inv*(a(1,1)*a(3,3)-a(3,1)*a(1,3))
a_inv(2,3) = det_a_inv*(a(2,1)*a(1,3)-a(1,1)*a(2,3))
a_inv(3,1) = det_a_inv*(a(2,1)*a(3,2)-a(3,1)*a(2,2))
a_inv(3,2) = det_a_inv*(a(3,1)*a(1,2)-a(1,1)*a(3,2))
a_inv(3,3) = det_a_inv*(a(1,1)*a(2,2)-a(2,1)*a(1,2))
!
RETURN
END SUBROUTINE matinv3dd
!!!

SUBROUTINE matinv2d(a,a_inv,det_a,istat)
!
! Returns A_inv, the inverse, and det_A, the determinant
! Note that the det is of the original matrix, not the
! inverse
!
use global

real(8), INTENT(IN)                       :: a(2,2)
real(8), INTENT(OUT)                      :: a_inv(2,2)
real(8), INTENT(OUT)                      :: det_a
INTEGER, INTENT(OUT)                     :: istat

!

!
real(8)  det_a_inv


istat = 1

det_a = a(1,1)*a(2,2) - a(1,2)*a(2,1)

IF (det_a <= 0.d0) THEN
  WRITE(*,*) 'WARNING: subroutine matInv2D:'
  WRITE(*,*) 'WARNING: det of mat=',det_a
  istat = 0
  RETURN
END IF

det_a_inv = 1.d0/det_a

a_inv(1,1) =  det_a_inv*a(2,2)
a_inv(1,2) = -det_a_inv*a(1,2)
a_inv(2,1) = -det_a_inv*a(2,1)
a_inv(2,2) =  det_a_inv*a(1,1)


RETURN
END SUBROUTINE matinv2d

!****************************************************************************

SUBROUTINE mdet(a,det)
!
! This subroutine calculates the determinant
! of a 3 by 3 matrix [A]
!
use global

real(8), INTENT(IN)                       :: a(3,3)
real(8), INTENT(OUT)                      :: det

!



det = a(1,1)*a(2,2)*a(3,3) + a(1,2)*a(2,3)*a(3,1)  &
    + a(1,3)*a(2,1)*a(3,2) - a(3,1)*a(2,2)*a(1,3)  &
    - a(3,2)*a(2,3)*a(1,1) - a(3,3)*a(2,1)*a(1,2)


RETURN
END SUBROUTINE mdet

!****************************************************************************

SUBROUTINE onem0(a)
!
! This subroutine stores the identity matrix in the
! 3 by 3 matrix [A]
!
use global

real(8), INTENT(OUT)                      :: a(3,3)

!
INTEGER :: i,j
!



DO i=1,3
  DO j=1,3
    IF (i == j) THEN
      a(i,j) = 1.0
    ELSE
      a(i,j) = 0.0
    END IF
  END DO
END DO


RETURN
END SUBROUTINE onem0
!***************************************************************************
! SUBROUTINE erfi(erf,b,nterm) (original)
SUBROUTINE erfi(erf,b)


!>    IMAGINARY ERROR FUNCTION OF SQRT(B); B IS THE DISPERSION PARAM
use global
IMPLICIT NONE

DOUBLE PRECISION, INTENT(OUT)            :: erf
DOUBLE PRECISION, INTENT(IN OUT)         :: b
! INTEGER, INTENT(IN)                      :: nterm (original)


DOUBLE PRECISION :: pi
DOUBLE PRECISION :: aux,aux1,aux2,aux3,aux4,fact
INTEGER :: i1,j1

pi=four*ATAN(one)
aux=SQRT(two*b)
aux1=two*aux
aux2=(two/three)*(aux**three)
aux4=zero
DO j1=3,nterm
  i1=j1-1
  CALL factorial (fact,i1)
  aux3=two*j1-one
  aux4=aux4+(aux**aux3)/(half*aux3*fact)
END DO

erf=pi**(-one/two)*(aux1+aux2+aux4)
RETURN
END SUBROUTINE erfi
SUBROUTINE sigisomatfic(sfic,pkfic,f,det,ndi)



!>    ISOTROPIC MATRIX:  ISOCHORIC CAUCHY STRESS
use global
IMPLICIT NONE


INTEGER, INTENT(IN OUT)                  :: ndi
DOUBLE PRECISION, INTENT(IN OUT)         :: sfic(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: pkfic(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: det





CALL push2(sfic,pkfic,f,det,ndi)

RETURN
END SUBROUTINE sigisomatfic
SUBROUTINE pullforce(zero0, a, b, machep, t,  &
        lambda,lambda0,l,r0,mu0,beta,b0)



!>    SINGLE FILAMENT: COMPUTES PULLING FORCE FOR A GIVEN STRETCH
!*********************************************************************72

!     ZERO SEEKS THE ROOT OF A FUNCTION F(X) IN AN INTERVAL [A,B].

!     DISCUSSION:

!     THE INTERVAL [A,B] MUST BE A CHANGE OF SIGN INTERVAL FOR F.
!     THAT IS, F(A) AND F(B) MUST BE OF OPPOSITE SIGNS.  THEN
!     ASSUMING THAT F IS CONTINUOUS IMPLIES THE EXISTENCE OF AT LEAST
!     ONE VALUE C BETWEEN A AND B FOR WHICH F(C) = 0.

!     THE LOCATION OF THE ZERO IS DETERMINED TO WITHIN AN ACCURACY
!     OF 6 * MACHEPS * ABS ( C ) + 2 * T.


!     LICENSING:

!     THIS CODE IS DISTRIBUTED UNDER THE GNU LGPL LICENSE.

!     MODIFIED:

!     11 FEBRUARY 2013

!     AUTHOR:

!     RICHARD BRENT
!     MODIFICATIONS BY JOHN BURKARDT

!     REFERENCE:

!     RICHARD BRENT,
!     ALGORITHMS FOR MINIMIZATION WITHOUT DERIVATIVES,
!     DOVER, 2002,
!     ISBN: 0-486-41998-3,
!     LC: QA402.5.B74.

!     PARAMETERS:

!     INPUT, DOUBLE PRECISION A, B, THE ENDPOINTS OF THE CHANGE OF SIGN
!     INTERVAL.
!     INPUT, DOUBLE PRECISION MACHEP, AN ESTIMATE FOR THE RELATIVE
!     MACHINE PRECISION.

!     INPUT, DOUBLE PRECISION T, A POSITIVE ERROR TOLERANCE.

!     INPUT, EXTERNAL DOUBLE PRECISION F, THE NAME OF A USER-SUPPLIED
!     FUNCTION, OF THE FORM "FUNCTION G ( F )", WHICH EVALUATES THE
!     FUNCTION WHOSE ZERO IS BEING SOUGHT.

!     OUTPUT, DOUBLE PRECISION ZERO, THE ESTIMATED VALUE OF A ZERO OF
!     THE FUNCTION G.
use global

DOUBLE PRECISION, INTENT(OUT)            :: zero0
DOUBLE PRECISION, INTENT(IN)             :: a
DOUBLE PRECISION, INTENT(IN)             :: b
DOUBLE PRECISION, INTENT(IN)             :: machep
DOUBLE PRECISION, INTENT(IN)             :: t
DOUBLE PRECISION, INTENT(IN OUT)         :: lambda
DOUBLE PRECISION, INTENT(IN OUT)         :: lambda0
DOUBLE PRECISION, INTENT(IN OUT)         :: l
DOUBLE PRECISION, INTENT(IN OUT)         :: r0
DOUBLE PRECISION, INTENT(IN OUT)         :: mu0
DOUBLE PRECISION, INTENT(IN OUT)         :: beta
DOUBLE PRECISION, INTENT(IN OUT)         :: b0
DOUBLE PRECISION :: c
DOUBLE PRECISION :: d
DOUBLE PRECISION :: e
DOUBLE PRECISION :: fa
DOUBLE PRECISION :: fb
DOUBLE PRECISION :: fc
DOUBLE PRECISION :: m

DOUBLE PRECISION :: p
DOUBLE PRECISION :: q
DOUBLE PRECISION :: r
DOUBLE PRECISION :: s
DOUBLE PRECISION :: sa
DOUBLE PRECISION :: sb

DOUBLE PRECISION :: tol




!     MAKE LOCAL COPIES OF A AND B.

sa = a
sb = b
CALL evalg(fa,sa,lambda,lambda0,l,r0,mu0,beta,b0)
CALL evalg(fb,sb,lambda,lambda0,l,r0,mu0,beta,b0)
!      FA = F ( SA )
!      FB = F ( SB )

10    CONTINUE

c = sa
fc = fa
e = sb - sa
d = e

20    CONTINUE

IF ( ABS ( fc ) < ABS ( fb ) ) THEN
  sa = sb
  sb = c
  c = sa
  fa = fb
  fb = fc
  fc = fa
END IF

30    CONTINUE

tol = 2.0D+00 * machep * ABS ( sb ) + t
m = 0.5D+00 * ( c - sb )
IF ( ABS ( m ) <= tol .OR. fb == 0.0D+00 ) GO TO 140
IF ( ABS ( e ) >= tol .AND. ABS ( fa ) > ABS ( fb ) ) GO TO 40

e = m
d = e
GO TO 100

40    CONTINUE

s = fb / fa
IF ( sa /= c ) GO TO 50

p = 2.0D+00 * m * s
q = 1.0D+00 - s
GO TO 60

50    CONTINUE

q = fa / fc
r = fb / fc
p = s * ( 2.0D+00 * m * q * ( q - r ) - ( sb - sa ) * ( r - 1.0D+00 ) )
q = ( q - 1.0D+00 ) * ( r - 1.0D+00 ) * ( s - 1.0D+00 )

60    CONTINUE

IF ( p <= 0.0D+00 ) GO TO 70

q = - q
GO TO 80

70    CONTINUE

p = - p

80    CONTINUE

s = e
e = d
IF ( 2.0D+00 * p >= 3.0D+00 * m * q - ABS ( tol * q ) .OR.  &
    p >= ABS ( 0.5D+00 * s * q ) ) GO TO 90

d = p / q
GO TO 100

90    CONTINUE

e = m
d = e

100   CONTINUE

sa = sb
fa = fb
IF ( ABS ( d ) <= tol ) GO TO 110
sb = sb + d
GO TO 130

110   CONTINUE

IF ( m <= 0.0D+00 ) GO TO 120
sb = sb + tol
GO TO 130

120   CONTINUE

sb = sb - tol

130   CONTINUE

!      FB = F ( SB )
CALL evalg(fb,sb,lambda,lambda0,l,r0,mu0,beta,b0)
IF ( fb > 0.0D+00 .AND. fc > 0.0D+00 ) GO TO 10
IF ( fb <= 0.0D+00 .AND. fc <= 0.0D+00 ) GO TO 10
GO TO 20

140   CONTINUE

zero0 = sb

RETURN
END SUBROUTINE pullforce

!*********************************************************************72
SUBROUTINE sigvol(svol,pv,unit2,ndi)



!>    VOLUMETRIC CAUCHY STRESS

use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: svol(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pv
DOUBLE PRECISION, INTENT(IN)             :: unit2(ndi,ndi)



INTEGER :: i1,j1



DO i1=1,ndi
  DO j1=1,ndi
    svol(i1,j1)=pv*unit2(i1,j1)
  END DO
END DO

RETURN
END SUBROUTINE sigvol
SUBROUTINE visco(pk,cmat,vv,pkvol,pkiso,cmatvol,cmatiso,dtime,  &
        vscprops,statev,ndi)



!>    VISCOUS DISSIPATION: MAXWELL SPRINGS AND DASHPOTS SCHEME
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: pk(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: cmat(ndi,ndi,ndi,ndi)
INTEGER, INTENT(IN)                      :: vv
DOUBLE PRECISION, INTENT(IN)             :: pkvol(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pkiso(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: cmatvol(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: cmatiso(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: dtime
DOUBLE PRECISION, INTENT(IN)             :: vscprops(6)
DOUBLE PRECISION, INTENT(IN OUT)         :: statev(nsdv)



INTEGER :: i1,j1,k1,l1, v1

DOUBLE PRECISION :: q(ndi,ndi),qv(ndi,ndi),hv(ndi,ndi), hv0(ndi,ndi)
DOUBLE PRECISION :: teta,tau,aux,auxc

q=zero
qv=zero
hv=zero
auxc=zero

!     ( GENERAL MAXWELL DASHPOTS)
DO v1=1,vv
  
  tau=vscprops(2*v1-1)
  teta=vscprops(2*v1)
  
!      READ STATE VARIABLES
  CALL hvread(hv,statev,v1,ndi)
  hv0=hv
!        RALAXATION TENSORS
  CALL relax(qv,hv,aux,hv0,pkiso,dtime,tau,teta,ndi)
  auxc=auxc+aux
!        WRITE STATE VARIABLES
  CALL hvwrite(statev,hv,v1,ndi)
  
  q=q+qv
  
END DO

auxc=one+auxc
pk=pkvol+pkiso


DO i1=1,ndi
  DO j1=1,ndi
    pk(i1,j1)=pk(i1,j1)+q(i1,j1)
    DO k1=1,ndi
      DO l1=1,ndi
        cmat(i1,j1,k1,l1)= cmatvol(i1,j1,k1,l1)+ auxc*cmatiso(i1,j1,k1,l1)
      END DO
    END DO
  END DO
END DO



RETURN
END SUBROUTINE visco
SUBROUTINE sigfilfic(sfic,rho,lambda,dw,m,rw,ndi)



!>    SINGLE FILAMENT:  'FICTICIOUS' CAUCHY STRESS
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi !number of dimensions
DOUBLE PRECISION, INTENT(OUT)            :: sfic(ndi,ndi) !ficticious cauchy stress 
DOUBLE PRECISION, INTENT(IN)             :: rho  !angular density at m
DOUBLE PRECISION, INTENT(IN)             :: lambda !filament stretch
DOUBLE PRECISION, INTENT(IN)             :: dw !derivative of filament strain energy
DOUBLE PRECISION, INTENT(IN)             :: m(ndi) !direction vector
DOUBLE PRECISION, INTENT(IN)             :: rw ! integration weights


INTEGER :: i1,j1

DOUBLE PRECISION :: aux

aux=rho*lambda**(-one)*rw*dw
DO i1=1,ndi
  DO j1=1,ndi
    sfic(i1,j1)=aux*m(i1)*m(j1)
  END DO
END DO

RETURN
END SUBROUTINE sigfilfic
SUBROUTINE hvread(hv,statev,v1,ndi)



!>    VISCOUS DISSIPATION: READ STATE VARS
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: ndi

DOUBLE PRECISION, INTENT(OUT)            :: hv(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: statev(nsdv)
INTEGER, INTENT(IN)                      :: v1



INTEGER :: pos


pos=9*v1-9
hv(1,1)=statev(1+pos)
hv(1,2)=statev(2+pos)
hv(1,3)=statev(3+pos)
hv(2,1)=statev(4+pos)
hv(2,2)=statev(5+pos)
hv(2,3)=statev(6+pos)
hv(3,1)=statev(7+pos)
hv(3,2)=statev(8+pos)
hv(3,3)=statev(9+pos)

RETURN

END SUBROUTINE hvread
SUBROUTINE hvwrite(statev,hv,v1,ndi)



!>    VISCOUS DISSIPATION: WRITE STATE VARS
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: statev(nsdv)
DOUBLE PRECISION, INTENT(IN)             :: hv(ndi,ndi)
INTEGER, INTENT(IN)                      :: v1



INTEGER :: pos


pos=9*v1-9
statev(1+pos)=hv(1,1)
statev(2+pos)=hv(1,2)
statev(3+pos)=hv(1,3)
statev(4+pos)=hv(2,1)
statev(5+pos)=hv(2,2)
statev(6+pos)=hv(2,3)
statev(7+pos)=hv(3,1)
statev(8+pos)=hv(3,2)
statev(9+pos)=hv(3,3)

RETURN

END SUBROUTINE hvwrite

subroutine icos_shape ( point_num, edge_num, face_num, face_order_max, &
  point_coord, edge_point, face_order, face_point )

!*****************************************************************************80
!
!! ICOS_SHAPE describes an icosahedron.
!
!  Discussion:
!
!    The input data required for this routine can be retrieved from ICOS_SIZE.
!
!    The vertices lie on the unit sphere.
!
!    The dual of an icosahedron is a dodecahedron.
!
!    The data has been rearranged from a previous assignment.  
!    The STRIPACK program refuses to triangulate data if the first
!    three nodes are "collinear" on the sphere.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    22 July 2007
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) POINT_NUM, the number of points (12).
!
!    Input, integer ( kind = 4 ) EDGE_NUM, the number of edges (30).
!
!    Input, integer ( kind = 4 ) FACE_NUM, the number of faces (20).
!
!    Input, integer ( kind = 4 ) FACE_ORDER_MAX, the maximum number of 
!    vertices per face (3).
!
!    Output, real ( kind = 8 ) POINT_COORD(3,POINT_NUM), the points.
!
!    Output, integer ( kind = 4 ) EDGE_POINT(2,EDGE_NUM), the points that 
!    make up each edge, listed in ascending order of their indexes.
!
!    Output, integer ( kind = 4 ) FACE_ORDER(FACE_NUM), the number of vertices
!    per face.
!
!    Output, integer ( kind = 4 ) FACE_POINT(FACE_ORDER_MAX,FACE_NUM); 
!    FACE_POINT(I,J) is the index of the I-th point in the J-th face.  The
!    points are listed in the counter clockwise direction defined
!    by the outward normal at the face.  The nodes of each face are ordered 
!    so that the lowest index occurs first.  The faces are then sorted by
!    nodes.
!
  use global

  integer ( kind = 4 ) edge_num
  integer ( kind = 4 ), parameter :: edge_order = 2
  integer ( kind = 4 ) face_num
  integer ( kind = 4 ) face_order_max
  integer ( kind = 4 ) point_num

  real ( kind = 8 ) a
  real ( kind = 8 ) b
  integer ( kind = 4 ) edge_point(edge_order,edge_num)
  integer ( kind = 4 ) face_order(face_num)
  integer ( kind = 4 ) face_point(face_order_max,face_num)
  real ( kind = 8 ) phi
  real ( kind = 8 ) point_coord(3,point_num)
  real ( kind = 8 ) z
!
!  Set the point coordinates.
!
  phi = 0.5D+00 * ( sqrt ( 5.0D+00 ) + 1.0D+00 )

  a = phi / sqrt ( 1.0D+00 + phi * phi )
  b = 1.0D+00 / sqrt ( 1.0D+00 + phi * phi )
  z = 0.0D+00
!
!  A*A + B*B + Z*Z = 1.
!
  point_coord(1:3,1:point_num) = reshape ( (/ &
      a,  b,  z, &
      a, -b,  z, &
      b,  z,  a, &
      b,  z, -a, &
      z,  a,  b, &
      z,  a, -b, &
      z, -a,  b, &
      z, -a, -b, &
     -b,  z,  a, &
     -b,  z, -a, &
     -a,  b,  z, &
     -a, -b,  z /), (/ 3, point_num /) )
!
!  Set the edges.
!
  edge_point(1:edge_order,1:edge_num) = reshape ( (/ &
     1,  2, &
     1,  3, &
     1,  4, &
     1,  5, &
     1,  6, &
     2,  3, &
     2,  4, &
     2,  7, &
     2,  8, &
     3,  5, &
     3,  7, &
     3,  9, &
     4,  6, &
     4,  8, &
     4, 10, &
     5,  6, &
     5,  9, &
     5, 11, &
     6, 10, &
     6, 11, &
     7,  8, &
     7,  9, &
     7, 12, &
     8, 10, &
     8, 12, &
     9, 11, &
     9, 12, &
    10, 11, &
    10, 12, &
    11, 12 /), (/ edge_order, edge_num /) )
!
!  Set the face orders.
!
  face_order(1:face_num) = (/ &
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3, &
    3, 3, 3, 3, 3, 3, 3, 3, 3, 3 /)
!
!  Set the faces.
!
  face_point(1:face_order_max,1:face_num) = reshape ( (/ &
     1,  2,  4, &
     1,  3,  2, &
     1,  4,  6, &
     1,  5,  3, &
     1,  6,  5, &
     2,  3,  7, &
     2,  7,  8, &
     2,  8,  4, &
     3,  5,  9, &
     3,  9,  7, &
     4,  8, 10, &
     4, 10,  6, &
     5,  6, 11, &
     5, 11,  9, &
     6, 10, 11, &
     7,  9, 12, &
     7, 12,  8, &
     8, 12, 10, &
     9, 11, 12, &
    10, 12, 11 /), (/ face_order_max, face_num /) )

  return
end
subroutine icos_size ( point_num, edge_num, face_num, face_order_max )
!*****************************************************************************80
!
!! ICOS_SIZE gives "sizes" for an icosahedron in 3D.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    19 July 2007
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Output, integer ( kind = 4 ) POINT_NUM, the number of points.
!
!    Output, integer ( kind = 4 ) EDGE_NUM, the number of edges.
!
!    Output, integer ( kind = 4 ) FACE_NUM, the number of faces.
!
!    Output, integer ( kind = 4 ) FACE_ORDER_MAX, the maximum order of any face.
!
  use global

  integer ( kind = 4 ) edge_num
  integer ( kind = 4 ) face_num
  integer ( kind = 4 ) face_order_max
  integer ( kind = 4 ) point_num

  point_num = 12
  edge_num = 30
  face_num = 20
  face_order_max = 3

  return
end

subroutine sphere01_triangle_project ( a_xyz, b_xyz, c_xyz, f1, f2, f3, &
  node_xyz )

!*****************************************************************************80
!
!! SPHERE01_TRIANGLE_PROJECT projects from plane to spherical triangle.
!
!  Discussion:
!
!    We assume that points A, B and C lie on the unit sphere, and they
!    thus define a spherical triangle.
!
!    They also, of course, define a planar triangle.
!
!    Let (F1,F2,F3) be the barycentric coordinates of a point in this 
!    planar triangle.
!
!    This function determines the coordinates of the point in the planar
!    triangle identified by the barycentric coordinates, and returns the
!    coordinates of the projection of that point onto the unit sphere.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    21 September 2010
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) A_XYZ(3), B_XYZ(3), C_XYZ(3), the coordinates
!    of the points A, B, and C.
!
!    Input, integer ( kind = 4 ) F1, F2, F3, the barycentric coordinates
!    of a point in the triangle ABC.  Normally, these coordinates would
!    be real numbers, and would sum to 1.  For convenience, we allow these
!    to be integers which must be divided by F1+F2+F3.
!
!    Output, real ( kind = 8 ) NODE_XYZ(3), the coordinates of the 
!    point on the unit sphere which is the projection of the point on the plane
!    whose barycentric coordinates with respect to A, B, and C is
!    (F1,F2,F3)/(F1+F2+F3).
!
  use global

  real ( kind = 8 ) a_xyz(3)
  real ( kind = 8 ) b_xyz(3)
  real ( kind = 8 ) c_xyz(3)
  integer ( kind = 4 ) f1
  integer ( kind = 4 ) f2
  integer ( kind = 4 ) f3
  real ( kind = 8 ) node_norm
  real ( kind = 8 ) node_xyz(3)
  real ( kind = 8 ) r8vec_norm

  node_xyz(1:3) = &
    ( real ( f1,           kind = 8 ) * a_xyz(1:3)   &
    + real (      f2,      kind = 8 ) * b_xyz(1:3)   &
    + real (           f3, kind = 8 ) * c_xyz(1:3) ) &
    / real ( f1 + f2 + f3, kind = 8 )

  node_norm = r8vec_norm ( 3, node_xyz(1:3) )

  node_xyz(1:3) = node_xyz(1:3) / node_norm

  return
end

subroutine sphere01_triangle_vertices_to_sides ( v1, v2, v3, as, bs, cs )

!*****************************************************************************80
!
!! SPHERE01_TRIANGLE_VERTICES_TO_SIDES computes spherical triangle sides.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    09 June 2002
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) V1(3), V2(3), V3(3), the vertices of the spherical
!    triangle.
!
!    Output, real ( kind = 8 ) AS, BS, CS, the (geodesic) length of the 
!    sides of the triangle.
!
  use global

  real ( kind = 8 ) as
  real ( kind = 8 ) bs
  real ( kind = 8 ) cs
  real ( kind = 8 ) v1(3)
  real ( kind = 8 ) v2(3)
  real ( kind = 8 ) v3(3)

  as = acos ( dot_product ( v2(1:3), v3(1:3) ) )
  bs = acos ( dot_product ( v3(1:3), v1(1:3) ) )
  cs = acos ( dot_product ( v1(1:3), v2(1:3) ) )

  return
end




subroutine sphere01_triangle_sides_to_angles ( as, bs, cs, a, b, c )

!*****************************************************************************80
!
!! SPHERE01_TRIANGLE_SIDES_TO_ANGLES computes spherical triangle angles.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    09 June 2002
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) AS, BS, CS, the (geodesic) length of the 
!    sides of the triangle.
!
!    Output, real ( kind = 8 ) A, B, C, the spherical angles of the triangle.
!    Angle A is opposite the side of length AS, and so on.
!
  use global

  real ( kind = 8 ) a
  real ( kind = 8 ) as
  real ( kind = 8 ) asu
  real ( kind = 8 ) b
  real ( kind = 8 ) bs
  real ( kind = 8 ) bsu
  real ( kind = 8 ) c
  real ( kind = 8 ) cs
  real ( kind = 8 ) csu
  real ( kind = 8 ) ssu
  real ( kind = 8 ) tan_a2
  real ( kind = 8 ) tan_b2
  real ( kind = 8 ) tan_c2

  asu = as
  bsu = bs
  csu = cs
  ssu = ( asu + bsu + csu ) / 2.0D+00

  tan_a2 = sqrt ( ( sin ( ssu - bsu ) * sin ( ssu - csu ) ) / &
                  ( sin ( ssu ) * sin ( ssu - asu )     ) )

  a = 2.0D+00 * atan ( tan_a2 )

  tan_b2 = sqrt ( ( sin ( ssu - asu ) * sin ( ssu - csu ) ) / &
                  ( sin ( ssu ) * sin ( ssu - bsu )     ) )

  b = 2.0D+00 * atan ( tan_b2 )

  tan_c2 = sqrt ( ( sin ( ssu - asu ) * sin ( ssu - bsu ) ) / &
                  ( sin ( ssu ) * sin ( ssu - csu )     ) )

  c = 2.0D+00 * atan ( tan_c2 )

  return
end
subroutine sphere01_triangle_vertices_to_area ( v1, v2, v3, area )

!*****************************************************************************80
!
!! SPHERE01_TRIANGLE_VERTICES_TO_AREA computes the area of a spherical triangle.
!
!  Discussion:
!
!    A sphere in 3D satisfies the equation:
!
!      X^2 + Y^2 + Z^2 = 1
!
!    A spherical triangle is specified by three points on the surface
!    of the sphere.
!
!    The area formula is known as Girard's formula.
!
!    The area of a spherical triangle is:
!
!      AREA = ( A + B + C - PI )
!
!    where A, B and C are the (surface) angles of the triangle.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    09 June 2002
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) V1(3), V2(3), V3(3), the vertices of the triangle.
!
!    Output, real ( kind = 8 ) AREA, the area of the sphere.
!
  use global

  real ( kind = 8 ) area
  real ( kind = 8 ) a
  real ( kind = 8 ) as
  real ( kind = 8 ) b
  real ( kind = 8 ) bs
  real ( kind = 8 ) c
  real ( kind = 8 ) cs
  real ( kind = 8 ) v1(3)
  real ( kind = 8 ) v2(3)
  real ( kind = 8 ) v3(3)
!
!  Compute the lengths of the sides of the spherical triangle.
!
  call sphere01_triangle_vertices_to_sides ( v1, v2, v3, as, bs, cs )
!
!  Get the spherical angles.
!
  call sphere01_triangle_sides_to_angles ( as, bs, cs, a, b, c )
!
!  Get the area.
!
  call sphere01_triangle_angles_to_area ( a, b, c, area )

  return
end


subroutine sphere01_triangle_angles_to_area ( a, b, c, area )

!*****************************************************************************80
!
!! SPHERE01_TRIANGLE_ANGLES_TO_AREA computes the area of a spherical triangle.
!
!  Discussion:
!
!    A unit sphere in 3D satisfies the equation:
!
!      X^2 + Y^2 + Z^2 = 1
!
!    A spherical triangle is specified by three points on the surface
!    of the sphere.
!
!    The area formula is known as Girard's formula.
!
!    The area of a spherical triangle is:
!
!      AREA = ( A + B + C - PI )
!
!    where A, B and C are the (surface) angles of the triangle.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    09 June 2002
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, real ( kind = 8 ) A, B, C, the angles of the triangle.
!
!    Output, real ( kind = 8 ) AREA, the area of the sphere.
!
  use global

  real ( kind = 8 ) area
  real ( kind = 8 ) a
  real ( kind = 8 ) b
  real ( kind = 8 ) c
  real ( kind = 8 ), parameter :: pi = 3.141592653589793D+00
!
!  Apply Girard's formula.
!
  area = a + b + c - pi

  return
end

subroutine polyterm_exponent ( action, e )

!*****************************************************************************80
!
!! POLYTERM_EXPONENT gets or sets the exponents for the polynomial term.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    08 June 2002
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = 3 ) ACTION.
!    'GET' asks the routine to return the current values in E.
!    'SET' asks the routine to set the current values to E.
!
!    Input/output, integer ( kind = 4 ) E(3), storage used to set or get values.
!
  use global

  character ( len = * )  action
  integer   ( kind = 4 ) e(3)
  integer   ( kind = 4 ), save, dimension ( 3 ) :: e_save = (/ 0, 0, 0 /)
  character ( len = 80 ) text
  character ( len = 80 ) text2

  if ( action(1:1) == 'G' ) then

    e(1:3) = e_save(1:3)

  else if ( action(1:1) == 'P' ) then

    write ( *, '(a)' ) ' '

    if ( all ( e_save(1:3) == 0 ) ) then

      text = 'P(X,Y,Z) = 1'

    else

      text = 'P(X,Y,Z) = '

      if ( e_save(1) == 0 ) then

      else if ( e_save(1) == 1 ) then

        call s_cat ( text, ' X', text )

      else

        call s_cat ( text, ' X^', text )

        write ( text2, '(i2)' ) e_save(1)
        text2 = adjustl ( text2 )
        call s_cat ( text, text2, text )

      end if

      if ( e_save(2) == 0 ) then

      else if ( e_save(2) == 1 ) then

        call s_cat ( text, ' Y', text )

      else

        call s_cat ( text, ' Y^', text )

        write ( text2, '(i2)' ) e_save(2)
        text2 = adjustl ( text2 )
        call s_cat ( text, text2, text )

      end if
       
      if ( e_save(3) == 0 ) then

      else if ( e_save(3) == 1 ) then

        call s_cat ( text, ' Z', text )

      else

        call s_cat ( text, ' Z^', text )

        write ( text2, '(i2)' ) e_save(3)
        text2 = adjustl ( text2 )
        call s_cat ( text, text2, text )

      end if
 
    end if

    write ( *, '(a)' ) trim ( text )
    
  else if ( action(1:1) == 'S' ) then

    e_save(1:3) = e(1:3)

  end if

  return
end
subroutine polyterm_value_3d ( n, x, f )

!*****************************************************************************80
!
!! POLYTERM_VALUE_3D evaluates a single polynomial term in 3D.
!
!  Discussion:
!
!    The polynomial term has the form:
!
!      F(X) = X(1)^E(1) * X(2)^E(2) * X(3)^E(3)
!
!    The exponents E(1:3) are set by calling POLYTERM_EXPONENT.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    13 September 2010
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of points.
!
!    Input, real ( kind = 8 ) X(3,N), the points where the polynomial term 
!    is to be evaluated.
!
!    Output, real ( kind = 8 ) F(N), the value of the polynomial term.
!
  use global

  integer ( kind = 4 ) n

  integer ( kind = 4 ) e(3)
  real ( kind = 8 ) f(n)
  integer ( kind = 4 ) i
  real ( kind = 8 ) x(3,n)

  call polyterm_exponent ( 'GET', e )

  f(1:n) = 1.0D+00

  do i = 1, 3

    if ( e(i) /= 0 ) then
      f(1:n) = f(1:n) * x(i,1:n)**e(i)
    end if

  end do
  
  return
end

function r8_gamma ( x )

!*****************************************************************************80
!
!! R8_GAMMA evaluates Gamma(X) for a real argument.
!
!  Discussion:
!
!    This routine calculates the gamma function for a real argument X.
!
!    Computation is based on an algorithm outlined in reference 1.
!    The program uses rational functions that approximate the gamma
!    function to at least 20 significant decimal digits.  Coefficients
!    for the approximation over the interval (1,2) are unpublished.
!    Those for the approximation for 12 <= X are from reference 2.
!
!  Modified:
!
!    11 February 2008
!
!  Author:
!
!    Original FORTRAN77 version by William Cody, Laura Stoltz.
!    FORTRAN90 version by John Burkardt.
!
!  Reference:
!
!    William Cody,
!    An Overview of Software Development for Special Functions,
!    in Numerical Analysis Dundee, 1975,
!    edited by GA Watson,
!    Lecture Notes in Mathematics 506,
!    Springer, 1976.
!
!    John Hart, Ward Cheney, Charles Lawson, Hans Maehly,
!    Charles Mesztenyi, John Rice, Henry Thatcher,
!    Christoph Witzgall,
!    Computer Approximations,
!    Wiley, 1968,
!    LC: QA297.C64.
!
!  Parameters:
!
!    Input, real ( kind = 8 ) X, the argument of the function.
!
!    Output, real ( kind = 8 ) R8_GAMMA, the value of the function.
!
  use global

  real ( kind = 8 ), dimension ( 7 ) :: c = (/ &
   -1.910444077728D-03, &
    8.4171387781295D-04, &
   -5.952379913043012D-04, &
    7.93650793500350248D-04, &
   -2.777777777777681622553D-03, &
    8.333333333333333331554247D-02, &
    5.7083835261D-03 /)
  real ( kind = 8 ), parameter :: eps = 2.22D-16
  real ( kind = 8 ) fact
  integer ( kind = 4 ) i
  integer ( kind = 4 ) n
  real ( kind = 8 ), dimension ( 8 ) :: p = (/ &
    -1.71618513886549492533811D+00, &
     2.47656508055759199108314D+01, &
    -3.79804256470945635097577D+02, &
     6.29331155312818442661052D+02, &
     8.66966202790413211295064D+02, &
    -3.14512729688483675254357D+04, &
    -3.61444134186911729807069D+04, &
     6.64561438202405440627855D+04 /)
  logical parity
  real ( kind = 8 ), parameter :: pi = 3.1415926535897932384626434D+00
  real ( kind = 8 ), dimension ( 8 ) :: q = (/ &
    -3.08402300119738975254353D+01, &
     3.15350626979604161529144D+02, &
    -1.01515636749021914166146D+03, &
    -3.10777167157231109440444D+03, &
     2.25381184209801510330112D+04, &
     4.75584627752788110767815D+03, &
    -1.34659959864969306392456D+05, &
    -1.15132259675553483497211D+05 /)
  real ( kind = 8 ) r8_gamma
  real ( kind = 8 ) res
  real ( kind = 8 ), parameter :: sqrtpi = 0.9189385332046727417803297D+00
  real ( kind = 8 ) sum
  real ( kind = 8 ) x
  real ( kind = 8 ), parameter :: xbig = 171.624D+00
  real ( kind = 8 ) xden
  real ( kind = 8 ), parameter :: xinf = 1.0D+30
  real ( kind = 8 ), parameter :: xminin = 2.23D-308
  real ( kind = 8 ) xnum
  real ( kind = 8 ) y
  real ( kind = 8 ) y1
  real ( kind = 8 ) ysq
  real ( kind = 8 ) z

  parity = .false.
  fact = 1.0D+00
  n = 0
  y = x
!
!  Argument is negative.
!
  if ( y <= 0.0D+00 ) then

    y = - x
    y1 = aint ( y )
    res = y - y1

    if ( res /= 0.0D+00 ) then

      if ( y1 /= aint ( y1 * 0.5D+00 ) * 2.0D+00 ) then
        parity = .true.
      end if

      fact = - pi / sin ( pi * res )
      y = y + 1.0D+00

    else

      res = xinf
      r8_gamma = res
      return

    end if

  end if
!
!  Argument is positive.
!
  if ( y < eps ) then
!
!  Argument < EPS.
!
    if ( xminin <= y ) then
      res = 1.0D+00 / y
    else
      res = xinf
      r8_gamma = res
      return
    end if

  else if ( y < 12.0D+00 ) then

    y1 = y
!
!  0.0 < argument < 1.0.
!
    if ( y < 1.0D+00 ) then

      z = y
      y = y + 1.0D+00
!
!  1.0 < argument < 12.0.
!  Reduce argument if necessary.
!
    else

      n = int ( y ) - 1
      y = y - real ( n, kind = 8 )
      z = y - 1.0D+00

    end if
!
!  Evaluate approximation for 1.0 < argument < 2.0.
!
    xnum = 0.0D+00
    xden = 1.0D+00
    do i = 1, 8
      xnum = ( xnum + p(i) ) * z
      xden = xden * z + q(i)
    end do

    res = xnum / xden + 1.0D+00
!
!  Adjust result for case  0.0 < argument < 1.0.
!
    if ( y1 < y ) then

      res = res / y1
!
!  Adjust result for case 2.0 < argument < 12.0.
!
    else if ( y < y1 ) then

      do i = 1, n
        res = res * y
        y = y + 1.0D+00
      end do

    end if

  else
!
!  Evaluate for 12.0 <= argument.
!
    if ( y <= xbig ) then

      ysq = y * y
      sum = c(7)
      do i = 1, 6
        sum = sum / ysq + c(i)
      end do
      sum = sum / y - y + sqrtpi
      sum = sum + ( y - 0.5D+00 ) * log ( y )
      res = exp ( sum )

    else

      res = xinf
      r8_gamma = res
      return

    end if

  end if
!
!  Final adjustments and return.
!
  if ( parity ) then
    res = - res
  end if

  if ( fact /= 1.0D+00 ) then
    res = fact / res
  end if

  r8_gamma = res

  return
end
function r8_uniform_01 ( seed )

!*****************************************************************************80
!
!! R8_UNIFORM_01 returns a unit pseudorandom R8.
!
!  Discussion:
!
!    An R8 is a real ( kind = 8 ) value.
!
!    For now, the input quantity SEED is an integer variable.
!
!    This routine implements the recursion
!
!      seed = 16807 * seed mod ( 2^31 - 1 )
!      r8_uniform_01 = seed / ( 2^31 - 1 )
!
!    The integer arithmetic never requires more than 32 bits,
!    including a sign bit.
!
!    If the initial seed is 12345, then the first three computations are
!
!      Input     Output      R8_UNIFORM_01
!      SEED      SEED
!
!         12345   207482415  0.096616
!     207482415  1790989824  0.833995
!    1790989824  2035175616  0.947702
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    05 July 2006
!
!  Author:
!
!    John Burkardt
!
!  Reference:
!
!    Paul Bratley, Bennett Fox, Linus Schrage,
!    A Guide to Simulation,
!    Springer Verlag, pages 201-202, 1983.
!
!    Pierre L'Ecuyer,
!    Random Number Generation,
!    in Handbook of Simulation,
!    edited by Jerry Banks,
!    Wiley Interscience, page 95, 1998.
!
!    Bennett Fox,
!    Algorithm 647:
!    Implementation and Relative Efficiency of Quasirandom
!    Sequence Generators,
!    ACM Transactions on Mathematical Software,
!    Volume 12, Number 4, pages 362-376, 1986.
!
!    Peter Lewis, Allen Goodman, James Miller
!    A Pseudo-Random Number Generator for the System/360,
!    IBM Systems Journal,
!    Volume 8, pages 136-143, 1969.
!
!  Parameters:
!
!    Input/output, integer ( kind = 4 ) SEED, the "seed" value, which should
!    NOT be 0. On output, SEED has been updated.
!
!    Output, real ( kind = 8 ) R8_UNIFORM_01, a new pseudorandom variate,
!    strictly between 0 and 1.
!
  use global

  integer ( kind = 4 ), parameter :: i4_huge = 2147483647
  integer ( kind = 4 ) k
  real ( kind = 8 ) r8_uniform_01
  integer ( kind = 4 ) seed

  if ( seed == 0 ) then
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'R8_UNIFORM_01 - Fatal error!'
    write ( *, '(a)' ) '  Input value of SEED = 0.'
    stop
  end if

  k = seed / 127773

  seed = 16807 * ( seed - k * 127773 ) - k * 2836

  if ( seed < 0 ) then
    seed = seed + i4_huge
  end if
!
!  Although SEED can be represented exactly as a 32 bit integer,
!  it generally cannot be represented exactly as a 32 bit real number!
!
  r8_uniform_01 = real ( seed, kind = 8 ) * 4.656612875D-10

  return
end
function r8vec_norm ( n, a )

!*****************************************************************************80
!
!! R8VEC_NORM returns the L2 norm of an R8VEC.
!
!  Discussion:
!
!    An R8VEC is a vector of R8's.
!
!    The vector L2 norm is defined as:
!
!      R8VEC_NORM = sqrt ( sum ( 1 <= I <= N ) A(I)^2 ).
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    21 August 2010
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of entries in A.
!
!    Input, real ( kind = 8 ) A(N), the vector whose L2 norm is desired.
!
!    Output, real ( kind = 8 ) R8VEC_NORM, the L2 norm of A.
!
  use global

  integer ( kind = 4 ) n

  real ( kind = 8 ) a(n)
  real ( kind = 8 ) r8vec_norm

  r8vec_norm = sqrt ( sum ( a(1:n)**2 ) )

  return
end
subroutine r8vec_polarize ( n, a, p, a_normal, a_parallel )

!*****************************************************************************80
!
!! R8VEC_POLARIZE decomposes an R8VEC into normal and parallel components.
!
!  Discussion:
!
!    An R8VEC is a vector of R8's.
!
!    The (nonzero) vector P defines a direction.
!
!    The vector A can be written as the sum
!
!      A = A_normal + A_parallel
!
!    where A_parallel is a linear multiple of P, and A_normal
!    is perpendicular to P.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    08 November 2000
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) N, the number of entries in the array.
!
!    Input, real ( kind = 8 ) A(N), the vector to be polarized.
!
!    Input, real ( kind = 8 ) P(N), the polarizing direction.
!
!    Output, real ( kind = 8 ) A_NORMAL(N), A_PARALLEL(N), the normal
!    and parallel components of A.
!
  use global

  integer ( kind = 4 ) n

  real ( kind = 8 ) a(n)
  real ( kind = 8 ) a_dot_p
  real ( kind = 8 ) a_normal(n)
  real ( kind = 8 ) a_parallel(n)
  real ( kind = 8 ) p(n)
  real ( kind = 8 ) p_norm

  p_norm = sqrt ( sum ( p(1:n)**2 ) )

  if ( p_norm == 0.0D+00 ) then
    a_normal(1:n) = a(1:n)
    a_parallel(1:n) = 0.0D+00
    return
  end if

  a_dot_p = dot_product ( a(1:n), p(1:n) ) / p_norm

  a_parallel(1:n) = a_dot_p * p(1:n) / p_norm

  a_normal(1:n) = a(1:n) - a_parallel(1:n)

  return
end
subroutine s_cat ( s1, s2, s3 )

!*****************************************************************************80
!
!! S_CAT concatenates two strings to make a third string.
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    18 September 2000
!
!  Author:
!
!    John Burkardt
!
!  Parameters:
!
!    Input, character ( len = * ) S1, the "prefix" string.
!
!    Input, character ( len = * ) S2, the "postfix" string.
!
!    Output, character ( len = * ) S3, the string made by
!    concatenating S1 and S2, ignoring any trailing blanks.
!
  use global

  character ( len = * ) s1
  character ( len = * ) s2
  character ( len = * ) s3

  if ( s1 == ' ' .and. s2 == ' ' ) then
    s3 = ' '
  else if ( s1 == ' ' ) then
    s3 = s2
  else if ( s2 == ' ' ) then
    s3 = s1
  else
    s3 = trim ( s1 ) // trim ( s2 )
  end if

  return
end
subroutine sphere01_monomial_integral ( e, integral )

!*****************************************************************************80
!
!! SPHERE01_MONOMIAL_INTEGRAL returns monomial integrals on the unit sphere.
!
!  Discussion:
!
!    The integration region is 
!
!      X^2 + Y^2 + Z^2 = 1.
!
!    The monomial is F(X,Y,Z) = X^E(1) * Y^E(2) * Z^E(3).
!
!  Licensing:
!
!    This code is distributed under the GNU LGPL license. 
!
!  Modified:
!
!    24 June 2002
!
!  Author:
!
!    John Burkardt
!
!  Reference:
!
!    Philip Davis, Philip Rabinowitz,
!    Methods of Numerical Integration,
!    Second Edition,
!    Academic Press, 1984, page 263.
!
!  Parameters:
!
!    Input, integer ( kind = 4 ) E(3), the exponents of X, Y and Z in the 
!    monomial.  Each exponent must be nonnegative.
!
!    Output, real ( kind = 8 ) INTEGRAL, the integral.
!
  use global

  integer ( kind = 4 ) e(3)
  integer ( kind = 4 ) i
  real ( kind = 8 ) integral
  real ( kind = 8 ), parameter :: pi = 3.141592653589793D+00
  real ( kind = 8 ) r8_gamma

  if ( any ( e(1:3) < 0 ) ) then
    integral = - huge ( integral )
    write ( *, '(a)' ) ' '
    write ( *, '(a)' ) 'SPHERE01_MONOMIAL_INTEGRAL - Fatal error!'
    write ( *, '(a)' ) '  All exponents must be nonnegative.'
    write ( *, '(a,i8)' ) '  E(1) = ', e(1)
    write ( *, '(a,i8)' ) '  E(2) = ', e(2)
    write ( *, '(a,i8)' ) '  E(3) = ', e(3)
    stop
  end if

  if ( all ( e(1:3) == 0 ) ) then

    integral = 2.0D+00 * sqrt ( pi**3 ) / r8_gamma ( 1.5D+00 )

  else if ( any ( mod ( e(1:3), 2 ) == 1 ) ) then

    integral = 0.0D+00

  else

    integral = 2.0D+00

    do i = 1, 3
      integral = integral * r8_gamma ( 0.5D+00 * real ( e(i) + 1, kind = 8 ) )
    end do

    integral = integral &
      / r8_gamma ( 0.5D+00 * ( real ( sum ( e(1:3) + 1 ), kind = 8 ) ) )

  end if

  return
end
SUBROUTINE xit()



CALL EXIT()

END SUBROUTINE
SUBROUTINE phifunc(phi,f,df,args,nargs)



! This subroutine serves as the function we would like to solve
! for the polymer volume fraction by finding phi such that ``f=0''
use global

real(8), INTENT(IN)                       :: phi
real(8), INTENT(OUT)                      :: f
real(8), INTENT(OUT)                      :: df
real(8), INTENT(IN)                       :: args(nargs)
INTEGER, INTENT(IN OUT)                  :: nargs


INTEGER :: material
INTEGER, PARAMETER :: neohookean=1
INTEGER, PARAMETER :: langevin=2

real(8)  mu,mu0,rgas,theta,chi,vmol,gshear,kbulk
real(8) detf, rt


! Obtain relevant quantities
!
mu     = args(1)
mu0    = args(2)
rgas   = args(3)
theta  = args(4)
chi    = args(5)
vmol   = args(6)
kbulk  = args(7)
detf   = args(8)


! Compute the useful quantity
!
rt = rgas*theta


! Compute the residual
!
f = (mu0 - mu)/rt + DLOG(one - phi) + phi + chi*phi*phi  &
    - ((kbulk*vmol)/rt)*DLOG(detf*phi)  &
    + ((kbulk*vmol)/(two*rt))*(DLOG(detf*phi)**two)


! Compute the tangent
!
IF(phi > 0.999D0) THEN
  df = zero
ELSE
  df = one - (one/(one - phi)) + two*chi*phi - (kbulk*vmol)/(rt*phi)  &
      + ((kbulk*vmol)/(rt*phi))*DLOG(detf*phi)
END IF


RETURN
END SUBROUTINE phifunc
SUBROUTINE fil(f,ff,dw,ddw,lambda,lambda0,ll,r0,mu0,beta,b0)



!>    SINGLE FILAMENT: STRAIN ENERGY DERIVATIVES
use global
IMPLICIT NONE

DOUBLE PRECISION, INTENT(OUT)            :: f
DOUBLE PRECISION, INTENT(OUT)            :: ff
DOUBLE PRECISION, INTENT(OUT)            :: dw
DOUBLE PRECISION, INTENT(OUT)            :: ddw
DOUBLE PRECISION, INTENT(IN OUT)         :: lambda
DOUBLE PRECISION, INTENT(IN OUT)         :: lambda0
DOUBLE PRECISION, INTENT(IN OUT)         :: ll
DOUBLE PRECISION, INTENT(IN OUT)         :: r0
DOUBLE PRECISION, INTENT(IN OUT)         :: mu0
DOUBLE PRECISION, INTENT(IN OUT)         :: beta
DOUBLE PRECISION, INTENT(IN OUT)         :: b0




DOUBLE PRECISION :: a,b,machep,t
DOUBLE PRECISION :: aux, pi,alpha
DOUBLE PRECISION :: aux0,aux1,aux2,aux3,aux4,aux5,aux6,y

a=zero
b=1.0E09
machep=2.2204E-16
t=1.0E-6
f=zero

CALL pullforce(f, a, b, machep, t, lambda,lambda0,ll,r0,mu0,beta,b0)

pi=four*ATAN(one)
! ff=f*ll*(pi*pi*b0)**(-one)
ff=f*ll*ll*(pi*pi*b0)**(-one)
! ff = 100000000000000000.0

alpha=pi*pi*b0*(ll*ll*mu0)**(-one)

aux0=beta/alpha
aux=alpha*ff
aux1=one+ff+aux*ff
aux2=one+two*aux
aux3=one+aux
! aux4=lambda0*r0*r0*mu0*(ll**(-one))
aux4=lambda0*lambda0*r0*r0*mu0*(ll**(-one))
aux5=((one+aux)*(aux1**(-one)))**beta
aux6=one-r0*((ll)**(-one))

y=aux0*(aux2*aux2*(aux1**(-one)))-beta*(aux2*(aux3**(-one)))-two

dw=lambda0*(r0)*f
! dw = pi*pi*r0*b0/(ll*ll)*(((ll/r0-1)/(ll/r0-lambda))**TWO - one)
ddw=aux4*((one+y*aux5*aux6)**(-one))

RETURN
END SUBROUTINE fil
SUBROUTINE deformation(f,c,b,ndi)



!>     RIGHT AND LEFT CAUCHY-GREEN DEFORMATION TENSORS
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: ndi
DOUBLE PRECISION, INTENT(IN OUT)         :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: c(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: b(ndi,ndi)


!     RIGHT CAUCHY-GREEN DEFORMATION TENSOR
c=matmul(transpose(f),f)
!     LEFT CAUCHY-GREEN DEFORMATION TENSOR
b=matmul(f,transpose(f))
RETURN
END SUBROUTINE deformation
SUBROUTINE contraction44(s,LT,rt,ndi)



!>       DOUBLE CONTRACTION BETWEEN 4TH ORDER TENSORS
!>      INPUT:
!>       LT - RIGHT 4TH ORDER TENSOR
!>       RT - LEFT  4TH ORDER TENSOR
!>      OUTPUT:
!>       S - DOUBLE CONTRACTED TENSOR (4TH ORDER)
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: s(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: LT(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: rt(ndi,ndi,ndi,ndi)



INTEGER :: i1,j1,k1,l1,m1,n1


DOUBLE PRECISION :: aux



DO i1=1,ndi
  DO j1=1,ndi
    DO k1=1,ndi
      DO l1=1,ndi
        aux=zero
        DO m1=1,ndi
          DO n1=1,ndi
            aux=aux+LT(i1,j1,m1,n1)*rt(m1,n1,k1,l1)
          END DO
        END DO
        s(i1,j1,k1,l1)=aux
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE contraction44
! SUBROUTINE affclnetfic_discrete(sfic,cfic,f,filprops,affprops,  &
!           efi,noel,det,prefdir,ndi) ! (original)

SUBROUTINE affclnetfic_discrete(sfic,cfic,f,filprops,affprops,  &
  efi,noel,det,prefdir,ndi,etac_sdv)  



!>    AFFINE NETWORK: 'FICTICIOUS' CAUCHY STRESS AND ELASTICITY TENSOR
!> DISCRETE ANGULAR INTEGRATION SCHEME (icosahedron)
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: sfic(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: cfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: filprops(8)
DOUBLE PRECISION, INTENT(IN)             :: affprops(2)
DOUBLE PRECISION, INTENT(IN OUT)         :: efi
INTEGER, INTENT(IN OUT)                  :: noel
DOUBLE PRECISION, INTENT(IN OUT)         :: det
!DOUBLE PRECISION, INTENT(OUT)            :: etac

INTEGER :: i1,j1,k1,l1,m1, im1
DOUBLE PRECISION :: sfilfic(ndi,ndi), cfilfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: mfi(ndi),mf0i(ndi)
DOUBLE PRECISION :: aux,lambdai,dwi,ddwi,rwi,lambdaic
DOUBLE PRECISION :: l,r0f,r0,mu0,b0,beta,lambda0,rho,n,fi,ffi,dtime
DOUBLE PRECISION :: r0c,etac,lambdaif
DOUBLE PRECISION :: bdisp,fric,ffmax,ang, frac(4),ru
DOUBLE PRECISION :: vara,avga,maxa,aux0,ffic,suma,rho0,dirmax(ndi)
DOUBLE PRECISION :: prefdir(nelem,4)
DOUBLE PRECISION :: pd(3),lambda_pref,prefdir0(3),ang_pref 

! RANDOM GENERATORS
INTEGER :: i_f, sum_f, test_num
INTEGER (kind=4) :: seed1, seed2
INTEGER (kind=4) :: test
CHARACTER(len=100) :: phrase
REAL(kind=4) , allocatable :: rnd_array(:)
REAL(kind=4) :: l_bound, h_bound
REAL(kind=4) :: mean, sd
REAL(kind=4) , allocatable ::  etac_array(:)
DOUBLE PRECISION, intent(out) :: etac_sdv(nsdv-1)

! INTEGRATION SCHEME
  integer ( kind = 4 ) node_num
  integer ( kind = 4 ) a
  real ( kind = 8 ) a_xyz(3)
  real ( kind = 8 ) a2_xyz(3)
  real ( kind = 8 ) ai !area of triangle i
  real ( kind = 8 ) area_total
  integer ( kind = 4 ) b
  real ( kind = 8 ) b_xyz(3)
  real ( kind = 8 ) b2_xyz(3)
  integer ( kind = 4 ) c
  real ( kind = 8 ) c_xyz(3)
  real ( kind = 8 ) c2_xyz(3)
  integer ( kind = 4 ) edge_num
  integer ( kind = 4 ), allocatable, dimension ( :, : ) :: edge_point
  integer ( kind = 4 ) f1
  integer ( kind = 4 ) f2
  integer ( kind = 4 ) f3
  integer ( kind = 4 ) face
  integer ( kind = 4 ) face_num
  integer ( kind = 4 ), allocatable, dimension ( : ) :: face_order
  integer ( kind = 4 ), allocatable, dimension ( :, : ) :: face_point
  integer ( kind = 4 ) face_order_max
  ! integer ( kind = 4 ) factor ! (original)
  !external             fun
  real ( kind = 8 ) node_xyz(3)
  real ( kind = 8 ), parameter :: pi = 3.141592653589793D+00
  real ( kind = 8 ), allocatable, dimension ( :, : ) :: point_coord
  integer ( kind = 4 ) point_num
  real ( kind = 8 ) rr, aa
  real ( kind = 8 ) v



!  Size the icosahedron.
!
  call icos_size ( point_num, edge_num, face_num, face_order_max )
!
!  Set the icosahedron.
!
  allocate ( point_coord(1:3,1:point_num) )
  allocate ( edge_point(1:2,1:edge_num) )
  allocate ( face_order(1:face_num) )
  allocate ( face_point(1:face_order_max,1:face_num) )

  call icos_shape ( point_num, edge_num, face_num, face_order_max, &
    point_coord, edge_point, face_order, face_point )
!
!  Initialize the integral data.
!
  rr = 0.0D+00
  area_total = 0.0D+00
  node_num = 0
  
!----------------------------------------------------------------------
!------------------------ RANDOM GENERATION ---------------------------
!----------------------------------------------------------------------
! A random value of a given property is generated for each direction/node (test_num = n_nodes )
sum_f = 0
do i_f = 1, factor-1
  sum_f = sum_f + i_f
end do
test_num = face_num * (FACTOR + 2*sum_f)

allocate (rnd_array(test_num))
allocate (etac_array(test_num))

l_bound = 0.5
h_bound = 0.502
CALL timestamp(phrase)
CALL phrtsd(phrase, seed1, seed2)
CALL test_gennor(mean, sd, phrase, test_num, rnd_array)

DO test=1, test_num 
  etac_array(test) = l_bound + (rnd_array(test) - minval(rnd_array))/(maxval(rnd_array) - minval(rnd_array)) * (h_bound-l_bound)
  IF (test .LE. nsdv-1) THEN
    etac_sdv(test) = etac_array(test)
  END IF
END DO
!----------------------------------------------------------------------

!! initialize the model data
  !     FILAMENT
l       = filprops(1)
r0f     = filprops(2)
r0c     = filprops(3)
etac    = filprops(4) !!!!!!! Input, sendo a media +- sd
mu0     = filprops(5)
beta    = filprops(6)
b0      = filprops(7)
lambda0 = filprops(8)
!     NETWORK
n       = affprops(1)
bdisp   = affprops(2)

  aux=n*(det**(-one))
  cfic=zero
  sfic=zero

  rho=one
  r0=r0f+r0c

  aa = zero
  avga=zero
  maxa=zero
  suma=zero
  dirmax=zero
  
  !preferred direction measures (macroscale measures)
  prefdir0=prefdir(noel,2:4)
  !calculate preferred direction in the deformed configuration
  CALL deffil(lambda_pref,pd,prefdir0,f,ndi)
  !update preferential direction - deformed configuration
  pd=pd/dsqrt(dot_product(pd,pd))

!  Pick a face of the icosahedron, and identify its vertices as A, B, C.
!  Total number of directions/nodes:
!  factor * [sum(1,factor,step=1) + sum(1,factor-1,step=1)]
!
  do face = 1, face_num
!
    a = face_point(1,face)
    b = face_point(2,face)
    c = face_point(3,face)
!
    a_xyz(1:3) = point_coord(1:3,a)
    b_xyz(1:3) = point_coord(1:3,b)
    c_xyz(1:3) = point_coord(1:3,c)
!
!  Some subtriangles will have the same direction as the face.
!  Generate each in turn, by determining the barycentric coordinates
!  of the centroid (F1,F2,F3), from which we can also work out the barycentric
!  coordinates of the vertices of the subtriangle.
!
    do f3 = 1, 3 * factor - 2, 3
      do f2 = 1, 3 * factor - f3 - 1, 3

        f1 = 3 * factor - f3 - f2

        call sphere01_triangle_project ( a_xyz, b_xyz, c_xyz, f1, f2, f3, &
          node_xyz )

        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 + 2, f2 - 1, f3 - 1, a2_xyz )
        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 - 1, f2 + 2, f3 - 1, b2_xyz )
        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 - 1, f2 - 1, f3 + 2, c2_xyz )

        call sphere01_triangle_vertices_to_area ( a2_xyz, b2_xyz, c2_xyz, ai )

        !direction of the sphere triangle barycenter - direction i
        mf0i=node_xyz
        CALL deffil(lambdai,mfi,mf0i,f,ndi)
  
        CALL bangle(ang,f,mfi,noel,pd,ndi)
  
        CALL density(rho,ang,bdisp,efi)
        rho = one

        !!! Always duplicate the changes to the opposite direction subtriangles
        !!!! Assigning random value to etac
        etac = etac_array(node_num + 1)  
        IF((etac > zero).AND.(etac .LE. one))THEN
            lambdaif=etac*(r0/r0f)*(lambdai-one)+one
            lambdaic=(lambdai*r0-lambdaif*r0f)/r0c
        ELSE
            lambdaif=lambdai ! False for a filament attached to a stiff crosslinker (etac = 1), only valid for etac = 0 (???)
            lambdaic=zero ! False for a stiff crosslinker (etac = 1), only valid for etac = 0 (???)
        END IF
        ! write(*,*) node_num, lambdaif, rho
        
        IF(lambdaif > 1.0d0)THEN
          CALL fil(fi,ffi,dwi,ddwi,lambdaif,lambda0,l,r0f,mu0,beta,b0)
          ! CALL fil(fi,ffi,dwi,ddwi,lambdaif,lambda0,l,r0,mu0,beta,b0)
          
          CALL sigfilfic(sfilfic,rho,lambdaif,dwi,mfi,ai,ndi)
    
          CALL csfilfic(cfilfic,rho,lambdaif,dwi,ddwi,mfi,ai,ndi)
    
          DO j1=1,ndi
            DO k1=1,ndi
                sfic(j1,k1)=sfic(j1,k1)+aux*sfilfic(j1,k1)
                DO l1=1,ndi
                  DO m1=1,ndi
                    cfic(j1,k1,l1,m1)=cfic(j1,k1,l1,m1)+aux*cfilfic(j1,k1,l1,m1)
                  END DO
                END DO
            END DO
          END DO

        END IF
        
        !v=dwi
        node_num = node_num + 1
        !rr = rr + ai * v
        !area_total = area_total + ai
        write(*,*) etac

      end do
    end do
!
!  The other subtriangles have the opposite direction from the face.
!  Generate each in turn, by determining the barycentric coordinates
!  of the centroid (F1,F2,F3), from which we can also work out the barycentric
!  coordinates of the vertices of the subtriangle.
!
    do f3 = 2, 3 * factor - 4, 3
      do f2 = 2, 3 * factor - f3 - 2, 3

        f1 = 3 * factor - f3 - f2

        call sphere01_triangle_project ( a_xyz, b_xyz, c_xyz, f1, f2, f3, &
          node_xyz )

        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 - 2, f2 + 1, f3 + 1, a2_xyz )
        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 + 1, f2 - 2, f3 + 1, b2_xyz )
        call sphere01_triangle_project ( &
          a_xyz, b_xyz, c_xyz, f1 + 1, f2 + 1, f3 - 2, c2_xyz )

        call sphere01_triangle_vertices_to_area ( a2_xyz, b2_xyz, c2_xyz, ai )

        !direction of the sphere triangle barycenter - direction i
        mf0i=node_xyz
        CALL deffil(lambdai,mfi,mf0i,f,ndi)
  
        CALL bangle(ang,f,mfi,noel,pd,ndi)
  
        CALL density(rho,ang,bdisp,efi)
        rho=one

        !!!! Assigning random value to etac
        etac = etac_array(node_num + 1)  
        IF((etac > zero).AND.(etac .LE. one))THEN
            lambdaif=etac*(r0/r0f)*(lambdai-one)+one
            lambdaic=(lambdai*r0-lambdaif*r0f)/r0c
        ELSE
            lambdaif=lambdai
            lambdaic=zero
        END IF
        ! write(*,*) node_num, lambdaif, rho
        
        IF(lambdaif > 1.0d0)THEN

          CALL fil(fi,ffi,dwi,ddwi,lambdaif,lambda0,l,r0f,mu0,beta,b0)
          ! CALL fil(fi,ffi,dwi,ddwi,lambdaif,lambda0,l,r0,mu0,beta,b0)
          
          CALL sigfilfic(sfilfic,rho,lambdaif,dwi,mfi,ai,ndi)
    
          CALL csfilfic(cfilfic,rho,lambdaif,dwi,ddwi,mfi,ai,ndi)
    
          DO j1=1,ndi
            DO k1=1,ndi
                sfic(j1,k1)=sfic(j1,k1)+aux*sfilfic(j1,k1)
                DO l1=1,ndi
                  DO m1=1,ndi
                    cfic(j1,k1,l1,m1)=cfic(j1,k1,l1,m1)+aux*cfilfic(j1,k1,l1,m1)
                  END DO
                END DO
            END DO
          END DO
        END IF
        
        
        !v=dwi
        node_num = node_num + 1  
        !rr = rr + ai * v
        !area_total = area_total + ai
        write(*,*) etac

      end do
    end do

  end do
!
!  Discard allocated memory.
!
  deallocate ( edge_point )
  deallocate ( face_order )
  deallocate ( face_point )
  deallocate ( point_coord )


RETURN
END SUBROUTINE affclnetfic_discrete
SUBROUTINE cmatisomatfic(cmisomatfic,cbar,cbari1,cbari2,  &
        diso,unit2,unit4,det,ndi)



!>    ISOTROPIC MATRIX: MATERIAL 'FICTICIOUS' ELASTICITY TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(IN OUT)         :: cmisomatfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: cbar(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: cbari1
DOUBLE PRECISION, INTENT(IN OUT)         :: cbari2
DOUBLE PRECISION, INTENT(IN)             :: diso(5)
DOUBLE PRECISION, INTENT(IN)             :: unit2(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: unit4(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: det



INTEGER :: i1,j1,k1,l1
    

DOUBLE PRECISION :: dudi1,dudi2,d2ud2i1,d2ud2i2,d2udi1i2
DOUBLE PRECISION :: aux,aux1,aux2,aux3,aux4
DOUBLE PRECISION :: uij,ukl,cij,ckl

dudi1=diso(1)
dudi2=diso(2)
d2ud2i1=diso(3)
d2ud2i2=diso(4)
d2udi1i2=diso(5)

aux1=four*(d2ud2i1+two*cbari1*d2udi1i2+ dudi2+cbari1*cbari1*d2ud2i2)
aux2=-four*(d2udi1i2+cbari1*d2ud2i2)
aux3=four*d2ud2i2
aux4=-four*dudi2

DO i1=1,ndi
  DO j1=1,ndi
    DO k1=1,ndi
      DO l1=1,ndi
        uij=unit2(i1,j1)
        ukl=unit2(k1,l1)
        cij=cbar(i1,j1)
        ckl=cbar(k1,l1)
        aux=aux1*uij*ukl+ aux2*(uij*ckl+cij*ukl)+aux3*cij*ckl+  &
            aux4*unit4(i1,j1,k1,l1)
        cmisomatfic(i1,j1,k1,l1)=aux * det**(-four/three)
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE cmatisomatfic
SUBROUTINE metvol(cvol,c,pv,ppv,det,ndi)



!>    VOLUMETRIC MATERIAL ELASTICITY TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: cvol(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: c(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: pv
DOUBLE PRECISION, INTENT(IN OUT)         :: ppv
DOUBLE PRECISION, INTENT(IN OUT)         :: det



INTEGER :: i1,j1,k1,l1
DOUBLE PRECISION :: cinv(ndi,ndi)


CALL matinv3d(c,cinv,ndi)

DO i1 = 1, ndi
  DO j1 = 1, ndi
    DO k1 = 1, ndi
      DO l1 = 1, ndi
        cvol(i1,j1,k1,l1)= det*ppv*cinv(i1,j1)*cinv(k1,l1)  &
            -det*pv*(cinv(i1,k1)*cinv(j1,l1) +cinv(i1,l1)*cinv(j1,k1))
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE metvol
SUBROUTINE density(rho,ang,bb,erfi)



!>    SINGLE FILAMENT: DENSITY FUNCTION VALUE
use global
IMPLICIT NONE

DOUBLE PRECISION, INTENT(OUT)            :: rho
DOUBLE PRECISION, INTENT(IN OUT)         :: ang
DOUBLE PRECISION, INTENT(IN OUT)         :: bb
DOUBLE PRECISION, INTENT(IN OUT)         :: erfi



DOUBLE PRECISION :: pi,aux1,aux2

pi=four*ATAN(one)
aux1=SQRT(bb/(two*pi))
aux2=DEXP(bb*(COS(two*ang)+one))
rho=four*aux1*aux2*(erfi**(-one))
!      RHO=RHO*((FOUR*PI)**(-ONE)

RETURN
END SUBROUTINE density
SUBROUTINE evalg(g,f,lambda,lambda0,l,r0,mu0,beta,b0)



!>     ESTABLISHMENT OF G(F)=LHS-RHS(F) THAT RELATES
!>       STRETCHFORCE RELATIONSHIP OF A SINGLE EXNTESIBLE FILAMENT
use global
IMPLICIT NONE

DOUBLE PRECISION, INTENT(OUT)            :: g
DOUBLE PRECISION, INTENT(IN)             :: f
DOUBLE PRECISION, INTENT(IN)             :: lambda
DOUBLE PRECISION, INTENT(IN)             :: lambda0
DOUBLE PRECISION, INTENT(IN)             :: l
DOUBLE PRECISION, INTENT(IN)             :: r0
DOUBLE PRECISION, INTENT(IN)             :: mu0
DOUBLE PRECISION, INTENT(IN OUT)         :: beta
DOUBLE PRECISION, INTENT(IN OUT)         :: b0


DOUBLE PRECISION :: lhs,rhs


DOUBLE PRECISION :: aux0,aux1,aux,aux2,aux3,aux4,pi

pi=four*ATAN(one)
aux0=one-r0/l
aux1=l*l*((pi*pi*b0)**(-one))
aux=f/mu0
aux2=one+aux
aux3=one+two*aux
aux4=one+f*aux1+f*aux*aux1

rhs=one+aux-aux0*(aux2**beta)*aux3*(aux4**(-beta))
lhs=lambda*lambda0*r0*(l**(-one))

g=lhs-rhs

RETURN
END SUBROUTINE evalg
SUBROUTINE pk2vol(pkvol,pv,c,ndi, det)



!>    VOLUMETRIC PK2 STRESS
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: pkvol(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pv, det
DOUBLE PRECISION, INTENT(IN OUT)         :: c(ndi,ndi)

INTEGER :: i1,j1
DOUBLE PRECISION :: cinv(ndi,ndi)


CALL matinv3d(c,cinv,ndi)

DO i1=1,ndi
  DO j1=1,ndi
    pkvol(i1,j1)=det*pv*cinv(i1,j1)
  END DO
END DO

RETURN
END SUBROUTINE pk2vol
SUBROUTINE rotation(f,r,u,ndi)



!>    COMPUTES ROTATION TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN OUT)                  :: ndi
DOUBLE PRECISION, INTENT(IN OUT)         :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: r(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: u(ndi,ndi)




DOUBLE PRECISION :: uinv(ndi,ndi)

CALL matinv3d(u,uinv,ndi)

r = matmul(f,uinv)
RETURN
END SUBROUTINE rotation
SUBROUTINE pk2iso(pkiso,pkfic,pl,det,ndi)



!>    ISOCHORIC PK2 STRESS TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: pkiso(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: pkfic(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: pl(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: det



INTEGER :: i1,j1

DOUBLE PRECISION :: scale2

CALL contraction42(pkiso,pl,pkfic,ndi)

scale2=det**(-two/three)
DO i1=1,ndi
  DO j1=1,ndi
    pkiso(i1,j1)=scale2*pkiso(i1,j1)
  END DO
END DO

RETURN
END SUBROUTINE pk2iso
SUBROUTINE setiso(ciso,cfic,pe,siso,sfic,unit2,ndi)


use global
IMPLICIT NONE

!>    ISOCHORIC SPATIAL ELASTICITY TENSOR

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: ciso(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: cfic(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pe(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: siso(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: sfic(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: unit2(ndi,ndi)



INTEGER :: i1,j1,k1,l1
DOUBLE PRECISION :: cisoaux(ndi,ndi,ndi,ndi), cisoaux1(ndi,ndi,ndi,ndi)
DOUBLE PRECISION :: trfic,xx,yy,zz

cisoaux1=zero
cisoaux=zero

CALL contraction44(cisoaux1,pe,cfic,ndi)
CALL contraction44(cisoaux,cisoaux1,pe,ndi)

trfic=zero
DO i1=1,ndi
  trfic=trfic+sfic(i1,i1)
END DO

DO i1=1,ndi
  DO j1=1,ndi
    DO k1=1,ndi
      DO l1=1,ndi
        xx=cisoaux(i1,j1,k1,l1)
        yy=trfic*pe(i1,j1,k1,l1)
        zz=siso(i1,j1)*unit2(k1,l1)+unit2(i1,j1)*siso(k1,l1)
        
        ciso(i1,j1,k1,l1)=xx+(two/three)*yy-(two/three)*zz
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE setiso
SUBROUTINE push4(spatial,mat,f,det,ndi)



!>        PIOLA TRANSFORMATION
!>      INPUT:
!>       MAT - MATERIAL ELASTICITY TENSOR
!>       F - DEFORMATION GRADIENT
!>       DET - DEFORMATION DETERMINANT
!>      OUTPUT:
!>       SPATIAL - SPATIAL ELASTICITY TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: spatial(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: mat(ndi,ndi,ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: det


INTEGER :: i1,j1,k1,l1,ii1,jj1,kk1,ll1


DOUBLE PRECISION :: aux


DO i1=1,ndi
  DO j1=1,ndi
    DO k1=1,ndi
      DO l1=1,ndi
        aux=zero
        DO ii1=1,ndi
          DO jj1=1,ndi
            DO kk1=1,ndi
              DO ll1=1,ndi
                aux=aux+(det**(-one))* f(i1,ii1)*f(j1,jj1)*  &
                    f(k1,kk1)*f(l1,ll1)*mat(ii1,jj1,kk1,ll1)
              END DO
            END DO
          END DO
        END DO
        spatial(i1,j1,k1,l1)=aux
      END DO
    END DO
  END DO
END DO

RETURN
END SUBROUTINE push4
SUBROUTINE contraction22(aux,lt,rt,ndi)
!>       DOUBLE CONTRACTION BETWEEN 2nd ORDER AND 2ND ORDER  TENSOR
!>      INPUT:
!>       LT - RIGHT 2ND ORDER TENSOR
!>       RT - LEFT  2nd ODER TENSOR
!>      OUTPUT:
!>       aux - DOUBLE CONTRACTED TENSOR (scalar)
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(IN)             :: lt(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: rt(ndi,ndi)
DOUBLE PRECISION, INTENT(OUT)            :: aux
INTEGER :: i1,j1


    aux=zero
    DO i1=1,ndi
      DO j1=1,ndi
        aux=aux+lt(i1,j1)*rt(j1,i1)
      END DO
    END DO
RETURN
END SUBROUTINE contraction22
SUBROUTINE push2(sig,pk,f,det,ndi)



!>        PIOLA TRANSFORMATION
!>      INPUT:
!>       PK - 2ND PIOLA KIRCHOOF STRESS TENSOR
!>       F - DEFORMATION GRADIENT
!>       DET - DEFORMATION DETERMINANT
!>      OUTPUT:
!>       SIG - CAUCHY STRESS TENSOR
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: sig(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: pk(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: f(ndi,ndi)
DOUBLE PRECISION, INTENT(IN OUT)         :: det


INTEGER :: i1,j1,ii1,jj1


DOUBLE PRECISION :: aux

DO i1=1,ndi
  DO j1=1,ndi
    aux=zero
    DO ii1=1,ndi
      DO jj1=1,ndi
        aux=aux+(det**(-one))*f(i1,ii1)*f(j1,jj1)*pk(ii1,jj1)
      END DO
    END DO
    sig(i1,j1)=aux
  END DO
END DO

RETURN
END SUBROUTINE push2
SUBROUTINE contraction24(s,LT,rt,ndi)



!>       DOUBLE CONTRACTION BETWEEN 4TH ORDER AND 2ND ORDER  TENSOR
!>      INPUT:
!>       LT - RIGHT 2ND ORDER TENSOR
!>       RT - LEFT  4TH ODER TENSOR
!>      OUTPUT:
!>       S - DOUBLE CONTRACTED TENSOR (2ND ORDER)
use global
IMPLICIT NONE

INTEGER, INTENT(IN)                      :: ndi
DOUBLE PRECISION, INTENT(OUT)            :: s(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: lt(ndi,ndi)
DOUBLE PRECISION, INTENT(IN)             :: rt(ndi,ndi,ndi,ndi)



INTEGER :: i1,j1,k1,l1


DOUBLE PRECISION :: aux



DO k1=1,ndi
  DO l1=1,ndi
    aux=zero
    DO i1=1,ndi
      DO j1=1,ndi
        aux=aux+lt(k1,l1)*rt(i1,j1,k1,l1)
      END DO
    END DO
    s(k1,l1)=aux
  END DO
END DO
RETURN
END SUBROUTINE contraction24
subroutine test_gennor (avtr, vartr,phrase , n, array)
    !*****************************************************************************80
    !
    !! TEST_GENNOR tests GENNOR, which generates normal deviates.
    !
    !  Licensing:
    !
    !    This code is distributed under the GNU LGPL license.
    !
    !  Modified:
    !
    !    31 March 2013
    !
    !  Author:
    !
    !    John Burkardt
    !
      implicit none
    
      integer ( kind = 4 ) n
    
      real ( kind = 4 ) array(n)
      real ( kind = 4 ) av
      real ( kind = 4 ) avtr
      real ( kind = 4 ) gennor
      real ( kind = 4 ) genunf
      !real ( kind = 4 ) min
      !real ( kind = 4 ) max
      real ( kind = 4 ) high
      integer ( kind = 4 ) i
      real ( kind = 4 ) low
      real ( kind = 4 ) mu
      real ( kind = 4 ) param(2)
      character ( len = 4 ) pdf
      character ( len = * ) phrase
      real ( kind = 4 ) sd
      integer ( kind = 4 ) seed1
      integer ( kind = 4 ) seed2
      real ( kind = 4 ) var
      real ( kind = 4 ) vartr
      real ( kind = 4 ) xmax
      real ( kind = 4 ) xmin
    
      !write ( *, '(a)' ) ' '
      !write ( *, '(a)' ) 'TEST_GENNOR'
      !write ( *, '(a)' ) '  GENNOR generates normal deviates.'
    !
    !  Initialize the generators.
    !
      call initialize_gen ( )   
      !
    !  Set the seeds based on the phrase.
    !
      call phrtsd ( phrase, seed1, seed2 )
    !
    !  Initialize all generators.
    !
      call set_initial_seed ( seed1, seed2 )
    !
    !  Select the parameters at random within a given range.
    !
      low = -10.0E+00
      high = 10.0E+00
      mu = genunf ( low, high )
      !write ( *, '(a,g14.6)' ) '  New MU =   ', mu
    
      low = 0.25E+00
      high = 4.0E+00
      sd = genunf ( low, high )
    
     ! write ( *, '(a)' ) ' '
    !write ( *, '(a,i6)' ) '  N = ', n
     ! write ( *, '(a)' ) ' '
     !write ( *, '(a)' ) '  Parameters:'
     ! write ( *, '(a)' ) ' '
     ! write ( *, '(a,g14.6)' ) '  MU =   ', mu
     ! write ( *, '(a,g14.6)' ) '  SD =   ', sd
    !
    !  Generate N samples.
    !
      do i = 1, n
        array(i) = gennor ( mu, sd )
      end do
      
    !
    !  Compute statistics on the samples.
    !
      call stats ( array, n, av, var, xmin, xmax )
    !
    !  Request expected value of statistics for this distribution.
    !
      pdf = 'nor'
      param(1) = mu
      param(2) = sd
    
      call trstat ( pdf, param, avtr, vartr )
    
      !write ( *, '(a)' ) ' '
      !write ( *, '(a,2g14.6)' ) '  Sample data range:          ', xmin, xmax
      !write ( *, '(a,2g14.6)' ) '  Sample mean, variance:      ', av,   var
      !write ( *, '(a,2g14.6)' ) '  Distribution mean, variance ', avtr, vartr
    
      return
    end

SUBROUTINE chemicalstat(frac,frac0,k,dtime)


use global
IMPLICIT NONE

DOUBLE PRECISION, INTENT(OUT)            :: frac(4)
DOUBLE PRECISION, INTENT(IN)             :: frac0(4)
DOUBLE PRECISION, INTENT(IN)             :: k(7)
DOUBLE PRECISION, INTENT(IN)             :: dtime


DOUBLE PRECISION :: stiff(4,4)

DOUBLE PRECISION :: aux
INTEGER :: i1,j1

frac=zero
stiff=zero
stiff(1,1)=-k(1)
stiff(1,2)=k(2)
stiff(1,4)=k(7)
stiff(2,1)=k(1)
stiff(2,2)=-k(2)-k(3)
stiff(2,3)=k(4)
stiff(3,2)=k(3)
stiff(3,3)=-k(4)-k(5)
stiff(3,4)=k(6)
stiff(4,3)=k(5)
stiff(4,4)=-k(6)-k(7)

DO i1=1,4
  aux=zero
  DO j1=1,4
    aux=aux+stiff(i1,j1)*frac0(j1)
  END DO
  frac(i1)=aux*dtime+frac0(i1)
END DO

!      FRAC0=FRAC

RETURN
END SUBROUTINE chemicalstat
