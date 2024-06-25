# -*- coding: mbcs -*-
#
# Abaqus/Viewer Release 2022 replay file
# Internal Version: 2022_04_29-15.51.23 176069
# Run by lpacheco on Thu Jun 20 10:40:58 2024
#

# from driverUtils import executeOnCaeGraphicsStartup
# executeOnCaeGraphicsStartup()
#: Executing "onCaeGraphicsStartup()" in the site directory ...
from abaqus import *
from abaqusConstants import *
session.Viewport(name='Viewport: 1', origin=(0.0, 0.0), width=433.333312988281, 
    height=266.381683349609)
session.viewports['Viewport: 1'].makeCurrent()
session.viewports['Viewport: 1'].maximize()
from viewerModules import *
from driverUtils import executeOnCaeStartup
executeOnCaeStartup()
o1 = session.openOdb(
    name='/home/lpacheco/biopolymer-networks/test_in_abaqus/cube_anl.odb')
session.viewports['Viewport: 1'].setValues(displayedObject=o1)
#: Model: /home/lpacheco/biopolymer-networks/test_in_abaqus/cube_anl.odb
#: Number of Assemblies:         1
#: Number of Assembly instances: 0
#: Number of Part instances:     1
#: Number of Meshes:             1
#: Number of Element Sets:       3
#: Number of Node Sets:          11
#: Number of Steps:              1
session.viewports['Viewport: 1'].odbDisplay.display.setValues(plotState=(
    CONTOURS_ON_DEF, ))
session.viewports['Viewport: 1'].odbDisplay.basicOptions.setValues(
    scratchCoordSystemDisplay=OFF)
session.viewports['Viewport: 1'].viewportAnnotationOptions.setValues(
    legend=OFF)
session.viewports['Viewport: 1'].viewportAnnotationOptions.setValues(legend=ON, 
    compass=OFF)
session.viewports['Viewport: 1'].viewportAnnotationOptions.setValues(state=OFF)
session.viewports['Viewport: 1'].viewportAnnotationOptions.setValues(title=OFF)
session.printOptions.setValues(vpDecorations=OFF)
session.printToFile(fileName='cube_image', format=PNG, canvasObjects=(
    session.viewports['Viewport: 1'], ))
