#include "SEAGeometryBase.h"

void SEAGeometryBase::read(ByteArray & stream)
{
	attrib = stream.readUShort();

	isBig = (attrib & 1) != 0;

	numVertex = isBig ? stream.readUInt() : stream.readUShort();
}