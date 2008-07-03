#
# Define the global environment, everything lives under /opt/apogee
# Change TKAPOGEE to move the code somewhere else
#
set TKAPOGEE /opt/apogee

source  $TKAPOGEE/scripts/nogui.tcl

#using the .apgui.tcl.snapshot.bin2 these are already defined properly
set CONFIG(geometry.BinX) 2
set CONFIG(geometry.BinY) 2
# but due to the bug in watchconfig, these are necessary to get a 512x512 image.
set CONFIG(geometry.NumCols) 512
set CONFIG(geometry.NumRows) 512

#the next line defines the filename in terms of the local time
#if you comment it out, the filename will be as in .apgui.tcl (e.g. test.fits)
#set SCOPE(imagename) [exec date +%j%H%M]
set SCOPE(overwrite) 1
set SCOPE(exposure) 4.0
#set SCOPE(shutter) 1
#set SCOPE(exptype) "Object"
set SCOPE(shutter) 0
set SCOPE(exptype) "Dark"
#set SCOPE(target) "foo"

# these print a lot of parameters to the console.
#printcamdata
#printscopedata

# this line in nogui.tcl is important to actually set the values into C++
# but don't use it here, I think.
#trace variable CONFIG w watchconfig

# this line in nogui.tcl seems to fix the exposure time to 0.1 sec or
# something. so comment it out in nogui.tcl
#trace variable SCOPE w watchscope

# take the picture, display it in ds9, and save it to disk.

obstodisk 1

# ramp CCD to ambient temperature
#setpoint AMB

# just switch off the TEC (not recommended because thermal shock may crack CCD)
#setpoint OFF
# cool the TEC to NN degrees Celcius
#setpoint SET $CONFIG(temperature.Target)
#setpoint SET [expr $CONFIG(temperature.Target) +1]

exit
