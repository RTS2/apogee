// ApogeeIoctl.h    Include file for I/O 
//
// Copyright (c) 2000 Apogee Instruments Inc.
//Portions Copyright (c) 2000 The Random Factory.
//
// Define the IOCTL codes we will use.  The IOCTL code contains a command
// identifier, plus other information about the device, the type of access
// with which the file must have been opened, and the type of buffering.
//

#ifdef LINUX


extern unsigned short apogee_bit;
extern unsigned short apogee_word;
extern unsigned long apogee_long;
extern short apogee_signed;


// General Ioctl definitions for Apogee CCD device driver 

#define APOGEE_IOC_MAGIC 'j'
#define APOGEE_IOC_MAXNR 100
#define APOGEE_IOCHARDRESET   _IO(APOGEE_IOC_MAGIC,0)

 
// Read single word 
#define IOCTL_GPD_READ_ISA_USHORT  _IOR(APOGEE_IOC_MAGIC,1,apogee_word)   
 
// Write single word 
#define IOCTL_GPD_WRITE_ISA_USHORT _IOW(APOGEE_IOC_MAGIC,2,apogee_word)  
    
// Read line from camera 
#define IOCTL_GPD_READ_ISA_LINE _IOR(APOGEE_IOC_MAGIC,3,apogee_word)  
 
#define IOCTL_GPD_READ_PPI_USHORT _IOR(APOGEE_IOC_MAGIC,1,apogee_word)  
    
// Write single word 
#define IOCTL_GPD_WRITE_PPI_USHORT _IOW(APOGEE_IOC_MAGIC,2,apogee_word)  
 
// Read line from camera 
#define IOCTL_GPD_READ_PPI_LINE  _IOR(APOGEE_IOC_MAGIC,3,apogee_word)  
   

#else

// Device type           -- in the "User Defined" range."
#define GPD_TYPE 40000

// The IOCTL function codes from 0x800 to 0xFFF are for customer use.

// Read single word
#define IOCTL_GPD_READ_ISA_USHORT \
    CTL_CODE(GPD_TYPE, 0x901, METHOD_BUFFERED, FILE_READ_ACCESS )

// Write single word
#define IOCTL_GPD_WRITE_ISA_USHORT \
    CTL_CODE(GPD_TYPE,  0x902, METHOD_BUFFERED, FILE_WRITE_ACCESS)

// Read line from camera
#define IOCTL_GPD_READ_ISA_LINE \
    CTL_CODE(GPD_TYPE,  0x903, METHOD_BUFFERED, FILE_READ_ACCESS)

#define IOCTL_GPD_READ_PPI_USHORT \
    CTL_CODE(GPD_TYPE, 0x904, METHOD_BUFFERED, FILE_READ_ACCESS )

// Write single word
#define IOCTL_GPD_WRITE_PPI_USHORT \
    CTL_CODE(GPD_TYPE,  0x905, METHOD_BUFFERED, FILE_WRITE_ACCESS)

// Read line from camera
#define IOCTL_GPD_READ_PPI_LINE \
    CTL_CODE(GPD_TYPE,  0x906, METHOD_BUFFERED, FILE_READ_ACCESS)


#endif
