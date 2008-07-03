#include <stdio.h>

// Import the type library to create an easy to use wrapper class
#import "../../Driver/ReleaseMinDependency/Apogee.DLL" no_namespace


void main()
{
	ICamera2Ptr		AltaCamera;			// Camera interface
	HRESULT 		hr;					// Return code 
	FILE*			filePtr;			// File pointer 
	unsigned long	ImgSizeBytes;		// Byte count of final image
	unsigned short	NumImages;			// Number of images in sequence
	unsigned short	i;					// Counter
	unsigned short*	pBuffer;			// Image data buffer
	long			ImgXSize, ImgYSize;	// Width and Height of the image
	char			szFilename[80];		// File name


	printf( "Apogee Alta External Trigger Sample Applet (Single and Sequenced)\n" );

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

	Sleep( 2000 );

	///////////////////////////////////////////////////////////////////
	// Single Hardware Trigger Example
	///////////////////////////////////////////////////////////////////

	// First we'll do a single triggered exposure.  This requires the 
	// "TriggerNormalGroup" property to be enabled
	AltaCamera->TriggerNormalGroup = true;

	// We will make our exposure a 0.1s light frame.  Even though this
	// is a triggered exposure, we still need the Expose() method to be
	// called to set up our exposure
	printf( "Starting a single triggered exposure of 0.1s...\n" );
	AltaCamera->Expose( 0.1, true );

	// Tell the user something informative...
	printf( "Waiting on trigger...\n" );

	// Check camera status to make sure image data is ready
	while ( AltaCamera->ImagingStatus != Apn_Status_ImageReady );

	// Get the image data from the camera
	printf( "Retrieving image data from camera...\n" );
	AltaCamera->GetImage( (long)pBuffer );

	// Write the test image to an output file (overwrite if it already exists)
	filePtr = fopen( "ExtTriggerData.raw", "wb" );

	if ( filePtr == NULL )
	{
		printf( "ERROR:  Failed to open file for writing output data." );
	}
	else
	{
		printf( "Wrote image data to output file \"ExtTriggerData.raw...\"\n" );
		fwrite( pBuffer, sizeof(unsigned short), (ImgSizeBytes/2), filePtr );
		fclose( filePtr );
	}

	// We're going to set this to "true" again in the next example, but 
	// for good form, we'll return our state to non-triggered images
	AltaCamera->TriggerNormalGroup = false;

	///////////////////////////////////////////////////////////////////
	// Sequenced (Internal) Hardware Trigger Example
	///////////////////////////////////////////////////////////////////

	// NOTE: The following example uses the camera engine's internal
	// capability to do sequences of images.  An application could 
	// also easily do a loop of single triggered images in order to 
	// achieve the same result, but driven by software/the application.

	// Do a sequence of triggered exposures.  This requires both the 
	// "TriggerNormalGroup" and "TriggerNormalEach" properties to be 
	// enabled.  TriggerNormalGroup will enable a trigger for the first
	// image.  TriggerNormalEach will enable a trigger for each 
	// subsequent image in the sequence.
	AltaCamera->TriggerNormalGroup = true;
	AltaCamera->TriggerNormalEach  = true;

	// Toggle the sequence download variable
	AltaCamera->SequenceBulkDownload = false;
	
	// Query user for number of images in the sequence
	printf( "Number of images in the sequence:  " );
	scanf( "%d", &NumImages );

	// Set the image count
	AltaCamera->ImageCount = NumImages;

	// For visual clarification, enable an LED light to see when the camera is
	// waiting on a trigger to arrive.  Enable the other LED to see when the 
	// camera is flushing.
	AltaCamera->LedMode = Apn_LedMode_EnableAll;
	AltaCamera->LedA	= Apn_LedState_ExtTriggerWaiting;
	AltaCamera->LedB	= Apn_LedState_Flushing;

	// As with single exposures, we must start the trigger process with the
	// Expose method.  We only need to call Expose once to kick off the entire
	// sequence process.
	printf( "Starting a sequence of triggered exposures of 0.1s...\n" );
	AltaCamera->Expose( 0.1, true );

	for ( i=1; i<=NumImages; i++ )
	{
		printf( "Waiting on trigger for image #%d...\n", i );

		// For sequences of images, the correct usage is to use the 
		// SequenceCounter property in order to correctly determine when 
		// an image is ready for download.
		while ( AltaCamera->SequenceCounter != i );

		// Get the image data from the camera
		printf( "Retrieving image data from camera (Image #%d)...\n", AltaCamera->SequenceCounter );
		AltaCamera->GetImage( (long)pBuffer );
		
		sprintf( szFilename, "ExtTriggerData%d.raw", i );

		filePtr = fopen( szFilename, "wb" );

		if ( filePtr == NULL )
		{
			printf( "ERROR:  Failed to open file for writing output data." );
		}
		else
		{
			printf( "Wrote image data to output file \"%s...\"\n", szFilename );

			fwrite( pBuffer, sizeof(unsigned short), (ImgSizeBytes/2), filePtr );
			fclose( filePtr );
		}
	}

	// Return our state to non-triggered images
	AltaCamera->TriggerNormalGroup = false;
	AltaCamera->TriggerNormalEach  = false;

	// Reset our image count to 1
	AltaCamera->ImageCount = 1;

	// Delete the memory buffer for storing the image
	delete [] pBuffer;

	// Release allocated objects.  
	AltaCamera	= NULL;		// Release ICamera2 COM object

	CoUninitialize();		// Close the COM library
}