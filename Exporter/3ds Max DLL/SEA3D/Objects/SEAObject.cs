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

using System;
using Poonya.Utils;

namespace Poonya.SEA3D.Objects
{
    public class SEAObject
    {        
        public string Name;
        public string Type;

        public bool Compressed = true;
        public bool Streaming = true;

        public object tag;

        public SEAObject()
            : this("unknown", "obj")
        {
        }

        public SEAObject(string name, string type)
        {
            Name = name;
            Type = type;
        }

        virtual public void Read(ByteArray stream)
        {
        }

        virtual public ByteArray Write()
        {
            return new ByteArray();
        }

        public int Flag
        {
            get
            {
                int val = 0;

                if (Named) val += 1;
                if (Compressed) val += 2;
                if (Streaming) val += 4;

                return val;
            }
        }

        public string Filename
        {
            set
            {
                if (value == null || value.Length == 0)
                    throw new Exception("Invalid name.");

                int end = value.LastIndexOf('.');

                if (end > 0)
                {
                    Type = value.Substring(end + 1);
                    Name = value.Substring(0, end);
                }
                else
                {
                    Type = "obj";
                    Name = value;
                }
            }
            get
            {
                return Name + "." + Type;
            }
        }

        public bool Named
        {
            get
            {
                return Name.Length > 0;
            }
        }
    }
}
