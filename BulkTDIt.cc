#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "fitsio.h"
#include <math.h>
#include <unistd.h>
#include <time.h>
#include "ApnCamera.h"
#include "ccd.h"


void main()
{
	CApnCamera *ApogeeCamera;			// Camera interface
	
	HRESULT 	hr;				// Return code 
	FILE*		filePtr;			// File pointer 
	unsigned short	NumTdiRows;			// Number of images to take
	double		TdiRate;			// TDI rate (in seconds)
	unsigned short* pBuffer;
	unsigned long	ImgSizeBytes;
	char		szFilename[80];			// File name


	printf( "Apogee Alta Bulk TDI Sample Applet\n" );


	// Create the CApnCamera object
	ApogeeCamera = (CApnCamera *)new CApnCamera();


	// Initialize camera using the default properties
	hr = ApogeeCamera->InitDriver( 0xC0A80116,
				       0x50,
				       0x0 );

	if ( hr == CAPNCAMERA_SUCCESS )
	{
		printf( "Connection to camera succeeded.\n" );
	}
	else
	{
		printf( "Failed to connect to camera" );
		
		ApogeeCamera	= NULL;		// Release CApnCamera object
		return;
	}

/*      Do a system reset to ensure known state, flushing enabled etc */
        ApogeeCamera->ResetSystem();


	printf("Current CCD temperature : %d\n",ApogeeCamera->TempCCD);


	// Query user for number of TDI rows
	printf( "Number of TDI Rows:  " );
	scanf( "%d", &NumTdiRows );
	printf( "Image to contain %d rows.\n", NumTdiRows );

	// Query user for TDI rate
	printf( "Interval between rows (TDI rate):  " );
	scanf( "%lf", &TdiRate );
	printf( "TDI rate set to %lf seconds.\n", TdiRate );

	// Set the TDI row count
	ApogeeCamera->TDIRows = NumTdiRows;

	// Set the TDI rate
	ApogeeCamera->TDIRate = TdiRate;

	// Toggle the camera mode for TDI
	ApogeeCamera->CameraMode = Apn_CameraMode_TDI;

	// Toggle the sequence download variable
	ApogeeCamera->SequenceBulkDownload = true;
	
	// Set the image size
	long ImgXSize = ApogeeCamera->ImagingColumns;
	long ImgYSize = NumTdiRows;		// Since SequenceBulkDownload = true

	// Display the camera model
//	_bstr_t szCamModel( ApogeeCamera->CameraModel );
//	printf( "Camera Model:  %s\n", (char*)szCamModel );
	
	// Display the driver version
//	_bstr_t szDriverVer( ApogeeCamera->DriverVersion );
//	printf( "Driver Version:  %s\n", (char*)szDriverVer );

	// Create a buffer for one image, which will be reused for
	// each image in the sequence
	pBuffer			= new unsigned short[ ImgXSize * ImgYSize];
	ImgSizeBytes	= ImgXSize * ImgYSize * 2;

	// Initialize the output file
	sprintf( szFilename, "BulkTdiData.raw" );
	filePtr = fopen( szFilename, "wb" );
	if ( filePtr == NULL )
	{
		printf( "ERROR:  Failed to open output file.  No file will be written." );
	}

	// Do a sequence of 0.001s dark frames (bias frames)
	printf( "Starting camera exposure...\n" );
	ApogeeCamera->Expose( 0.1, true );

	// Check camera status to make sure image data is ready
	while ( ApogeeCamera->ImagingStatus != Apn_Status_ImageReady );

	// Get the image data from the camera
	printf( "Retrieving image data from camera...\n" );
	ApogeeCamera->GetImage( (long)pBuffer );

	if ( filePtr == NULL )
	{
		printf( "ERROR:  Failed to open file for writing output data." );
	}
	else
	{
		printf( "Writing line data to output file \"%s...\"\n", szFilename );

		fwrite( pBuffer, sizeof(unsigned short), (ImgSizeBytes/2), filePtr );
	}

	// Close the file
	if ( filePtr != NULL )
	{
		printf( "Closing output file.\n" );
		fclose( filePtr );
	}

	// Delete the memory buffer for storing the image
	delete [] pBuffer;

	// Release allocated objects.  
	
	ApogeeCamera	= NULL;		// Release CApnCamera COM object

}
