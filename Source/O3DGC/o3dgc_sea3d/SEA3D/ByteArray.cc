#include "ByteArray.h"
#include "Deflate/zlib.h"
#include "LZMA/lzmadecode.c"

#include <stdio.h>
#include <malloc.h>
#include <string>

#define _CRT_SECURE_NO_WARNINGS

#ifdef WIN32

#pragma warning(disable:4996)

#include <windows.h>

#else // UNIX

#include <unistd.h>

#endif

using namespace std;

struct uint24 {
    unsigned int data : 24;
};

ByteArray::ByteArray(void)
{
	pos = 0;
	buffersize = 0;
}

ByteArray::~ByteArray(void)
{
	//dispose();
}

unsigned int ByteArray::readUInt()
{
	unsigned int val = *((unsigned int *)(buffer + pos));

	pos += 4;

	return val;
}

unsigned int ByteArray::readUInt24()
{
	unsigned int val = *((unsigned int *)(buffer + pos));

	pos += 3;

	return val & 0xFFFFFF;
}


unsigned int ByteArray::readUInt24F()
{
	uint24 val = *((uint24 *)(buffer + pos));

	pos += 3;

	return val.data;
}

char ByteArray::readByte()
{	
	return *((char *)(buffer + pos++));
}

unsigned short ByteArray::readUShort()
{	
	unsigned short val = *((unsigned short *)(buffer + pos));

	pos += 2;

	return val;
}

unsigned char ByteArray::readUByte()
{	
	return *((unsigned char *)(buffer + pos++));
}

float ByteArray::readFloat()
{
	float f = *((float *)(buffer + pos));

	pos += 4;

	return f;
}

string ByteArray::readString( unsigned int size )
{
	char *output = new char[size];
	
	memcpy( output, buffer + pos, size );

	string str ( output, size );

	delete[] output;

	pos += size;

	return str;
}

string ByteArray::readTString()
{	
	return readString( (unsigned int)readByte() );
}

string ByteArray::readType()
{	
	string type = readString(4);
	int i = 3;

	while(i > 0 && type[i] == '\0') --i;

	if (i != 3)
		type.resize(i+1);

	return type;
}

void ByteArray::readBytes( unsigned char *data, unsigned int size )
{
	memcpy(data, buffer + pos, size);

	pos += size;
}

unsigned char* ByteArray::readBytes( unsigned int size )
{
	unsigned char *data = new unsigned char[size];

	readBytes(data, size);

	return data;
}

ByteArray* ByteArray::readToStream( unsigned int size )
{
	ByteArray *stream = new ByteArray();

	stream->buffer = readBytes( size );
	stream->buffersize = size;

	return stream;
}

//
//	REF: https://chromium.googlesource.com/chromiumos/third_party/coreboot/+/master/src/lib/lzma.c
//
bool ByteArray::ulzmaBuffer()
{
    unsigned char properties[LZMA_PROPERTIES_SIZE];
    UInt32 outSize;
    SizeT inProcessed;
    SizeT outProcessed;
    int res;
    CLzmaDecoderState state;
    SizeT mallocneeds;
#if !defined(__PRE_RAM__)
    /* in ramstage, this can go in BSS */
    static
#endif
    /* in pre-ram, it must go on the stack */
    unsigned char scratchpad[15980];
    unsigned char *cp;

    memcpy(properties, buffer, LZMA_PROPERTIES_SIZE);

    /* The outSize in LZMA stream is a 64bit integer stored in little-endian
        * (ref: lzma.cc@LZMACompress: put_64). To prevent accessing by
        * unaligned memory address and to load in correct endianess, read each
        * byte and re-costruct. */
    cp = buffer + LZMA_PROPERTIES_SIZE;
    outSize = cp[3] << 24 | cp[2] << 16 | cp[1] << 8 | cp[0];

    if (LzmaDecodeProperties(&state.Properties, properties, LZMA_PROPERTIES_SIZE) != LZMA_RESULT_OK) {
        fputs("lzma: Incorrect stream properties.",stderr);
        return true;
    }

    mallocneeds = (LzmaGetNumProbs(&state.Properties) * sizeof(CProb));
    if (mallocneeds > 15980) {
        fputs("lzma: Decoder scratchpad too small!",stderr);
        return true;
    }
	
	unsigned char *dst = new unsigned char[outSize];

    state.Probs = (CProb *)scratchpad;
    res = LzmaDecode(&state, buffer + LZMA_PROPERTIES_SIZE + 8, (SizeT)0xffffffff, &inProcessed,
            dst, outSize, &outProcessed);

    if (res != 0) {
        fputs("lzma: Decoding error = %d", stderr); // res
		delete [] dst;
        return true;
    }

	delete [] buffer;

	buffer = dst;
	buffersize = outSize;

    return false;
}

//
// REF: http://www.experts-exchange.com/Programming/System/Windows__Programming/A_3189-In-Memory-Compression-and-Decompression-Using-ZLIB.html
//
bool ByteArray::inflateBuffer()
{
	//
	//	GET UNCOMPRESS SIZE
	//

	int n16kBlocks = (buffersize + 16383) / 16384; // round up any fraction of a block
	int dtnSize = ( buffersize + 6 + (n16kBlocks*5) );

	//
	//	UNCOMPRESS
	//

	BYTE* dtnBuffer = new BYTE [dtnSize];  // alloc dest buffer

	z_stream zInfo = {0};
	zInfo.total_in = zInfo.avail_in = buffersize;
	zInfo.total_out = zInfo.avail_out = dtnSize;
	zInfo.next_in = (BYTE*)buffer;
	zInfo.next_out = dtnBuffer;
			
	int nErr, nRet= -1;
			
	nErr = inflateInit2( &zInfo, -MAX_WBITS ); // zlib function

	if ( nErr == Z_OK ) 
	{
		nErr = inflate( &zInfo, Z_FINISH ); // zlib function

		if ( nErr == Z_STREAM_END ) 
		{
			nRet = zInfo.total_out;
		}
	}

	deflateEnd( &zInfo ); // zlib function			
			
	if (nRet != -1)
	{
		delete [] buffer;

		buffer = dtnBuffer;
		buffersize = nRet;

		return true;
	}

	return false;
}

bool ByteArray::uncompress( sea_tcomp algorithm )
{
	switch(algorithm)
	{
		case DEFLATE:			
			return inflateBuffer();

		case LZMA:
			return ulzmaBuffer();
	}

	return true;
}

void ByteArray::fromBuffer( unsigned char * buffer, unsigned int buffersize )
{
	this->buffer = buffer;
	this->buffersize = buffersize;
}

bool ByteArray::saveFile( const char *filename ) 
{
	FILE * fout = fopen(filename, "wb");

    if (!fout) return false;
	
    fwrite(buffer, 1, buffersize, fout);

    fclose(fout);

	return true;
}

bool ByteArray::fromFile( const char *filename )
{
	FILE* file;
	fpos_t fileSize;

#ifdef _WIN32

	// open a multicode filename
	wchar_t mFileName[256];
	int	mSize;

	ZeroMemory( &mFileName, 256 );	

	mSize = MultiByteToWideChar( 932, 0, filename, strlen( filename ), mFileName, 256 );

	if ( mSize == 0 ) return false;

	if (_wfopen_s( &file, mFileName, L"rb" )) 
	{
		fputs ("File not found",stderr); 
		return false; 
	} 

#else

	if ( !(file = fopen( filename, "rb" )) ) 
	{		
		fputs ("File not found",stderr); 
		return false; 
	} 

#endif

	// read file size
	fseek( file, 0, SEEK_END );
	fgetpos( file, &fileSize );

	// memory allocation
	//buffer = (unsigned char *)malloc( (size_t)fileSize );
	buffer = new unsigned char[(unsigned int)fileSize];
	if (buffer == NULL) { fputs ("Memory allocation error",stderr); return false; }

	// read file
	fseek( file, 0, SEEK_SET );	
	if ( fread( buffer, 1, (size_t)fileSize, file ) != fileSize ) { fputs ("Reading error",stderr); return false; }

	fclose( file );

	buffersize = (unsigned int)fileSize;

	return true;
}

void ByteArray::dispose()
{
	if (buffer != NULL)
	{
		//free( buffer );
		delete [] buffer;		
	}
}