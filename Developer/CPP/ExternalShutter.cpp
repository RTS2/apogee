#include <stdio.h>

// Import the type library to create an easy to use wrapper class
#import "../../Driver/ReleaseMinDependency/Apogee.DLL" no_namespace


void main()
{
	ICamera2Ptr		AltaCamera;			// Camera interface
	ICamDiscoverPtr Discover;			// Discovery interface
	HRESULT 		hr;					// Return code 
	FILE*			filePtr;			// File pointer 


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
		CoUninitialize();		// Close the COM library
		return;
	}

	// Create the ICamDiscover object
	hr = Discover.CreateInstance( __uuidof( CamDiscover ) );
	if ( SUCCEEDED(hr) )
	{
		printf( "Successfully created the ICamDiscover object\n" );
	}
	else
	{
		printf( "Failed to create the ICamDiscover object\n" );
		AltaCamera = NULL;		// Release ICamera2 COM object
		CoUninitialize();		// Close the COM library
		return;
	}

	// Set the checkboxes to default to searching both USB and 
	// ethernet interfaces for Alta cameras
	Discover->DlgCheckEthernet	= true;
	Discover->DlgCheckUsb		= true;

	// Display the dialog box for finding an Alta camera
	Discover->ShowDialog( true );

	// If a camera was not selected, then release objects and exit
	if ( !Discover->ValidSelection )
	{
		printf( "No valid camera selection made\n" );
		Discover	= NULL;		// Release ICamDiscover COM object
		AltaCamera	= NULL;		// Release ICamera2 COM object
		CoUninitialize();		// Close the COM library
		return;
	}

	// Initialize camera using the ICamDiscover properties
	hr = AltaCamera->Init( Discover->SelectedInterface, 
				 		   Discover->SelectedCamIdOne,
						   Discover->SelectedCamIdTwo,
						   0x0 );

	if ( SUCCEEDED(hr) )
	{
		printf( "Connection to camera succeeded.\n" );
	}
	else
	{
		printf( "Failed to connect to camera" );
		Discover	= NULL;		// Release Discover COM object
		AltaCamera	= NULL;		// Release ICamera2 COM object
		CoUninitialize();		// Close the COM library
		return;
	}

	// Query the camera for a full frame image
	long ImgXSize = AltaCamera->ImagingColumns;
	long ImgYSize = AltaCamera->ImagingRows;

	// Allocate memory and calculate a byte count
	unsigned short *pBuffer			= new unsigned short[ ImgXSize * ImgYSize ];
	unsigned long	ImgSizeBytes	= ImgXSize * ImgYSize * 2;

	// Display the camera model
	_bstr_t szCamModel( AltaCamera->CameraModel );
	printf( "Camera Model:  %s\n", (char*)szCamModel );
	
	// Display the driver version
	_bstr_t szDriverVer( AltaCamera->DriverVersion );
	printf( "Driver Version:  %s\n", (char*)szDriverVer );

	// External operations
	AltaCamera->ExternalShutter		= true;
	AltaCamera->ExternalIoReadout	= false;
	AltaCamera->IoPortAssignment	= 0x08;

	// Do a light frame 
	printf( "Starting camera exposure 1...\n" );
	AltaCamera->Expose( 0.001, true );

	// Check camera status to make sure image data is ready
	while ( AltaCamera->ImagingStatus != Apn_Status_ImageReady );

	// Get the image data from the camera
	printf( "Retrieving image data from camera...\n" );
	AltaCamera->GetImage( (long)pBuffer );

	// Write the test image to an output file (overwrite if it already exists)
	filePtr = fopen( "ExternalShutterData1.raw", "wb" );

	if ( filePtr == NULL )
	{
		printf( "ERROR:  Failed to open file for writing output data." );
	}
	else
	{
		printf( "Wrote image data to output file \"ExternalShutterData1.raw...\"\n" );
		fwrite( pBuffer, sizeof(unsigned short), (ImgSizeBytes/2), filePtr );
		fclose( filePtr );
	}

	// Do another light frame
	printf( "Starting camera exposure 2...\n" );
	AltaCamera->Expose( 0.001, true );

	// Check camera status to make sure image data is ready
	while ( AltaCamera->ImagingStatus != Apn_Status_ImageReady );

	// Get the image data from the camera
	printf( "Retrieving image data from camera...\n" );
	AltaCamera->GetImage( (long)pBuffer );

	// Write the test image to an output file (overwrite if it already exists)
	filePtr = fopen( "ExternalShutterData2.raw", "wb" );

	if ( filePtr == NULL )
	{
		printf( "ERROR:  Failed to open file for writing output data." );
	}
	else
	{
		printf( "Wrote image data to output file \"ExternalShutterData2.raw...\"\n" );
		fwrite( pBuffer, sizeof(unsigned short), (ImgSizeBytes/2), filePtr );
		fclose( filePtr );
	}

	// Delete the memory buffer for storing the image
	delete [] pBuffer;

	// Release allocated objects.  
	Discover	= NULL;		// Release ICamDiscover COM object
	AltaCamera	= NULL;		// Release ICamera2 COM object

	CoUninitialize();		// Close the COM library
}