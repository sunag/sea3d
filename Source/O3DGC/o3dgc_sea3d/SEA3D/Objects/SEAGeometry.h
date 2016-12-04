#pragma once

#include "../Types.h"
#include "SEAGeometryBase.h"



class SEAGeometry :
	public SEAGeometryBase
{
public:

	//
	//	Properties
	//

	sea_uint32 numIndexes;
	sea_uint32 numGroups;
	sea_uint32 numUV;

	sea_uint32* starts;
	sea_uint32* counts;

	sea_float* vertex;
	sea_uint32* indexes;

	sea_float** uv;
	sea_float* normal;
	sea_float* tangent;
	sea_float** color;

	sea_long* joint;
	sea_float* weight;

	//
	//	Methods
	//

	void read( ByteArray & stream );

};

