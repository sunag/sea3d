using System;
using System.Collections.Generic;
using System.Text;
using Poonya.Utils;

namespace Poonya.SEA3D.Objects.Skeleton
{
    public class JointData
    {
        public string name;
        public int parentIndex;
        public float[] inverseBindMatrix;

        public void Write(ByteArray data)
        {
            data.WriteUTF8(name);
            data.WriteUInt16(parentIndex + 1);
            data.WriteFloats(inverseBindMatrix);
        }
    }
}
