using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;
using Poonya.Utils;
using Sunag.SEA3D;

namespace Poonya.Server.Engine
{
    public class SEA3DEncoder : Session
    {
        public static readonly string Type = "sea3d-encoder";

        public ByteArray FileData;
        public string FileFormat;

        public SEA3DEncoder(SID sid)
            : base(sid)
        {
            FileFormat = Data.ReadUTF8();

            byte[] buffer = Data.ReadDataObject().ToArray();
            buffer = Compression.Decompress(buffer, CompressionAlgorithm.Lzma);

            FileData = new ByteArray(buffer);
        }

        public override ByteArray Run()
        {
            SEA3DAssimp importer = new SEA3DAssimp();
            importer.CalculateNormal = true;
            importer.OptimizeLevel = 3;
            importer.Modifiers = false;
            importer.LimitBoneWeights = true;
            importer.SceneOnly = true;
            importer.MeshOnly = true;

            try
            {
                importer.Import(FileData.Stream, FileFormat);
            }
            catch (Exception)
            {
                return new ByteArray();
            }

            return new ByteArray(importer.Build());
        }
    }
}
