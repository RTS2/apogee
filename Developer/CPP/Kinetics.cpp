#include <stdio.h>

// Import the type library to create an easy to use wrapper class
#import "../../Driver/ReleaseMinDependency/Apogee.DLL" no_namespace


void main()
{
	ICamera2Ptr		AltaCamera;			// Camera interface
	HRESULT 		hr;					// Return code 
	FILE*			filePtr;			// File pointer 
	unsigned long	ImgSizeBytes;		// Byte count of final image
	unsigned short	NumSections;		// Number of sections in the image
	unsigned short*	pBuffer;			// Image data buffer
	long			ImgXSize, ImgYSize;	// Width and Height of the image


	printf( "Apogee Alta Kinetics Mode Sample Applet\n" );

	CoInitialize( NULL );			// Initialize COM library

	// Create the ICamera2 object
	hr = AltaCamera.CreateInstance( __uuidof( Camera2 ) );
	if ( SUCCEEDED(hr) )
	{
		printf( "Successfully created the ICamera2 object\n" );
	}
	else
	{
		printf( "Failed to create the ICamera2 object\n" );
		CoUninitialize();			// Close the COM library
		return;
	}

	// Initialize camera using the ICamDiscover properties
	hr = AltaCamera->Init( Apn_Interface_USB, 0, 0x0, 0x0 ); 

	if ( SUCCEEDED(hr) )
	{
		printf( "Connection to camera succeeded.\n" );
	}
	else
	{
		printf( "Failed to connect to camera" );
		AltaCamera	= NULL;		// Release ICamera2 COM object
		CoUninitialize();		// Close the COM library
		return;
	}

	// Query the camera for a full frame image
	ImgXSize = AltaCamera->ImagingColumns;
	ImgYSize = AltaCamera->ImagingRows;

	// Allocate memory and calculate a byte count
	pBuffer			= new unsigned short[ ImgXSize * ImgYSize ];
	ImgSizeBytes	= ImgXSize * ImgYSize * 2;

	// Display the camera model
	_bstr_t szCamModel( AltaCamera->CameraModel );
	printf( "Camera Model:  %s\n", (char*)szCamModel );
	
	// Display the driver version
	_bstr_t szDriverVer( AltaCamera->DriverVersion );
	printf( "Driver Version:  %s\n", (char*)szDriverVer );

	// Just to insure the camera had time plenty of time to 
	// complete initial flush cycles
	Sleep( 2000 );

	// Set the camera mode to Kinetics
	AltaCamera->CameraMode = Apn_CameraMode_Kinetics;

	// 4 sections
	NumSections = 4;

	// Set our section variables
	AltaCamera->KineticsSections		= NumSections;
	AltaCamera->KineticsSectionHeight	= ImgYSize / NumSections;
	
	// Set the section rate...using 0.2s arbitrarily
	AltaCamera->KineticsShiftInterval	= 0.2;

	// Begin the exposure process
	printf( "Starting imaging process...\n" );
	AltaCamera->Expose( 0.001, true );

	// Tell the user something informative...
	printf( "Kinetics imaging in progress...\n" );

	// Check camera status to make sure image data is ready
	while ( AltaCamera->ImagingStatus != Apn_Status_ImageReady );

	// Get the image data from the camera
	printf( "Retrieving image data from camera...\n" );
	AltaCamera->GetImage( (long)pBuffer );

	// Write the test image to an output file (overwrite if it already exists)
	filePtr = fopen( "KineticsData.raw", "wb" );

	if ( filePtr == NULL )
	{
		printf( "ERROR:  Failed to open file for writing output data." );
	}
	else
	{
		printf( "Wrote image data to output file \"KineticsData.raw...\"\n" );
		fwrite( pBuffer, sizeof(unsigned short), (ImgSizeBytes/2), filePtr );
		fclose( filePtr );
	}

	// Set the camera mode back to Normal
	AltaCamera->CameraMode = Apn_CameraMode_Normal;

	// Delete the memory buffer for storing the image
	delete [] pBuffer;

	// Release allocated objects.  
	AltaCamera	= NULL;		// Release ICamera2 COM object

	CoUninitialize();		// Close the COM library
}