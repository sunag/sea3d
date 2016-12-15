#pragma once

#include "Types.h"

#include <iostream>
#include <string>

using namespace std;

class DataTable
{
public:

	static const int NONE = 0;

	// 1D = 0 at 31
	static const int BOOLEAN = 1;
		
	static const int BYTE = 2;
	static const int UBYTE = 3;
		
	static const int SHORT = 4;
	static const int USHORT = 5;
		
	static const int INT24 = 6;
	static const int UINT24 = 7;
		
	static const int INT = 8;
	static const int UINT = 9;
		
	static const int FLOAT = 10;
	static const int DOUBLE = 11;
	static const int DECIMAL = 12;
		
	// 2D = 32 at 63
		
	// 3D = 64 at 95
	static const int VECTOR3D = 74;				
		
	// 4D = 96 at 127
	static const int VECTOR4D = 106;
		
	// Undefined Values = 128 at 256
	static const int STRING_TINY = 128;
	static const int STRING_SHORT = 129;
	static const int STRING_LONG = 130;
				
	static const int MAX_SIZE = 4;

	static const char* BLEND_MODE[];
	static const char* INTERPOLATION_TABLE[];
};