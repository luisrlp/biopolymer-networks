import subprocess
import importlib
import sys

command = ['/bin/python3.6',
        '-m', 
        'numpy.f2py', 
        '-c', 
        '-m', 
        'nsdvpy', 
        'sdv_py.f90']

try:
    result = subprocess.run(command, check=True)
    # Print the standard output and error (if any)
    # print("Output:")
    # print(result.stdout)
    if result.stderr:
        print("Error:")
        print(result.stderr)
except subprocess.CalledProcessError as e:
    print(f"An error occurred: {e}")

import nsdvpy
importlib.reload(nsdvpy)

#print('Number of sdvs')
#print(nsdvpy.sdv_read_py())
nsdv = nsdvpy.sdv_read_py()

# Create section input file
def write_inp_file(filename, nsdv):
    with open(filename, 'w') as file:
        # Write the Solid Section
        file.write('*Solid Section, elset=main_element, material=UD\n')
        
        # Write the Material Definition
        file.write('*Material, name=UD\n')
        file.write('*User Material, constants=14\n')
        # Replace placeholders with actual values as needed
        file.write('<K>,<C10>,<C01>,<PHI>,<L>,<R0F>,<R0C>,<ETA>\n')
        file.write('<MU0>,<BETA>,<B0>,<LAMBDA0>,<NA>,<BDISP>\n')
        # Write the DEPVAR Section
        file.write('*DEPVAR\n')
        file.write(f'{nsdv},\n')
        file.write('1, DET, "DET"\n')
        if nsdv > 1:
            for i in range(2, nsdv+1):
                file.write(f'{i}, ETAC{i-1}, "ETAC{i-1}"\n')

# Write the file
write_inp_file('sec_anl_rnd.inp', nsdv)

'''print('-------------')
print('Number of sdvs:')
print(nsdvpy.sdv_read_py())'''

'''print('Modules:')
for mod in sys.modules:
    if mod == 'nsdvpy':
        print(mod)
del sys.modules['nsdvpy']
for mod in sys.modules:
    if mod == 'nsdvpy':
        print(mod)'''