#
# Define the global environment, everything lives under /opt/apogee
# Change TKAPOGEE to move the code somewhere else
#
set TKAPOGEE /opt/apogee

source  $TKAPOGEE/scripts/nogui.tcl

set SCOPE(imagename) [exec date +%j%H%M]

#set SCOPE(shutter) 1
#set SCOPE(exptype) "Object"
set SCOPE(shutter) 0
set SCOPE(exptype) "Dark"

#this was used prior to Sep 2003
#driftscan 14000 105400

driftscan 9000 50000

exit
