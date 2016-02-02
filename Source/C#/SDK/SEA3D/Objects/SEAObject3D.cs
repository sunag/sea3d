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
    public class SEAObject3D : SEAObject
    {
        public int parent;
        public List<uint> animations = new List<uint>();    

        public SEAObject3D(string name, string type) 
            : base(name, type)
        {
        }

        protected int Write3D(ByteArray header)
        {
            int attrib = 0x0000;

            if (parent != -1)
            {
                attrib |= 1;
                header.WriteUInt32((uint)parent);
            }

            return attrib;
        }

        protected void WriteTags(ByteArray data)
        {
            data.WriteByte(0);
        }

        override public ByteArray Write()
        {           
            return null;
        }
    }
}
