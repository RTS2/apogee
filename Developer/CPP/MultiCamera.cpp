#include <stdio.h>

// Import the type library to create an easy to use wrapper class
#import "../../Driver/ReleaseMinDependency/Apogee.DLL" no_namespace


void main()
{
	ICamera2Ptr		AltaCamera1;			// Camera interface
	ICamera2Ptr		AltaCamera2;
	FILE*			filePtr;				// File pointer 
	unsigned short	Width1, Width2;			// Widths of images
	unsigned short	Height1, Height2;		// Heights of images
	unsigned short	*pBuffer1, *pBuffer2;	// Image Buffers
	unsigned long	ImgSize1, ImgSize2;		// Image Sizes

	CoInitialize( NULL );			// Initialize COM library

	// Create the ICamera2 object
	AltaCamera1.CreateInstance( __uuidof( Camera2 ) );
	AltaCamera2.CreateInstance( __uuidof( Camera2 ) );
	
	// Initialize camera using the ICamDiscover properties
	AltaCamera1->Init( Apn_Interface_USB, 0, 0, 0x0 ); 
	AltaCamera2->Init( Apn_Interface_USB, 1, 0, 0x0 );

	// Allow the cameras a second to flush
	Sleep( 1000 );

	// Query the camera for a full frame image
	Width1	= (unsigned short)AltaCamera1->ImagingColumns;
	Height1 = (unsigned short)AltaCamera1->ImagingRows;

	Width2	= (unsigned short)AltaCamera2->ImagingColumns;
	Height2 = (unsigned short)AltaCamera2->ImagingRows;

	// Display the camera models
	_bstr_t szCamModel( AltaCamera1->CameraModel );
	printf( "Camera 1 Model:  %s\n", (char*)szCamModel );
	
	szCamModel = AltaCamera2->CameraModel;
	printf( "Camera 2 Model:  %s\n", (char*)szCamModel );

	// Display the width/height info
	printf( "Image1:  Width = %u    Height = %u\n", Width1, Height1 );
	printf( "Image2:  Width = %u    Height = %u\n", Width2, Height2 );

	// Allocate buffers
	pBuffer1 = new unsigned short[ Width1 * Height1 ];
	ImgSize1 = Width1 * Height1;

	pBuffer2 = new unsigned short[ Width2 * Height2 ];
	ImgSize2 = Width2 * Height2;

	// Do a 0.001s dark frame (bias)
	printf( "Starting camera exposure 1...\n" );
	AltaCamera1->Expose( 0.001, false );

	printf( "Starting camera exposure 2...\n" );
	AltaCamera2->Expose( 0.001, false );

	// Get the image data
	AltaCamera1->GetImage( (long)pBuffer1 );
	AltaCamera2->GetImage( (long)pBuffer2 );

	// Save the image data
	filePtr = fopen( "Image1.raw", "wb" );
	fwrite( pBuffer1, sizeof(unsigned short), (ImgSize1), filePtr );
	fclose( filePtr );

	filePtr = fopen( "Image2.raw", "wb" );
	fwrite( pBuffer2, sizeof(unsigned short), (ImgSize2), filePtr );
	fclose( filePtr );

	// Delete the memory buffer for storing the image
	delete [] pBuffer1;
	delete [] pBuffer2;

	// Release allocated objects.  
	AltaCamera1	= NULL;		// Release ICamera2 COM object
	AltaCamera2 = NULL;		

	CoUninitialize();		// Close the COM library
}