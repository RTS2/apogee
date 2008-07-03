

#
# This script assists the user in selecting the appropriate kernel module
# for an Apogee CCD camera driver.
#

puts stdout "Please choose the correct ini file for your camera"
set cfg [tk_getOpenFile -initialdir /opt/apogee/config/ -filetypes {{{Apogee cameras} {.ini}}}]
if { [file exists "$cfg"] } {
      set i [string trim [lindex [split [exec grep Interface $cfg] =] 1]]
      switch $i {
           PPI { set l "Cancel 0x378 0x278 0x3BC"
                 set it [ tk_dialog .d "Select IO address" "Please specify the IO address for the camera ?" {} -1 Cancel "0x378" "0x278" "0x3BC"]
                 set marg "apppi_addr=[lindex $l $it]"
                 catch {
                    foreach n "0 1 2 3" {
                       exec mknod /dev/apppi$n c 61 $n
                       exec chmod og+rw /dev/apppi$n
                    }
                 }
               }
           ISA { set l "Cancel 0x290 0x200 0x210 0x280 0x300 0x310 0x390"
                 set it [ tk_dialog .d "Select IO address" "Please specify the IO address for the camera ?" {} -1 Cancel "0x290" "0x200" "0x210" "0x280" "0x300" "0x310" "0x390"]
                 set marg "apisa_addr=[lindex $l $it]"
                 catch {
                    foreach n "0 1 2 3" {
                       exec mknod /dev/apisa$n c 62 $n
                       exec chmod og+rw /dev/apisa$n
                    }
                 }
               }
           PCI { set it 1
                 set marg ""
                 catch {
                    foreach n "0 1 2 3" {
                       exec mknod /dev/appci$n c 60 $n
                       exec chmod og+rw /dev/appci$n
                    }
                 }
               }
      }
}

puts stdout $marg

#
# Check for a known installation
#

set modpath none

if { [file exists /etc/redhat-release] } {
   set fin [open /etc/redhat-release r] ; gets $fin rec ; close $fin
   set v redhat[lindex $rec 4]
   if { [file exists /opt/apogee/src/apogee/module/$v] } {
      puts stdout "Located prebuilt modules ($v)"
      set modpath /opt/apogee/src/apogee/module/$v
   }
}

if { [file exists /etc/mandrake-release] } {
   set fin [open /etc/mandrake-release r] ; gets $fin rec ; close $fin
   set v mandrake[lindex $rec 3]
   if { [file exists /opt/apogee/src/apogee/module/$v] } {
      puts stdout "Located prebuilt modules ($v)"
      set modpath /opt/apogee/src/apogee/module/$v
   }
}

if { [file exists /etc/SuSE-release] } {
   set fin [open /etc/SuSE-release r] ; gets $fin rec ; close $fin
   set v suse[lindex $rec 2]
   if { [file exists /opt/apogee/src/apogee/module/$v] } {
      puts stdout "Located prebuilt modules ($v)"
      set modpath /opt/apogee/src/apogee/module/$v
   }
}

if { $modpath == "none" } {
      set it [ tk_dialog .d "Load failure" "There is no prebuilt module\n - building a custom version" {} -1 OK]
      cd /opt/apogee/src/apogee/module
      exec make
      set modpath /opt/apogee/src/apogee/module
}


if { $modpath != "none" } {
   exec /sbin/insmod $modpath/apogee$i.o $marg
   set ok 0
   catch {
     set mods [exec /sbin/lsmod | grep apogee$i]
     set ok 1
   }
   if { $ok } {
   } else {
      set it [ tk_dialog .d "Load failure" "The chosen module failed to load\n - building a custom version" {} -1 OK]
      cd /opt/apogee/src/apogee/module
      exec make
      set modpath /opt/apogee/src/apogee/module
      exec /sbin/insmod $modpath/apogee$i.o $marg
      set ok 0
      catch {
        set mods [exec /sbin/lsmod | grep apogee$i]
        set ok 1
      }
   }
   if { $ok } {
      set it [ tk_dialog .d "Load OK" "The chosen module loads OK\n - Do you want it loaded automatically after a reboot?" {} -1 No Yes]
      if { $it } {
         cd /etc/rc.d
         if { [file exists rc.local.preapogee] } {
            exec cp rc.local.preapogee rc.local
         }
         exec cp rc.local rc.local.preapogee
         set fout [open rc.local a]
         puts $fout " "
         puts $fout "echo \"Loading Apogee CCD driver module\""
         puts $fout "/sbin/insmod $modpath/apogee$i.o $marg"
         close $fout
      }
      set fout [open /usr/bin/apogee_load w]
      puts $fout "#!/bin/sh"
      puts $fout "echo \"Loading Apogee CCD driver module\""
      puts $fout "/sbin/insmod $modpath/apogee$i.o $marg"
      close $fout
      set fout [open /usr/bin/apogee_remove w]
      puts $fout "#!/bin/sh"
      puts $fout "/sbin/rmmod apogee$i"
      close $fout
      exec chmod 755 /usr/bin/apogee_load
      exec chmod 755 /usr/bin/apogee_remove
      set it [ tk_dialog .d "Done" "The module can be manually loaded or removed\n using the commands\n\n/usr/bin/apogee_load\n/usr/bin/apogee_remove" {} -1 OK]
   }
}


exit



