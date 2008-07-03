

set t [split [exec grep Apn_ Apogee.h | grep int] \n]
set t2 [split [exec grep Camera_ Apogee.h | grep int] \n]
foreach i "$t\n$t2" {
   set T([lindex $i 1]) 1
   puts stdout "Type [lindex $i 1]"
}

set fusb [open apogeeUSB.i w]
set fnet [open apogeeNET.i w]
puts $fusb "/* File : apogeeUSB.i */
%module apogee_usb
%\{     
\#include \"ApnCamera.h\" 
%\}"
puts $fnet "/* File : apogeeNET.i */
%module apogee_net
%\{     
\#include \"ApnCamera.h\" 
%\}"

foreach s [lsort [array names T]] {
   puts $fusb "%typemap(tcl,in) $s = int;"
   puts $fusb "%typemap(tcl,out) $s = int;"
   puts $fnet "%typemap(tcl,in) $s = int;"
   puts $fnet "%typemap(tcl,out) $s = int;"
}

puts $fusb "
%include \"ApnCamera.i\"
"

puts $fnet "
%include \"ApnCamera.i\"
"


close $fusb
close $fnet
