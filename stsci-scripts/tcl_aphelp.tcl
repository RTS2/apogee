
set APHELP(base) "
Default value :
none
Value range :
none
Purpose :
This entry defines the hexadecimal base address of the camera interface card. 
open_camera() will return CCD_OPEN_LOOPTST if the base address is incorrect or the 
interface card is not installed."
set APHELP(reg_offset) "
Default value:
Value range :
0..240
Purpose :
Define the register offset of the associated PPI camera."
set APHELP(c0_repeat) "
Default value:
Value range :
1..64k-1
Purpose :
This parameter defines a repeat count to slow the parallel port phase transitions so the
                         PPI cameras have time to react."
set APHELP(mode) "
Default value:
Value range :
0..15
Purpose :
Define the default value of the mode parameter to the open_camera() API routine."
set APHELP(test) "
Default value :
Value range :
0..15
Purpose :
Define the default value of the test parameter to the open_camera() API routine."
set APHELP(test2) "
Default value :
Value range :
0..15
Purpose :
Define the default value of the test parameter to the open_camera() API routine."
set APHELP(shutter) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
Default value of the shutter_enable parameter to the start_exposure() API routine. Value 
string is case insensitive."
set APHELP(trigger) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
Default value of the trigger_mode parameter to the start_exposure() API routine. Value 
string is case insensitive."
set APHELP(driftscan) "
Default value : 
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
Default value of the TDI parameter to the start_exposure() API routine. Value 
string is case insensitive."
set APHELP(shutter_speed) "
Default value : normal
Value range : normal, fast, dual
Purpose :
Default value of the shutter speed."
set APHELP(guider_relays) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
Default value of the Guider_Relays parameter."
set APHELP(slice) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
This entry controls whether slice mode acquisitions are supported by the sensor. If the 
value is 0, calls to config_slice() and acquire_slice() will return errors."
set APHELP(slice_time) "
Default value :
Value range :
unsigned short integer greater than 0
Purpose :
This value determines the minimum time between shutter close and open commands in 
slice mode acquisitions that control the shutter. The value is defined in milliseconds."
set APHELP(caching) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
This entry defines whether the camera interface supports cached image data transfers. If 
this value is ON and the cache parameter to the acquire_image() or acquire_line() API 
routine is also TRUE, caching will be used during the transfer. This entry will be reset to 
OFF if the mode and test entries are both 0."
set APHELP(gain) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
This entry determines whether the camera hardware supports dual gain operation."
set APHELP(frame_timeout) "
Default value :
Value range :
unsigned short integer greater than 0
Purpose :
This value determines the base timeout value used in internal routines when waiting for 
the frame done bit. The value is defined in seconds."
set APHELP(line_timeout) "
Default value :
Value range :
unsigned short integer greater than 0
Purpose :
This value determines the timeout value used in internal routines when waiting for the 
line done bit. The value is defined in seconds."
set APHELP(cable) "
Default value :
SHORT = 0
Value range :
LONG = 1, else 0
Purpose :
This entry determines whether the camera data cable delivered with your system 
requires special interface timing because of its length."
set APHELP(data_bits) "
Default value :
Value range :
{12,14,16}
Purpose :
This entry defines the bit depth of camera pixel values."
set APHELP(port_bits) "
Default value :
Value range :
0..8
Purpose :
This entry defines how many bits are available to be used by the output_port() API 
routine."
set APHELP(tscale) "
Default value :
Value range :
double real
Purpose :
This value defines the exposure time constant used by the camera control library. It 
should not be modified by user software. Applications must retrieve this value to convert 
internal timer units to/from seconds. See the description of config_camera() for details."
set APHELP(columns) "
Default value :
none
Value range :
1..4096
Purpose :
This entry defines the virtual number of pixel columns on the sensor surface. To get the 
largest possible image from caching controllers, read the geometry note below. This 
number may be larger than the physical number of sensor columns."
set APHELP(rows) "
Default value :
none
Value range :
1..4096
Purpose :
This entry defines the virtual number of pixel rows on the sensor surface. To get the 
largest possible image from caching controllers, read the geometry note below. This 
number may be larger than the physical number of sensor rows."
set APHELP(bic) "
Default value :
Value range :
1..4096
Purpose :
This entry defines the number of columns at the beginning of each pixel row that are 
non-imaging (bic = before image columns)."
set APHELP(bir) "
Default value :
Value range :
1..4096
Purpose :
This entry defines the number of rows at the beginning of the CCD that are non-imaging 
(bir = before image rows)."
set APHELP(skipc) "
Default value :
Value range :
unsigned
Purpose :
This entry defines the number of pixels that must be read from the camera fifo to clear 
or stabilize the data transfer pipeline. To get the largest possible image from caching 
controllers, read the geometry note below."
set APHELP(skipr) "
Default value :
Value range :
unsigned
Purpose :
This entry defines the number of rows that must be read from the camera fifo to clear or 
stabilize the data transfer pipeline. To get the largest possible image from caching 
controllers, read the geometry note below."
set APHELP(numcols) "
Default value :
columns - bic - skipc
Value range :
1..4096
Purpose :
This entry defines the number of imaging columns on the sensor surface."
set APHELP(numrows) "
Default value :
rows - bir - skipr
Value range :
1..4096
Purpose :
This entry defines the number of imaging rows on the sensor surface."
set APHELP(startcol) "
Default value : 1
Value range :
1..4096
Purpose :
This entry defines the start of imaging columns on the sensor surface."
set APHELP(startrow) "
Default value : 1
Value range :
1..4096
Purpose :
This entry defines the start of imaging rows on the sensor surface."
set APHELP(hflush) "
Default value :
Value range :
1..8
Purpose :
This entry defines the value of the horizontal binning parameter used during camera pre-
exposure and intra-exposure flush operations. This entry will be reset to 1 if the mode 
and test entries are both 0."
set APHELP(vflush) "
Default value :
Value range :
1..64
Purpose :
This entry defines the value of the vertical binning parameter used during camera pre-
exposure and intra-exposure flush operations. This entry will be reset to 1 if the mode 
and test entries are both 0."
set APHELP(binx) "
Default value :
Value range :
1..8
Purpose :
This entry defines the value of the horizontal binning parameter used during camera 
exposure operations. This entry will be reset to 1 if the mode 
and test entries are both 0."
set APHELP(biny) "
Default value :
Value range :
1..64
Purpose :
This entry defines the value of the vertical binning parameter used during camera 
exposure operations. This entry will be reset to 1 if the mode 
and test entries are both 0."
set APHELP(maxbinx) "
Default value :
Value range :
1..8
Purpose :
This entry defines the maximum value of the horizontal binning parameter used during camera 
exposure operations. This entry will be reset to 1 if the mode 
and test entries are both 0."
set APHELP(maxbiny) "
Default value :
Value range :
1..64
Purpose :
This entry defines the maximum value of the vertical binning parameter used during camera 
exposure operations. This entry will be reset to 1 if the mode 
and test entries are both 0."
set APHELP(target) "
Default value :
Value range :
-40.0..40.0
Purpose :
Define the default target temerature of the camera temperature sub-system. "
set APHELP(backoff) "
Default value :
Value range :
double real
Purpose :
Define the suggested size to decrement or increment a target temperature that causes 
the cooling sub-system to return CCD_TMPSTUCK or CCD_TMPMAX status values."
set APHELP(temp_cal) "
Default value :
Value range :
double real
Purpose :
Define the temperature calibration intercept value. Internal temperature control values 
are calculated using the formula; DacValue = desired_temp * temp_scale + temp_cal;"
set APHELP(temp_scale) "
Default value :
Value range :
double real
Purpose :
Define the temperature calibration slope value. Internal temperature control values are 
calculated using the formula; DacValue = desired_temp * temp_scale + temp_cal;"
set APHELP(gain) "
Default value :
Value range :
0..1
Purpose :
Define the initial value of the camera gain. If the camera system supports dual gain, see 
\[system\] gain, and this value is 1, the camera will initially acquire data using the high 
gain setting."
set APHELP(opt1) "
Default value :
Value range :
0..1
Purpose :
Define the initial value of the camera option 1 setting. If this value is 1, the option will be 
active."
set APHELP(opt2) "
Default value :
Value range :
0..1
Purpose :
Define the initial value of the camera option 2 setting. If this value is 1, the option will be 
active."
set APHELP(base) "
Default value :
none
Value range :
none
Purpose :
This entry defines the hexadecimal base address of the camera interface card. 
open_camera() will return CCD_OPEN_LOOPTST if the base address is incorrect or the 
interface card is not installed."
set APHELP(reg_offset) "
Default value:
Value range :
0..240
Purpose :
Define the register offset of the associated PPI camera."
set APHELP(c0_repeat) "
Default value:
Value range :
1..64k-1
Purpose :
This parameter defines a repeat count to slow the parallel port phase transitions so the
                         PPI cameras have time to react."
set APHELP(mode) "
Default value:
Value range :
0..15
Purpose :
Define the default value of the mode parameter to the open_camera() API routine."
set APHELP(test) "
Default value :
Value range :
0..15
Purpose :
Define the default value of the test parameter to the open_camera() API routine."
set APHELP(shutter) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
Default value of the shutter_enable parameter to the start_exposure() API routine. Value 
string is case insensitive."
set APHELP(trigger) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
Default value of the trigger_mode parameter to the start_exposure() API routine. Value 
string is case insensitive."
set APHELP(slice) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
This entry controls whether slice mode acquisitions are supported by the sensor. If the 
value is 0, calls to config_slice() and acquire_slice() will return errors."
set APHELP(slice_time) "
Default value :
Value range :
unsigned short integer greater than 0
Purpose :
This value determines the minimum time between shutter close and open commands in 
slice mode acquisitions that control the shutter. The value is defined in milliseconds."
set APHELP(caching) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
This entry defines whether the camera interface supports cached image data transfers. If 
this value is ON and the cache parameter to the acquire_image() or acquire_line() API 
routine is also TRUE, caching will be used during the transfer. This entry will be reset to 
OFF if the mode and test entries are both 0."
set APHELP(gain) "
Default value :
OFF = 0
Value range :
ON or TRUE = 1, else 0
Purpose :
This entry determines whether the camera hardware supports dual gain operation."
set APHELP(frame_timeout) "
Default value :
Value range :
unsigned short integer greater than 0
Purpose :
This value determines the base timeout value used in internal routines when waiting for 
the frame done bit. The value is defined in seconds."
set APHELP(line_timeout) "
Default value :
Value range :
unsigned short integer greater than 0
Purpose :
This value determines the timeout value used in internal routines when waiting for the 
line done bit. The value is defined in seconds."
set APHELP(cable) "
Default value :
SHORT = 0
Value range :
LONG = 1, else 0
Purpose :
This entry determines whether the camera data cable delivered with your system 
requires special interface timing because of its length."
set APHELP(data_bits) "
Default value :
Value range :
12,14,16
Purpose :
This entry defines the bit depth of camera pixel values."
set APHELP(port_bits) "
Default value :
Value range :
0..8
Purpose :
This entry defines how many bits are available to be used by the output_port() API 
routine."
set APHELP(tscale) "
Default value :
Value range :
double real
Purpose :
This value defines the exposure time constant used by the camera control library. It 
should not be modified by user software. Applications must retrieve this value to convert 
internal timer units to/from seconds. See the description of config_camera() for details."
set APHELP(columns) "
Default value :
none
Value range :
1..4096
Purpose :
This entry defines the virtual number of pixel columns on the sensor surface. To get the 
largest possible image from caching controllers, read the geometry note below. This 
number may be larger than the physical number of sensor columns."
set APHELP(rows) "
Default value :
none
Value range :
1..4096
Purpose :
This entry defines the virtual number of pixel rows on the sensor surface. To get the 
largest possible image from caching controllers, read the geometry note below. This 
number may be larger than the physical number of sensor rows."
set APHELP(bic) "
Default value :
Value range :
1..4096
Purpose :
This entry defines the number of columns at the beginning of each pixel row that are 
non-imaging (bic = before image columns)."
set APHELP(bir) "
Default value :
Value range :
1..4096
Purpose :
This entry defines the number of rows at the beginning of the CCD that are non-imaging 
(bir = before image rows)."
set APHELP(skipc) "
Default value :
Value range :
unsigned
Purpose :
This entry defines the number of pixels that must be read from the camera fifo to clear 
or stabilize the data transfer pipeline. To get the largest possible image from caching 
controllers, read the geometry note below."
set APHELP(skipr) "
Default value :
Value range :
unsigned
Purpose :
This entry defines the number of rows that must be read from the camera fifo to clear or 
stabilize the data transfer pipeline. To get the largest possible image from caching 
controllers, read the geometry note below."
set APHELP(imgcols) "
Default value :
columns - bic - skipc
Value range :
1..4096
Purpose :
This entry defines the number of imaging columns on the sensor surface."
set APHELP(imgrows) "
Default value :
rows - bir - skipr
Value range :
1..4096
Purpose :
This entry defines the number of imaging rows on the sensor surface."
set APHELP(hflush) "
Default value :
Value range :
1..8
Purpose :
This entry defines the value of the horizontal binning parameter used during camera pre-
exposure and intra-exposure flush operations. This entry will be reset to 1 if the mode 
and test entries are both 0."
set APHELP(vflush) "
Default value :
Value range :
1..64
Purpose :
This entry defines the value of the vertical binning parameter used during camera pre-
exposure and intra-exposure flush operations. This entry will be reset to 1 if the mode 
and test entries are both 0."
set APHELP(target) "
Default value :
Value range :
-40.0..40.0
Purpose :
Define the default target temerature of the camera temperature sub-system. "
set APHELP(backoff) "
Default value :
Value range :
double real
Purpose :
Define the suggested size to decrement or increment a target temperature that causes 
the cooling sub-system to return CCD_TMPSTUCK or CCD_TMPMAX status values."
set APHELP(cal) "
Default value :
Value range :
double real
Purpose :
Define the temperature calibration intercept value. Internal temperature control values 
are calculated using the formula; DacValue = desired_temp * temp_scale + temp_cal;"
set APHELP(scale) "
Default value :
Value range :
double real
Purpose :
Define the temperature calibration slope value. Internal temperature control values are 
calculated using the formula; DacValue = desired_temp * temp_scale + temp_cal;"
set APHELP(gain) "
Default value :
Value range :
0..1
Purpose :
Define the initial value of the camera gain. If the camera system supports dual gain, see 
system gain, and this value is 1, the camera will initially acquire data using the high
gain setting."
set APHELP(opt1) "
Default value :
Value range :
0..1
Purpose :
Define the initial value of the camera option 1 setting. If this value is 1, the option will be 
active."
set APHELP(opt2) "
Default value :
Value range :
0..1
Purpose :
Define the initial value of the camera option 2 setting. If this value is 1, the option will be 
active."
set APHELP(position) "
Default value :
Value range :
0..16
Purpose :
Set the filter wheel position if available"
set APHELP(type) "
Default value : none
Value range :
apogee, holmeyer, custom
Purpose :
Set the filter wheel type if available"


