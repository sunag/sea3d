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
using System.Collections.Generic;
#if !ENABLE_MONO
using System.Windows.Forms;
#endif
using System.Threading;
using Poonya.Utils;
using Poonya.SEA3D.Objects;
using System.IO;

namespace Poonya.SEA3D
{
    public class SEA3DWriter
    {
        public static int VERSION = 18000;

        private List<SEAObject> _objects = new List<SEAObject>();

        protected int version;

        protected string compressAlgorithm = CompressionAlgorithm.Lzma;
        protected string protectionAlgorithm = "";

        public SEA3DWriter()
            : this(VERSION)
        {
        }

        public SEA3DWriter(int version)
        {
            this.version = version;
        }

        public List<SEAObject> Objects
        {
            get
            {
                return _objects;
            }
        }

        public int Version
        {
            get
            {
                return version;
            }
        }

        public string CompressAlgorithm
        {
            set
            {
                compressAlgorithm = value;
            }
            get
            {
                return compressAlgorithm;
            }
        }

        public string ProtectionAlgorithm
        {
            set
            {
                protectionAlgorithm = value;
            }
            get
            {
                return protectionAlgorithm;
            }
        }

        private byte[] GetBody()
        {
            ByteArray bytes = new ByteArray();

            // Write Packets Data            
            for (int i = 0; i < _objects.Count; i++)
            {
                SEAObject asset = _objects[i];

                ByteArray data = new ByteArray();

                byte[] buffer = asset.Write().ToArray();

                data.WriteByte(asset.Flag);
                data.WriteTypeCode(asset.Type);

                if (asset.Named)
                    data.WriteUTF8(asset.Name);

                if (asset.Compressed)
                    buffer = Compression.Compress(buffer, compressAlgorithm);

                data.WriteBytes(buffer);

                bytes.WriteBytesObject(data.ToArray());
            }

            return bytes.ToArray();
        }

        public byte[] Build()
        {
            // Body
            byte[] body = GetBody();

            // Write Bytes
            ByteArray bytes = new ByteArray();

            // Write MAGIC
            bytes.WriteUTFBytes("SEA");

            // Write SIGNATURE
            bytes.WriteUTFBytes("S3D");

            // Write Version
            bytes.WriteUInt24(version);

            // Write Protect Method            
            bytes.WriteByte(0);

            // Write Compress Method
            bytes.WriteByte(SEA3DWriter.CompressionID(compressAlgorithm));

            // Write File Count
            bytes.WriteUInt32((uint)_objects.Count);

            // Write Body
            bytes.WriteBytes(body);

            // Write Final
            bytes.WriteUInt24(0x5EA3D1);

            return bytes.ToArray();
        }

        public int AddSharedObject(SEAData obj)
        {
            for (int i = 0; i < _objects.Count; i++)
            {
                if (_objects[i] is SEAData)
                {
                    SEAData f = (SEAData)_objects[i];

                    if (f.Type == obj.Type && f.Data.Length == obj.Data.Length)
                    {
                        if (obj.Data.GetCrc32() == f.Data.GetCrc32())
                        {
                            return i;
                        }
                    }
                }
            }

            return AddObject(obj);
        }

        public int AddObject(SEAObject obj)
        {
            _objects.Add(obj);
            return _objects.Count - 1;
        }

        public void Save(string filename)
        {
            try
            {
                byte[] data = Build();

                // Open file for reading
                FileStream filestream = new FileStream(filename, FileMode.Create, FileAccess.Write);

                // Writes a block of bytes to this stream using data from a byte array.
                filestream.Write(data, 0, data.Length);

                // close file stream
                filestream.Close();
            }
#if !ENABLE_MONO
            catch (Exception e)
            {
                MessageBox.Show("Error saving the file:" + Environment.NewLine + e.ToString());
            }
#else
            catch (Exception)
            {
            }
#endif

        }

#if !ENABLE_MONO

        public void SaveDialog()
        {
            Thread saveFileDialog = new Thread(OpenSaveFileDialog);
            saveFileDialog.SetApartmentState(ApartmentState.STA);
            saveFileDialog.Start();
        }

        private void OpenSaveFileDialog()
        {
            SaveFileDialog saveFileDialog = new SaveFileDialog();
            //saveFileDialog.InitialDirectory = @"C:\";
            saveFileDialog.Title = "Save SEA3D File";
            saveFileDialog.CheckFileExists = true;
            saveFileDialog.CheckPathExists = true;
            saveFileDialog.DefaultExt = "sea";
            saveFileDialog.Filter = "Sunag Entertainment Assets|*.sea";
            saveFileDialog.RestoreDirectory = true;
            saveFileDialog.ValidateNames = false;

            if (saveFileDialog.ShowDialog() == DialogResult.OK)
            {
                Save(saveFileDialog.FileName);
            }
        }

#endif

        public static int CompressionID(string type)
        {
            switch (type)
            {
                case CompressionAlgorithm.Deflate:
                    return 1;

                case CompressionAlgorithm.Lzma:
                    return 2;
            }

            return 0;
        }
    }
}
