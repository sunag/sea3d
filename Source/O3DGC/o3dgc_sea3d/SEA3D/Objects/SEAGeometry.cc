#include "SEAGeometry.h"

#define ARRAYSIZE(a) ((sizeof(a) / sizeof(*(a))) / static_cast<size_t>(!(sizeof(a) % sizeof(*(a)))))

void SEAGeometry::read(ByteArray & stream)
{
	SEAGeometryBase::read( stream );

	sea_uint32 i, j, k, len = numVertex * 3;

	// NORMAL
	if (attrib & 4)
	{
		normal = new sea_float[len];

		i = 0; 
		while (i < len)		
			normal[i++] = stream.readFloat();			
	}

	// TANGENT
	if (attrib & 8)
	{
		tangent = new sea_float[len];

		i = 0; 
		while (i < len)		
			tangent[i++] = stream.readFloat();
	}

	// UVS
	if (attrib & 32)
	{
		numUV = stream.readUByte();

		sea_uint32 uvLen = numVertex * 2;

		uv = new sea_float*[numUV];

		for (i = 0; i < numUV; i++)
		{
			// UV_VERTEX
			uv[i] = new sea_float[uvLen];	

			j = 0; 
			while(j < uvLen) 
				uv[i][j++] = stream.readFloat();
		}
	}
	else
	{
		numUV = 0;
	}

	// JOINT_INDEXES | WEIGHTS
	if (attrib & 64)
	{
		jointPerVertex = stream.readUByte();
				
		sea_uint32 jntLen = numVertex * jointPerVertex;
				
		joint = new sea_long[jntLen];
		weight = new sea_float[jntLen];
				
		i = 0;
		while (i < jntLen) 		
			joint[i++] = stream.readUShort();
				
		i = 0;
		while (i < jntLen) 		
			weight[i++] = stream.readFloat(); 
	}
	else
	{
		jointPerVertex = 0;
	}

	// VERTEX_COLOR
	if (attrib & 128)
	{
	}

	// VERTEX
	vertex = new sea_float[len];

	i = 0; 
	while(i < len) 
		vertex[i++] = stream.readFloat();

	numGroups = stream.readUByte();
	numIndexes = 0;

	sea_uint32** indexes = new sea_uint32*[numGroups];

	starts = new sea_uint32[numGroups];
	counts = new sea_uint32[numGroups];
	
	// INDEXES
	if (isBig)
	{
		for (i = 0; i < numGroups; i++)
		{
			sea_uint32 triLen = stream.readUInt();

			starts[ i ] = numIndexes;
			counts[ i ] = triLen;

			numIndexes += triLen;

			triLen *= 3;
				
			indexes[i] = new sea_uint32[triLen];

			j = 0; 
			while(j < triLen) 
				indexes[i][j++] = stream.readUInt();
		}
	}
	else
	{
		for (i = 0; i < numGroups; i++)
		{
			sea_uint32 triLen = stream.readUShort();

			starts[ i ] = numIndexes;
			counts[ i ] = triLen;

			numIndexes += triLen;

			triLen *= 3;

			indexes[i] = new sea_uint32[triLen];

			j = 0; 
			while(j < triLen) 
				indexes[i][j++] = stream.readUShort();
		}
	}

	this->indexes = new sea_uint32[numIndexes * 3];

	for (i = 0, k = 0; i < numGroups; i++)
	{
		unsigned int size = counts[i] * 3;

		for (j = 0; j < size; j++)
		{
			this->indexes[k++] = indexes[i][j];
		}
	}
}