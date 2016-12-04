#pragma once

#include "Types.h"
#include "ByteArray.h"

#include "Objects/SEAObject.h"
#include "Objects/SEAGeometry.h"

#include <iostream>
#include <string>
#include <vector>

using namespace std;

//#define SEA3D_ERROR_MESSAGE

class SEA3D
{
public:
	//
	//	Properties
	//

#ifdef SEA3D_ERROR_MESSAGE
	// ERROR STRING
	string error;
#endif

	// SIGNATURE 
	// S3D = Standard (focused to a Web File Format) 
	string sign; 	

	// VERSION
	// Max = 16777215 - VVSSBB  | V = Version | S = Subversion | B = Buildversion
	sea_version version;

	// 0 = None
	sea_uint32 protectionAlgorithm; 

	// 0 = None | 1 = Deflate | 2 = Lzma
	sea_uint32 compressionAlgorithm; 

	// Position and count of SEA objects
	sea_uint32 position;
	sea_uint32 count; 

	// objects ( all sea3d data )	
	vector<SEAObject*> objects;	

	//
	//	Methods
	//

	SEA3D(void);

	bool read( ByteArray stream );	
	
	SEAObject* getObject(sea_index index);	

	void dispose();

private:

	SEAObject* createObject(string type);

};

