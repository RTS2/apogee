set fout [open sourcefiles.lst w]
set all [lsort [glob *.h]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob *.c]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob *.i]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob *.cpp]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob ApogeeNet/*.h]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob ApogeeNet/*.cpp]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob ApogeeUsb/*.h]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob ApogeeUsb/*.cpp]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob ApogeeNet/*.h]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob FpgaRegs/*]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
set all [lsort [glob mak*]]
foreach f $all {
   puts $fout "/opt/apogee/src/apogee/$f"
}
close $fout

