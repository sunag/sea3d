using System;
using System.Collections.Generic;
using System.Text;
using Poonya.Utils;

namespace Poonya.SEA3D.Objects.Techniques
{
    public class PhysicalTech : TechBase
    {
        public int color;

        public float roughness;
        public float metalness;

        public PhysicalTech()
            : base(24)
        {
        }

        override public ByteArray Write()
        {
            ByteArray data = new ByteArray();

            data.WriteUInt24(color);

            data.WriteFloat(roughness);
            data.WriteFloat(metalness);

            return data;
        }
    }
}
