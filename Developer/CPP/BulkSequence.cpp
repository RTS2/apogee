#include <stdio.h>

// Import the type library to create an easy to use wrapper class
#import "../../Driver/ReleaseMinDependency/Apogee.DLL" no_namespace


void main()
{
	ICamera2Ptr		AltaCamera;			// Camera interface
	ICamDiscoverPtr Discover;			// Discovery interface
	HRESULT 		hr;					// Return code 
	FILE*			filePtr;			// File pointer 
	unsigned short	NumImages;			// Number of images to take
	unsigned short	i;					// Counter
	unsigned short* pBuffer;
	unsigned short* pBufferIterator;
	unsigned long	ImgSizeBytes;
	char			szFilename[80];		// File name



	printf( "Apogee Alta Bulk Sequence Sample Applet\n" );

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

	// Query user for number of images in the sequence
	printf( "Number of images in the sequence:  " );
	scanf( "%d", &NumImages );
	printf( "Preparing sequence of %d images.\n", NumImages );

	// Set the image count
	AltaCamera->ImageCount = NumImages;

	// Query the camera for a full frame image
	long ImgXSize = AltaCamera->ImagingColumns;
	long ImgYSize = AltaCamera->ImagingRows;

	// Display the camera model
	_bstr_t szCamModel( AltaCamera->CameraModel );
	printf( "Camera Model:  %s\n", (char*)szCamModel );
	
	// Display the driver version
	_bstr_t szDriverVer( AltaCamera->DriverVersion );
	printf( "Driver Version:  %s\n", (char*)szDriverVer );

	// Toggle the sequence download variable
	AltaCamera->SequenceBulkDownload = true;

	// Allocate memory and calculate a byte count.  For bulk
	// sequences, the buffer should be sized to include all images
	pBuffer			= new unsigned short[ ImgXSize * ImgYSize * NumImages];
	ImgSizeBytes	= ImgXSize * ImgYSize * 2;

	// Do a 0.001s dark frame (bias)
	printf( "Starting camera exposure...\n" );
	AltaCamera->Expose( 0.001, false );

	// Check camera status to make sure image data is ready
	while ( AltaCamera->ImagingStatus != Apn_Status_ImageReady );

	// Get the image data from the camera
	printf( "Retrieving image data from camera...\n" );
	AltaCamera->GetImage( (long)pBuffer );

	pBufferIterator = pBuffer;

	// Write the test images to different output file (overwrite if it already exists)
	// In this process, we are dividing the single image buffer into the separate
	// images that comprise the bulk data set.
	for ( i=1; i<=NumImages; i++ )
	{
		sprintf( szFilename, "BulkImage%d.raw", i );

		filePtr = fopen( szFilename, "wb" );

		if ( filePtr == NULL )
		{
			printf( "ERROR:  Failed to open file for writing output data." );
		}
		else
		{
			printf( "Wrote image data to output file \"%s...\"\n", szFilename );

			fwrite( pBufferIterator, sizeof(unsigned short), (ImgSizeBytes/2), filePtr );
			fclose( filePtr );

			if ( i < NumImages )
			{
				// Only change the pointer for the first n-1 images
				pBufferIterator += (ImgSizeBytes/2);
			}
		}
	}

	printf( "Sequence Count:  %d\n", AltaCamera->SequenceCounter );

	// Delete the memory buffer for storing the image
	delete [] pBuffer;

	// Release allocated objects.  
	Discover	= NULL;		// Release ICamDiscover COM object
	AltaCamera	= NULL;		// Release ICamera2 COM object

	CoUninitialize();		// Close the COM library
}
