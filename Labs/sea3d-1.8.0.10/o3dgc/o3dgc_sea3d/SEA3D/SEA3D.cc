#include "Types.h"
#include "SEA3D.h"
#include "ByteArray.h"

SEA3D::SEA3D(void)
{
}

bool SEA3D::read(ByteArray stream)
{
	//
	//	Head
	//

	if (stream.readString(3) != "SEA")
	{
#ifdef SEA3D_ERROR_MESSAGE
		error += "Invalid SEA3D file\n"; 
#endif
		return true;	
	}

	sign = stream.readString(3);
	version = stream.readUInt24();

	protectionAlgorithm = stream.readUByte();
	compressionAlgorithm = stream.readUByte();

	count = stream.readUInt();
	
	//
	//	Body
	//

	for (position = 0; position < count; position++)
	{		
		unsigned int size = stream.readUInt();		
		unsigned int pos = stream.pos;

		char flag = stream.readByte();

		string type = stream.readType();
		string name;

		if (flag & 1)
		{
			name = stream.readTString();
		}

		bool compression = (flag & 2) != 0;
		bool streaming = (flag & 4) != 0;
		
		ByteArray* data = stream.readToStream( size - (stream.pos - pos) );

		if (compression && this->compressionAlgorithm > 0)
		{
			data->uncompress( this->compressionAlgorithm  );
		}

		SEAObject* sea;

		if (type == SEA3D_GEOMETRY) 
		{
			sea = new SEAGeometry();
			((SEAGeometry*)sea)->read( * data );
		}
		else 
		{
			sea = new SEAObject();	
		}

		sea->id = position;
		sea->name = name;
		sea->type = type;
		sea->data = * data;
		sea->compression = compression;
		sea->streaming = streaming;

		objects.push_back(sea);
	}
	
	//
	//	Finish
	//

	if (stream.readUInt24() != 0x5EA3D1)
	{
#ifdef SEA3D_ERROR_MESSAGE
		error += "SEA3D file is corrupted\n"; 
#endif
		return false;
	}

	return true;
}

SEAObject* SEA3D::getObject(sea_index index)
{
	return objects[index];
}

void SEA3D::dispose()
{
	unsigned int i = count;

	while(i-- > 0)
		delete objects[i];

	objects.clear();
}