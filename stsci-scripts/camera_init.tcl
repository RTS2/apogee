#
#  This file contains the most Apogee camera specific parts of the interface.
#  It is designed so that other camera types can easily be incorporated in
#  future (hopefully)
#
#

#
# Define the global environment, everything lives under /opt/apogee
# Change TKAPOGEE to move the code somewhere else
#
set TKAPOGEE /opt/apogee

#
#  This set of definitions is at the heart of the API interface. It defines an
#  assocation between items in the C++ API, and the generic elements of the
#  user interface. These elements are defined in the tcl_config.dat file.
#  Entries in this file automatically generate GUI widgets, and the 
#  lines below link these widgets with C++ callbacks in the CameraIO object.
#
set CCAPI(geometry.BIC) BIC
set CCAPI(geometry.BIR) BIR
set CCAPI(system.Base) BaseAddress
set CCAPI(geometry.BinX) BinX
set CCAPI(geometry.BinY) BinY
set CCAPI(ccd.Color) Color 
set CCAPI(geometry.Columns) Columns
set CCAPI(temperature.Mode) CoolerMode
set CCAPI(temperature.Target) CoolerSetPoint
set CCAPI(temperature.Status) CoolerStatus
set CCAPI(system.Data_Bits) DataBits 
set CCAPI(filter.Position) FilterPosition
set CCAPI(filter.StepPos) FilterStepPos
set CCAPI(ccd.Gain) Gain
set CCAPI(system.Guider_Relays) GuiderRelays 
set CCAPI(geometry.HFlush) HFlush 
set CCAPI(system.HighPriority) HighPriority
set CCAPI(geometry.Imgcols) ImgColumns
set CCAPI(geometry.Imgrows) ImgRows
set CCAPI(system.Interface) Interface
set CCAPI(system.Cable) LongCable
set CCAPI(system.MaxBinX) MaxBinX 
set CCAPI(system.MaxBinY) MaxBinY 
set CCAPI(ccd.Mode) Mode
set CCAPI(ccd.Noise) Noise
set CCAPI(geometry.NumCols) NumX
set CCAPI(geometry.NumRows) NumY
set CCAPI(ccd.PixelXSize) PixelXSize
set CCAPI(ccd.PixelYSize) PixelYSize
set CCAPI(system.RegisterOffset) RegisterOffset
set CCAPI(geometry.Rows) Rows
set CCAPI(ccd.Sensor) Sensor
set CCAPI(system.Sensor) SensorType
set CCAPI(system.Shutter_Speed) Shutter
set CCAPI(geometry.SkipC) SkipC
set CCAPI(geometry.SkipR) SkipR
set CCAPI(geometry.StartCol) StartX
set CCAPI(geometry.StartRow) StartY
set CCAPI(system.CameraStatus) Status
set CCAPI(geometry.DriftScan) TDI 
set CCAPI(temperature.Cal) TempCalibration 
set CCAPI(temperature.Control) TempControl
set CCAPI(temperature.Scale) TempScale 
set CCAPI(temperature.Value) Temperature
set CCAPI(system.Test2) Test2Bits
set CCAPI(system.Test) TestBits
set CCAPI(system.Timeout) Timeout
set CCAPI(system.Trigger) UseTrigger 
set CCAPI(geometry.VFlush) VFlush

#
#  Create reverse loopup into the CCAPI
#

foreach i [array names CCAPI] {
   set CCAPI($CCAPI($i)) $i
}


set DEBUG 0




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : debuglog
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  Redirect debug messages, currently just print them out
#
#  Arguments  :
#
#               msg	-	message text
 
proc debuglog { msg } {
 
#
#  Globals    :		n/a
#  
   puts stdout "$msg"
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : fileopen
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure lets the user select a configuration file then 
#  parses it to initialize the GUI widgets.
#
#  Arguments  :
#
 
proc fileopen { } {
 
#
#  Globals    :
#  
#               CFGFILE	-	Configuraion file in use
#               DEBUG	-	Set to 1 for verbose logging
#               TKAPOGEE	-	Base directory for installation
#               env	-	The shell environment
global CFGFILE DEBUG TKAPOGEE env
   set cfg [tk_getOpenFile -initialdir $TKAPOGEE/config -filetypes {{{Apogee cameras} {.ini}}}]
   if { $DEBUG } {debuglog "Loading configuration from $cfg"}
   loadconfig $cfg
   exec ln -sf $CFGFILE $env(HOME)/.apccd.ini
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : loadconfig
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure opens a named Apogee .ini configuration file and
#  parses the contents. Items are entered in the global array CONFIG, 
#  which has automatic callbacks to the GUI widgets.
#
#  Arguments  :
#
#               cfg	-	Configuration file name
 
proc loadconfig { cfg } {
 
#
#  Globals    :
#  
#               CFGFILE	-	Configuraion file in use
#               CONFIG	-	GUI configuration
#               DEBUG	-	Set to 1 for verbose logging
global CFGFILE CONFIG DEBUG
   set CFGFILE $cfg
   set fcfg [open $CFGFILE r]
   while { [gets $fcfg rec] > -1 } {
      if { [string range $rec 0 0] == "\[" } {
         set subsys [lindex [split $rec "\[\]"] 1]
      }
      if { [llength [split $rec "="]] == 2 } {
         set par [string trim [lindex [split $rec "="] 0]]
         if { $par == "ImgRows" } {set par Imgrows}
         if { $par == "ImgCols" } {set par Imgcols}
         set val [lindex [split $rec "="] 1]
         set CONFIG($subsys.$par) [string trim $val]
         if { $DEBUG } {debuglog "Configuration $subsys,$par = $val"}
      }
   }
   close $fcfg
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : shutdown
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  Set the camera to  ramp-up to ambient, and then exit
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc shutdown { {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
global CAMERAS
   set it [tk_dialog .d "Exit" "Confirm exit" {} -1 "Cancel" "EXIT" "EXIT and ramp cooler to ambient"]
   if { $it == 1 } {
     set camera $CAMERAS($id)
     catch { exec xpaset -p ds9 exit }
     exit
     } else {
     if { $it == 2 } {
       set camera $CAMERAS($id)
       $camera write_CoolerMode 2
       catch { exec xpaset -p ds9 exit }
       exit
       }
     }
}






#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : apogeeSetVal
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure is a simple wrapper to easily set Apogee camera parameters
#  using the C++ wrapper interface.
#
#  Arguments  :
#
#               configPar	-	Name of a .ini configuration parameter
#               objPar	-	Name of C++ instance variable
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc apogeeSetVal { configPar objPar {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               CONFIG	-	GUI configuration
global CAMERAS DEBUG CONFIG
  set camera $CAMERAS($id)
  if { [info exists CONFIG($configPar)] } {
     if { $DEBUG } {debuglog "Setting value for $objPar = $CONFIG($configPar)"}  
     $camera configure -m_$objPar $CONFIG($configPar)     
  } else {
     if { $DEBUG } {debuglog "No value available for $configPar"}
  }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : apogeeSetBool
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine is a simple wrapper to set boolean Apogee camera variables.
#
#  Arguments  :
#
#               configPar	-	Name of a .ini configuration parameter
#               objPar	-	Name of C++ instance variable
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc apogeeSetBool { configPar objPar {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               CONFIG	-	GUI configuration
global CAMERAS DEBUG CONFIG
  set camera $CAMERAS($id)
  if { [info exists CONFIG($configPar)] } {
     if { $DEBUG } {debuglog "Setting value for $objPar = $CONFIG($configPar)"}
     set state [string toupper  $CONFIG($configPar)]
     switch $state {
             0         -
             OFF       -
             CCD       -
             FALSE     { $camera configure -m_$objPar 0 }
             1         -
             ON        -
             CMOS      -
             TRUE      { $camera configure -m_$objPar 1 }
     }
  } else {
     if { $DEBUG } {debuglog "No value available for $configPar"}
  }
}

#
#  Load the Apogee ini file
#

loadconfig $env(HOME)/.apccd.ini

#
#  Load the appropriate wrapper library (only ISA and PPI exist currently)
#

switch $CONFIG(system.Interface) {
      ISA {load $TKAPOGEE/lib/apogee_ISA.so}
      PPI {load $TKAPOGEE/lib/apogee_PPI.so}
      PCI {load $TKAPOGEE/lib/apogee_PCI.so}
      USB {load $TKAPOGEE/lib/apogee_USB.so}
}

set XLATE(SHORT) 0
set XLATE(LONG)  1
set CAMERAS(0) [CCameraIO]
set CAMERA $CAMERAS(0)


#
#  Setup the camera, using values read from the .ini file
#
#    These  2 value are no longer set here, they are specified
#    when the kernel module is loaded
#
#	apogeeSetVal system.Base BaseAddress
#	apogeeSetVal system.Reg_offset RegisterOffset
#

apogeeSetVal geometry.Rows Rows
apogeeSetVal geometry.Columns Columns
apogeeSetVal system.PP_Repeat PPRepeat

$CAMERA InitDriver 0
$CAMERA Reset 
$CAMERA write_LongCable $XLATE($CONFIG(system.Cable))
$CAMERA write_UseTrigger 0
$CAMERA write_ForceShutterOpen 0

apogeeSetBool system.High_priority HighPriority
apogeeSetVal system.Data_Bits DataBits
apogeeSetBool system.Sensor SensorType 

$CAMERA write_Mode $CONFIG(system.Mode)
$CAMERA write_TestBits $CONFIG(system.Test)
if { [info exists CONFIG(system.Test2)] } {
   $CAMERA write_Test2Bits $CONFIG(system.Test2)
}

switch $CONFIG(system.Shutter_Speed) {
      normal {
              $CAMERA configure -m_FastShutter 0
              $CAMERA configure -m_MaxExposure 1048.75
              $CAMERA configure -m_MinExposure 0.01
             }
      fast   {
              $CAMERA configure -m_FastShutter 1
              $CAMERA configure -m_MaxExposure 1048.75
              $CAMERA configure -m_MinExposure 0.001
             }
      dual   {
              $CAMERA configure -m_FastShutter 1
              $CAMERA configure -m_MaxExposure 1048.75
              $CAMERA configure -m_MinExposure 0.001
             }
}
set CONFIG(tmp1) [expr $CONFIG(system.Shutter_Bits) & 0x0f]
apogeeSetVal tmp1 FastShutterBits_Mode
set CONFIG(tmp1) [expr ($CONFIG(system.Shutter_Bits) & 0xf0) >> 4]
apogeeSetVal tmp1 FastShutterBits_Test
apogeeSetVal system.MaxBinX MaxBinX
apogeeSetVal system.MaxBinY MaxBinY
apogeeSetBool system.Guider_Relays GuiderRelays
apogeeSetVal system.Timeout Timeout
apogeeSetVal geometry.BIC BIC
apogeeSetVal geometry.BIR BIR
apogeeSetVal geometry.SkipC SkipC
apogeeSetVal geometry.SkipR SkipR
apogeeSetVal geometry.Imgcols ImgColumns
apogeeSetVal geometry.Imgrows ImgRows
apogeeSetVal geometry.HFlush HFlush
apogeeSetVal geometry.VFlush VFlush
apogeeSetVal geometry.Imgcols NumX
apogeeSetVal geometry.Imgrows NumY
apogeeSetBool temp.Control TempControl 
apogeeSetVal temp.Cal TempCalibration 
apogeeSetVal temp.Scale TempScale 
# PRM 15Jun2002, don't mess with Cooler on startup
# $CAMERA write_CoolerSetPoint $CONFIG(temp.Target)
# $CAMERA write_CoolerMode  0
# $CAMERA write_CoolerMode  1   
# OK then turn it on then
apogeeSetBool ccd.Color Color 
apogeeSetVal ccd.Noise Noise
apogeeSetVal ccd.Gain Gain
apogeeSetVal ccd.PixelXSize PixelXSize
apogeeSetVal ccd.PixelYSize PixelYSize







#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : test
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This is a minimal test procedure to test exposure, in-memory buffer, and save-to-disk
#
#  Arguments  :
#
#               exp	-	Exposure time in seconds
#               name	-	Image file name
#               light	-	Shutter open(1) or closed(0) (optional, default is 0)
 
proc test { exp name {light 0} } {
 
#
#  Globals    :
#  
#               CAMERA	-	id of current camera
#               DEBUG	-	Set to 1 for verbose logging
global CAMERA DEBUG
  if { $DEBUG } {debuglog "T = [$CAMERA read_Temperature]"}
  if { $DEBUG } {debuglog "Starting exposure"}
  $CAMERA Expose $exp $light
  if { $DEBUG } {debuglog "Reading out..."}
  $CAMERA BufferImage READOUT
  if { $DEBUG } {debuglog "Saving to FITS $name"}
  write_image READOUT $name.fits
}



set DEBUG 1
