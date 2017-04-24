/*
Copyright (c) 2013 Khaled Mammou - Advanced Micro Devices, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <map>
#include <string>
#include <vector>

#include "SEA3D/SEA3D.h"
#include "SEA3D/ByteArray.h"

#include "o3dgc/o3dgcCommon.h"
#include "o3dgc/o3dgcVector.h"
#include "o3dgc/o3dgcSC3DMCEncodeParams.h"
#include "o3dgc/o3dgcIndexedFaceSet.h"
#include "o3dgc/o3dgcSC3DMCEncoder.h"
#include "o3dgc/o3dgcSC3DMCDecoder.h"
#include "o3dgc/o3dgcTimer.h"
#include "o3dgc/o3dgcDVEncodeParams.h"
#include "o3dgc/o3dgcDynamicVectorEncoder.h"
#include "o3dgc/o3dgcDynamicVectorDecoder.h"

#ifdef _WIN32
  #include <io.h>
  #include <fcntl.h>
#endif

using namespace o3dgc;
using namespace std;

void print(string str) 
{
	for (unsigned int i = 0; i < str.size(); i++) cout << str[i];
	cout << endl;
}

unsigned char * convertToGeometryGC(
	SEAGeometry * geo, 
	unsigned int & bufferLen,
	int qcoord,
    int qtexCoord,
    int qnormal,
	int qcolor,
    int qweights
	) 
{
	// init

	unsigned int nIntAttributes = 0;
	unsigned int nFloatAttributes = 0;

	SC3DMCEncodeParams params;
	params.SetStreamType(O3DGC_STREAM_TYPE_BINARY);
	IndexedFaceSet<unsigned int> ifs;
	
	// indexes

	ifs.SetNCoordIndex((unsigned int)geo->numIndexes);
	ifs.SetCoordIndex((unsigned int * const)geo->indexes);

	if (geo->numGroups > 1)
	{
		unsigned long *groups = (unsigned long*)malloc(sizeof(unsigned long) * geo->numIndexes);

		for (unsigned int i = 0, offset = 0; i < geo->numGroups; i++) 
		{
			unsigned int total = geo->counts[i];

			total += offset;

			while (offset < total) 
			{
				groups[offset++] = i;
			}
		}

		ifs.SetIndexBufferID( groups );
	}

	// position

	params.SetCoordQuantBits(qcoord);
    params.SetCoordPredMode(O3DGC_SC3DMC_PARALLELOGRAM_PREDICTION);
	ifs.SetNCoord(geo->numVertex);
	ifs.SetCoord((float * const)geo->vertex);

	// normal

	if (geo->normal != NULL) 
	{
		params.SetNormalQuantBits(qnormal);
		params.SetNormalPredMode(O3DGC_SC3DMC_SURF_NORMALS_PREDICTION);
		ifs.SetNNormal(geo->numVertex);
		ifs.SetNormal((float * const)geo->normal);
	}

	// uv

	if (geo->numUV > 0)
	{
		for (unsigned int i = 0; i < geo->numUV; i++) 
		{
			params.SetFloatAttributeQuantBits(nFloatAttributes, qtexCoord);
			params.SetFloatAttributePredMode(nFloatAttributes, O3DGC_SC3DMC_PARALLELOGRAM_PREDICTION);
			ifs.SetNFloatAttribute(nFloatAttributes, geo->numVertex);
			ifs.SetFloatAttributeDim(nFloatAttributes, 2);
			ifs.SetFloatAttributeType(nFloatAttributes, O3DGC_IFS_FLOAT_ATTRIBUTE_TYPE_TEXCOORD);
			ifs.SetFloatAttribute(nFloatAttributes, (float * const)geo->uv[i]);
			nFloatAttributes++;
		}
	}

	// joint / weight

	if (geo->jointPerVertex > 0)
	{
        ifs.SetNIntAttribute(nIntAttributes, geo->numVertex);
		ifs.SetIntAttributeDim(nIntAttributes, geo->jointPerVertex);
        ifs.SetIntAttributeType(nIntAttributes, O3DGC_IFS_INT_ATTRIBUTE_TYPE_JOINT_ID);
		ifs.SetIntAttribute(nIntAttributes, (long * const)geo->joint);
        nIntAttributes++;

		params.SetFloatAttributeQuantBits(nFloatAttributes, qweights);
		params.SetFloatAttributePredMode(nFloatAttributes, O3DGC_SC3DMC_DIFFERENTIAL_PREDICTION);
        ifs.SetNFloatAttribute(nFloatAttributes, geo->numVertex);
		ifs.SetFloatAttributeDim(nFloatAttributes, geo->jointPerVertex);
        ifs.SetFloatAttributeType(nFloatAttributes, O3DGC_IFS_FLOAT_ATTRIBUTE_TYPE_WEIGHT);
		ifs.SetFloatAttribute(nFloatAttributes, (float * const)geo->weight);
        nFloatAttributes++;
	}

	// compute Open3DGC geometry

	params.SetNumIntAttributes(nIntAttributes);
    ifs.SetNumIntAttributes(nIntAttributes);

	params.SetNumFloatAttributes(nFloatAttributes);
    ifs.SetNumFloatAttributes(nFloatAttributes);

    ifs.ComputeMinMax(O3DGC_SC3DMC_MAX_ALL_DIMS); // O3DGC_SC3DMC_DIAG_BB

	BinaryStream bstream((geo->numVertex * 3) * 8);

	SC3DMCEncoder<unsigned int> encoder;

    encoder.Encode(params, ifs, bstream);

	// create GeometryGC

	nIntAttributes = 0;
	nFloatAttributes = 0;

	unsigned char * s3dBuffer = bstream.GetBuffer();
	unsigned int s3dSize = bstream.GetSize();

	unsigned char * buffer = new unsigned char[s3dSize + 1024]; // 1024 is header buffer
	unsigned int bufferPos = 2; // first value is attribs

	int attribs = geo->isBig ? 1 : 0;

	// write groups

	if (geo->numGroups > 1) 
	{
		attribs |= 2;

		buffer[bufferPos++] = geo->numGroups;

		for (unsigned int i = 0; i < geo->numGroups; i++)
		{
			unsigned int numTris = geo->counts[i];

			buffer[bufferPos++] = numTris;
			buffer[bufferPos++] = numTris >> 8;

			if (geo->isBig)
			{
				buffer[bufferPos++] = numTris >> 16;
				buffer[bufferPos++] = numTris >> 24;
			}
		}
	}

	// write uvs

	if (geo->numUV > 0) 
	{
		attribs |= 4;

		buffer[bufferPos++] = geo->numUV;

		for (unsigned int i = 0; i < geo->numUV; i++)
		{
			buffer[bufferPos++] = nFloatAttributes++;
		}
	}

	// write joint/weight

	if (geo->jointPerVertex > 0)
	{
		attribs |= 32;

		buffer[bufferPos++] = nIntAttributes++;
		buffer[bufferPos++] =  nFloatAttributes++;
	}

	// write buffer size

	buffer[bufferPos++] = s3dSize;
	buffer[bufferPos++] = s3dSize >> 8;
	buffer[bufferPos++] = s3dSize >> 16;
	buffer[bufferPos++] = s3dSize >> 24;

	// write attribs ( flags )

	buffer[0] = attribs;
	buffer[1] = attribs >> 8;

	memcpy(buffer + bufferPos, s3dBuffer, s3dSize);

	bufferLen = s3dSize + bufferPos;

	return buffer;

}

int main(int argc, char * argv[])
{
	string input, output;

	double 
		qposition_quality = 1,
		qgradient_quality = 1;

	for(int i = 1; i < argc; ++i)
    {
        if ( !strcmp(argv[i], "-i"))
        {
            if (++i < argc)
            {
                input = argv[i];
            }
        }
		else if ( !strcmp(argv[i], "-o"))
        {
            if (++i < argc)
            {
                output = argv[i];
            }
        }
		else if ( !strcmp(argv[i], "-qp"))
        {
            if (++i < argc)
            {
                qposition_quality = atof(argv[i]);
            }
        }
		else if ( !strcmp(argv[i], "-qg"))
        {
            if (++i < argc)
            {
                qgradient_quality = atof(argv[i]);
            }
        }
	}

	int qcoord = (int)(12 * qposition_quality);
    int qtexCoord = (int)(15 * qgradient_quality);
    int qnormal = (int)(12 * qgradient_quality);
	int qcolor = (int)(12 * qgradient_quality);
    int qweights = (int)(10 * qgradient_quality);

	if (qposition_quality < 0.1) qposition_quality = 0.1;
	else if (qposition_quality > 2) qposition_quality = 2;

	if (qgradient_quality < 0.1) qgradient_quality = 0.1;
	else if (qgradient_quality > 2) qgradient_quality = 2;

	//input = "D:\\Sunag\\Github\\sea3d_sdk\\Source\\O3DGC\\Debug\\Object002.geo";
	//input = "D:\\Sunag\\Github\\sea3d_sdk\\Source\\O3DGC\\Debug\\temp-14.geo";
	//output = "D:\\Sunag\\Github\\sea3d_sdk\\Source\\O3DGC\\Debug\\Object002.s3D";

	if (input.empty() || output.empty())
	{
		cout << "Convert SEAGeometry to SEAGeometryGC example: SEA3DLossyCompress.exe -i sea3d_geometry.geo -o sea3d_o3dgc.s3D";
		return 1;
	}

	ByteArray istream;
	istream.fromFile( input.c_str() );

	SEAGeometry geo;
	geo.read( istream );

	unsigned int geoGCSize;
	unsigned char * geoGCBuffer = convertToGeometryGC(&geo, geoGCSize, qcoord, qtexCoord, qnormal, qcolor, qweights);

	ByteArray ostream;
	ostream.fromBuffer(geoGCBuffer, geoGCSize);
	ostream.saveFile( output.c_str() );

}