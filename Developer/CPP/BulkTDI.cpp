#include <stdio.h>

// Import the type library to create an easy to use wrapper class
#import "../../Driver/ReleaseMinDependency/Apogee.DLL" no_namespace


void main()
{
	ICamera2Ptr		AltaCamera;			// Camera interface
	ICamDiscoverPtr Discover;			// Discovery interface
	HRESULT 		hr;					// Return code 
	FILE*			filePtr;			// File pointer 
	unsigned short	NumTdiRows;			// Number of images to take
	double			TdiRate;			// TDI rate (in seconds)
	unsigned short* pBuffer;
	unsigned long	ImgSizeBytes;
	char			szFilename[80];		// File name


	printf( "Apogee Alta Bulk TDI Sample Applet\n" );

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

	// Query user for number of TDI rows
	printf( "Number of TDI Rows:  " );
	scanf( "%d", &NumTdiRows );
	printf( "Image to contain %d rows.\n", NumTdiRows );

	// Query user for TDI rate
	printf( "Interval between rows (TDI rate):  " );
	scanf( "%lf", &TdiRate );
	printf( "TDI rate set to %lf seconds.\n", TdiRate );

	// Set the TDI row count
	AltaCamera->TDIRows = NumTdiRows;

	// Set the TDI rate
	AltaCamera->TDIRate = TdiRate;

	// Toggle the camera mode for TDI
	AltaCamera->CameraMode = Apn_CameraMode_TDI;

	// Toggle the sequence download variable
	AltaCamera->SequenceBulkDownload = true;
	
	// Set the image size
	long ImgXSize = AltaCamera->ImagingColumns;
	long ImgYSize = NumTdiRows;		// Since SequenceBulkDownload = true

	// Display the camera model
	_bstr_t szCamModel( AltaCamera->CameraModel );
	printf( "Camera Model:  %s\n", (char*)szCamModel );
	
	// Display the driver version
	_bstr_t szDriverVer( AltaCamera->DriverVersion );
	printf( "Driver Version:  %s\n", (char*)szDriverVer );

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
	AltaCamera->Expose( 0.001, false );

	// Check camera status to make sure image data is ready
	while ( AltaCamera->ImagingStatus != Apn_Status_ImageReady );

	// Get the image data from the camera
	printf( "Retrieving image data from camera...\n" );
	AltaCamera->GetImage( (long)pBuffer );

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
	Discover	= NULL;		// Release ICamDiscover COM object
	AltaCamera	= NULL;		// Release ICamera2 COM object

	CoUninitialize();		// Close the COM library
}
