using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Text;
using System.Collections;
using System.IO;
using System.Collections.Generic;

namespace Poonya.Server.Engine
{
    public class Server
    {
        public delegate void ConnectionDelegate(SID sid);
        public delegate void ErrorDelegate(string ErroMessage, Socket soc, int ErroCode);

        public event ConnectionDelegate OnConnect;
        public event ErrorDelegate OnError;

        private Dictionary<Socket, SID> SIDs = new Dictionary<Socket, SID>();
        private ArrayList Clientes = ArrayList.Synchronized(new ArrayList());
        private Socket mainSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        private IPEndPoint ipLocal;
        private int mPorta = 0;

        public int Port
        {
            get
            {
                return mPorta;
            }
        }

        public int Count
        {
            get
            {
                return Clientes.Count;
            }
        }

        public Server(int port)
        {
            mPorta = port;
            ipLocal = new IPEndPoint(IPAddress.Any, mPorta);

            mainSocket.Bind(ipLocal);
            mainSocket.Listen(0);
            mainSocket.BeginAccept(new AsyncCallback(OnClientConnect), null);
        }

        private void OnClientConnect(IAsyncResult asyn)
        {
            try
            {
                Socket workSocket = mainSocket.EndAccept(asyn);
                try
                {
                    SID sid = new SID(workSocket);

                    sid.OnDisconnect += OnClientDisconnect;

                    if (OnConnect != null)
                        OnConnect(sid);

                    lock (this)
                    {
                        Clientes.Add(workSocket);
                        SIDs.Add(workSocket, sid);
                    }

                    mainSocket.BeginAccept(new AsyncCallback(OnClientConnect), null);
                }
                catch (SocketException se)
                {
                    if (OnError != null)
                        OnError(se.Message, workSocket, se.ErrorCode);
                }
            }
            catch (ObjectDisposedException se)
            {
                if (OnError != null)
                    OnError(se.Message, null, 0);
            }
        }

        private void OnClientDisconnect(SID session)
        {
            Socket socket = session.Socket;

            Clientes.Remove(socket);
            SIDs.Remove(socket);
        }
    }
}