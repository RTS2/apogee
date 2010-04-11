#
# APOGEE makefile for linux
# $Id: Makefile.svr4,v 1.4 2004/02/15 07:34:43 rfactory Exp $
#


DEVHOME		= .
INSTALL_DIR	= /opt/apogee/lib
TCLSRC = /opt/apogee/extern/tcl8.3.1/generic
TKSRC = /opt/apogee/extern/tk8.3.1/generic                                   



.KEEP_STATE:
CC =	g++
SWIG = /opt/apogee/bin/swig

INCDIR		= $(DEVHOME)
PRIVATEINCDIR	= ../../include
GUIINC          = /opt/apogee/include
ALTAINC		= -I./ApogeeUsb -I./ApogeeNet -I./FpgaRegs -DHAVE_STRERROR
CPPFLAGS	= -O2 -g -fpic -DWall -DLINUX -Iinclude -I.
SWIGFLAGS	= -tcl8 -c++ -I/opt/apogee/lib/swig1.3 -I/opt/apogee/lib/swig1.3/tcl
LDFLAGS		= -shared -O2 -g
CONFIGTARGETS	= apogee_ISA.so apogee_PCI.so apogee_PPI.so \
		  apogee_USB.so apogee_NET.so \
		  serial_USB.so serial_NET.so

all: $(CONFIGTARGETS)

include models.mak


apogee_ISA.so:	
	$(CC) $(CPPFLAGS) -c CameraIO_Linux.cpp
	$(CC) $(CPPFLAGS) -c CameraIO_LinuxISA.cpp
	$(SWIG) $(SWIGFLAGS) apogeeISA.i
	$(CC) $(CPPFLAGS) -c apogeeISA_wrap.c
	$(CC) $(LDFLAGS) apogeeISA_wrap.o CameraIO_Linux.o CameraIO_LinuxISA.o -o apogee_ISA.so

apogee_PCI.so:	
	$(CC) $(CPPFLAGS) -c CameraIO_Linux.cpp
	$(CC) $(CPPFLAGS) -c CameraIO_LinuxPCI.cpp
	$(SWIG) $(SWIGFLAGS) apogeePCI.i
	$(CC) $(CPPFLAGS) -c apogeePCI_wrap.c
	$(CC) $(LDFLAGS) apogeePCI_wrap.o CameraIO_Linux.o CameraIO_LinuxPCI.o -o apogee_PCI.so

apogee_PPI.so: 
	$(CC) $(CPPFLAGS) -c CameraIO_Linux.cpp
	$(CC) $(CPPFLAGS) -c CameraIO_LinuxPPI.cpp
	$(SWIG) $(SWIGFLAGS) apogeePPI.i
	$(CC) $(CPPFLAGS) -c apogeePPI_wrap.c
	$(CC) $(LDFLAGS) apogeePPI_wrap.o CameraIO_Linux.o CameraIO_LinuxPPI.o -o apogee_PPI.so

apogee_USB.so: CamData
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera_USB.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera_Linux.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApogeeUsb/ApogeeUsbLinux.cpp 
	$(CC) $(LDFLAGS) ApnCamera.o ApnCamera_Linux.o ApnCamera_USB.o \
			ApogeeUsbLinux.o ApnCamData*.o ApnCamTable.o \
			-o apogee_USB.so -I. -lusb

filter_USB.so:
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnFilterWheel.cpp
	$(SWIG) $(SWIGFLAGS) filterUSB.i
	$(CC) $(CPPFLAGS) $(ALTAINC) -c filterUSB_wrap.c
	$(CC) $(LDFLAGS) ApnFilterWheel.o filterUSB_wrap.o \
			 -o filter_USB.so -I. /opt/apogee/lib/libusb.so /opt/apogee/lib/apogee_USB.so

serial_USB.so:
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnSerial.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnSerial_USB.cpp
	$(SWIG) $(SWIGFLAGS) serialUSB.i
	$(CC) $(CPPFLAGS) $(ALTAINC) -c serialUSB_wrap.c
	$(CC) $(LDFLAGS) ApnSerial.o ApnSerial_USB.o serialUSB_wrap.o \
			 -o serial_USB.so -I. /opt/apogee/lib/libusb.so /opt/apogee/lib/apogee_USB.so
serial_NET.so:
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnSerial.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnSerial_NET.cpp
	$(SWIG) $(SWIGFLAGS) serialNET.i
	$(CC) $(CPPFLAGS) $(ALTAINC) -c serialNET_wrap.c
	$(CC) $(LDFLAGS) ApnSerial.o ApnSerial_NET.o serialNET_wrap.o \
			 -o serial_NET.so -I. /opt/apogee/lib/libcurl.a -lz /opt/apogee/lib/apogee_NET.so

#
#  Legacy version for use with kernel modules, deprecated in favor
#  of libusb based access.
#
#apogee_USB.so: CamData
#	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera.cpp
#	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera_USB.cpp
#	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera_Linux.cpp
#	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApogeeUsb/ApogeeUsbLinuxForKernel.cpp 
#	$(SWIG) $(SWIGFLAGS) apogeeUSB.i
#	$(CC) $(CPPFLAGS) $(ALTAINC) -c apogeeUSB_wrap.c
#	$(CC) $(LDFLAGS) ApnCamera.o ApnCamera_Linux.o ApnCamera_USB.o \
#			ApogeeUsbLinuxForKernel.o ApnCamData*.o ApnCamTable.o \
#			apogeeUSB_wrap.o -o apogee_USB.so -I.

apogee_NET.so: CamData
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera_NET.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApnCamera_Linux.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApogeeNet/ApogeeNet.cpp
	$(CC) $(CPPFLAGS) $(ALTAINC) -c ApogeeNet/ApogeeNetLinux.c 
	$(CC) $(LDFLAGS) ApnCamera.o ApnCamera_Linux.o ApnCamera_NET.o \
			ApogeeNet.o ApogeeNetLinux.o ApnCamData*.o ApnCamTable.o \
			-o apogee_NET.so -I. -lcurl -lz


test_altae: apogee_NET.so
	$(CC) $(CPPFLAGS) $(ALTAINC) -DALTA_NET test_alta.cpp -IFpgaRegs -o test_altae \
			ApogeeNet.o ApogeeNetLinux.o ApnCamData*.o ApnCamTable.o  \
			ApnCamera.o ApnCamera_Linux.o ApnCamera_NET.o  \
			-L/opt/apogee/lib -ltcl8.3 -lccd -lfitsTcl /opt/apogee/lib/libcurl.a -lz

test_altau: apogee_USB.so
	$(CC) $(CPPFLAGS) $(ALTAINC) test_alta.cpp -IFpgaRegs -o test_altau \
			ApogeeUsbLinux.o ApnCamData*.o ApnCamTable.o  \
			ApnCamera.o ApnCamera_Linux.o ApnCamera_USB.o  \
			-L/opt/apogee/lib -lccd -lfitsTcl -lusb

test_staticu:
	$(CC) $(CPPFLAGS) $(ALTAINC) test_alta.cpp -IFpgaRegs -o test_staticu \
			ApogeeUsbLinux.o ApnCamData*.o ApnCamTable.o  \
			ApnCamera.o ApnCamera_Linux.o ApnCamera_USB.o  \
			apogeeUSB_wrap.o -L/opt/apogee/lib -ltcl8.3 -lccd -lfitsTcl \
			/opt/apogee/lib/libusb.so

test_apogeeppi: apogee_PPI.so
	$(CC) $(CPPFLAGS) $(ALTAINC)  test_apogee.cpp -o test_apogeeppi \
			CameraIO_Linux.o CameraIO_LinuxPPI.o \
			-L/opt/apogee/lib -ltcl8.3 -lccd -lfitsTcl

test_apogeepci: apogee_PCI.so
	$(CC) $(CPPFLAGS) $(ALTAINC)  test_apogee.cpp -o test_apogeepci \
			CameraIO_Linux.o CameraIO_LinuxPCI.o \
			-L/opt/apogee/lib -ltcl8.3 -lccd -lfitsTcl

test_apogeeisa: apogee_ISA.so
	$(CC) $(CPPFLAGS) $(ALTAINC)  test_apogee.cpp -o test_apogeeisa \
			CameraIO_Linux.o CameraIO_LinuxISA.o \
			-L/opt/apogee/lib -ltcl8.3 -lccd -lfitsTcl

install: $(CONFIGTARGETS) FORCE
	cp $(CONFIGTARGETS) $(INSTALL_DIR)

clean:
	rm -f tags TAGS .make.state .nse_depinfo *.o *.so

tags:
	ctags $(LIBSOURCES)

FORCE:



