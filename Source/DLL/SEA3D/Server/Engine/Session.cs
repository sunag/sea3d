using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using Poonya.Utils;

namespace Poonya.Server.Engine
{
    public class Session
    {
        public ByteArray Data;
        public SID SID;

        public Session(SID sid)
        {
            SID = sid;
            Data = SID.Data;
        }

        public virtual ByteArray Run()
        {
            ByteArray bytes = new ByteArray();
            return bytes;
        }
    }
}
