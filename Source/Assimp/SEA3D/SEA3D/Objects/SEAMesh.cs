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
using System.Collections.Generic;

namespace Poonya.SEA3D.Objects
{
    public class SEAMesh : SEAObject3D
    {
        public List<int> materials = new List<int>();
        public List<uint> modifiers = new List<uint>();        

        public int geometry;
        public float[] transform;

        public SEAMesh(string name)
            : base(name, "m3d")
        {
        }

        override public ByteArray Write()
        {
            ByteArray header = new ByteArray();

            int attrib = Write3D(header);

            if (materials.Count > 0)
            {
                attrib |= 256;

                header.WriteByte(materials.Count);

                if (materials.Count == 1)
                {
                    header.WriteUInt32((uint)materials[0]);
                }
                else
                {
                    for (int i = 0; i < materials.Count; i++)
                    {
                        header.WriteUInt32((uint)(materials[i] + 1));
                    }
                }
            }

            if (modifiers.Count > 0)
            {
                attrib |= 512;

                header.WriteByte(modifiers.Count);

                for (int i = 0; i < modifiers.Count; i++)
                {
                    header.WriteUInt32(modifiers[i]);
                }
            }

            ByteArray data = new ByteArray();

            data.WriteUInt16(attrib);
            data.WriteBytes(header.ToArray());

            data.WriteFloats(transform);
            data.WriteUInt32((uint)geometry);

            WriteTags(data);

            return data;
        }
    }
}
