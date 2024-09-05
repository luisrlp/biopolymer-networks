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
SUBROUTINE sdv_read_py(nsdv_out)

    !use,intrinsic :: ISO_Fortran_env
    use global

    INTEGER, INTENT(OUT) :: nsdv_out

    nsdv_out = nsdv

END SUBROUTINE