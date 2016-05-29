#pragma once

#include "Types.h"

#include <iostream>
#include <string>

using namespace std;

//
//	Little-Endian
//

class ByteArray
{
public:
	static const char NONE = 0;
	static const char DEFLATE = 1;
	static const char LZMA = 2;

	//
	//	Properties
	//

	// DATA
	unsigned int pos;
	unsigned int buffersize;
	unsigned char* buffer;

	//
	//	Methods
	//

	ByteArray(void);	
	~ByteArray(void);
	
	char readByte();
	unsigned char readUByte();
	unsigned int readUInt();
	unsigned short readUShort();
	unsigned int readUInt24();
	unsigned int readUInt24F();
	float readFloat();
	string readString( unsigned int size );
	// Tiny String = 8 bit string length
	string readTString();
	void readBytes( unsigned char* data, unsigned int size );
	unsigned char* readBytes( unsigned int size );
	ByteArray* readToStream( unsigned int size );
	string readType();
	
	bool compress( sea_tcomp algorithm );
	bool uncompress( sea_tcomp algorithm );

	bool saveFile( const char *filename );

	void fromBuffer( unsigned char * buffer, unsigned int buffersize );
	bool fromFile( const char *filename );

	void dispose();

private:

	bool ulzmaBuffer();
	bool inflateBuffer();

};