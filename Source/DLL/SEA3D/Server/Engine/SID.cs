using System;
using System.Collections.Generic;
using System.Text;
using System.Net.Sockets;
using System.Net;
using Poonya.Utils;
using System.IO;

namespace Poonya.Server.Engine
{
    public class SID
    {
        public SessionID ID;

        private Socket mSocket;
        public Socket Socket
        {
            get
            {
                return mSocket;
            }
        }

        private int iRx;
        private int mTotal;
        private int mPosition;
        private ByteArray mData;
        private byte[] mReadBytes;
        private byte[] mWriteBytes;

        private AsyncCallback WorkerCallBack;

        public event Server.ConnectionDelegate OnDisconnect;
        public event Server.ConnectionDelegate OnRead;
        public event Server.ConnectionDelegate OnComplete;
        public event Server.ConnectionDelegate OnWrite;
        public event Server.ErrorDelegate OnError;

        #region Classes
        private class SocketPacket
        {
            public SocketPacket(Socket socket)
            {
                m_currentSocket = socket;
            }
            public Socket m_currentSocket;
            public byte[] dataBuffer = new byte[1024 * 1024];//1024 * 
        }
        #endregion

        public SID(Socket socket)
        {
            mSocket = socket;
            WaitForData(mSocket);
        }

        private void WaitForData(Socket soc)
        {
            try
            {
                if (WorkerCallBack == null)
                    WorkerCallBack = new AsyncCallback(OnDataReceived);
                SocketPacket theSocPkt = new SocketPacket(soc);
                soc.BeginReceive(theSocPkt.dataBuffer, 0,
                    theSocPkt.dataBuffer.Length,
                    SocketFlags.None,
                    WorkerCallBack,
                    theSocPkt);
            }
            catch (SocketException se)
            {
                if (OnError != null)
                    OnError(se.Message, soc, se.ErrorCode);
            }
        }

        private void OnDataReceived(IAsyncResult asyn)
        {
            SocketPacket socketData = (SocketPacket)asyn.AsyncState;
            
            try
            {
                iRx = mSocket.EndReceive(asyn);

                if (iRx < 1)
                {
                    if (Close())
                        socketData.m_currentSocket = null;
                }
                else
                {
                    mReadBytes = socketData.dataBuffer;
                    
                    if (mData == null)
                    {
                        mData = new ByteArray();
                        mTotal = iRx + socketData.m_currentSocket.Available;
                    }

                    mPosition = (int)mData.Position;
                    mData.Position = mData.Length;

                    mData.WriteBytes(mReadBytes, 0, iRx);
                    mData.Position = (uint)mPosition;

                    if (OnRead != null)                    
                        OnRead(this);

                    if (socketData.m_currentSocket.Available == 0)
                    {
                        if (OnComplete != null)
                            OnComplete(this);

                        mData = null;
                    }

                    WaitForData(mSocket);
                }
            }
            catch (InvalidOperationException se)
            {
                if (socketData.m_currentSocket.Connected)
                    socketData.m_currentSocket.Close();
                if (!socketData.m_currentSocket.Connected)
                {
                    if (OnDisconnect != null)
                        OnDisconnect(this);
                    socketData.m_currentSocket = null;
                }
                if (OnError != null)
                    OnError(se.Message, null, 0);
            }
            catch (SocketException se)
            {
                if (OnError != null)
                    OnError(se.Message, socketData.m_currentSocket, se.ErrorCode);
                if (!socketData.m_currentSocket.Connected)
                {
                    if (OnDisconnect != null)
                        OnDisconnect(this);
                    socketData.m_currentSocket = null;
                }
            }
        }

        public string ReadUTF()
        {
            char[] chars = new char[iRx];
            Decoder d = Encoding.UTF8.GetDecoder();
            d.GetChars(mReadBytes, 0, iRx, chars, 0);
            return new String(chars);
        }

        public byte[] ReadBytes
        {
            get
            {
                return mReadBytes;
            }
        }

        public ByteArray Data
        {
            get
            {
                return mData;
            }
        }

        public int Length
        {
            get
            {
                return mTotal;
            }
        }

        public int Position
        {
            get
            {
                return (int)mData.Length;
            }
        }

        public bool Send(ByteArray bytes)
        {
            return Send(bytes.ToArray());
        }

        public bool Send(byte[] data)
        {
            try
            {
                mWriteBytes = data;
                int NumBytes = mSocket.Send(mWriteBytes);
                if (NumBytes == mWriteBytes.Length)
                {
                    if (OnWrite != null)
                        OnWrite(this);
                    return true;
                }
                else
                    return false;
            }
            catch (ArgumentException se)
            {
                if (OnError != null)
                    OnError(se.Message, null, 0);
                return false;
            }
            catch (ObjectDisposedException se)
            {
                if (OnError != null)
                    OnError(se.Message, null, 0);
                return false;
            }
            catch (SocketException se)
            {
                if (OnError != null)
                    OnError(se.Message, null, 0);
                return false;
            }
        }

        public bool Send(string value)
        {
            return Send(System.Text.Encoding.UTF8.GetBytes(value));
        }

        public bool Send(bool value)
        {
            return Send(BitConverter.GetBytes(value));
        }

        public string RemoteAddress(int SocketIndex)
        {
            try
            {
                string temp = mSocket.RemoteEndPoint.ToString();
                return temp.Substring(0, temp.IndexOf(":"));
            }
            catch (ArgumentException se)
            {
                if (OnError != null)
                    OnError(se.Message, null, 0);
                return "";
            }
            catch (SocketException se)
            {
                if (OnError != null)
                    OnError(se.Message, null, 0);
                return "";
            }
        }

        public string RemoteHost()
        {
            try
            {
                string temp = mSocket.RemoteEndPoint.ToString();
                temp = temp.Substring(0, temp.IndexOf(":"));
                IPHostEntry retorno = Dns.GetHostEntry(temp);
                return retorno.HostName;
            }
            catch (ArgumentException se)
            {
                if (OnError != null)
                    OnError(se.Message, null, 0);
                return "";
            }
            catch (SocketException se)
            {
                if (OnError != null)
                    OnError(se.Message, null, 0);
                return "";
            }
        }

        public bool Connected
        {
            get
            {
                return mSocket.Connected;
            }
        }

        public bool Close()
        {
            mSocket.Close();

            if (!mSocket.Connected)
            {
                if (OnDisconnect != null)
                    OnDisconnect(this);

                OnRead = null;
                OnWrite = null;
                OnError = null;
                OnDisconnect = null;

                return true;
            }

            return false;
        }
    }
}
