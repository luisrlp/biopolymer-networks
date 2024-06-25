# Run with python3 instead of python

import matplotlib
matplotlib.use('Agg')  # Use a non-GUI backend
import matplotlib.pyplot as plt
import numpy as np

'''
Output array has shape (6, n_steps):
[[u1],
 [u2],
 [sigma_principal],
 [sigma_11],
 [sigma_22],
 [sigma_12]]
'''
# Set the deformation mode so that only relevant info is plotted ('uni'axial, 'bi'axial, 'sh'ear)
def_mode = 'sh'
output = np.load('output.npy')

def stress_plot(data, def_mode:str):
    keys = [kk for kk in data.keys()]
    x = data[keys[0]]
    for i, k in enumerate(keys[1:]):
        plt.figure(i)
        plt.plot(x, data[k])
        plt.xlabel(keys[0], fontsize=16)
        plt.ylabel(k, fontsize=16)
        plt.grid(True, alpha=0.3)
        plt.savefig('plot_' + def_mode + '_' + str(i) + '.pdf', bbox_inches = 'tight')

s22 = output[4,:]
u2 = output[1,:]
stretch = u2 + 1

if def_mode == 'uni':
    data = {'$\lambda$': stretch,
                '$\sigma_{22}$ (Pa)': s22}
else:
    s11 = output[3,:]
    if def_mode == 'bi':
        data = {'$\lambda$': stretch,
                '$\sigma_{11}$ (Pa)': s11,
                '$\sigma_{22}$ (Pa)': s22}
    elif def_mode == 'sh':
        s12 = output[5,:]
        u1 = output[0,:]
        shear = np.arctan(u1)
        data = {'$\gamma$': shear,
                '$\sigma_{11}$ (Pa)': s11,
                '$\sigma_{22}$ (Pa)': s22,
                '$\\tau_{12}$ (Pa)': s12}

stress_plot(data, def_mode)
