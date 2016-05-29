#pragma once

#include "Types.h"

#include <iostream>
#include <string>

using namespace std;

class DataTable
{
public:

	static const char NONE = 0;

	// 1D = 0 at 31
	static const char BOOLEAN = 1;
		
	static const char BYTE = 2;
	static const char UBYTE = 3;
		
	static const char SHORT = 4;
	static const char USHORT = 5;
		
	static const char INT24 = 6;
	static const char UINT24 = 7;
		
	static const char INT = 8;
	static const char UINT = 9;
		
	static const char FLOAT = 10;
	static const char DOUBLE = 11;
	static const char DECIMAL = 12;
		
	// 2D = 32 at 63
		
	// 3D = 64 at 95
	static const char VECTOR3D = 74;				
		
	// 4D = 96 at 127
	static const char VECTOR4D = 106;
		
	// Undefined Values = 128 at 256
	static const char STRING_TINY = 128;
	static const char STRING_SHORT = 129;
	static const char STRING_LONG = 130;
				
	static const char MAX_SIZE = 4;

	static const char* BLEND_MODE[];
	static const char* INTERPOLATION_TABLE[];
};