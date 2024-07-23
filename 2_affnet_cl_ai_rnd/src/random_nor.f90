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

