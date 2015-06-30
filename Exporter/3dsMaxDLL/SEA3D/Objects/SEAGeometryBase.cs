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
    public class SEAGeometryBase : SEAObject
    {
        public int attrib;

        public uint numVertex;
        public uint jointPerVertex;

        public bool isBig
        {
            get
            {
                return numVertex > 0xFFFF;
            }
        }

        public SEAGeometryBase(string name, string type) 
            : base(name, type)
        {
        }

        override public void Read(ByteArray stream)
        {
            attrib = stream.ReadUInt16();

            numVertex = (attrib & 1) != 0 ? stream.ReadUInt32() : (uint)stream.ReadUInt16();
        }

        override public ByteArray Write()
        {
            return new ByteArray();
        }
    }
}
