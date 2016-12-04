#pragma once

#include "SEAObject.h"

class SEAGeometryBase :
	public SEAObject
{
public:

	//
	//	Properties
	//

	sea_attrib attrib;

	sea_uint32 numVertex;
	sea_byte jointPerVertex;

	sea_bool isBig;

	//
	//	Methods
	//

	void read( ByteArray & stream );

};

