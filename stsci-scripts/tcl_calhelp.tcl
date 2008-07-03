set APHELP(caltmin) "
Default value : 
-30.0
Value range :
-40.0 , 40.0
Purpose :
Sets the starting low temperature limit for the construction of a 
library of calibration frames. The procedure will step from min
to max temperature in steps of 1 deg. A calibration frame 
(average of n frames) is output for each temperature in the range.
Selecting automatic will instruct the program to automatically 
calibrate observation frames using the best (nearest temperature
match) frame from the selected calibration library."
set APHELP(caltmax) "
Default value : 
-30.0
Value range :
-40.0 , 40.0
Purpose :
Sets the maximum temperature limit for the construction of a 
library of calibration frames. The procedure will step from min
to max temperature in steps of 1 deg. A calibration frame 
(average of n frames) is output for each temperature in the range.
Selecting automatic will instruct the program to automatically 
calibrate observation frames using the best (nearest temperature
match) frame from the selected calibration library."
set APHELP(calnavg) "
Default value : 
10
Value range :
1 , 100
Purpose :
Sets the number of frames to average when constructing each
calibration frame. Note that the calibration procedure will 
take (average * (tmax-tmin)) exposures. The frame averaging is
done im memory and only 1 frame per temperature increment is
written to disk. Sufficient memory is required to store the
number of frames chosen to average."
set APHELP(calexp) "
Default value : 
0.5
Value range :
0.02 , 65535.
Purpose :
Sets the exposure time (in seconds). Note that the calibration procedure will 
take (average * (tmax-tmin)) exposures, and each exposure will 
require a number of seconds to read out."

                                               
