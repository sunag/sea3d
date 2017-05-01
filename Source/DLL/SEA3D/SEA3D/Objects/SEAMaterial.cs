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
using Poonya.SEA3D.Objects.Techniques;
using System.Collections.Generic;

namespace Poonya.SEA3D.Objects
{
    public class SEAMaterial : SEAObject
    {
        public bool doubleSided;
        public bool repeat;

        public float alpha;	
		public int blendMode;

        public bool receiveShadows;
		public bool receiveLights;
        public bool receiveFog;

        public List<TechBase> techniques = new List<TechBase>();

        public SEAMaterial(string name)
            : base(name, "mat")
        {
        }

        override public ByteArray Write()
        {
            ByteArray header = new ByteArray();

            int attrib = 0x0000;
			
            if (doubleSided) attrib |= 1;

            if (!receiveLights) attrib |= 2;
            if (!receiveShadows) attrib |= 4;
            if (!receiveFog) attrib |= 8;

            if (!repeat) attrib |= 16;			
			
			if (alpha != 1)
            {
                attrib |= 32;
				header.WriteFloat(alpha);
            }

            if (blendMode != 0)
            {
                attrib |= 64;
                header.WriteByte(blendMode);
            }
            
            ByteArray data = new ByteArray();

            data.WriteUInt16(attrib);
            data.WriteBytes(header.ToArray());

            data.WriteByte(techniques.Count);

            foreach (TechBase tech in techniques)
            {
                ByteArray techData = tech.Write();

                data.WriteUInt16(tech.type);
                data.WriteUInt16((int)techData.Length);
                data.WriteBytes(techData.ToArray());
            }

            return data;
        }
    }
}
