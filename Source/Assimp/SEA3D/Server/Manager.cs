using System;
using System.Collections.Generic;
using System.Text;
using Poonya.Server.Engine;
using System.IO;

using PoonyaServer = Poonya.Server.Engine.Server;
using Poonya.Utils;
using System.Reflection;

namespace Poonya.Server
{   
    public class Manager
    {
        public delegate void CallerDelegate(Session session);
        public delegate void UserDelegate(SessionID session);

        public PoonyaServer Server;

        private String POLICY_REQUEST;
        private String POLICY_FILE;

        public Dictionary<string, Type> Caller;

        public event UserDelegate OnLogin;

        public event CallerDelegate OnCaller;        

        public Manager()
        {
            Init(1080);
        }

        public Manager(int port)
        {
            Init(port);
        }

        private void Init(int port)
        {
            // FOR ADOBE FLASH PLAYER
            POLICY_REQUEST = "<policy-file-request/>\u0000";
            POLICY_FILE = "<?xml version=\"1.0\"?>\n" +
            "<!DOCTYPE cross-domain-policy SYSTEM \"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd\">\n" +
            "<cross-domain-policy>\n" +
            "<allow-access-from domain=\"*\" to-ports=\"" + port.ToString() + "\"/>\n" +
            "</cross-domain-policy>\u0000";

            Caller = new Dictionary<string, Type>();

            Server = new PoonyaServer(port);
            Server.OnConnect += OnConnect;            
        }

        public void OnConnect(SID sid)
        {
            sid.OnComplete += OnSIDComplete;
            sid.OnDisconnect += OnSIDDisconnect;
        }

        public void OnSIDComplete(SID sid)
        {
            try
            {
                if (sid.Length == POLICY_REQUEST.Length && sid.ReadUTF() == POLICY_REQUEST)
                {
                    sid.Send(POLICY_FILE);
                }
                else
                {
                    Session caller = null;

                    string callerType = sid.Data.ReadUTF8();

                    if (sid.ID != null)
                    {
                        if (Caller.ContainsKey(callerType))
                        {
                            ConstructorInfo constructorInfo = Caller[callerType].GetConstructor(new Type[1] { typeof(SID) });
                            caller = (Session)constructorInfo.Invoke(new object[1] { sid });
                        }

                        if (OnCaller != null)
                            OnCaller(caller);
                    }
                    else if (callerType == SessionID.Type)
                    {
                        caller = sid.ID = new SessionID(sid);

                        if (OnLogin != null)
                            OnLogin(sid.ID);
                    }
                    else
                    {
                        Console.WriteLine("Caller not found \"" + callerType + "\"");
                    }

                    if (caller != null)
                    {
                        ByteArray data = new ByteArray();
                        data.WriteDataObject(caller.Run());

                        sid.Send(data);
                    }
                }
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
            }
        }

        public void OnSIDDisconnect(SID sid)
        {
            
        }
    }
}
