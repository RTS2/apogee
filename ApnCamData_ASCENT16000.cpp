/////////////////////////////////////////////////////////////
//
// ApnCamData_ASCENT16000.cpp:  Implementation file for the CApnCamData_ASCENT16000 class.
//
// Copyright (c) 2003-2007 Apogee Instruments, Inc.
//
/////////////////////////////////////////////////////////////

#include "ApnCamData_ASCENT16000.h"

#include <stdlib.h>
#include <malloc.h>
#include <string.h>


/////////////////////////////////////////////////////////////
// Construction/Destruction
/////////////////////////////////////////////////////////////


CApnCamData_ASCENT16000::CApnCamData_ASCENT16000()
{
}


CApnCamData_ASCENT16000::~CApnCamData_ASCENT16000()
{
}


void CApnCamData_ASCENT16000::Initialize()
{
	strcpy( m_Sensor, "ASCENT16000" );
	strcpy( m_CameraModel, "16000" );
	m_CameraId = 320;
	m_InterlineCCD = true;
	m_SupportsSerialA = false;
	m_SupportsSerialB = false;
	m_SensorTypeCCD = true;
	m_TotalColumns = 4942;
	m_ImagingColumns = 4872;
	m_ClampColumns = 35;
	m_PreRoiSkipColumns = 0;
	m_PostRoiSkipColumns = 0;
	m_OverscanColumns = 35;
	m_TotalRows = 3324;
	m_ImagingRows = 3248;
	m_UnderscanRows = 56;
	m_OverscanRows = 20;
	m_VFlushBinning = 10;
	m_EnableSingleRowOffset = false;
	m_RowOffsetBinning = 1;
	m_HFlushDisable = false;
	m_ShutterCloseDelay = 0;
	m_PixelSizeX = 7.4;
	m_PixelSizeY = 7.4;
	m_Color = false;
	m_ReportedGainSixteenBit = 0.8;
	m_MinSuggestedExpTime = 0.1;
	m_CoolingSupported = true;
	m_RegulatedCoolingSupported = true;
	m_TempSetPoint = -20.0;
	m_TempRampRateOne = 1200;
	m_TempRampRateTwo = 4000;
	m_TempBackoffPoint = 2.0;
	m_PrimaryADType = ApnAdType_Ascent_Sixteen;
	m_AlternativeADType = ApnAdType_None;
	m_DefaultGainLeft = 0;
	m_DefaultOffsetLeft = 100;
	m_DefaultGainRight = 0;
	m_DefaultOffsetRight = 100;
	m_DefaultRVoltage = 1000;
	m_DefaultSpeed = 0x1;
	m_DefaultDataReduction = true;

	set_vpattern();

	set_hpattern_clamp_sixteen();
	set_hpattern_skip_sixteen();
	set_hpattern_roi_sixteen();

	set_hpattern_clamp_twelve();
	set_hpattern_skip_twelve();
	set_hpattern_roi_twelve();
}


void CApnCamData_ASCENT16000::set_vpattern()
{
	const unsigned short Mask = 0x6;
	const unsigned short NumElements = 71;
	unsigned short Pattern[NumElements] = 
	{
		0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 
		0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0004, 0x0004, 0x0004, 0x0004, 
		0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 0x0004, 
		0x0004, 0x0004, 0x0004, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 
		0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0202, 0x0202, 0x0202, 
		0x0202, 0x0202, 0x0202, 0x0202, 0x0202, 0x0202, 0x0202, 0x0002, 0x0002, 0x0002, 
		0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0002, 0x0003, 
		0x0002
	};

	m_VerticalPattern.Mask = Mask;
	m_VerticalPattern.NumElements = NumElements;
	m_VerticalPattern.PatternData = 
		(unsigned short *)malloc(NumElements * sizeof(unsigned short));

	for ( int i=0; i<NumElements; i++ )
	{
		m_VerticalPattern.PatternData[i] = Pattern[i];
	}
}


void CApnCamData_ASCENT16000::set_hpattern_skip_sixteen()
{
	const unsigned short Mask = 0x0;
	const unsigned short BinningLimit = 1;
	const unsigned short RefNumElements = 0;
	const unsigned short SigNumElements = 0;

	unsigned short *RefPatternData = NULL;

	unsigned short *SigPatternData = NULL;

	unsigned short BinNumElements[APN_MAX_HBINNING] = 
	{
		0x000E
	};

	unsigned short BinPatternData[1][256] = {
	{
		0x0004, 0x000A, 0x000A, 0x000A, 0x0008, 0x0008, 0x0008, 0x0004, 0x0004, 0x0004, 
		0x0004, 0x0004, 0x0005, 0x0004
	} };

	set_hpattern(	&m_SkipPatternSixteen,
					Mask,
					BinningLimit,
					RefNumElements,
					SigNumElements,
					BinNumElements,
					RefPatternData,
					SigPatternData,
					BinPatternData );
}


void CApnCamData_ASCENT16000::set_hpattern_clamp_sixteen()
{
	const unsigned short Mask = 0x0;
	const unsigned short BinningLimit = 1;
	const unsigned short RefNumElements = 0;
	const unsigned short SigNumElements = 0;

	unsigned short *RefPatternData = NULL;

	unsigned short *SigPatternData = NULL;

	unsigned short BinNumElements[APN_MAX_HBINNING] = 
	{
		0x000E
	};

	unsigned short BinPatternData[1][256] = {
	{
		0x0004, 0x000A, 0x000A, 0x000A, 0x0008, 0x0008, 0x0008, 0x0004, 0x0004, 0x0004, 
		0x0004, 0x0004, 0x0005, 0x0004
	} };

	set_hpattern(	&m_ClampPatternSixteen,
					Mask,
					BinningLimit,
					RefNumElements,
					SigNumElements,
					BinNumElements,
					RefPatternData,
					SigPatternData,
					BinPatternData );
}


void CApnCamData_ASCENT16000::set_hpattern_roi_sixteen()
{
	const unsigned short Mask = 0x0;
	const unsigned short BinningLimit = 1;
	const unsigned short RefNumElements = 0;
	const unsigned short SigNumElements = 0;

	unsigned short *RefPatternData = NULL;

	unsigned short *SigPatternData = NULL;

	unsigned short BinNumElements[APN_MAX_HBINNING] = 
	{
		0x0014
	};

	unsigned short BinPatternData[1][256] = {
	{
		0x0004, 0x012A, 0x012A, 0x012A, 0x0928, 0x0928, 0x0128, 0x0208, 0x0008, 0x0048, 
		0x4004, 0xE004, 0xE004, 0x4004, 0x0004, 0x0004, 0x0404, 0x0004, 0x8085, 0x8004, 
	} };

	set_hpattern(	&m_RoiPatternSixteen,
					Mask,
					BinningLimit,
					RefNumElements,
					SigNumElements,
					BinNumElements,
					RefPatternData,
					SigPatternData,
					BinPatternData );
}


void CApnCamData_ASCENT16000::set_hpattern_skip_twelve()
{
	const unsigned short Mask = 0x0;
	const unsigned short BinningLimit = 1;
	const unsigned short RefNumElements = 0;
	const unsigned short SigNumElements = 0;

	unsigned short *RefPatternData = NULL;

	unsigned short *SigPatternData = NULL;

	unsigned short BinNumElements[APN_MAX_HBINNING] = 
	{
		0x000E
	};

	unsigned short BinPatternData[1][256] = {
	{
		0x0004, 0x000A, 0x000A, 0x000A, 0x0008, 0x0008, 0x0008, 0x0004, 0x0004, 0x0004, 
		0x0004, 0x0004, 0x0005, 0x0004
	} };

	set_hpattern(	&m_SkipPatternTwelve,
					Mask,
					BinningLimit,
					RefNumElements,
					SigNumElements,
					BinNumElements,
					RefPatternData,
					SigPatternData,
					BinPatternData );
}


void CApnCamData_ASCENT16000::set_hpattern_clamp_twelve()
{
	const unsigned short Mask = 0x0;
	const unsigned short BinningLimit = 1;
	const unsigned short RefNumElements = 0;
	const unsigned short SigNumElements = 0;

	unsigned short *RefPatternData = NULL;

	unsigned short *SigPatternData = NULL;

	unsigned short BinNumElements[APN_MAX_HBINNING] = 
	{
		0x000E
	};

	unsigned short BinPatternData[1][256] = {
	{
		0x0004, 0x000A, 0x000A, 0x000A, 0x0008, 0x0008, 0x0008, 0x0004, 0x0004, 0x0004, 
		0x0004, 0x0004, 0x0005, 0x0004
	} };

	set_hpattern(	&m_ClampPatternTwelve,
					Mask,
					BinningLimit,
					RefNumElements,
					SigNumElements,
					BinNumElements,
					RefPatternData,
					SigPatternData,
					BinPatternData );
}


void CApnCamData_ASCENT16000::set_hpattern_roi_twelve()
{
	const unsigned short Mask = 0x2;
	const unsigned short BinningLimit = 1;
	const unsigned short RefNumElements = 0;
	const unsigned short SigNumElements = 0;

	unsigned short *RefPatternData = NULL;

	unsigned short *SigPatternData = NULL;

	unsigned short BinNumElements[APN_MAX_HBINNING] = 
	{
		0x0014
	};

	unsigned short BinPatternData[1][256] = {
	{
		0x0004, 0x012A, 0x012A, 0x012A, 0x0928, 0x0928, 0x0128, 0x0208, 0x0008, 0x0048, 
		0x4004, 0xE004, 0xE004, 0x4004, 0x0004, 0x0004, 0x0404, 0x0004, 0x8085, 0x8004, 
	} };

	set_hpattern(	&m_RoiPatternTwelve,
					Mask,
					BinningLimit,
					RefNumElements,
					SigNumElements,
					BinNumElements,
					RefPatternData,
					SigPatternData,
					BinPatternData );
}


void CApnCamData_ASCENT16000::set_hpattern(	APN_HPATTERN_FILE	*Pattern,
											unsigned short	Mask,
											unsigned short	BinningLimit,
											unsigned short	RefNumElements,
											unsigned short	SigNumElements,
											unsigned short	BinNumElements[],
											unsigned short	RefPatternData[],
											unsigned short	SigPatternData[],
											unsigned short	BinPatternData[][APN_MAX_PATTERN_ENTRIES] )
{
	int i, j;

	Pattern->Mask = Mask;
	Pattern->BinningLimit = BinningLimit;
	Pattern->RefNumElements = RefNumElements;
	Pattern->SigNumElements = SigNumElements;

	if ( RefNumElements > 0 )
	{
		Pattern->RefPatternData = 
			(unsigned short *)malloc(RefNumElements * sizeof(unsigned short));

		for ( i=0; i<RefNumElements; i++ )
		{
			Pattern->RefPatternData[i] = RefPatternData[i];
		}
	}

	if ( SigNumElements > 0 )
	{
		Pattern->SigPatternData = 
			(unsigned short *)malloc(SigNumElements * sizeof(unsigned short));

		for ( i=0; i<SigNumElements; i++ )
		{
			Pattern->SigPatternData[i] = SigPatternData[i];
		}
	}

	if ( BinningLimit > 0 )
	{
		for ( i=0; i<BinningLimit; i++ )
		{
			Pattern->BinNumElements[i] = BinNumElements[i];

			Pattern->BinPatternData[i] = 
				(unsigned short *)malloc(BinNumElements[i] * sizeof(unsigned short));

			for ( j=0; j<BinNumElements[i]; j++ )
			{
				Pattern->BinPatternData[i][j] = BinPatternData[i][j];
			}
		}
	}
}
