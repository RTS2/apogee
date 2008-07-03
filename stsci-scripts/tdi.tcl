#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : driftscan
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure manages driftscan observations. All the heavy lifting is
#  done by the C/C++ code of course.
#
#  Arguments  :
#
#               nrow	-	Number of rows to readout (optional, default is 0)
#               delay	-	Per-row delay in microseconds (optional, default is 0)
#               nblock	-	Number of rows to read per cycle (optional, default is 1)
#               shutter	-	Shutter open(1), closed(0) (optional, default is 1)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc driftscan { {nrow 0} {delay 0} {nblock 1} {shutter 1} {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               SCOPE	-	Telescope parameters, gui setup
#               DEBUG	-	Set to 1 for verbose logging
global CAMERAS SCOPE DEBUG
  if { $delay == 0 } {set delay $SCOPE(driftdcalc)}
  if { $nrow == 0 } {set nrow $SCOPE(driftrows)}
# PRM, 15Jun2002, added shutter control
  set shutter $SCOPE(shutter)
  if { $DEBUG } {debuglog  "Drift scan using delay = $delay, rows = $nrow, nblock = $nblock, shutter = $shutter"}
  set camera $CAMERAS($id)
  setutc
  $camera configure -m_TDI 1
  $camera Expose [expr $delay/1000] $shutter
  $camera BufferDriftScan drift $delay $nrow $nblock
# PRM 13Jun2002 begin; if shutter was opened, then close it at the end
  if { $shutter == 1 } {$camera write_ForceShutterOpen 0}
# PRM 13Jun2002 end
  set name "$SCOPE(datadir)/$SCOPE(imagename).fits"
  saveandshow drift $name
  $camera configure -m_TDI 0
  $camera Flush
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : driftcalib
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#
#  This procedure calculates the equatorial drift rate based upon a 
#  rate measured by the user at an arbritary (hopefully accurate) known
#  DEC.
#
#  Arguments  :
#
 
proc driftcalib { } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
global SCOPE
   set delay $SCOPE(driftsamp)
   set d [dms_to_radians [.main.vdec get]]
   set fac [expr cos($d)]
   set SCOPE(driftdelay) [expr int($delay*$fac)]
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : driftcalc
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure calculates the drift rate in microseconds. It presumes that
#  the equatorial rate has already been calculated.
#
#
#  Arguments  :
#
 
proc driftcalc { } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
#               CAMSTATUS	-	Current values of camera variables
global SCOPE CAMSTATUS
   set delay $SCOPE(driftdelay)
   set d [dms_to_radians [.main.vdec get]]
   set fac [expr cos($d)]
   set SCOPE(driftdcalc) [expr int($delay/$fac)]
   set t [tlabel [expr $SCOPE(driftdcalc)/1000000.*($CAMSTATUS(NumY)+$SCOPE(driftrows))/3600./12.*3.14159]]
   set SCOPE(driftexp) $t
}

set DRIFTDELAY 0

