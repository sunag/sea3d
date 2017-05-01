using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using Poonya.Utils;
using Poonya.SEA3D;

namespace Poonya.Server.Engine
{
    public class SessionID : Session
    {
        public static readonly string Type = "session";

        public Hashtable Properties = new Hashtable();       

        public SessionID(SID sid)
            : base(sid)
        {
            Properties.ReadJson(Data.ReadUTF32());
        }

        public bool Connected
        {
            get
            {
                return Properties.Get("version") != null;
            }
        }

        public override ByteArray Run()
        {
            ByteArray bytes = new ByteArray();
            bytes.WriteUTF32(Properties.ToJson());
            return bytes;
        }
    }
}
