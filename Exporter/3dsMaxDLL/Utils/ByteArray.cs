/*
*
* Copyright (c) Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

using System;
using System.Text;
using System.IO;

namespace Poonya.Utils
{
    public class ByteArray
    {
        private MemoryStream _memoryStream;
        private uint _crc32 = 0;

        public ByteArray()
        {
            _memoryStream = new MemoryStream();
        }

        public ByteArray(MemoryStream memoryStream)
        {
            _memoryStream = memoryStream;
        }

        public ByteArray(byte[] bytes)
            : this(new MemoryStream(bytes))
        {
        }            

        public int ReadUByte()
        {
            return _memoryStream.ReadByte();
        }

        public int ReadUInt16()
        {
            return BitConverter.ToUInt16(ReadBytes(2), 0);
        }

        public int ReadUInt24()
        {
            byte[] bytes = ReadBytes(3);
            return ((bytes[2] & 0xff) << 16) | ((bytes[1] & 0xff) << 8) | (bytes[0] & 0xff);
        }

        public uint ReadUInt32()
        {
            return BitConverter.ToUInt32(ReadBytes(4), 0);
        }

        public string ReadUTF8()
        {
            return ReadUTFBytes((uint)ReadUByte());
        }

        public string ReadUTF16()
        {
            return ReadUTFBytes((uint)ReadUInt16());
        }

        public string ReadUTF32()
        {
            return ReadUTFBytes((uint)ReadUInt32());
        }

        public float ReadFloat()
        {
            return BitConverter.ToSingle(ReadBytes(4), 0);
        }

        public double ReadDouble()
        {
            return BitConverter.ToDouble(ReadBytes(8), 0);
        }

        public void WriteUInt16(int value)
        {
            WriteBytes(BitConverter.GetBytes((ushort)value));
        }

        public string ReadUTFBytes(uint length)
        {
            if (length == 0)
                return string.Empty;
            UTF8Encoding utf8 = new UTF8Encoding(false, true);
            byte[] encodedBytes = ReadBytes((int)length);
            string decodedString = utf8.GetString(encodedBytes, 0, encodedBytes.Length);
            return decodedString;
        }

        public byte[] ReadBytes(int length)
        {
            byte[] buffer = new byte[length];
            _memoryStream.Read(buffer, 0, length);
            return buffer;
        }

        public void WriteTypeCode(string value)
        {
            ByteArray bytes = new ByteArray();
            bytes.WriteUTFBytes(value);
            bytes.Position = 0;
            WriteUInt32(bytes.ReadUInt32()); 
        }

        public void WriteUTFBytes(string value)
        {
            //Length - max 65536.
            UTF8Encoding utf8Encoding = new UTF8Encoding();
            byte[] buffer = utf8Encoding.GetBytes(value);
            if (buffer.Length > 0)
                WriteBytes(buffer);
        }

        public void WriteUTF32(string value)
        {
            UTF8Encoding utf8Encoding = new UTF8Encoding();
            byte[] buffer = utf8Encoding.GetBytes(value);
            WriteUInt32((uint)buffer.Length);
            WriteUTFBytes(value);
        }

        public void WriteUTF16(string value)
        {
            //null string is not accepted
            //in case of custom serialization leads to TypeError: Error #2007: Parameter value must be non-null.  at flash.utils::ObjectOutput/writeUTF()

            //Length - max 65536.
            UTF8Encoding utf8Encoding = new UTF8Encoding();
            int byteCount = utf8Encoding.GetByteCount(value);
            byte[] buffer = utf8Encoding.GetBytes(value);
            this.WriteUInt16(byteCount);
            if (buffer.Length > 0)
                WriteBytes(buffer);
        }

        public void WriteUTF8(string value)
        {
            UTF8Encoding utf8Encoding = new UTF8Encoding();
            byte[] buffer = utf8Encoding.GetBytes(value);
            WriteByte(buffer.Length);
            WriteUTFBytes(value);
        }

        public void WriteByte(int value)
        {
            _memoryStream.WriteByte((byte)value);
        }

        public void WriteBytes(byte[] buffer)
        {
            if (buffer == null)
                return;

            WriteBytes(buffer, 0, buffer.Length);
        }

        public void WriteBytes(byte[] buffer, int offset, int length)
        {
            while (offset < length)            
                _memoryStream.WriteByte(buffer[offset++]);            
        }

        public void WriteFloats(float[] buffer)
        {
            if (buffer == null)
                return;

            for (int i = 0; i < buffer.Length; i++)
                WriteFloat(buffer[i]);
        }

        public void WriteBytesObject(byte[] buffer)
        {
            WriteUInt32((uint)buffer.Length);
            WriteBytes(buffer);
        }

        public ByteArray ReadDataObject()
        {            
            return new ByteArray( ReadBytes( (int)ReadUInt32() ) );            
        }

        public void WriteData(ByteArray data)
        {
            WriteBytes(data.ToArray());
        }        

        public void WriteDataObject(ByteArray data)
        {
            WriteBytesObject(data.ToArray());
        }

        public void WriteFloat(float value)
        {
            WriteBytes(BitConverter.GetBytes(value));
        }

        public void WriteDouble(double value)
        {
            WriteBytes(BitConverter.GetBytes(value));
        }

        public void WriteUInt24(int value)
        {
            byte[] bytes = new byte[3];
            bytes[0] = (byte)(0xFF & value);
            bytes[1] = (byte)(0xFF & (value >> 8));
            bytes[2] = (byte)(0xFF & (value >> 16));
            _memoryStream.Write(bytes, 0, bytes.Length);
        }

        public void WriteInt16(short value)
        {
            WriteBytes(BitConverter.GetBytes(value));
        }

        public void WriteInt32(int value)
        {
            WriteBytes(BitConverter.GetBytes(value));
        }

        public void WriteUInt32(uint value)
        {
            WriteBytes(BitConverter.GetBytes(value));
        }

        public void WriteInteger(int value)
        {
            uint abs = (uint)Math.Abs(value);

            if (abs > 0x3F)
            {
                WriteByte((value & 0x3F) | 0x80 | (value < 0 ? 0x40 : 0));

                if (abs > 0x1FFF)
                {
                    WriteByte(((value >> 6) & 0x7F) | 0x80);

                    WriteByte((value >> 12) & 0x7F);
                }
                else
                {
                    WriteByte((value >> 6) & 0x7F);
                }
            }
            else
            {
                WriteByte((value & 0x3F) | (value < 0 ? 0x40 : 0));
            }          
        }
        
        public int ReadInteger()
        {
            int v = ReadUByte(),
                r = v & 0x3F;

            bool negate = (v & 0x40) != 0;

            if ((v & 0x80) != 0)
            {
                v = ReadUByte();
                r |= (v & 0x7F) << 6;

                if ((v & 0x80) != 0)
                {
                    v = ReadUByte();
                    r |= (v & 0x7F) << 12;
                }
            }

            return negate ? -r : r;
        }

        public void WriteUInteger(int value)
        {
            uint abs = (uint)Math.Abs(value);

            if (abs > 0x3F)
            {
                WriteByte((value & 0x7F) | 0x80);

                if (abs > 0x1FFF)
                {
                    WriteByte(((value >> 7) & 0x7F) | 0x80);

                    WriteByte((value >> 13) & 0x7F);
                }
                else
                {
                    WriteByte((value >> 7) & 0x7F);
                }
            }
            else
            {
                WriteByte(value & 0x7F);
            }
        }

        public int ReadUInteger()
        {
            int v = ReadUByte(),
                r = v & 0x7F;

            if ((v & 0x80) != 0)
            {
                v = ReadUByte();
                r |= (v & 0x7F) << 7;

                if ((v & 0x80) != 0)
                {
                    v = ReadUByte();
                    r |= (v & 0x7F) << 13;
                }
            }

            return r;
        }

        public void WriteNull()
        {
            WriteByte(0);
        }
       
        public void WriteBoolean(bool value)
        {
            _memoryStream.WriteByte(value ? ((byte)1) : ((byte)0));
        }

        public uint Length
        {
            get
            {
                return (uint)_memoryStream.Length;
            }
        }

        public uint Position
        {
            get { return (uint)_memoryStream.Position; }
            set { _memoryStream.Position = value; }
        }

        public uint BytesAvailable
        {
            get { return Length - Position; }
        }

        public byte[] ToArray()
        {
            return _memoryStream.ToArray();
        }

        public uint GetCrc32()
        {
            return _crc32 == 0 ? _crc32 = Crc32.Compute(_memoryStream.ToArray()) : _crc32;
        }

        public void ReadFile(string filePath)
        {
            byte[] buffer;
            FileStream fileStream = new FileStream(filePath, FileMode.Open, FileAccess.Read);
            try
            {
                int length = (int)fileStream.Length;  // get file length
                buffer = new byte[length];            // create buffer
                int count;                            // actual number of bytes read
                int sum = 0;                          // total number of bytes read

                // read until Read method returns 0 (end of the stream has been reached)
                while ((count = fileStream.Read(buffer, sum, length - sum)) > 0)
                    sum += count;  // sum is a buffer offset for next reading
            }
            finally
            {
                fileStream.Close();
            }

            WriteBytes(buffer);
        }

        public MemoryStream Stream
        {
            get
            {
                return _memoryStream;
            }
        }
    }
}
