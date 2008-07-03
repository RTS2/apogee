#
#  Copy model specific CamData files from a new release
#

proc copynew { from } {
  set all [lsort [glob $from/ApnCamData_*.h]]
  set fcc [open models.mak w]
  set fsm [open SupportedModels.txt w]
  puts $fcc "
CamData:
	\$(CC) \$(CPPFLAGS) -c ApnCamData.cpp
	\$(CC) \$(CPPFLAGS) -c ApnCamTable.cpp"
  exec cp $from/ApnCamData.cpp .
  exec cp $from/ApnCamData.h .
  exec cp $from/ApnCamTable.cpp .
  exec cp $from/ApnCamTable.h .
  foreach i $all { 
      set model [string trim [string range [file tail $i] 11 end] ".h"]
      puts $fsm "$model"
      puts $fcc "	\$(CC) \$(CPPFLAGS) -c ApnCamData_$model.cpp"
      exec cp $from/ApnCamData_$model.h .
      exec cp $from/ApnCamData_$model.cpp .
      puts stdout "Processed $model"
  }
  puts $fcc " "
  close $fcc
  close $fsm
  set all [lsort [glob ApnCamData_*.h]]
  foreach i $all { 
    set fap [open $i a]
    puts $fap " "
    close $fap 
    puts stdout "done $i"
  }
}



