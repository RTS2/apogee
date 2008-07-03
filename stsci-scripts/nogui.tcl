
wm withdraw .

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : waituntil
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.5
#  Date       : Mar-26-2002
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine waits until the required time (day and hh:mm:ss)
#
#  Arguments  :
#
#               day	-	Day number in month
#		hh:mm:ss-	time in hours,mins,seconds
 
proc waituntil { day when } {
  set targ [split $when :]
  set tsecs [expr $day*24*60*60 + [lindex $targ 0]*60*60 + [lindex $targ 1]*60 + [lindex $targ 2]]
  set now 0
  while { $now < $tsecs} {
     exec sleep 1
     set d [exec date] 
     set ndy [lindex $d 2]
     set hms [split [lindex $d 3] :]
     set now [expr $ndy*24*60*60 + [format %f [lindex $hms 0]]*60*60 + [format %f [lindex $hms 1]]*60 + [format %f [lindex $hms 2]]]
  }
  puts stdout "ready"
}

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : showstatus
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine displays text messages in the status window
#
#  Arguments  :
#
#               msg	-	message text
 
proc showstatus { msg } {
 
#
#  Globals    :		n/a
#  
  puts stdout "$msg"
}


#
# Define the global environment, everything lives under /opt/apogee
# Change TKAPOGEE to move the code somewhere else
#
set TKAPOGEE /opt/apogee

#
# Define the path to the shared libraries.
# These libraries are used to add facilities to the default tcl/tk
# wish shell. 
#
set libs /opt/apogee/lib

#
# Load the tcl interface to FITS (Flexible image transport system) disk files
# FITS is the standard disk file format for Astronomical data
#

showstatus "Loading FitsTcl"
load $libs/libfitsTcl.so

###PRM 29Oct#### Prepare for Guide Star Catalog access
###PRM 29Oct###package ifneeded gsc 3.1       [load $libs/libgsc.so]
###PRM 29Oct###
###PRM 29Oct#### Prepare for Digital sky survey access
###PRM 29Oct###package ifneeded dss 3.1       [load $libs/libdss.so]
###PRM 29Oct###
###PRM 29Oct#### Prepare for Oracle (target ephemeris prediction)
###PRM 29Oct###package ifneeded oracle 2.1    [load $libs/liboracle.so]
###PRM 29Oct###
# Prepare for generic astrometry
package ifneeded xtcs 3.1      [load $libs/libxtcs.so]

###PRM 30Oct#### Prepare for Graphics widget package
###PRM 30Oct###package ifneeded BLT 2.4       [load $libs/libBLT24.so]

# Prepare for Ccd image buffering package
package ifneeded ccd 1.0       [load $libs/libccd.so]

###PRM 29Oct#### Load packages provided by dynamically loadable libraries
###PRM 29Oct###showstatus "Loading Digital Sky survey access"
###PRM 29Oct###package require dss
###PRM 29Oct###showstatus "Loading GSC catalog access"
###PRM 29Oct###package require gsc
###PRM 29Oct###showstatus "Loading Oracle"
###PRM 29Oct###package require oracle
###PRM 30Oct###showstatus "Loading graphics package"
###PRM 30Oct###package require BLT
###PRM 30Oct###namespace import blt::graph
showstatus "Loading CCD package"
package require ccd
###PRM 30Oct###lappend auto_path $libs/BWidget-1.2.1
###PRM 30Oct###package require BWidget






#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : getDSS
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure provides access to the Digital Sky Survey (100x compressed)
#  dataset. These can be purchased from "The Astronomical Society of the Pacific"
#  The cdroms provide 1arcsec resolution coverage of the entire sky. 
#  The location of the DSS files is specified by the configuration in
#  /opt/apogee/scripts/dss.env
#
#  Arguments  :
#
#               name	-	Image file name
#               ra	-	RA in the form hh:mm:ss.ss
#               dec	-	DEC in the form +ddd:mm:ss.ss
#               xsize	-	X dimension in arcmin
#               ysize	-	Y dimension in arcmin
 
proc getDSS {name ra dec xsize ysize } {
 
#
#  Globals    :		n/a
#  
   set fout [open /tmp/dsscmd w]
   puts $fout "$name [split $ra :] [split $dec :] $xsize $ysize"
   close $fout
   dss -i /tmp/dsscmd
   set f [glob $name*.fits]
   checkDisplay
   exec xpaset -p ds9 file $f
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : checkDisplay
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure checks if the image display tool DS9 is up and running.
#  If not we start a copy. The xpans server is used to communicate with DS9
#  it should always be running, as a copy is started by the /opt/apogee/scripts/setup.env
#
#  Arguments  :
#
 
proc checkDisplay { } {
 
#
#  Globals    :		n/a
#  
   set x ""
   catch {set x [exec xpaget ds9]}
   if { $x == "" } {
      exec /opt/apogee/bin/ds9 &
   }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : getGSC
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This proceduure provides access to the Compressed version of the Hubble
#  Guide Star Catalog. This catalog contains the same set of objects, but 
#  occupies only ~300Mb of disk space, rather than 2 full cdroms.
#
#  The obtained set of positions are overlaid on the current image displayed
#  in the DS9 image display tool. For other purposes, simply use the 
#  cmdGFind call to return the list of objects for further processing.
#
#  Arguments  :
#
#               ra	-	RA in the form hh:mm:ss.ss
#               dec	-	DEC in the form +ddd:mm:ss.ss
#               xsize	-	X dimension in arcmin
#               ysize	-	Y dimension in arcmin
 
proc getGSC { ra dec xsize ysize } {
 
#
#  Globals    :		n/a
#  
   if { $xsize < 0 } {
      set results [exec cat testgsc.dat]
   } else {
      set results [cmdGFind $ra $dec $xsize $ysize]
   }
   set byline [lrange [split $results "\n"] 1 end]
   exec xpaset -p ds9 regions deleteall                                                
   foreach l $byline {
      set lra  [join [lrange $l 1 3] :]
      set ldec [join [lrange $l 4 6] :]
      exec xpaset -p ds9 regions circle $lra $ldec 5.
   }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : locateObjs
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  Test routine, will eventually be part of automatic image coordinate
#  system calibration
#
#  Arguments  :
#
 
proc locateObjs { } {
 
#
#  Globals    :		n/a
#  
   set fin [open test.cat r]
   exec xpaset -p ds9 regions coordformat xy
   exec xpaset -p ds9 regions deleteall                                                
   set i 7
   while { $i > 0 } {gets $fin rec ;  incr i -1}
   while { [gets $fin rec] > -1 } {
      exec xpaset -p ds9 regions circle [lindex $rec 4] [lindex $rec 5] 5.
   }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : getRegion
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure will eventaully be part of automatic coordinate determination
#
#  Arguments  :
#
 
proc getRegion { } {
 
#
#  Globals    :		n/a
#  
   set res [exec xpaget  ds9 regions]
   set i [lsearch $res "image\;box"]
   if { $i < 0 } {
      exec  xpaset -p ds9 regions deleteall  
      tk_dialog
   }
   set lx [lindex $res [expr $i+1]]
   set ly [lindex $res [expr $i+2]]
   set nx [lindex $res [expr $i+3]]
   set ny [lindex $res [expr $i+4]]
#  test command for sextractor
# /opt/apogee/bin/sextractor -DETECT_MINAREA 10 -DETECT_THRESH 30 test207vo.fits        
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : autoIdentify
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  Experimental - This procedure attempts to autocorrelate image coordinate
#  lists between GSC and an  sextractor run
#
#
#  Arguments  :
#
#               imax	-	Maximum number of candidates (optional, default is 20)
#               type	-	Calibration type (flat,dark,sky,zero) (optional, default is raw)
#               aspp	-	Threshold (optional, default is 1.7)
 
proc autoIdentify { {imax 20} {type raw} {aspp 1.7} } {
 
#
#  Globals    :
#  
#               X	-	X data for temperature plot
#               Y	-	Y data for temperature plot
#               F	-	 
global X Y F
    exec sort -r +2 test.cat > stest.dat
    if { $type == "raw" } {
     set fin [open stest.dat r]
     set i 1
     while { $i < $imax } {
        gets $fin rec
        if { [string range $rec 0 0] != "#" } {   
          set X($i) [lindex $rec 4]
          set Y($i) [lindex $rec 5]
          set F($i) [lindex $rec 2]
          incr i 1
        }
     }
     close $fin
    } 
    if { $type == "gsc" } {
     set fin [open testgsc.dat r]
     set i 1
     set DEC 50
     while { $i < $imax } {
        gets $fin rec
        set dec [expr ([lindex $rec 4]*3600+[lindex $rec 5]*60+[lindex $rec 6])  / $aspp]
        set ra [expr ([lindex $rec 1]*3600+[lindex $rec 2]*60+[lindex $rec 3]) *15. / $aspp]
        set ra [expr $ra*cos($DEC/180.*3.14159)]
        set X($i) $ra
        set Y($i) $dec
        set F($i) [lindex $rec 7]
        incr i 1
     }
     close $fin
    } 
    set i 1
    while { $i < $imax } {
       set mind 9999999999.
       set maxd 0.
       set j 1
       while { $j < $imax  } {
         if { $i != $j } {
           set d [expr sqrt( ($X($i)-$X($j))*($X($i)-$X($j)) + ($Y($i)-$Y($j))*($Y($i)-$Y($j)) )]
           if { $d > $maxd } {set maxd $d}
           if { $d < $mind && $d > 50.} {
              set mind $d
              set minj($i) $j
           }
         }
         incr j 1
       }
       set M($i) [expr $maxd / $mind]
       puts stdout "$i $mind $minj($i)"
       incr i 1
    }
}






#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : choosedir
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure prompts the user to specify a directory using a 
#  flexible GUI interface.
#
#  Arguments  :
#
#               type	-	Calibration type (flat,dark,sky,zero)
#               name	-	Image file name
 
proc choosedir { type name} {
 
#
#  Globals    :
#  
#               CALS	-	Calibration run parmaeters
#               CATALOGS	-	Catalog configurations
#               SCOPE	-	Telescope parameters, gui setup
global CALS CATALOGS SCOPE
   if { $type == "data" } {
     set cfg [tk_chooseDirectory -initialdir $SCOPE(datadir)/$name]
     set SCOPE(datadir) $cfg
     .main.seldir configure -text "$cfg"
   } else {
     set cfg [tk_chooseDirectory -initialdir $CALS(home)/$name]
   }
   if { [string length $cfg] > 0 } {
     if { [file exists $cfg] == 0 } {
        exec mkdir -p $cfg
     }
     switch $type {
         calibrations {set CALS($name,dir) $cfg }
         catalogs     {set CATALOGS($name,dir) $cfg }
     }
   }
}

#
#
#  Set defaults for the directories used to store calibration 
#  library frames
#
set CALS(home) $env(HOME)/calibrations
set CALS(zero,dir) $CALS(home)/zero
set CALS(dark,dir) $CALS(home)/dark
set CALS(flat,dir) $CALS(home)/flat
set CALS(skyflat,dir) $CALS(home)/skyflat
set SCOPE(datadir) $env(HOME)




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : inspectapi
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure inspects the set of wrapper commands generated by SWIG.
#  These commands will be of the form Object_somename_set/get, and the
#  instance variable wrappers will be of the form -m_somename.
#  This predictable nomenclature is exploited to parse the set of 
#  all available commands, and seek out all those associated with 
#  the named C++ object type.
#
#  This ensures that when facilities are added to the C++ code, only
#  minimal rewrite (if any) will be needed in the tcl code.
#
#  Arguments  :
#
#               object	-	Name of wrapped C++ object
 
proc inspectapi { object } {
 
#
#  Globals    :
#  
#               CCAPIR	-	C++ readable instance variables
#               CCAPIW	-	C++ writable instance variables
global CCAPIR CCAPIW
  set all [info commands]
  foreach i $all { 
     set s [split $i _]
     if { [lindex $s 0] == $object } {
        if { [lindex $s end] == "get" } {
           set name [join [lrange $s 1 [expr [llength $s]-2]] _]
           set CCAPIR($name) cget
        }
        if { [lindex $s end] == "set" } {
           set name [join [lrange $s 1 [expr [llength $s]-2]] _]
           set CCAPIW($name) configure
        }
        if { [lindex $s 1] == "read" } {
           set name [join [lrange $s 1 end] _]
           set CCAPIR($name) method
        }
        if { [lindex $s 1] == "write" } {
           set name [join [lrange $s 1 end] _]
           set CCAPIW($name) method
        }
     }
  }
}






#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : printcamdata
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure loop thru all the items in CAMSTATUS and 
#  prints the current values, primarily for interactive debugging use.
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc printcamdata { {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               CAMSTATUS	-	Current values of camera variables
global CAMERAS CAMSTATUS
    foreach i [lsort [array names CAMSTATUS]] { 
        puts stdout "$i = $CAMSTATUS($i)"
    }
}

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : printscopedata
#
#---------------------------------------------------------------------------
#  Author     : PRM
#
#  This procedure loop thru all the items in SCOPE and 
#  prints the current values, primarily for interactive debugging use.
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc printscopedata { {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               SCOPE	-	Current values of camera variables
global CAMERAS SCOPE
    foreach i [lsort [array names SCOPE]] { 
        puts stdout "$i = $SCOPE($i)"
    }
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : refreshcamdata
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure interrogates the current value of all instance variables
#  exported from the C++ api. Values are stored into the global array
#  CAMSTATUS for easy acces from the tcl code
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc refreshcamdata { {id 0} } {
 
#
#  Globals    :
#  
#               CAMSTATUS	-	Current values of camera variables
#               CCAPIR	-	C++ readable instance variables
#               CCAPI	-	Generic C++ object names
#               CAMERAS	-	Camera id's
#               CONFIG	-	GUI configuration
global CAMSTATUS CCAPIR CCAPI CAMERAS CONFIG
    set camera $CAMERAS($id)
    foreach i [lsort [array names CCAPIR]] { 
       if { $CCAPIR($i) == "method" } {
          set CAMSTATUS([string range $i 5 end]) [$camera $i]
          set name [string range $i 5 end]
          if { [info exists CCAPI($name)] } {
             set CONFIG($CCAPI($name)) $CAMSTATUS($name)
          }
       }
       if { $CCAPIR($i) == "cget" } {
          set name [string range $i 2 end]
          set CAMSTATUS($name) [$camera cget -$i]
          if { [info exists CCAPI($name)] } {
             set CONFIG($CCAPI($name)) $CAMSTATUS($name)
          }
       }
    }
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : get_temp
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure retrieves the current ccd temperature, it is included so that
#  future versions can transparently support other makes of camera.
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc get_temp { {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
global CAMERAS
   set t [$CAMERAS($id) read_Temperature]
   return $t
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : setpoint
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure controls the operation of the cooling circuit. 
#  The cooler can be swithed off, ramped to ambient, or ramped to 
#  a required target temperature.
#
#  Arguments  :
#
#               op	-	Operation specifier
#               t	-	Temperature (degrees c) (optional, default is 10.0)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc setpoint { op {t 10.0} {id 0} } {
 
#
#  Globals    :
#  
#               CCD_TMP	-	 
#               SETPOINTS	-	Cooler setpoints
#               CAMERAS	-	Camera id's
global CCD_TMP SETPOINTS CAMERAS
    set op [string toupper $op]
    set camera $CAMERAS($id)
    switch $op {
       SET { $camera write_CoolerMode 1 
             $camera write_CoolerSetPoint $t 
           }
       AMB { $camera write_CoolerMode 2 
           }
       OFF { $camera write_CoolerMode 0
           }
       ON  { $camera write_CoolerMode 1
             $camera write_CoolerSetPoint $SETPOINTS
             set t $SETPOINTS
           }
    }
    if { $op == "SET" || $op == "ON"  } {
       set SETPOINTS $t
    } else {
       set SETPOINTS 99
    }
}
   

#
#  Define globals for temperature control

set TEMPS ""
set STATUS(tempgraph) 1







#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : monitortemp
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure monitors the ccd temperature, and periodically calls 
#  plottemp to update the graphical display. The temperature as plotted is
#  based on an average of the last 10 values, this is done because the 
#  least significant bit of the temperature ADC represents ~0.5degrees
#  and averaging produces a more representative display.
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc monitortemp { {id 0} } {
 
#
#  Globals    :
#  
#               TEMPS	-	Raw temperatures
#               AVGTEMPS	-	Average temps for plotting
#               STATUS	-	Exposure status
global TEMPS AVGTEMPS STATUS
  if { $STATUS(tempgraph) }  {
   set t [lindex [get_temp $id] 0]
   if { $TEMPS == "" } {
       set TEMPS "$t $t $t $t $t $t $t $t $t $t"
   } else {
       set TEMPS [lrange "$t $TEMPS" 0 9]
   }
   set i 0
   set temp 0
   while { $i < 10 } {set temp [expr $temp+[lindex $TEMPS $i]] ; incr i 1}
   set AVGTEMPS [expr $temp/10.0]
   plottemp
   after 5000 monitortemp
  }
}

 



#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : plottemp
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure updates the graphical display of temperature.
#  It uses the  BLT graph widget to do all the hard work.
#
#  Arguments  :
#
 
proc plottemp { } {
 
#
#  Globals    :
#  
#               ydata	-	temp plot array - temp
#               ysetp	-	temp plot array - setpoint
#               TEMPWIDGET	-	BLT temperature graph widget name
#               AVGTEMPS	-	Average temps for plotting
#               SETPOINTS	-	Cooler setpoints
global ydata ysetp TEMPWIDGET AVGTEMPS SETPOINTS
   set ydata "[lrange [split $ydata] 1 59] $AVGTEMPS"
   if { $SETPOINTS == 99 }  {
      set ysetp "[lrange [split $ysetp] 1 59] $AVGTEMPS"
   } else {
      set ysetp "[lrange [split $ysetp] 1 59] $SETPOINTS"
   }
   $TEMPWIDGET element configure Temp -symbol none -ydata $ydata
   $TEMPWIDGET element configure SetPoint -color red -symbol none -ydata $ysetp
   setminmax
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : setminmax
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure resets the display parameters for the temperature
#  graphic in an attempt to autoscale it to the recent range.
#
#  Arguments  :
#
 
proc setminmax { } {
 
#
#  Globals    :
#  
#               ydata	-	temp plot array - temp
#               ysetp	-	temp plot array - setpoint
#               TEMPWIDGET	-	BLT temperature graph widget name
global ydata ysetp TEMPWIDGET
  set min  9999999
  set max -9999999 
  foreach i $ydata { 
     if { $i < $min } { set min $i } 
     if { $i > $max } { set max $i } 
  }
  foreach i $ysetp { 
     if { $i < $min } { set min $i } 
     if { $i > $max } { set max $i } 
  }
  set r [expr ($max-$min)/5.+1.]
  $TEMPWIDGET yaxis configure -min [expr $min-$r] -max [expr $max+$r]
}






set PI 3.14159265359




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : tlabel
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes an input time in radians and converts it to hh:mm:ss form
#
#  Arguments  :
#
#               atime	-	Time in radians
 
proc tlabel { atime } {
 
#
#  Globals    :
#  
#               PI	-	 
global PI
    if { $atime < 0 } {
       set asign "-"
       set atime [expr -$atime]
    } else {
       set asign ""
    }
    set atime [expr $atime/$PI*12.0]
    set ahrs [expr int($atime)]
    set amins [expr int(60*($atime-$ahrs))]
    set asecs [expr int(($atime-$ahrs-$amins/60.0)*3600.0)]
    set out ""
    if { $ahrs < 10 } {
      set ahrs "0$ahrs"
    }
    if { $amins < 10 } {
      set amins "0$amins"
    }
    if { $asecs < 10 } {
      set asecs "0$asecs"
    }
    return "$asign$ahrs:$amins:$asecs"
}
                                                                                





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : showconfig
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure toggles visibility of the properties window.
#
#  Arguments  :
#
 
proc showconfig { } {
 
#
#  Globals    :
#  
  if { [winfo ismapped .p] } {
     wm withdraw .p
  } else {
     wm deiconify .p
  }
}

set STATUS(busy) 0




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : snapshot
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure is a minimal interface to take an exposure
#
#  Arguments  :
#
#               name	-	Image file name
#               exp	-	Exposure time in seconds
#               bcorr	-	Bias correction (1=yes) (optional, default is 0)
#               shutter	-	Shutter open(1), closed(0) (optional, default is 1)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc snapshot { name exp {bcorr 0} {shutter 1} {id 0} } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CFG	-	 
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               SCOPE	-	Telescope parameters, gui setup
global STATUS CFG CAMERAS DEBUG SCOPE
   if { $STATUS(busy) == 0 } {
    set STATUS(busy) 1
    set camera $CAMERAS($id)
    setutc
    $camera Expose $exp $shutter   
    set SCOPE(exposure) $exp
    set SCOPE(shutter) $shutter
    set SCOPE(exptype) OBJECT
    if { $DEBUG } {debuglog "exposing (snapshot)"}
    after [expr $exp*1000+1000] "grabimage $name.fits $bcorr $id"
  }
}


proc setutc { } {
global SCOPE
  set now [split [exec  date -u +%Y-%m-%d,%T] ,]
  set SCOPE(obsdate) [lindex $now 0]
  set SCOPE(obstime) [lindex $now 1]
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : testgeometry
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure uses the Expose method to test that the current set
#  of geometry parameters represents a legal combination.
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc testgeometry { {id 0} } {
 
#
#  Globals    :
#  
#               CONFIG	-	GUI configuration
#               CAMERAS	-	Camera id's
global CONFIG CAMERAS
   set exp 0.01
   set shutter 0
   set res "illegal"
   set camera $CAMERAS($id)
   set res [$camera Expose $exp $shutter]
   return $res
}







#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : snapsleep
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes an exposure and then sleeps until we expect the
#  exposure is over. At which point it is read out. This routine is 
#  deprecated, as waitforimage is much more useful for normal usage.
#
#  Arguments  :
#
#               name	-	Image file name
#               exp	-	Exposure time in seconds
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
#               shutter	-	Shutter open(1), closed(0) (optional, default is 1)
 
proc snapsleep { name exp {id 0} {shutter 1} } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CAMERAS	-	Camera id's
#               SCOPE	-	Telescope parameters, gui setup
global STATUS CAMERAS SCOPE
    set camera $CAMERAS($id)
    setutc
    $camera Expose $exp $shutter   
    set SCOPE(exposure) $exp
    set SCOPE(shutter) $shutter
    if { $DEBUG } {debuglog "exposing (snapshot)"}
    set STATUS(busy) 1
    exec sleep [expr ($exp*10+1000)/1000 + 1] 
    grabimage $name.fits
}






#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : flattobuffer
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a flat-field exposure and saves it in an
#  in-memory buffer name FLAT-n. It is intended to be used as part
#  of a calibration library creation sequence.
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc flattobuffer { n {id 0} } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               CALS	-	Calibration run parmaeters
#               SCOPE	-	Telescope parameters, gui setup
global STATUS CAMERAS DEBUG CALS SCOPE
    set camera $CAMERAS($id)
    set STATUS(busy) 1
    setutc
    $camera Expose $CALS(flat,exp) 1  
    set SCOPE(exposure) $CALS(flat,exp)
    set SCOPE(shutter) 1
    set SCOPE(exptype) FLAT
    if { $DEBUG } {debuglog "exposing (flattobuffer)"}
    set timeout [waitforimage [expr int($CALS(flat,exp))] $id]
    if { $timeout } {
       puts stdout "TIMEOUT/ABORT"
    } else {
      if { $DEBUG } {debuglog "Reading out..."}
      $camera BufferImage temp
      set STATUS(readout) 0
      store_calib temp FLAT $n 
    }
    set STATUS(busy) 0
}

proc abortexposure { {id 0} } {
global CAMERAS
  set camera $CAMERAS($id)
  $camera write_ForceShutterOpen 0
  $camera write_Shutter 0
  $camera Flush
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : waitforimage
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure periodically wakes up and checks if the current exposure is
#  ready to be read out yet. If not, it loops around again. If the elapsed time
#  exceeds the expected exposure time (plus a couple of seconds) then it times out.
#
#  Arguments  :
#
#               exp	-	Exposure time in seconds
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc waitforimage { exp {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               STATUS	-	Exposure status
#               DEBUG	-	Set to 1 for verbose logging
global CAMERAS STATUS DEBUG SCOPE
  set camera $CAMERAS($id)
  exec sleep 1
  if { $exp == 0 } {set exp 1}
  set STATUS(readout) 0
  set STATUS(pause) 0
  set SCOPE(darktime) 0
  set s [$camera read_Status]
  while { $s != 5 && $exp > 0} {
     update 
     exec usleep 990000
     incr exp -1
     set s [$camera read_Status]
     if { $STATUS(abort) } {
        abortexposure
        set exp -1
        return 1
     }
     if { $STATUS(pause) } {
        $camera write_ForceShutterOpen 0
        $camera write_Shutter 0
        while { $STATUS(pause) } {
           if { $STATUS(abort) } {
             abortexposure
             set exp -1
             return 1
           }
           update 
           exec usleep 100000
           set SCOPE(darktime) [expr $SCOPE(darktime) +1]
        }
        $camera write_ForceShutterOpen 1
        $camera write_Shutter 1
     }
     if { $SCOPE(darktime) > 0 } {set s 0}
     if { $DEBUG } {debuglog "waiting $exp $s"}
  }
  if { $SCOPE(darktime) > 0 } {
     $camera write_Shutter 0
     $camera write_ForceShutterOpen 0
     set s 5
  }
  set STATUS(readout) 1
  update
  if { $s != 5 } {
     return 1
  }
  return 0
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : darktobuffer
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a dark exposure and saves it in an
#  in-memory buffer name DARK-n. It is intended to be used as part
#  of a calibration library creation sequence.
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc darktobuffer { n {id 0} } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               CALS	-	Calibration run parmaeters
#               SCOPE	-	Telescope parameters, gui setup
global STATUS CAMERAS DEBUG CALS SCOPE
    set camera $CAMERAS($id)
    set STATUS(busy) 1
    setutc
    $camera Expose $CALS(dark,exp) 0  
    set SCOPE(exposure) $CALS(dark,exp)
    set SCOPE(shutter) 0
    set SCOPE(exptype) DARK
    if { $DEBUG } {debuglog "exposing (darktobuffer)"}
    set timeout [waitforimage [expr int($CALS(dark,exp))] $id]
    if { $timeout } {
       puts stdout "TIMEOUT/ABORT"
    } else {
      if { $DEBUG } {debuglog "Reading out..."}
      update
      $camera BufferImage temp
      set STATUS(readout) 0
      store_calib temp DARK $n 
    }
    set STATUS(busy) 0
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : zerotobuffer
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a zero length exposure and saves it in an
#  in-memory buffer name ZERO-n. It is intended to be used as part
#  of a calibration library creation sequence.
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc zerotobuffer { n {id 0} } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               CALS	-	Calibration run parmaeters
#               SCOPE	-	Telescope parameters, gui setup
global STATUS CAMERAS DEBUG CALS SCOPE
    set camera $CAMERAS($id)
    set STATUS(busy) 1
    setutc
    $camera Expose $CALS(zero,exp) 0  
    set SCOPE(exposure) $exp
    set SCOPE(shutter) 0
    set SCOPE(exptype) ZERO
    if { $DEBUG } {debuglog "exposing (zerotobuffer)"}
    set timeout [waitforimage 1 $id]
    if { $timeout } {
       puts stdout "TIMEOUT/ABORT"
    } else {
      if { $DEBUG } {debuglog "Reading out..."}
      update
      $camera BufferImage temp
      set STATUS(readout) 0
      store_calib temp ZERO $n 
    }
    set STATUS(busy) 0
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : fskytobuffer
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a skyflat-field exposure and saves it in an
#  in-memory buffer name FSKY-n. It is intended to be used as part
#  of a calibration library creation sequence.
#  Arguments  :
#
#               n	-	Number of frame(s)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc fskytobuffer { n {id 0} } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               CALS	-	Calibration run parmaeters
#               SCOPE	-	Telescope parameters, gui setup
global STATUS CAMERAS DEBUG CALS SCOPE
    set camera $CAMERAS($id)
    set STATUS(busy) 1
    setutc
    $camera Expose $CALS(skyflat,exp) 1
    set SCOPE(exposure) $exp
    set SCOPE(shutter) 1
    set SCOPE(exptype) SKYFLAT
    if { $DEBUG } {debuglog "exposing (fskytobuffer)"}
    set timeout [waitforimage 1 $id]
    if { $timeout } {
       puts stdout "TIMEOUT/ABORT"
    } else {   
      if { $DEBUG } {debuglog "Reading out..."}
      $camera BufferImage temp
      set STATUS(readout) 0
      store_calib temp FSKY $n 
    }
    set STATUS(busy) 0
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : obstodisk
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure performs the standard exposure operations. The image is
#  saved to a FITS file on disk.
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc obstodisk { n {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               STATUS	-	Exposure status
#               SCOPE	-	Telescope parameters, gui setup
#               DEBUG	-	Set to 1 for verbose logging
global CAMERAS STATUS SCOPE DEBUG
    set camera $CAMERAS($id)
    set STATUS(busy) 1
    setutc
    $camera Expose $SCOPE(exposure) $SCOPE(shutter)
    if { $DEBUG } {debuglog "exposing (obstobuffer)"}
# PRM JUl 2, 2002
#    if { [expr int($SCOPE(exposure))] > 3 } { 
#       countdown [expr int($SCOPE(exposure))]
#    }
    set timeout [waitforimage [expr int($SCOPE(exposure))] $id]
    if { $timeout } {
       puts stdout "TIMEOUT/ABORT"
    } else {   
      if { $DEBUG } {debuglog "Reading out..."}
      set d1 [exec date]
      $camera BufferImage tempobs
      set d2 [exec date]
      puts stdout "$d1 $d2"
# PRM JUl 2, 2002
#      countdown off
      set STATUS(readout) 0
      if { [llength [split $SCOPE(imagename) "\%"]] > 1 } {
         set name "$SCOPE(datadir)/[format "$SCOPE(imagename)" $SCOPE(seqnum)].fits"
         incr SCOPE(seqnum) 1
      } else {
         set name "$SCOPE(datadir)/$SCOPE(imagename).fits"
      }
      saveandshow tempobs $name
   }
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : saveandshow
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure is used to copy an image from an in-memory buffer to 
#  a FITS file on disk. It optionally deletes the file first if
#  overwrite is enabled. It also calls the appropriate routine for 
#  bias correction if that is enabled, and finally displays the image
#  in DS9 if that is enabled.
#
#  Arguments  :
#
#               buffer	-	Name of in-memory image buffer
#               name	-	Image file name
 
proc saveandshow { buffer name } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               STATUS	-	Exposure status
#               SCOPE	-	Telescope parameters, gui setup
#               DEBUG	-	Set to 1 for verbose logging
global CAMERAS STATUS SCOPE DEBUG
      if { [file exists $name] } {
         if { $SCOPE(overwrite) } {
            exec rm -f $name
         } else {
            set it [ tk_dialog .d "File exists" "The file named\n $name\n already exists, Overwrite it ?" {} -1 No "Yes"]           
            if { $it } {
               exec rm -f $name
            } else {
                set saveas [tk_getSaveFile -initialdir [file dirname $name] -filetypes {{{FITS images} {.fits}}}]
                set name [file rootname $saveas].fits
                saveandshow $buffer $name
                return
            }
         }
      }
      if { $SCOPE(autocalibrate) } {
          loadcalibrations
      }
      if { $SCOPE(autobias) } {
         write_cimage $buffer $SCOPE(exposure) $name
      } else {
         write_calibrated $buffer $SCOPE(exposure) $name 0
#           write_image $buffer $name
      }
      if { $SCOPE(autodisplay) } {
        checkDisplay
        exec xpaset -p ds9 file $name
      } 
      set STATUS(busy) 0
}

set LASTTEMP 0.0


proc confirmaction { msg } {
   set it [ tk_dialog .d "Confirm" "$msg ?" {} -1 No "Yes"]           
   return $it
}



#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : loadcalibrations
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine loads the best (nearest temperature match) calibration frames
#  if available.
#  The frames are buffered in memory, and can be used  by the write_calibrated
#  c-code call.
#
#  Arguments  :
#
 
proc loadcalibrations { } {
 
#
#  Globals    :
#  
#               LASTTEMP	-	Last temperature used for calibration
#               AVGTEMPS	-	Average temps for plotting
#               DEBUG	-	Set to 1 for verbose logging
#               SCOPE	-	Telescope parameters, gui setup
#               CALS	-	Calibration run parmaeters
global LASTTEMP AVGTEMPS DEBUG SCOPE CALS
  if { $SCOPE(autocalibrate) } {
    if { [expr abs($LASTTEMP-$AVGTEMPS)] > 1.0 } {
       set tnow [expr int($AVGTEMPS)]
       if { [file exists $CALS(zero,dir)/temp$tnow.fits] } {
          if { $DEBUG } {debuglog "loading calibration library data from  $CALS(zero,dir)/temp$tnow.fits"}
          read_image CALIBRATION-ZERO  $CALS(zero,dir)/temp$tnow.fits
       }
       if { [file exists $CALS(dark,dir)/temp$tnow.fits] } {
          if { $DEBUG } {debuglog "loading calibration library data from  $CALS(dark,dir)/temp$tnow.fits"}
          read_image CALIBRATION-DARK  $CALS(dark,dir)/temp$tnow.fits
       }
       if { [file exists $CALS(flat,dir)/temp$tnow.fits] } {
          if { $DEBUG } {debuglog "loading calibration library data from  $CALS(flat,dir)/temp$tnow.fits"}
          read_image CALIBRATION-FLAT  $CALS(flat,dir)/temp$tnow.fits
       }
       if { [file exists $CALS(skyflat,dir)/temp$tnow.fits] } {
          if { $DEBUG } {debuglog "loading calibration library data from  $CALS(skyflat,dir)/temp$tnow.fits"}
          read_image CALIBRATION-FSKY  $CALS(skyflat,dir)/temp$tnow.fits
       }
       set LASTTEMP $AVGTEMPS
    }
  }
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : grabimage
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine  readouts the image from the chip, and then writes it
#  to a disk FITS file. Either raw or bias corrected images are supported.
#  
#  Arguments  :
#
#               name	-	Image file name
#               bcorr	-	Bias correction (1=yes) (optional, default is 0)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc grabimage { name {bcorr 0} {id 0} } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               SCOPE	-	Telescope parameters, gui setup
global STATUS CAMERAS DEBUG SCOPE
    set camera $CAMERAS($id)
    if { $DEBUG } {debuglog "Reading out..."}
    $camera BufferImage READOUT
    if { [file exists $name] } {
      puts stdout "Overwriting $name"
      exec rm -f $name
    }
    if { $DEBUG } {debuglog "Saving to FITS $name"}
#   write_calibrated temp $name
    if { $bcorr } {
       write_cimage READOUT $SCOPE(exposure) $name
    } else {
       write_image READOUT  $name
    }
    checkDisplay
    exec xpaset -p ds9 file $name
#   show_image test 0
    set STATUS(busy) 0
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : displayimage
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine uses the XPA interface to request a shared memory transfer
#  of image data to the DS9 image display tool.
#
#  Arguments  :
#
#               name	-	Image file name
 
proc displayimage { name } {
 
#
#  Globals    :
#  
  set pars [shmem_image $name]
  set cmd "exec xpaset -p ds9  shm array shmid [lindex $pars 0] [lindex $pars 1] \\\[xdim=[lindex $pars 2],ydim=[lindex $pars 3],bitpix=16\\\]"
  eval $cmd
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : abortsequence
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure aborts the current exposure or sequence of exposures.
#  It simply sets the global abort flag and resets the GUI widgets.
#
#  Arguments  :
#
 
proc abortsequence { } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
global STATUS
  set STATUS(abort) 1
  countdown off
  .main.observe configure -text "Observe" -bg gray -relief raised
  .main.abort configure -bg gray -relief sunken -fg LightGray
  .main.pause configure -bg gray -relief sunken -fg LightGray
  .main.resume configure -bg gray -relief sunken -fg LightGray
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : continuousmode
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure continuously calls itself to repeatedly take exposures
#  and auto-display them. It will generally be used to image acquisition
#  and focus applications.
#  This mode of operation will continue until the user clicks "abort"
#
#  Arguments  :
#
#               exp	-	Exposure time in seconds
#               n	-	Number of frame(s) (optional, default is 9999)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc continuousmode { exp {n 9999} {id 0} } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CAMERAS	-	Camera id's
global STATUS CAMERAS SCOPE
   if { $STATUS(abort) } {set STATUS(abort) 0 ; return}
   if { $STATUS(busy) } {after 100 continuousmode $exp $n}
   .main.observe configure -text "continuous" -bg green -relief sunken
   .main.abort configure -bg orange -relief raised -fg black
   .main.pause configure -bg orange -relief raised -fg black
   update
   set camera $CAMERAS($id)
   exec rm -f /tmp/continuous.fits
   $camera Expose $exp 1
   $camera BufferImage READOUT
###   write_calibrated READOUT $SCOPE(exposure) /tmp/continuous.fits 0
###   checkDisplay
###   exec xpaset -p ds9 file  /tmp/continuous.fits
     displayimage READOUT
   incr n -1
   if { $n > 0 } {
      after 10 continuousmode $exp $n
   } else {
      .main.observe configure -text "Observe" -bg gray -relief raised
      .main.abort configure -bg gray -relief sunken -fg LightGray
      .main.pause configure -bg gray -relief sunken -fg LightGray
   }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : observe
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This stub routine responds to user selections on the observe menu.
#
#  Arguments  :
#
#               op	-	Operation specifier
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc observe { op {id 0} } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
global SCOPE
  switch $op {
      region {acquisitionmode}
      multiple {continuousmode $SCOPE(exposure) 9999 $id}
      fullframe {setfullframe}
  }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : setfullframe
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This stub routine responds to user selections on the observe menu.
#
#  Arguments  :
#
#               op	-	Operation specifier
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc setfullframe { } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
global SCOPE CONFIG
   set CONFIG(geometry.StartCol)  $SCOPE(StartCol)
   set CONFIG(geometry.StartRow)  $SCOPE(StartRow)
   set CONFIG(geometry.NumCols) $SCOPE(NumCols)
   set CONFIG(geometry.NumRows) $SCOPE(NumRows)
}


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : waitfortemp
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure is used to wait until the required temperature is 
#  reached (within 1 degree). At that point it calls the routine
#  specified. It is used by the calibration library generation routines.
#
#  Arguments  :
#
#               t	-	Temperature (degrees c)
#               cmd	-	Command to execute after timed wait (optional, default is bell)
 
proc waitfortemp { t {cmd bell} } {
 
#
#  Globals    :
#  
#               AVGTEMPS	-	Average temps for plotting
#               WAITCMD	-	Command to execute after a wait
global AVGTEMPS WAITCMD 
   if { $cmd != "wait" } {set  WAITCMD "$cmd"}
   if { [expr abs($t-$AVGTEMPS)] < 1.0 } {
       eval $WAITCMD
   } else {
       after 5000 waitfortemp $t wait
   }
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : darklibrary
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure generates a library of dark frames. It repeatedly 
#  steps thru a set of temperatures, and call dakrframes at each
#  point to take the exposures.
#
#  Arguments  :
#
#               t	-	Temperature (degrees c)
#               high	-	Maximum temperature for a calibration run
#               n	-	Number of frame(s)
 
proc darklibrary { t high n } {
 
#
#  Globals    :
#  
   if { $t < $high } {
      wm title .countdown "countdown - Acquiring darks at $t deg C"
      setpoint set $t
      waitfortemp $t "darkframes $n $t $high"
   }
}






#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : flatlibrary
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure generates a library of flat-field frames. It repeatedly 
#  steps thru a set of temperatures, and call flatframes at each
#  point to take the exposures.
#
#  Arguments  :
#
#               t	-	Temperature (degrees c)
#               high	-	Maximum temperature for a calibration run
#               n	-	Number of frame(s)
 
proc flatlibrary { t high n } {
 
#
#  Globals    :
#  
   if { $t < $high } {
      wm title .countdown "countdown - Acquiring flat-fields at $t deg C"
      setpoint set $t
      waitfortemp $t "flatframes $n $t $high"
   }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : skyflatlibrary
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure generates a library of sky flat frames. It repeatedly 
#  steps thru a set of temperatures, and call skyflatframes at each
#  point to take the exposures.
#
#  Arguments  :
#
#               t	-	Temperature (degrees c)
#               high	-	Maximum temperature for a calibration run
#               n	-	Number of frame(s)
 
proc skyflatlibrary { t high n } {
 
#
#  Globals    :
#  
   if { $t < $high } {
      wm title .countdown "countdown - Acquiring skyflat-fields at $t deg C"
      setpoint set $t
      waitfortemp $t "skyflatframes $n $t $high"
   }
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : zerolibrary
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure generates a library of zero frames. It repeatedly 
#  steps thru a set of temperatures, and call zeroframes at each
#  point to take the exposures.
#
#  Arguments  :
#
#               t	-	Temperature (degrees c)
#               high	-	Maximum temperature for a calibration run
#               n	-	Number of frame(s)
 
proc zerolibrary { t high n } {
 
#
#  Globals    :
#  
   if { $t < $high } {
      wm title .countdown "countdown - Acquiring zeroes at $t deg C"
      setpoint set $t
      waitfortemp $t "zeroframes $n $t $high"
   }
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : flatframes
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a set of n flat-field frames and stores them in 
#  memory buffers.
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               t	-	Temperature (degrees c)
#               high	-	Maximum temperature for a calibration run
 
proc flatframes { n  t high } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CALS	-	Calibration run parmaeters
global STATUS CALS
   set i 0
   while { $i < $n } {
      set FRAME $i
      countdown [expr $CALS(flat,exp)]
      puts stdout "flat frame $i"
      flattobuffer $i $CALS(flat,exp)
      incr i 1
   }
   if { [file exists  $CALS(flat,dir)/temp$t.fits] } {
      exec rm -f $CALS(flat,dir)/temp$t.fits
   }
   if { [file exists $CALS(zero,dir)/temp$t.fits] } {
      read_image CALIBRATION-ZERO  $CALS(zero,dir)/temp$t.fits
   }
   if { [file exists $CALS(dark,dir)/temp$t.fits] } {
      read_image CALIBRATION-DARK  $CALS(dark,dir)/temp$t.fits
   }
   write_fimage $CALS(flat,dir)/temp$t.fits $CALS(flat,exp) 0
   incr t 1
   flatlibrary $t $high $n 
   countdown off
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : skyflatframes
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a set of n skyflat-field frames and stores them in 
#  memory buffers.
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               t	-	Temperature (degrees c)
#               high	-	Maximum temperature for a calibration run
 
proc skyflatframes { n t high } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               CALS	-	Calibration run parmaeters
global STATUS CALS
   set i 0
   while { $i < $n } {
      set FRAME $i
      countdown [expr $CALS(skyflat,exp)]
      puts stdout "flat frame $i"
      fskytobuffer $i $CALS(skyflat,exp)
      incr i 1
   }
   if { [file exists  $CALS(skyflat,dir)/temp$t.fits] } {
      exec rm -f $CALS(skyflat,dir)/temp$t.fits
   }
   if { [file exists $CALS(zero,dir)/temp$t.fits] } {
      read_image CALIBRATION-ZERO  $CALS(zero,dir)/temp$t.fits
   }
   if { [file exists $CALS(dark,dir)/temp$t.fits] } {
      read_image CALIBRATION-DARK  $CALS(dark,dir)/temp$t.fits
   }
   write_simage $CALS(skyflat,dir)/temp$t.fits $CALS(skyflat,exp) 0
   incr t 1
   skyflatlibrary $t $high $n
   countdown off
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : darkframes
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a set of n dark frames and stores them in 
#  memory buffers.
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               t	-	Temperature (degrees c)
#               high	-	Maximum temperature for a calibration run
 
proc darkframes { n t high } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               FRAME	-	Frame number in a sequence
#               CALS	-	Calibration run parmaeters
global STATUS FRAME CALS
   set i 1
   while { $i <= $n } {
      set FRAME $i
      countdown [expr $CALS(dark,exp)]
      puts stdout "dark frame $i"
      darktobuffer $i 
      incr i 1
   }
   if { [file exists  $CALS(dark,dir)/temp$t.fits] } {
      exec rm -f $CALS(dark,dir)/temp$t.fits
   }
   if { [file exists $CALS(zero,dir)/temp$t.fits] } {
      read_image CALIBRATION-ZERO  $CALS(zero,dir)/temp$t.fits
   }
   write_dimage $CALS(dark,dir)/temp$t.fits $CALS(dark,exp) 0
   incr t 1
   darklibrary $t $high $n 
   countdown off
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : zeroframes
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a set of n zero frames and stores them in 
#  memory buffers.
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               t	-	Temperature (degrees c)
#               high	-	Maximum temperature for a calibration run
 
proc zeroframes { n t high } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#               FRAME	-	Frame number in a sequence
#               CALS	-	Calibration run parmaeters
global STATUS FRAME CALS
   set i 1
   while { $i <= $n } {
      set FRAME $i
      countdown 1
      puts stdout "zero frame $i"
      zerotobuffer $i
      incr i 1
   }
   incr t 1
   if { [file exists  $CALS(zero,dir)/temp$t.fits] } {
      exec rm -f $CALS(zero,dir)/temp$t.fits
   }
   write_zimage $CALS(zero,dir)/temp$t.fits $CALS(zero,exp) 1
   zerolibrary $t $high $n 
   countdown off
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : caltest
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This is a test routine to exercise the calibration routines
#
#  Arguments  :
#
#               n	-	Number of frame(s)
#               exp	-	Exposure time in seconds
#               t	-	Temperature (degrees c) (optional, default is -30)
 
proc caltest { n exp {t -30} } {
 
#
#  Globals    :
#  
   catch {exec rm zero$n.fits dark$n.fits}
   setpoint set $t
   zeroframes $n 1 $t $t
   write_zimage zero$n.fits $exp 1 
   darkframes $n $exp $t $t
   write_dimage dark$n.fits $exp 1 
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : opencalibrate
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine is a stub to support the calibrate menu entries
#
#  Arguments  :
#
#               type	-	Calibration type (flat,dark,sky,zero)
 
proc opencalibrate { type} {
 
#
#  Globals    :
#  
   wm deiconify .cal
   .cal.$type.sel invoke
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : savestate
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine saves the current configuration to ~/.apgui.tcl
#  from whence it will be autoloaded on subsequent runs
#
#  Arguments  :
#
#            
 
proc savestate { } {
 
#
#  Globals    :
#  
global CONFIG SCOPE ACQREGION LASTBIN OBSPARS env
   set fout [open $env(HOME)/.apgui.tcl w]
   foreach i [array names CONFIG] {
      puts $fout "catch \{set CONFIG($i) \"$CONFIG($i)\"\}"
   }
   foreach i [array names ACQREGION] {
      puts $fout "set ACQREGION($i) \"$ACQREGION($i)\""
   }
   foreach i [array names SCOPE] {
      puts $fout "set SCOPE($i) \"$SCOPE($i)\""
   }
   foreach i [array names LASTBIN] {
      puts $fout "set LASTBIN($i) \"$LASTBIN($i)\""
   }
   foreach i [array names OBSPARS] {
      puts $fout "set OBSPARS($i) \"$OBSPARS($i)\""
   }
   foreach i [array names CALS] {
      puts $fout "set CALS($i) \"$CALS($i)\""
   }
   close $fout
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : createcalibrations
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure calls the appropriate calibration library routine
#
#  Arguments  :
#
#               type	-	Calibration type (flat,dark,sky,zero)
 
proc createcalibrations { type } {
 
#
#  Globals    :
#  
#               CALS	-	Calibration run parmaeters
#               CCDID	-	Camera id
global CALS CCDID
   set dt [expr $CALS($type,tmax)-$CALS($type,tmin)+1]
   set t [format %.2f [expr $dt * $CALS($type,navg) * (9 + $CALS($type,exp))]]
   set it [ tk_dialog .d "$type calibrations" "Click OK to run a $type calibration library\nsequence of $CALS($type,navg) frames. This will take approx. $t seconds" {} -1 OK "Cancel to select new mode"]      
   if { $it } {
      switch $type {
          zero { zerolibrary $CALS(zero,tmin) $CALS(zero,tmax) $CALS(zero,navg) }
          dark { darklibrary $CALS(dark,tmin) $CALS(dark,tmax) $CALS(dark,navg) $CALS(dark,exp) }
          flat { flatlibrary $CALS(flat,tmin) $CALS(flat,tmax) $CALS(flat,navg) $CALS(flat,exp) }
          skyflat { skyflatlibrary $CALS(skyflat,tmin) $CALS(skyflat,tmax) $CALS(skyflat,navg) $CALS(skyflat,exp) }
      }
   }
}

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : loadcalibrate
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure loads the a calibration frame chosen by the user
#
#  Arguments  :
#
#               type	-	Calibration type (flat,dark,skyflat,zero)

proc loadcalibrate { type } {

#
#  Globals    :
#  
#               CALS	-	Calibration run parmaeters
global CALS SCOPE
   set d $CALS($type,dir)
   set cal [tk_getOpenFile -initialdir $d -filetypes {{{Calibrations} {.fits}}}]   
   switch $type {
      dark    { read_image CALIBRATION_DARK $cal }
      zero    { read_image CALIBRATION_ZERO $cal }
      skyflat { read_image CALIBRATION_FSKY $cal }
      flat    { read_image CALIBRATION_FLAT $cal }
   }
   set SCOPE(autocalibrate) 0
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : acquisitionmode
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure controls the specification of a sub-image region using
#  the DS9 image display tool.
#
#  Arguments  :
#
 
proc  acquisitionmode { } {
 
#
#  Globals    :
#  
#               ACQREGION	-	Sub-frame region coordinates
#               CONFIG	-	GUI configuration
global ACQREGION CONFIG
  set it [ tk_dialog .d "Acquisition region" "Click New to define a new region,\n OK to use the current region " {} -1 OK "New"]      
  if {$it} {
    catch {
      exec xpaset -p ds9 regions deleteall
      exec xpaset -p ds9 regions box $ACQREGION(xs) $ACQREGION(ys) $ACQREGION(xe) $ACQREGION(ye)
    }
    set it [tk_dialog .d "Edit region" "Resize/Move the region in the\n image display tool then click OK" {} -1 "OK"]
    set reg [split [exec xpaget ds9 regions] \n]
    foreach i $reg {
     if { [string range $i 0 8] == "image;box" } {
        set r [lrange [split $i ",()"] 1 4]
        set ACQREGION(xs) [expr int([lindex $r 0] - [lindex $r 2]/2)]
        set ACQREGION(ys) [expr int([lindex $r 1] - [lindex $r 3]/2)]
        set ACQREGION(xe) [expr int([lindex $r 0] + [lindex $r 2]/2)]
        set ACQREGION(ye) [expr int([lindex $r 1] + [lindex $r 3]/2)]
        puts stdout "selected region $r"
     }
    }
  } 
  set CONFIG(geometry.StartCol) [expr $ACQREGION(xs)]
  set CONFIG(geometry.StartRow) [expr $ACQREGION(ys)]
  set CONFIG(geometry.NumCols) [expr $ACQREGION(xe)-$ACQREGION(xs)+1]
  set CONFIG(geometry.NumRows) [expr $ACQREGION(ye)-$ACQREGION(ys)+1]
}


#
#  Define a default sub-region
#  
set ACQREGION(xs) 200
set ACQREGION(xe) 64
set ACQREGION(ys) 200
set ACQREGION(ye) 64




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : toggle
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine opens/closes any window based upon it current open/closed status
#
#  Arguments  :
#
#               win	-	Widget id of window
 
proc toggle { win } {
 
#
#  Globals    :
#  
   if { [winfo ismapped $win] } { 
      wm withdraw $win
   } else {
      wm deiconify $win
   }
}



set FRAME 1
set STATUS(readout) 0




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : countdown
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine manages a countdown window. The window displays the 
#  current frame number, and seconds remaining.
#
#  Arguments  :
#
#               time	-	Countdown time in seconds
 
proc countdown { time } {
 
#
#  Globals    :
#  
#               FRAME	-	Frame number in a sequence
#               STATUS	-	Exposure status
global FRAME STATUS
  if { $time == "off" || $STATUS(abort) } {
     wm withdraw .countdown
     return
  }
  .countdown.f configure -text $FRAME
  .countdown.t configure -text $time
  if { $STATUS(pause) == 0 } {
      incr time -1
  } else {
      .countdown.t configure -text "$time (HOLD)"
  }
  if { [winfo ismapped .countdown] == 0 } {
     wm deiconify .countdown
     wm geometry .countdown +20+20
  }
  if { $time > -1 } {
     update
     after 850 countdown $time
  } else {
     if { $STATUS(readout) } {
       .countdown.t configure -text "READING"
     } else {
       wm withdraw .countdown
     }
  }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : startsequence
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine manages a sequence of exposures. It updates bias columns
#  specifications in case they have been changed, then it loops thru
#  a set of frames, updating the countdown window, and calling obstodisk to 
#  do the actual exposures.
#
#  Arguments  :
#
 
proc startsequence { } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
#               OBSPARS	-	Default observation parameters
#               FRAME	-	Frame number in a sequence
#               STATUS	-	Exposure status
#               DEBUG	-	Set to 1 for verbose logging
global SCOPE OBSPARS FRAME STATUS DEBUG
   set OBSPARS($SCOPE(exptype)) "$SCOPE(exposure) $SCOPE(numframes) $SCOPE(shutter)"
   set STATUS(abort) 0
   if { $SCOPE(lobias) > 0 && $SCOPE(hibias) > 0 } {
      set_biascols $SCOPE(lobias) $SCOPE(hibias)
   }
   .main.observe configure -text "working" -bg green -relief sunken
   .main.abort configure -bg orange -relief raised -fg black
   .main.pause configure -bg orange -relief raised -fg black
   set i 1
   while { $i <= $SCOPE(numframes) && $STATUS(abort) == 0 } {
      set FRAME $i
      countdown [expr int($SCOPE(exposure))]
      if { $DEBUG} {debuglog "$SCOPE(exptype) frame $i"}
      obstodisk $i 
      incr i 1
   }
   .main.observe configure -text "Observe" -bg gray -relief raised
   .main.abort configure -bg gray -relief sunken -fg LightGray
   .main.pause configure -bg gray -relief sunken -fg LightGray
   countdown off
}


proc pausesequence { } {
global STATUS
  set STATUS(pause) 1
  .main.pause configure -bg gray -relief sunken -fg Black -bg yellow
  .main.resume configure -bg gray -relief raised -fg Black -bg orange
}

proc resumesequence { } {
global STATUS
  set STATUS(pause) 0
  .main.pause configure -bg orange -relief raised -fg black
  .main.resume configure -bg gray -relief sunken -fg LightGray
}




#
#  Update status display
#
set SCOPE(driftdelay) 60000
set SCOPE(driftrows) 212
set SCOPE(telescope) " "
set SCOPE(instrument) " "
set SCOPE(equinox) "2000.0"


#
#  Initialize telescope/user variables
#
source $TKAPOGEE/scripts/tele_init.tcl


#
#  Create main observation management widgets
#
#
set SCOPE(exptype) Object
set SCOPE(seqnum) 1
set SCOPE(lobias) 0
set SCOPE(hibias) 0
set SCOPE(autodisplay) 1
set SCOPE(autobias) 0
set SCOPE(autocalibrate) 0
set SCOPE(overwrite) 0
set STATUS(abort) 0
set STATUS(pause) 0
set STATUS(readout) 0




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : pastelocation
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure updates the users longitude/latitude when they select
#  their location in the site list.
#
#  Arguments  :
#
 
proc pastelocation { } {
 
#
#  Globals    :
#  
#               SITES	-	Site long/lat info
global SITES 
  set l [.psite.l curselection]
  set ll [split $SITES($l) |]
  set lat [lindex $ll 0]
  set lon [lindex $ll 1]
  .main.vsite delete 0 end
  .main.vlatitude delete 0 end
  .main.vlongitude delete 0 end
  .main.vlatitude insert 0 "[join [lrange $lat 0 2] :] [lindex $lat 3]"
  .main.vlongitude insert 0 "[join [lrange $lon 0 2] :] [lindex $lon 3]" 
  .main.vsite insert 0 "[.psite.l get $l]"
  wm withdraw .psite
}
foreach t "zero dark flat skyflat" {
   set CALS($t,tmin) -30
   set CALS($t,tmax) 10
   set CALS($t,navg) 10
}
set CALS(dark,exp) 10
set CALS(flat,exp) 0.5
set CALS(skyflat,exp) 0.5

#
#  Set up the default structures for temperaure control/plotting
#

set TIMES "0"
set SETPOINTS "0.0"
set AVGTEMPS "0.0"
set i -60
set xdata ""
set ydata ""
set ysetp ""
while { $i < 0 } {
  lappend xdata $i
  lappend ydata $AVGTEMPS
  lappend ysetp $SETPOINTS
  incr i 1
}




#
#
#  Call the camera setup code, and the telescope setup code
#
showstatus "Initializing camera"
source  $TKAPOGEE/scripts/camera_init.tcl
source  $TKAPOGEE/scripts/tele_init.tcl
source  $TKAPOGEE/scripts/tdi.tcl




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : focustest
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes a focus exposure. This consists of taking a series
#  of exposures, and shifting the charge on the ccd in between each.
#  In addition, the focus is also altered between each exposure.
#  The resulting image can be automatically analsed to determine 
#  optimum focus.
#  This is an example of using TDI mode, without writing any c/c++ code, the 
#  applications of this technique are legion.....
#
#  Arguments  :
#
#               name	-	Image file name
#               exp	-	Exposure time in seconds
#               nstep	-	Number of steps in focus
#               nshift	-	Number of rows to shift per focus step
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc focustest { name exp nstep nshift {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
#               DEBUG	-	Set to 1 for verbose logging
#               CAMSTATUS	-	Current values of camera variables
global CAMERAS DEBUG CAMSTATUS
  set camera $CAMERAS($id)
  setutc
  $camera configure -m_TDI 1
  $camera Expose 0.02 0
  set istep 1
  set ishift 0
  while { $ishift < $CAMSTATUS(NumY) } {
     $camera DigitizeLine
     incr ishift 1
  }
  while { $istep <= $nstep } {
    set it [tk_dialog .d "Focus exposure" "Move to focus position $istep\n then click OK" {} -1 "Cancel" "OK"]
    if { $it } {
      if { $istep == $nstep } {set nshift [expr $nshift*2] }
      $camera write_ForceShutterOpen 1 
      exec sleep $exp
      $camera write_ForceShutterOpen 0
      set ishift 0
      while { $ishift < $nshift } {
         $camera DigitizeLine
         incr ishift 1
      }
    } else { 
       set istep $nstep
    }
    incr istep 1
  }
  $camera configure -m_TDI 0
  $camera BufferImage READOUT
  $camera Flush
  if { $DEBUG } {debuglog "Saving to FITS $name"}
  write_image READOUT $name.fits
}




set CCDID 0




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : watchconfig
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure "watches" the variables in the CONFIG array. The
#  value of these variables may be altered by the user using the 
#  properties panels. This procedure ensures that the C++ instance
#  variables get updated in sync
#
#  Arguments  :
#
#               arr	-	Array name
#               var	-	tcl variable name
#               op	-	Operation specifier
 
proc watchconfig { arr var op } {
 
#
#  Globals    :
#  
#               CONFIG	-	GUI configuration
#               CAMERAS	-	Camera id's
#               CCAPI	-	Generic C++ object names
#               CCAPIW	-	C++ writable instance variables
#               CCDID	-	Camera id
#               LASTBIN	-	Last binning factor used
global CONFIG CAMERAS CCAPI CCAPIW CCDID LASTBIN
#      puts stdout "$arr $var $op"
      switch $var {
           temperature.Target { setpoint set $CONFIG($var) }
           ccd.Gain    { catch {set_gain $CONFIG(gain) $CCDID} }
      }
      foreach i [array names CCAPIW] {
         if { [string range $i 2 end] == $CCAPI($var) } {
            set camera $CAMERAS($CCDID)
#            puts stdout "setting $i"
            if { $var == "geometry.BinX" } {
               set newcols [expr $CONFIG(geometry.NumCols)*$LASTBIN(x)/$CONFIG(geometry.BinX)]
               set LASTBIN(x) $CONFIG($var)
               set CONFIG(geometry.NumCols) $newcols
            }
            if { $var == "geometry.BinY" } {
               set newrows [expr $CONFIG(geometry.NumRows)*$LASTBIN(y)/$CONFIG(geometry.BinY)]
               set LASTBIN(y) $CONFIG($var)
               set CONFIG(geometry.NumRows) $newrows
            }
            $camera configure -$i $CONFIG($var)
         }
      }
# PRM Jul 2, 2002
#      if { [testgeometry] == 0 } {
#         .p.props.fGeometry configure -bg orange
#         bell
#      } else {
#         .p.props.fGeometry configure -bg gray
#      }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : watchscope
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (rfactory@theriver.com)
#  Version    : 0.3
#  Date       : Jan-14-2001
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure updates the global observation parameter defaults
#  so that they can be saved/restored as exit/startup (NYI)
#  Arguments  :
#
#               arr	-	Array name
#               var	-	tcl variable name
#               op	-	Operation specifier
 
proc watchscope { arr var op } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
#               OBSPARS	-	Default observation parameters
global SCOPE OBSPARS
    switch $var { 
        exptype {
                 set SCOPE(exposure)  [lindex $OBSPARS($SCOPE($var)) 0]
                 set SCOPE(numframes) [lindex $OBSPARS($SCOPE($var)) 1]
                 set SCOPE(shutter)   [lindex $OBSPARS($SCOPE($var)) 2]
                }
    }
}



#
#  Set defaults for observation parameters
#

set OBSPARS(Object) "1.0 1 1"
set OBSPARS(Focus)  "0.1 1 1"
set OBSPARS(Acquire) "1.0 1 1"
set OBSPARS(Flat)    "1.0 1 1"
set OBSPARS(Dark)    "100.0 1 0"
set OBSPARS(Zero)    "0.01 1 0"
set OBSPARS(Skyflat) "0.1 1 1"

set LASTBIN(x) 1
set LASTBIN(y) 1
setutc
set d  [split $SCOPE(obsdate) "-"]
set SCOPE(equinox) [format %7.2f [expr [lindex $d 0]+[lindex $d 1]./12.]]

#
#  Do the actual setup of the GUI, to sync it with the camera status
#

showstatus "Loading camera API"
inspectapi CCameraIO
refreshcamdata
trace variable CONFIG w watchconfig
#trace variable SCOPE w watchscope

###29oct the next two lines move the target temp up and down, the effect of
###29oct which is to turn on the cooler. Commenting them out makes the
###cooler not get triggered everytime this script is run.
###29oct set CONFIG(temperature.Target) [expr $CONFIG(temperature.Target) +1]
###29oct set CONFIG(temperature.Target) [expr $CONFIG(temperature.Target) -1]

#
#  Reset to the last used configuration if available
#

if { [file exists $env(HOME)/.apgui.tcl] } {
   showstatus "Loading $env(HOME)/.apgui.tcl"
   source $env(HOME)/.apgui.tcl
}

#
#  Fix the date
#

set SCOPE(obsdate) [join "[lrange $now 1 2] [lindex $now 4]" -]  
set SCOPE(StartCol) $CONFIG(geometry.StartCol)
set SCOPE(StartRow) $CONFIG(geometry.StartRow) 
set SCOPE(NumCols)  $CONFIG(geometry.NumCols) 
set SCOPE(NumRows)  $CONFIG(geometry.NumRows) 
set SCOPE(darktime) 0.0


#ap7p  set_biascols 1 7, set bic 4
#kx260 set_biascols 1 5, set bic 2

#source  $TKAPOGEE/scripts/mycode.tcl
