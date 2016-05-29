#pragma once

#include "../Types.h"
#include "../ByteArray.h"

#include <iostream>

using namespace std;

class SEAObject
{
public:	
	//
	//	Properties
	//

	unsigned int id;

	string name;
	string type;

	ByteArray data;

	bool compression;
	bool streaming;

	//
	//	Methods
	//

	void read( ByteArray & stream );
};
