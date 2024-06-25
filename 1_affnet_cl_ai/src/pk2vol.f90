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
