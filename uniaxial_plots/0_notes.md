Plots created for monotonic uniaxial tensile tests, varying the cross_linker stiffness and total end-to-end distance.

- end-to-end distance (r0 = r0f + r0c): is changed in anl_ai.f90 (props(6 and 7))

- cross-linker sitffness (eta = drf/dr): is changed in anl_ai.f90 (props(8))

- .out files: 1) 1st column - dtime
              2) 2nd column - stretch
              3) 3rd column - stress (xx)

First value of each file name is the end-to-end distance, while the second is the CL stiffness.