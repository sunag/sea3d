using System;
using System.Collections.Generic;
using System.Text;
using Poonya.Utils;

namespace Poonya.SEA3D.Objects.Techniques
{
    public class TextureTech : TechBase
    {
        public int texture;

        public TextureTech(int type)
            : base(type)
        {
        }

        override public ByteArray Write()
        {
            ByteArray data = new ByteArray();

            data.WriteInt32(texture);

            return data;
        }
    }
}
