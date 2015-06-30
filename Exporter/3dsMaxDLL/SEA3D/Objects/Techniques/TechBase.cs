using System;
using System.Collections.Generic;
using System.Text;
using Poonya.Utils;

namespace Poonya.SEA3D.Objects.Techniques
{
    public class TechBase
    {
        public int type;

        public TechBase(int type)
        {
            this.type = type;
        }

        virtual public ByteArray Write()
        {
            return new ByteArray();
        }
    }
}
