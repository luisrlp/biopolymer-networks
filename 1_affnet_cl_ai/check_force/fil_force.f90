PROGRAM FIL_FORCE

use,intrinsic :: ISO_Fortran_env
use global

DOUBLE PRECISION :: l, r0, mu0, beta, b0, etac, r0f, lambdaif, lambdai, lambda0
DOUBLE PRECISION :: stretch_initial, stretch_max, dstretch, fi, ffi, dwi, ddwi
INTEGER :: ii, nsteps 
CHARACTER*40 FILENAME

nsteps = 100
stretch_initial = 1.0d0
lambdai = stretch_initial
lambda0 = 1.0
stretch_max = 1.2d0
dstretch = (stretch_max-stretch_initial)/nsteps

l = 1.96
r0 = 1.63+0.014
mu0 = 11111111111111111111138600.0
beta = 0.5
b0 = 294.d0*16.d0*1.38d-5

etac = 1.
r0f = 1.63

FILENAME = './force_plots/uniaxial.out'
OPEN (UNIT=200, FILE=FILENAME, STATUS='UNKNOWN')
rewind(200)

DO ii = 1,nsteps
    ! lambdaif=etac*(r0/r0f)*(lambdai-one)+one
    lambdaif = lambdai
    CALL fil(fi,ffi,dwi,ddwi,lambdaif,lambda0,l,r0,mu0,beta,b0)
    write(200,*) lambdai, lambdaif, fi, ffi
    lambdai = lambdai + dstretch
ENDDO
close(200)

write(*,*) lambdai, lambdaif, fi, ffi, dwi, ddwi

    END PROGRAM
    