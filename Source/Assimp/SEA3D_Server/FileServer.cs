using System;
using System.Collections.Generic;
using System.Text;
using Poonya.Server.Engine;

namespace Poonya.Server
{
    public class FileServer : Manager
    {
        public FileServer()
            : base(3280)
        {
            Caller.Add(SEA3DEncoder.Type, typeof(SEA3DEncoder));

            OnLogin += onLoginConsole;
            OnCaller += OnCallerConsole;
        }

        private void onLoginConsole(SessionID id)
        {
            Console.WriteLine("Login: " + id.Properties.Get("version"));
        }

        public void OnCallerConsole(Session session)
        {
            Console.WriteLine(session.ToString());
        }
    }
}
