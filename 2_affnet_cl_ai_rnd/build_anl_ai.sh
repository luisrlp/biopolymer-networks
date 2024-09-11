#ls -rd *src*/*.f90 | LC_ALL=C sort | xargs cat > umat_anl_ai.f90
find . -type f -path '*src/*' -name '_global.*' -exec cat {} +> umat_anl_ai_rnd.f90
find . -type f -path '*src/*'  -name '*.f90' -not -name '_global.f90'  -exec cat {} >> umat_anl_ai_rnd.f90 \;
gfortran -o anl_ai_rnd.o anl_ai_rnd.f90 umat_anl_ai_rnd.f90
find . -type f -path '*src/*' -name '_global.*' -exec cat {} +> test_in_abaqus/umat_anl_ai_rnd.f
find . -type f -path '*src/*' -name '*.f90' -not \( -name 'GETOUTDIR.f90' -o -name '_global.*' \) -exec cat {} >> test_in_abaqus/umat_anl_ai_rnd.f \;
find . -type f -path '*src/*' -name '_global.*' -exec cat {} +> test_in_abaqus/sdv_py.f90
find . -type f -name 'sdv_read_py.f90' -exec cat {} >> test_in_abaqus/sdv_py.f90 \;
#find . -type f -path '*src/*' -name '*.f90' -not -name 'GETOUTDIR.f90' -exec cat {} +> test_in_abaqus/umat_anl_ai.f90