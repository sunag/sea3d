using System;
using System.Collections.Generic;
using System.Text;
using Poonya.Utils;

namespace Poonya.SEA3D.Objects.Techniques
{
    public class PhongTech : TechBase
    {
        public int ambientColor;
        public int diffuseColor;
        public int specularColor;

        public float specular;
        public float gloss;

        public PhongTech()
            : base(0)
        {
        }

        override public ByteArray Write()
        {
            ByteArray data = new ByteArray();

            data.WriteUInt24(ambientColor);
            data.WriteUInt24(diffuseColor);
            data.WriteUInt24(specularColor);

            data.WriteFloat(specular);
            data.WriteFloat(gloss);

            return data;
        }
    }
}
