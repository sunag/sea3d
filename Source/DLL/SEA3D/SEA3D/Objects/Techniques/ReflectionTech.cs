using System;
using System.Collections.Generic;
using System.Text;
using Poonya.Utils;

namespace Poonya.SEA3D.Objects.Techniques
{
    public class ReflectionTech : TextureTech
    {
        public float alpha;

        public ReflectionTech()
            : base(2)
        {
        }

        override public ByteArray Write()
        {
            ByteArray data = base.Write();

            data.WriteFloat(alpha);

            return data;
        }
    }
}
