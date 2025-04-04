import subprocess

'''Compiles material routines in mains directory and /test_in_abaqus, for deterministic or random approach.'''

def build_umat(approach=None, compile: bool = True):

    if approach == 'deterministic':
        ignore_umat = '_umat_rnd_.f90'
        ignore_affcl = 'affclnetfic_discrete_rnd.f90'
        ignore_uexternal = 'uexternaldb_rnd.f90'
    elif approach == 'random':
        ignore_umat = '_umat_det_.f90'
        ignore_affcl = 'affclnetfic_discrete_det.f90'
        ignore_uexternal = 'uexternaldb_det.f90'

    # 1. Concatenate all .f90 files from *src/* to umat_anl_ai_mcs.f90
    # Global module must be at the beginning
    
    subprocess.run(
        "find . -type f -path '*src/*' -name '_global.f90' -exec cat {} +> umat_anl_ai_mcs.f90", 
        shell=True, check=True
    )

    subprocess.run(
        f"find . -type f -path '*src/*' -name '*.f90' -not \( -name '_global.f90' -o -name {ignore_umat} -o -name {ignore_affcl} -o -name {ignore_uexternal} \) -exec cat {{}} >> umat_anl_ai_mcs.f90 \;", 
        shell=True, check=True
    )

    # 2. Concatenate all .f90 files from *src/* to test_in_abaqus folder
    subprocess.run(
        "find . -type f -path '*src/*' -name '_global.*' -exec cat {} +> test_in_abaqus/umat_anl_ai_mcs.f", 
        shell=True, check=True
    )

    subprocess.run(
        "find . -type f -path '*src/*' -name '*.f90' -not \\( -name 'GETOUTDIR.f90' -o -name '_global.*' \\) -exec cat {} >> test_in_abaqus/umat_anl_ai_mcs.f \;", 
        shell=True, check=True
    )

    subprocess.run(
        "find . -type f -path '*src/*' -name '_global.*' -exec cat {} +> glb_py.f90", 
        shell=True, check=True
    )

    subprocess.run(
        "find . -type f -name 'global_read_py.f90' -exec cat {} >> glb_py.f90 \;", 
        shell=True, check=True
    )

    subprocess.run(
        "find . -type f -path '*src/*' -name '_global.*' -exec cat {} +> test_in_abaqus/glb_py.f90", 
        shell=True, check=True
    )

    subprocess.run(
        "find . -type f -name 'global_read_py.f90' -exec cat {} >> test_in_abaqus/glb_py.f90 \;", 
        shell=True, check=True
    )

    if compile:
        command1 = ['/bin/python3.6', '-m', 'numpy.f2py', 
                    '-c', '-m', 'globpy', 'glb_py.f90']
        command2 = ['/bin/python3.6', '-m', 'numpy.f2py', 
                '-c', '-m', 'umatpy', 'py_anl_ai_mcs.f90', 'umat_anl_ai_mcs.f90']
        try:
            subprocess.run(command1, check=True)
            subprocess.run(command2, check=True)
        except subprocess.CalledProcessError as e:
            print(f"An error occurred: {e}")

    print("UMAT compiled successfully.")

build_umat(approach='deterministic')