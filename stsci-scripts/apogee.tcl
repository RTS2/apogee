set libs /usr/local/gui/lib/shared
package ifneeded gsc 3.1       [load $libs/libgsc.so]
package ifneeded dss 3.1       [load $libs/libdss.so]
package ifneeded fitsTcl 3.1   [load $libs/libfitstcl.so]
package ifneeded oracle 2.1    [load $libs/liboracle.so]
package ifneeded xtcs 3.1      [load $libs/libxtcs.so]
package ifneeded BLT 2.4       [load $libs/libBLT24.so]
package require dss
package require gsc
package require oracle
package require BLT
namespace import blt::graph

set TKAPOGEE /usr/local/gui/tclsrc/apogee

proc getDSS {name ra dec xsize ysize } {
   set fout [open /tmp/dsscmd w]
   puts $fout "$name [split $ra :] [split $dec :] $xsize $ysize"
   close $fout
   dss -i /tmp/dsscmd
   set f [glob $name*.fits]
   checkDisplay
   exec xpaset -p ds9 file $f
}

proc checkDisplay { } {
   set x ""
   catch {set x [exec xpaget ds9]}
   if { $x == "" } {
      exec /astro/bin/ds9 &
   }
}

proc getGSC { ra dec xsize ysize } {
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

proc locateObjs { } {
   set fin [open test.cat r]
   exec xpaset -p ds9 regions coordformat xy
   exec xpaset -p ds9 regions deleteall                                                
   set i 7
   while { $i > 0 } {gets $fin rec ;  incr i -1}
   while { [gets $fin rec] > -1 } {
      exec xpaset -p ds9 regions circle [lindex $rec 4] [lindex $rec 5] 5.
   }
}

proc getRegion { } {
   set res [exec xpaget  ds9 regions]
   set i [lsearch $res "rectangle"]
   set lx [lindex $res [expr $i+1]]
   set ly [lindex $res [expr $i+2]]
   set nx [lindex $res [expr $i+3]]
   set ny [lindex $res [expr $i+4]]
#  test command for sextractor
# /astro/bin/sextractor -DETECT_MINAREA 10 -DETECT_THRESH 30 test207vo.fits        
}

proc autoIdentify { {imax 20} {type raw} {aspp 1.7} } {
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

proc fileopen { } {
global CFGFILE
   set cfg [tk_getOpenFile -initialdir ./config -filetypes {{{Apogee cameras} {.ini}}}]
   set CFGFILE $cfg
   loadconfig apogee
}

proc loadconfig { cameratype } {
global CFGFILE CFG
   set fcfg [open $CFGFILE r]
   while { [gets $fcfg rec] > -1 } {
      if { [llength [split $rec "="]] == 2 } {
         set par [lindex [split $rec "="] 0]
         set val [lindex [split $rec "="] 1]
         set CFG($par) $val
      }
   }
   close $fcfg
}

proc fileclose { } {
global CFGFILE
   set CFGFILE ""
}


proc choosedir { type name} {
global CALS CATALOGS
   set cfg [tk_chooseDirectory -initialdir $CALS(home)/$name]
   switch $type {
       calibrations {set CALS($name,dir) $cfg }
       catalogs     {set CATALOGS($name,dir) $cfg }
   }
}

set CALS(home) $env(HOME)/calibrations
set CALS(zero,dir) $CALS(home)/zero
set CALS(dark,dir) $CALS(home)/dark
set CALS(flat,dir) $CALS(home)/flat
set CALS(skyflat,dir) $CALS(home)/skyflat


proc printcamdata { { camid 0 } } {
global APCAM0
    get_camdata $camid
    foreach i [lsort [array names APCAM0]] { 
        puts stdout "$i = $APCAM0($i)"
    }
}


proc refreshcamdata { { camid 0 } } {
global APCAM0 CFG
    get_camdata $camid
    foreach i [lsort [array names APCAM0]] { 
        if { [info exists CFG($i)] } {
           set CFG($i) $APCAM0($i)
        }
    }
}



set TEMPS ""
set STATUS(tempgraph) 1

proc monitortemp { {id 0} } {
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

 
proc plottemp { } {
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


proc setminmax { } {
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

set CCD_TMP(SET)     4    
set CCD_TMP(AMB)     5     
set CCD_TMP(OFF)     6      

proc setpoint { op {t 10.0} {id 0} } {
global CCD_TMP SETPOINTS
    set op [string toupper $op]
    set_temp $t $CCD_TMP($op) $id
    if { $op == "SET" } {
       set SETPOINTS $t
    } else {
       set SETPOINTS 99
    }
}



set PI 3.14159265359

proc tlabel { atime } {
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
                                                                                


proc showconfig { } {
  if { [winfo ismapped .p] } {
     wm withdraw .p
  } else {
     wm deiconify .p
  }
}

set STATUS(busy) 0

proc snapshot { name exp {id 0} {shutter 1} } {
global STATUS CFG
   if { $STATUS(busy) == 0 } {
     set STATUS(busy) 1
# this config gives 10 columns of bias plus 512 image
#   config_camera 8 3 522 511 1 1 $exp 0 0 $id
# this config gives 3 trailing columns of bias
#   config_camera 8 3 130 128 4 4 $exp 0 0 $id
# this config gives 1 trailing columns of bias and lower noise
#   config_camera 8 3 128 128 4 4 $exp 0 0 $id
# this config gives 1 leading columns of bias and lower noise
#   config_camera 8 3 256 256 2 2 $exp 0 0 $id
# this config gives 3 trailing columns of bias
#   config_camera 8 3 64 64 8 8 $exp 0 0 $id
    config_camera $CFG(bic) $CFG(bir) [expr ($CFG(imgcols)+1)/$CFG(hflush)] [expr ($CFG(imgrows)+1)/$CFG(vflush)] $CFG(hflush) $CFG(vflush) $exp 0 0 $id
    start_exposure $shutter 0 0 0 $id   
    puts stdout "exposing"
    after [expr $exp*10+1000] "grabimage $name.fits $id"
  }
}

proc snapslice { name exp {id 0} {shutter 1} } {
global STATUS CFG
   if { $STATUS(busy) == 0 } {
     set STATUS(busy) 1
     config_slice $CFG(bic) $CFG(bir) [expr ($CFG(imgcols)+1)/$CFG(hflush)] [expr ($CFG(imgrows)+1)/$CFG(vflush)] $CFG(hflush) $CFG(vflush) $id
     start_exposure $shutter 0 0 0 $id   
     puts stdout "exposing"
     after [expr $exp*10+1000] "grabslice $name.fits $id"
  }
}

proc testgeometry { {id 0} } {
global CFG
   set exp 2
   set shutter 0
   set res "illegal"
   config_camera $CFG(bic) $CFG(bir) [expr ($CFG(imgcols)+1)/$CFG(hflush)] [expr ($CFG(imgrows)+1)/$CFG(vflush)] $CFG(hflush) $CFG(vflush) $exp 0 0 $id
   catch {
      start_exposure $shutter 0 0 0 $id
      set res ok
   }
   return $res
}




proc snapsleep { name exp {id 0} {shutter 1} } {
global STATUS
# this config gives 10 columns of bias plus 512 image
   config_camera  8 3 522 511 1 1 $exp 0 0 $id
#   config_camera 12 3 511 511 1 1 $exp 0 0 $id
   start_exposure $shutter 0 0 0 $id
   set STATUS(busy) 1
   puts stdout "exposing"
   exec sleep [expr ($exp*10+1000)/1000 + 1] 
   grabimage $name.fits $id
}


proc flattobuffer { n exp {id 0} } {
global STATUS
# this config gives 10 columns of bias plus 512 image
   config_camera  8 3 522 511 1 1 $exp 0 0 $id
   start_exposure 1 0 0 0 $id
   set STATUS(busy) 1
   puts stdout "exposing"
   exec sleep [expr ($exp*10+1000)/1000 + 1] 
   puts stdout "fetching data"
   acquire_image 1 temp 0 $id
   store_flat temp $n 10 $id
   set STATUS(busy) 0
}


proc darktobuffer { n exp {id 0} } {
global STATUS
# this config gives 10 columns of bias plus 512 image
   config_camera  8 3 522 511 1 1 $exp 0 0 $id
   start_exposure 0 0 0 0 $id
   set STATUS(busy) 1
   puts stdout "exposing"
   exec sleep [expr ($exp*10+1000)/1000 + 1] 
   puts stdout "fetching data"
   acquire_image 1 temp 0 $id
   store_dark temp $n 10 $id
   set STATUS(busy) 0
}


proc zerotobuffer { n exp {id 0} } {
global STATUS
# this config gives 10 columns of bias plus 512 image
   config_camera  8 3 522 511 1 1 $exp 0 0 $id
   start_exposure 0 0 0 0 $id
   set STATUS(busy) 1
   puts stdout "exposing"
   exec sleep [expr ($exp*10+1000)/1000 + 1] 
   puts stdout "fetching data"
   acquire_image 1 temp 0 $id
   store_zero temp $n 10 $id
   set STATUS(busy) 0
}


proc fskytobuffer { n exp {id 0} } {
global STATUS
# this config gives 10 columns of bias plus 512 image
   config_camera  8 3 522 511 1 1 $exp 0 0 $id
   start_exposure 1 0 0 0 $id
   set STATUS(busy) 1
   puts stdout "exposing"
   exec sleep [expr ($exp*10+1000)/1000 + 1] 
   puts stdout "fetching data"
   acquire_image 1 temp 0 $id
   store_skyflat temp $n 10 $id
   set STATUS(busy) 0
}


proc grabimage { name {id 0}} {
global STATUS
   puts stdout "fetching data"
   acquire_image 1 test 0 $id
   if { [file exists $name] } {
      puts stdout "Overwriting $name"
      exec rm -f $name
   }
#   write_calibrated test $name $id
   write_image test $name $id
   puts stdout "saved $name"
   checkDisplay
   exec xpaset -p ds9 file $name
#   show_image test 0
   set STATUS(busy) 0
}

proc grabslice { name {id 0}} {
global STATUS
   puts stdout "fetching data"
   acquire_slice 1 test 0 0 0 0 $id
   if { [file exists $name] } {
      puts stdout "Overwriting $name"
      exec rm -f $name
   }
#   write_calibrated test $name $id
   set STATUS(busy) 0
   write_image test $name $id
   puts stdout "saved $name"
   checkDisplay
#   show_image calibrated 0
}

proc continuousmode { exp } {
global STATUS
   if { $STATUS(abort) } {return}
   if { $STATUS(busy) } {after 100 continuousmode $exp}
   snapshot junk $exp
   after 100 continuousmode $exp
}



proc waitfortemp { t {cmd bell} } {
global AVGTEMPS WAITCMD
   if { $cmd != "wait" } {set  WAITCMD "$cmd"}
   if { [expr abs($t-$AVGTEMPS)] < 1.0 } {
       eval $WAITCMD
   } else {
       after 5000 waitfortemp $t wait
   }
}


proc darklibrary { t high n exp } {
   if { $t < $high } {
      puts stdout "Acquiring darks at $t deg C"
      setpoint set $t
      waitfortemp $t "darkframes $n $exp $t $high"
   }
}

proc odarkframes { n exp t high } {
global STATUS
   set i 0
   while { $i < $n } {
      puts stdout "dark frame $i"
      snapsleep data/dark/temp$t-exp$exp-$i $exp
      incr i 1
   }
   incr t 1
   darklibrary $t $high $n $exp 
}


proc flatlibrary { t high n exp } {
   if { $t < $high } {
      puts stdout "Acquiring flat-fields at $t deg C"
      setpoint set $t
      waitfortemp $t "flatframes $n $exp $t $high"
   }
}


proc zerolibrary { t high n } {
   if { $t < $high } {
      puts stdout "Acquiring zeroes at $t deg C"
      setpoint set $t
      waitfortemp $t "zeroframes $n $t $high"
   }
}


proc flatframes { n exp t high } {
global STATUS
   set i 0
   while { $i < $n } {
      puts stdout "flat frame $i"
      flattobuffer $i $exp
      incr i 1
   }
   incr t 1
   writeflat data/flat/temp$t-exp$exp
   flatlibrary $t $high $n $exp 
}

proc skyflatframes { n exp t high } {
global STATUS
   set i 0
   while { $i < $n } {
      puts stdout "flat frame $i"
      fskytobuffer $i $exp
      incr i 1
   }
   incr t 1
   writeskyflat data/flat/temp$t-exp$exp
   skyflatlibrary $t $high $n $exp 
}

proc darkframes { n exp t high } {
global STATUS FRAME
   set i 0
   while { $i < $n } {
      set FRAME $i
      countdown [expr $exp/100]
      puts stdout "dark frame $i"
      darktobuffer $i $exp
      incr i 1
   }
   incr t 1
   writedark data/dark/temp$t-exp$exp
#   darklibrary $t $high $n $exp 
}

proc zeroframes { n t high } {
global STATUS
   set i 0
   while { $i < $n } {
      puts stdout "zero frame $i"
      zerotobuffer $i 1
      incr i 1
   }
   incr t 1
   writezero data/zero/temp$t
   zerolibrary $t $high $n 
}


proc caltest { n exp {t -30} } {
   catch {exec rm zero$n.fits dark$n.fits}
   setpoint set $t
   zeroframes $n 1 $t $t
   write_zimage zero$n.fits 1 0
   darkframes $n $exp $t $t
   write_dimage dark$n.fits 1 0
}

proc opencalibrate { type} {
   wm deiconify .cal
   .cal.$type.sel invoke
}


proc createcalibrations { type } {
global CALS CCDID
   set t [format %.2f [expr $CALS($type,navg) * (9 + $CALS($type,exp))]]
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


proc  acquisitionmode { } {
global ACQREGION CFG
  set it [ tk_dialog .d "Acquisition region" "Click New to define a new region,\n OK to use the current region " {} -1 OK "New"]      
  if {$it} {
    exec xpaset -p ds9 regions deleteall
    exec xpaset -p ds9 regions box $ACQREGION(xs) $ACQREGION(ys) $ACQREGION(xe) $ACQREGION(ye)
    set it [tk_dialog .d "Edit region" "Resize/Move the region in the\n image display tool then click OK" {} -1 "OK"]
    set reg [split [exec xpaget ds9 regions] \n]
    foreach i $reg {
     if { [string range $i 0 8] == "image;box" } {
        set r [lrange [split $i "()\},"] 1 4]
        set ACQREGION(xs) [expr int([lindex $r 0])]
        set ACQREGION(ys) [expr int([lindex $r 1])]
        set ACQREGION(xe) [expr int([lindex $r 2])]
        set ACQREGION(ye) [expr int([lindex $r 3])]
        puts stdout "selected region $r"
     }
    }
  } 
  set CFG(bic) [expr $ACQREGION(xs)-1]
  set CFG(bir) [expr $ACQREGION(ys)-1]
  set CFG(imgcols) [expr $ACQREGION(xe)]
  set CFG(imgrows) [expr $ACQREGION(ye)]
}
  
set ACQREGION(xs) 200
set ACQREGION(xe) 64
set ACQREGION(ys) 200
set ACQREGION(ye) 64



set FRAME 1

proc countdown { time } {
global FRAME
  .countdown.f configure -text $FRAME
  .countdown.t configure -text $time
  incr time -1
  if { [winfo ismapped .countdown] == 0 } {
     wm deiconify .countdown
     wm geometry .countdown +20+20
  }
  if { $time > 0 } {
     after 950 countdown $time
  } else {
     wm withdraw .countdown
  }
}

set f "Helvetica -30 bold"
toplevel .countdown -bg orange -width 450 -height 115
label .countdown.lf -text "Frame # " -bg orange -font $f
label .countdown.lt -text "Seconds : " -bg orange -font $f
label .countdown.f -text "???" -bg orange -font $f
label .countdown.t -text "???" -bg orange -font $f
place .countdown.lf -x 10 -y 40
place .countdown.f -x 140 -y 40
place .countdown.lt -x 230 -y 40
place .countdown.t -x 380 -y 40
wm withdraw .countdown

wm title . "Apogee Camera Control"
frame .mbar -width 400 -height 30 -bg gray
menubutton .mbar.file -text "File" -fg black -bg gray -menu .mbar.file.m
menubutton .mbar.edit -text "Edit" -fg black -bg gray -menu .mbar.edit.m
menubutton .mbar.observe -text "Observe" -fg black -bg gray -menu .mbar.observe.m
menubutton .mbar.calib -text "Calibrate" -fg black -bg gray -menu .mbar.calib.m
menubutton .mbar.help -text "Help" -fg black -bg gray -menu .mbar.help.m
menubutton .mbar.tools -text "Tools" -fg black -bg gray -menu .mbar.tools.m
pack .mbar
place .mbar.file -x 0 -y 0
place .mbar.edit -x 40 -y 0
place .mbar.observe -x 80 -y 0
place .mbar.calib -x 150 -y 0
place .mbar.tools -x 210 -y 0
place .mbar.help -x 350 -y 0
menu .mbar.file.m 
menu .mbar.edit.m
menu .mbar.observe.m
menu .mbar.calib.m
menu .mbar.tools.m
menu .mbar.help.m
.mbar.file.m add command -label "Open" -command fileopen
.mbar.file.m add command -label "Save" -command filesave
.mbar.file.m add command -label "Save As" -command filesaveas
.mbar.file.m add command -label "Exit" -command shutdown
.mbar.edit.m add command -label "Properties" -command showconfig
.mbar.observe.m add command -label "Single-frame" -command "observe single"
.mbar.observe.m add command -label "Continuous" -command "observe multiple"
.mbar.observe.m add command -label "Snap-region" -command "observe region"
.mbar.calib.m add command -label "Focus" -command "opencalibrate focus"
.mbar.calib.m add command -label "Dark" -command "opencalibrate dark"
.mbar.calib.m add command -label "Flat" -command "opencalibrate flat"
.mbar.calib.m add command -label "Sky" -command "opencalibrate sky"
.mbar.calib.m add command -label "Calculate WCS" -command "calcwcs"
.mbar.calib.m add command -label "Collimation" -command "observe collimate"
.mbar.tools.m add command -label "Auto-locate" -command autoIdentify
.mbar.tools.m add command -label "DSS" -command getDSS
.mbar.tools.m add command -label "GSC" -command getGSC
.mbar.tools.m add command -label "USNO" -command getUSNO
.mbar.tools.m add command -label "RNGC" -command getRNGC

lappend auto_path /usr/local/gui/extern/BWidget-1.2.1
package require BWidget
source tcl_aphelp.tcl
source tcl_cathelp.tcl
source tcl_telehelp.tcl
source tcl_calhelp.tcl
toplevel .p 
wm title .p Properties

NoteBook .p.props -width 510 -height 300
.p.props insert 1 Telescope -text Telescope
.p.props insert 2 System -text System
.p.props insert 3 Geometry -text Geometry
.p.props insert 4 Temperature -text Temperature
.p.props insert 5 CamReg -text CamReg
.p.props insert 6 Catalogs -text Catalogs
pack .p.props
set spc "                "
set xsize 220
set ysize 30

set fin [open $TKAPOGEE/tcl_config.dat r]
while { [gets $fin rec] > -1 } {
   catch {
   if { [lsearch "Telescope System Geometry Temperature CamReg Catalogs" $rec] > -1 } {
      set idx [expr [lsearch "Telescope System Geometry Temperature CamReg Catalogs" $rec] +1]
      set f [.p.props getframe $rec]
      set ix 0
      set iy 0
   } else {
      set name    [lindex $rec 0]
      set lname "$name[string range $spc 0 [expr 16-[string length $name]]]"
      set range   [lindex $rec 1]
      set default [lindex $rec 2]
      if { $range == "READONLY" } {
         label $f.$name -text "$lname" -fg DarkGray -bg gray -relief sunken -width 27
      }
      if { $range == "URL" } {
         button $f.$name -text "$lname" -fg black -bg gray -command "choosedir catalogs $name" -width 27
      }
      if { $range == "ONOFF" } {
         ComboBox $f.$name -label "$lname" -helptext "$APHELP($name)" -labelfont "fixed" -bg gray -values "Off On" -width 10 -textvariable CFG($name)
         $f.$name setvalue first
      }
      if { [llength [split $range :]] > 1 } {
         set vmin [lindex [split $range :] 0]
         set vmax [lindex [split $range :] 1]
         SpinBox $f.$name -label "$lname" -helptext "$APHELP($name)" -labelfont "fixed"  -range "$vmin $vmax 1" -width 10 -textvariable CFG($name)
         set CFG($name) $default
      }
      if { [llength [split $range "|"]] > 1 } {
         set opts [split $range "|"]
         ComboBox $f.$name -label "$lname" -helptext "$APHELP($name)" -labelfont "fixed"  -values "$opts" -width 10 -textvariable CFG($name)
         set CFG($name) $default
      }
      place $f.$name -x [expr 10+$xsize*$ix] -y [expr 10+$ysize*$iy]
      incr ix 1
      if { $ix > 1 } {
         set ix 0
         incr iy 1
      }
    }
   }
}
close $fin


toplevel .cal -bg gray -width 500 -height -250
wm  title .cal "Calibrations"
foreach t "zero dark flat skyflat" {
   frame .cal.$t -bg gray
   label .cal.$t.l -bg gray -text $t -width 8 
   checkbutton .cal.$t.auto -text automatic -variable CALS($t,auto)
   button .cal.$t.sel -text "Select library" -bg gray -command "choosedir calibrations $t"
   SpinBox .cal.$t.tmin -label "   min temp" -helptext "$APHELP(caltmin)" -labelfont "fixed"  -range "-40 40 1" -width 4 -textvariable CALS($t,tmin)
   SpinBox .cal.$t.tmax -label "   max temp" -helptext "$APHELP(caltmax)" -labelfont "fixed"  -range "-40 40 1" -width 4 -textvariable CALS($t,tmax)
   SpinBox .cal.$t.navg -label "   num. frames" -helptext "$APHELP(calnavg)" -labelfont "fixed"  -range "1 100 1" -width 4 -textvariable CALS($t,navg)
   SpinBox .cal.$t.exp -label "   exposure" -helptext "$APHELP(calexp)" -labelfont "fixed"  -range "0.02 65535. .01" -width 4 -textvariable CALS($t,exp)
   set CALS($t,tmin) -30
   set CALS($t,tmax) 10
   set CALS($t,navg) 10
   pack .cal.$t.l -side left -fill both -expand yes
   pack .cal.$t.auto -side left -fill both -expand yes
   pack .cal.$t.sel -side left -fill both -expand yes
   pack .cal.$t.tmin -side left -fill both -expand yes
   pack .cal.$t.tmax -side left -fill both -expand yes
   pack .cal.$t.navg -side left -fill both -expand yes
   pack .cal.$t.exp -side left -fill both -expand yes
   pack .cal.$t -side top -fill both -expand yes
}
set CALS(dark,exp) 10
set CALS(flat,exp) 0.5
set CALS(skyflat,exp) 0.5
foreach t "zero dark flat skyflat" {
   button .cal.run$t -text "Create $t calibrations library" -bg gray -command "createcalibrations $t"
   pack .cal.run$t -side top -fill both -expand yes
}
button .cal.close -text "close" -bg yellow -command "wm withdraw .cal"
pack .cal.close -side top -fill both -expand yes



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

set f [.p.props getframe Temperature]
set TEMPWIDGET $f.plot
graph $f.plot -title "Temperature" -width 500 -height 220
$f.plot element create Temp
$f.plot element create SetPoint
$f.plot element configure Temp -symbol none -xdata $xdata -ydata $ydata
$f.plot element configure SetPoint -color red -symbol none -xdata $xdata -ydata $ysetp
place $f.plot -x 0 -y 60
wm withdraw .cal
update
set type [exec grep base APCCD.INI]   
switch [lindex [split $type "="] 1] {
      290 { puts stdout "loading ISA driver"
            package ifneeded apogee 1.0    [load $libs/libapogee_isa.so] }
      378 { puts stdout "loading PPI driver"
            package ifneeded apogee 1.0    [load $libs/libapogee.so] }
}

set CFGFILE $TKAPOGEE/APCCD.INI
loadconfig
catch {open_camera $CFG(mode) $CFG(test) APCCD.INI }
set CCDID 0

proc watchconfig { arr var op } {
global CFG CCDID
#      puts stdout "$arr $var $op"
      switch $var {
          target { setpoint set $CFG($var) }
          gain   { catch {set_gain $CFG(gain) $CCDID} }
          bic     -
          bir     -
          skipc   -
          skipr   -
          imgcols -
          imgrows -
          hflush  -
          vflush  {
                     if {  [testgeometry] != "ok" } {
                         .p.props.fGeometry configure -bg orange
                         bell
                     } else {
                         .p.props.fGeometry configure -bg gray
                     }
                  }
     }
}

trace variable CFG w watchconfig
#config_camera  8 3 522 511 1 1 30 0 0 0
refreshcamdata
monitortemp



