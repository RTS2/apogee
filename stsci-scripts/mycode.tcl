set $SCOPE(imagename) [exec date +%j%H]
set $SCOPE(driftsamp) 100000
set $SCOPE(driftdcalc) 100000
set $SCOPE(driftrows) 60

driftcalib
driftcalc
driftscan 0 0
exit
