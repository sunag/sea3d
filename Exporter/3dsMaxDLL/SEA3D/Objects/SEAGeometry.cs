/*
*
* Copyright (c) Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

using Poonya.Utils;

namespace Poonya.SEA3D.Objects
{
    public class SEAGeometry : SEAGeometryBase
    {
        public float[] vertex;
        public uint[][] indexes;

        public float[][] uv;
        public float[] normal;
        public float[] tangent;
        public float[][] color;

        public uint[] joint;
        public float[] weight;

        public SEAGeometry(string name)
            : base(name, "geo")
        {            
        }

        override public void Read(ByteArray stream)
        {
            base.Read(stream);

            uint i, j, len = numVertex * 3;

            // NORMAL
            if ((attrib & 4) != 0)
            {
                normal = new float[len];

                i = 0;
                while (i < len)
                    normal[i++] = stream.ReadFloat();	
            }

            // TANGENT
            if ((attrib & 8) != 0)
            {
                tangent = new float[len];

                i = 0;
                while (i < len)
                    tangent[i++] = stream.ReadFloat();


                // UVS
                if ((attrib & 32) != 0)
                {
                    int uvCount = stream.ReadUByte();
                    uint uvLen = numVertex * 2;

                    uv = new float[uvCount][];

                    i = 0;
                    while (i < uvLen)
                    {
                        // UV_VERTEX
                        uv[i++] = new float[uvLen];

                        j = 0;
                        while (j < numVertex)
                            uv[i][j++] = stream.ReadFloat();
                    }
                }
            }

            // JOINT_INDEXES | WEIGHTS
            if ((attrib & 64) != 0)
            {
                jointPerVertex = (uint)stream.ReadUByte();

                uint jntLen = numVertex * jointPerVertex;

                joint = new uint[jntLen];
                weight = new float[jntLen];

                i = 0;
                while (i < jntLen)
                    joint[i++] = (uint)stream.ReadUInt16();

                i = 0;
                while (i < jntLen)
                    weight[i++] = stream.ReadFloat();
            }

            // VERTEX_COLOR
            if ((attrib & 128) != 0)
            {
                int colorLen = stream.ReadUByte();

                color = new float[colorLen][];

                for (i = 0; i < colorLen; i++)
                {
                    color[i] = new float[len];

                    j = 0;
                    while (j < len)
                        color[j++][j] = (float)stream.ReadUByte() / 255.0f;
                }
            }

            // VERTEX
            vertex = new float[len];

            i = 0;
            while (i < len)
                vertex[i++] = stream.ReadFloat();

            int idxCount = stream.ReadUByte();

            indexes = new uint[idxCount][];

            // INDEXES
            if (isBig)
            {
                for (i = 0; i < idxCount; i++)
                {
                    uint triLen = stream.ReadUInt32() * 3;

                    indexes[i] = new uint[triLen];

                    j = 0;
                    while (j < triLen)
                        indexes[i][j++] = stream.ReadUInt32();
                }
            }
            else
            {
                for (i = 0; i < idxCount; i++)
                {
                    uint triLen = (uint)stream.ReadUInt16() * 3;

                    indexes[i] = new uint[triLen];

                    j = 0;
                    while (j < triLen)
                        indexes[i][j++] = (uint)stream.ReadUInt16();
                }
            }
        }

        override public ByteArray Write()
        {
            ByteArray stream = new ByteArray();

            // update num of vertex
            numVertex = (uint)(vertex.Length / 3);

            int attrib = 0x0000;

            if (isBig) attrib |= 1;
            if (normal != null) attrib |= 4;
            if (tangent != null) attrib |= 8;
            if (uv != null) attrib |= 32;

            stream.WriteUInt16(attrib);

            if (isBig) stream.WriteUInt32(numVertex);
            else stream.WriteUInt16((int)numVertex);

            if (normal != null)
            {
                for (int i = 0; i < normal.Length; i++)
                {
                    stream.WriteFloat(normal[i]);
                }
            }

            if (tangent != null)
            {
                for (int i = 0; i < tangent.Length; i++)
                {
                    stream.WriteFloat(tangent[i]);
                }
            }

            if (uv != null)
            {
                stream.WriteByte(uv.Length);

                for (int i = 0; i < uv.Length; i++)
                {
                    for (int j = 0; j < uv[i].Length; j++)
                    {
                        stream.WriteFloat(uv[i][j]);
                    }
                }
            }

            for (int i = 0; i < vertex.Length; i++)
            {
                stream.WriteFloat(vertex[i]);
            }

            stream.WriteByte(indexes.Length);

            if (isBig)
            {
                for (int i = 0; i < indexes.Length; i++)
                {
                    uint[] idxs = indexes[i];

                    stream.WriteUInt32((uint)(idxs.Length / 3));

                    uint j = 0;
                    while (j < idxs.Length)
                    {
                        stream.WriteUInt32(idxs[j++]);
                    }
                }
            }
            else
            {
                for (int i = 0; i < indexes.Length; i++)
                {
                    uint[] idxs = indexes[i];

                    stream.WriteUInt16(idxs.Length / 3);

                    int j = 0;
                    while (j < idxs.Length)
                    {
                        stream.WriteUInt16((int)idxs[j++]);
                    }
                }
            }

            return stream;
        }
    }
}
