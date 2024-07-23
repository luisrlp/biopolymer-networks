# -*- coding: mbcs -*-
#
# Abaqus/Viewer Release 6.14-3 replay file
# Internal Version: 2015_02_02-21.14.46 134785
# Run by jferreira on Fri Dec 18 14:10:08 2015
#

# from driverUtils import executeOnCaeGraphicsStartup
# executeOnCaeGraphicsStartup()
#: Executing "onCaeGraphicsStartup()" in the site directory ...
import os
from abaqus import *
from abaqusConstants import *
import numpy as np

# ODB file to get data from
file = 'cube_anl_rnd.odb'

# Define deformation mode (if relevant) - 'uni', 'bi', 'sh'
# def_mode = 'uni'

session.Viewport(name='Viewport: 1', origin=(0.0, 0.0), width=243.416656494141, 
    height=165.277770996094)
session.viewports['Viewport: 1'].makeCurrent()
session.viewports['Viewport: 1'].maximize()
from viewerModules import *
from driverUtils import executeOnCaeStartup
executeOnCaeStartup()

odb_file = os.path.join(os.getcwd(), file)

o1 = session.openOdb(name=odb_file)
session.viewports['Viewport: 1'].setValues(displayedObject=o1)
session.viewports['Viewport: 1'].odbDisplay.display.setValues(plotState=(
    CONTOURS_ON_DEF, ))
odb = session.odbs[odb_file]
session.xyDataListFromField(odb=odb, outputPosition=NODAL, 
                            variable=(('U', NODAL, ((COMPONENT, 'U1'), (COMPONENT, 'U2'),)), 
                                      ('S', INTEGRATION_POINT, ((INVARIANT, 'Max. Principal'), (COMPONENT, 'S11'), (COMPONENT, 'S22'), (COMPONENT, 'S12'),)), 
                                      ('SDV_DET', INTEGRATION_POINT), ), 
                                      nodePick=(('PART-1-1', 1, ('[#1 ]', )), ), )
u1 = session.xyDataObjects['U:U1 PI: PART-1-1 N: 1']
u2 = session.xyDataObjects['U:U2 PI: PART-1-1 N: 1']
s_principal = session.xyDataObjects['S:Max Principal (Avg: 75%) PI: PART-1-1 N: 1']
s11 = session.xyDataObjects['S:S11 (Avg: 75%) PI: PART-1-1 N: 1']
s22 = session.xyDataObjects['S:S22 (Avg: 75%) PI: PART-1-1 N: 1']
s12 = session.xyDataObjects['S:S12 (Avg: 75%) PI: PART-1-1 N: 1']
t = []
for frame in odb.steps['static'].frames:  # Use 'static' as the step name
    t.append(frame.frameValue)



data_list = [u2, s_principal, s11, s22, s12, t]
output_array = np.array([pt[1] for pt in u1.data])

for i, dt in enumerate(data_list):
    if i == len(data_list)-1:
        aux_array = np.array(t)
    else:
        aux_array = np.array([pt[1] for pt in dt.data])
    output_array = np.vstack((output_array, aux_array))
    
np.save('output.npy', output_array)




