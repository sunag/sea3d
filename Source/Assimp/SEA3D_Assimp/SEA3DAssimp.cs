using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Linq;
using System.Text;
using Assimp;
using System.IO;
using System.Reflection;
using Assimp.Configs;
using Poonya.SEA3D;
using Poonya.SEA3D.Objects;
using Poonya.SEA3D.Objects.Techniques;
using Poonya.Utils;
using Poonya.SEA3D.Objects.Skeleton;
using System.Windows.Forms;
using System.Threading;

namespace Sunag.SEA3D
{
    public class SEA3DAssimp
    {
        private SEA3DWriter Writer = new SEA3DWriter();

        public bool EnabledDummy = false;
        public bool SceneOnly = true;
        public bool MeshOnly = false;
        public bool CalculateTangent = false;
        public bool CalculateNormal = true;
        public bool LimitBoneWeights = false;
        public bool Modifiers = true;
        public bool EmbedTexture = true;
        public string Path = "";
        public int OptimizeLevel = 3;

        private List<SEAObject3D> objects = new List<SEAObject3D>();
        private List<SEAMaterial> materials = new List<SEAMaterial>();
        private List<SEAGeometryBase> geometries = new List<SEAGeometryBase>();
        private List<SEAObject> textures = new List<SEAObject>();
        private List<SEAObject> modifiers = new List<SEAObject>();
        private List<SEAAnimationBase> animations = new List<SEAAnimationBase>();

        private PostProcessSteps GetConfig()
        {
            PostProcessSteps config =                 
                PostProcessSteps.JoinIdenticalVertices |
                PostProcessSteps.RemoveRedundantMaterials |
                PostProcessSteps.Triangulate |
                PostProcessSteps.GenerateUVCoords |
                PostProcessSteps.FindInvalidData |
                PostProcessSteps.FindInstances |
                PostProcessSteps.ValidateDataStructure |
                PostProcessSteps.OptimizeMeshes;

            if (OptimizeLevel >= 1) config |= PostProcessSteps.JoinIdenticalVertices;

            if (OptimizeLevel >= 2)
            {
                config |= PostProcessSteps.OptimizeMeshes;
                config |= PostProcessSteps.SortByPrimitiveType;
            }

            if (OptimizeLevel >= 3)
            {
                config |= PostProcessSteps.OptimizeGraph;
            }

            if (LimitBoneWeights) config |= PostProcessSteps.LimitBoneWeights;            
            if (CalculateNormal) config |= PostProcessSteps.GenerateSmoothNormals;
            if (CalculateTangent) config |= PostProcessSteps.CalculateTangentSpace;

            return config;
        }

        public void Import(String filename)
        {
            Path = filename.Substring(0, filename.LastIndexOf('\\') + 1);

            AppendScene(GetImporter().ImportFile(filename, GetConfig()));
        }

        public void LoadSave()
        {
            Thread openFileDialog = new Thread(OpenSaveFileDialog);
            openFileDialog.SetApartmentState(ApartmentState.STA);
            openFileDialog.Start();           
        }

        private void OpenSaveFileDialog()
        {
            string filename = null;

            try
            {
                OpenFileDialog openFileDialog = new OpenFileDialog();
                openFileDialog.RestoreDirectory = true;

                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                    filename = openFileDialog.FileName;
                }
            }
            catch (Exception e)
            {
                MessageBox.Show("Error opening the file:" + Environment.NewLine + e.ToString());
            }

            if (filename != null)
            {
                Import(filename);
                SaveDialog();
            }
        }

        public void Import(Stream stream, string format)
        {
            AppendScene(GetImporter().ImportFileFromStream(stream, GetConfig(), format));
        }

        public byte[] Build()
        {
            return Writer.Build();
        }

        public void SaveDialog()
        {
            Writer.CompressAlgorithm = CompressionAlgorithm.Lzma;
            Writer.SaveDialog();
        }

        public void Save(string filename)
        {
            Writer.CompressAlgorithm = CompressionAlgorithm.Lzma;
            Writer.Save(filename);
        }

        //
        //  IMPOTER
        //

        private void InitLog()
        {
            LogStream logstream = new LogStream(delegate(String msg, String userData)
            {
                Console.WriteLine(msg);
            });
            logstream.Attach();
        }

        private AssimpContext GetImporter()
        {
            AssimpContext importer = new AssimpContext();
            importer.SetConfig(new NormalSmoothingAngleConfig(66.0f));
            return importer;
        }

        private SEAObject AppendTexture(string url)
        {
            int sIndex = GetIndexByTag(url);
            if (sIndex != -1) return (SEATextureURL)Writer.Objects[sIndex];

            int end = Math.Max(0, url.LastIndexOf('.'));
            if (end == 0) end = url.Length;

            int start = url.LastIndexOf('/', end - 1) + 1;
            
            string name = url.Substring(start, end - start);
            string path = Path + url;

            SEAObject tex;

            if (EmbedTexture && File.Exists(path))
            {
                SEATexture texEmbed = new SEATexture(GetValidString(textures, name), url.Substring(end + 1).ToLower());
                texEmbed.Data = new ByteArray();
                texEmbed.Data.ReadFile(path);
                texEmbed.tag = url;

                tex = texEmbed;
            }
            else
            {
                SEATextureURL texurl = new SEATextureURL(GetValidString(textures, name));
                texurl.tag = texurl.url = url;

                tex = texurl;
            }
            
            textures.Add(tex);
            Writer.AddObject(tex);

            return tex;
        }

        private SEAObject AppendTexture(EmbeddedTexture texture)
        {
            int sIndex = GetIndexByTag(texture);
            if (sIndex != -1) return (SEATexture)Writer.Objects[sIndex];

            SEATexture tex = new SEATexture(GetValidString(textures, "EmbeddedTexture"), texture.CompressedFormatHint.ToLower());
            tex.Data.WriteBytes(texture.CompressedData);
            tex.tag = texture;

            textures.Add(tex);
            Writer.AddObject(tex);

            return tex;
        }        

        private SEAMaterial AppendMaterial(Scene scene, Material material)
        {
            int sIndex = GetIndexByTag(material);
            if (sIndex != -1) return (SEAMaterial)Writer.Objects[sIndex];

            SEAMaterial mat = new SEAMaterial(GetValidString(materials, material.Name));

            mat.doubleSided = material.IsTwoSided;

            mat.receiveLights = true;
            mat.receiveShadows = true;
            mat.receiveFog = true;

            mat.repeat = true;

            mat.alpha = material.Opacity;

            //
            //  DEFAULT
            //

            PhongTech defaultTech = new PhongTech();

            defaultTech.diffuseColor = ToInteger( material.ColorDiffuse );
            defaultTech.specularColor = ToInteger( material.ColorSpecular );

            defaultTech.specular = material.ShininessStrength;
            defaultTech.gloss = material.Shininess;

            mat.techniques.Add(defaultTech);

            //
            //  DIFFUSE_MAP
            //

            if (material.HasTextureDiffuse)
            {
                SEAObject tex = AppendTextureFromSlot(scene, material.TextureDiffuse);

                if (tex != null)
                {
                    DiffuseMapTech tech = new DiffuseMapTech();
                    tech.texture = GetIndex(tex);
                    mat.techniques.Add(tech);
                }
            }

            //
            //  SPECULAR_MAP
            //

            if (material.HasTextureSpecular)
            {
                SEAObject tex = AppendTextureFromSlot(scene, material.TextureSpecular);

                if (tex != null)
                {
                    SpecularMapTech tech = new SpecularMapTech();
                    tech.texture = GetIndex(tex);
                    mat.techniques.Add(tech);
                }
            }

            //
            //  EMISSIVE_MAP
            //

            if (material.HasTextureAmbient || material.HasTextureEmissive)
            {
                SEAObject tex = AppendTextureFromSlot(scene, material.HasTextureAmbient ? material.TextureAmbient : material.TextureEmissive);

                if (tex != null)
                {
                    EmissiveMapTech tech = new EmissiveMapTech();
                    tech.texture = GetIndex(tex);
                    mat.techniques.Add(tech);
                }
            }

            //
            //  NORMAL_MAP
            //

            if (material.HasTextureNormal)
            {
                SEAObject tex = AppendTextureFromSlot(scene, material.TextureNormal);

                if (tex != null)
                {
                    NormalMapTech tech = new NormalMapTech();
                    tech.texture = GetIndex(tex);
                    mat.techniques.Add(tech);
                }
            }

            //
            //  OPACITY_MAP
            //

            if (material.HasTextureOpacity)
            {
                SEAObject tex = AppendTextureFromSlot(scene, material.TextureOpacity);

                if (tex != null)
                {
                    OpacityMapTech tech = new OpacityMapTech();
                    tech.texture = GetIndex(tex);
                    mat.techniques.Add(tech);
                }
            }            

            //
            //  REFLECTION_MAP
            //

            if (material.HasTextureReflection)
            {
                SEAObject tex = AppendTextureFromSlot(scene, material.TextureReflection);

                if (tex != null)
                {
                    ReflectionTech tech = new ReflectionTech();
                    tech.texture = GetIndex(tex);
                    tech.alpha = material.Reflectivity;
                    mat.techniques.Add(tech);
                }
            }

            //  --

            mat.tag = material;

            materials.Add(mat);
            Writer.AddObject(mat);

            return mat;
        }

        private SEAGeometry AppendGeometry(Scene scene, Node node, List<Mesh> geometryList)
        {
            int sIndex = GetIndexByTag(node);

            if (sIndex != -1) return (SEAGeometry)Writer.Objects[sIndex];

            List<float> vertex = new List<float>();
            List<List<float>> uvs = new List<List<float>>();
            List<float> normal = new List<float>();
            List<float> tangent = new List<float>();
            List<uint> joints = new List<uint>();
            List<float> weights = new List<float>();
            List<List<float>> colors = new List<List<float>>();
            List<List<uint>> indexes = new List<List<uint>>();

            uint countUV = 0;
            uint countColor = 0;
            uint jointPerVertex = 0;
            uint indexOffset = 0;

            bool containsNormal = false;
            bool containsTangent = false;

            foreach(Mesh mesh in geometryList)
            {
                countUV = (uint)Math.Max(countUV, mesh.TextureCoordinateChannelCount);
                countColor = (uint)Math.Max(countColor, mesh.VertexColorChannelCount);

                if (mesh.HasNormals) containsNormal = mesh.HasNormals;
                if (mesh.HasTangentBasis) containsTangent = mesh.HasTangentBasis;

                if (mesh.HasBones)
                {
                    foreach (Bone bone in mesh.Bones)
                    {
                        if (bone.VertexWeightCount > jointPerVertex)
                            jointPerVertex = (uint)bone.VertexWeightCount;
                    }
                }
            }

            for (int i = 0; i < countUV; i++)
            {
                uvs.Add(new List<float>());
            }

            for (int i = 0; i < countColor; i++)
            {
                colors.Add(new List<float>());
            }

            foreach (Mesh geometry in geometryList)
            {
                if (!geometry.HasVertices || !geometry.HasFaces) continue;

                int NumVertex = geometry.VertexCount;

                for (int i = 0; i < NumVertex; i++)
                {
                    vertex.Add(geometry.Vertices[i].X);
                    vertex.Add(geometry.Vertices[i].Y);
                    vertex.Add(geometry.Vertices[i].Z);
                }

                for (int i = 0; i < countUV; i++)
                {
                    List<float> uv = uvs[i];

                    if (geometry.HasTextureCoords(i))
                    {
                        List<Vector3D> uv3d = geometry.TextureCoordinateChannels[i];

                        for (int j = 0; j < NumVertex; j++)
                        {
                            uv.Add(uv3d[j].X);
                            uv.Add(1 - uv3d[j].Y);
                        }
                    }
                    else
                    {
                        for (int j = 0; j < NumVertex; j++)
                        {
                            uv.Add(0);
                            uv.Add(0);
                        }
                    }
                }

                if (containsNormal)
                {
                    if (geometry.HasNormals)
                    {
                        for (int i = 0; i < NumVertex; i++)
                        {
                            normal.Add(geometry.Normals[i].X);
                            normal.Add(geometry.Normals[i].Y);
                            normal.Add(geometry.Normals[i].Z);
                        }
                    }
                    else
                    {
                        for (int i = 0; i < NumVertex; i++)
                        {
                            normal.Add(0);
                            normal.Add(0);
                            normal.Add(0);
                        }
                    }
                }

                if (containsTangent)
                {
                    if (geometry.HasTangentBasis)
                    {
                        for (int i = 0; i < NumVertex; i++)
                        {
                            tangent.Add(geometry.Tangents[i].X);
                            tangent.Add(geometry.Tangents[i].Y);
                            tangent.Add(geometry.Tangents[i].Z);
                        }
                    }
                    else
                    {
                        for (int i = 0; i < NumVertex; i++)
                        {
                            tangent.Add(0);
                            tangent.Add(0);
                            tangent.Add(0);
                        }
                    }
                }

                for (int i = 0; i < colors.Count; i++)
                {
                    List<float> color = colors[i];

                    if (geometry.HasVertexColors(i))
                    {
                        List<Color4D> clr = geometry.VertexColorChannels[i];

                        int j = 0;

                        while (j < NumVertex)
                        {
                            color.Add(clr[j].R);
                            color.Add(clr[j].G);
                            color.Add(clr[j].B);
                            color.Add(clr[j].A);
                        }
                    }
                    else
                    {
                        int j = 0;

                        while (j < NumVertex)
                        {
                            color.Add(0);
                            color.Add(0);
                            color.Add(0);
                            color.Add(0);
                        }
                    }
                }

                if (Modifiers && jointPerVertex > 0)
                {
                    foreach (Bone bone in geometry.Bones)
                    {
                        int i = 0;

                        for (; i < bone.VertexWeights.Count; i++)
                        {
                            joints.Add(indexOffset + (uint)bone.VertexWeights[i].VertexID);
                            weights.Add((uint)bone.VertexWeights[i].Weight);
                        }

                        for (; i < jointPerVertex; i++)
                        {
                            joints.Add(0);
                            weights.Add(0);
                        }
                    }
                }

                List<uint> index = geometry.GetUnsignedIndices().ToList();

                for (int i = 0; i < index.Count; i++)
                {
                    index[i] += indexOffset;
                }

                indexOffset += (uint)NumVertex;

                indexes.Add(index);
            }

            float[][] _uv = new float[uvs.Count][];
            float[][] _color = new float[colors.Count][];
            uint[][] _indexes = new uint[indexes.Count][];

            for (int i = 0; i < uvs.Count; i++) _uv[i] = uvs[i].ToArray();
            for (int i = 0; i < colors.Count; i++) _color[i] = colors[i].ToArray();
            for (int i = 0; i < indexes.Count; i++) _indexes[i] = indexes[i].ToArray();

            SEAGeometry geo = new SEAGeometry(GetValidString(geometries, node.Name));
            geo.vertex = vertex.ToArray();
            geo.uv = uvs.Count > 0 ? _uv : null;
            geo.normal = normal.Count > 0 ? normal.ToArray() : null;
            geo.tangent = tangent.Count > 0 ? tangent.ToArray() : null;
            geo.color = colors.Count > 0 ? _color : null;
            geo.weight = weights.Count > 0 ? weights.ToArray() : null;
            geo.joint = joints.Count > 0 ? joints.ToArray() : null;
            geo.jointPerVertex = jointPerVertex;
            geo.indexes = _indexes;

            geo.tag = node;

            geometries.Add(geo);
            Writer.AddObject(geo);

            return geo;
        }

        private SEASkeleton AppendSkeleton(Scene scene, Mesh mesh)
        {
            SEASkeleton skl = new SEASkeleton(GetValidString(modifiers, mesh.Name));

            skl.joints = new List<JointData>();

            foreach (Bone bone in mesh.Bones)
            {
                JointData jnt = new JointData();
                jnt.name = bone.Name;
                jnt.parentIndex = -1;
                jnt.inverseBindMatrix = To3x4Array( bone.OffsetMatrix );
            }

            modifiers.Add(skl);
            Writer.AddObject(skl);

            return skl;
        }

        private SEAAnimationBase AppendKeyFrameAnimation(Scene scene, Animation animation)
        {
            return null;
        }

        private SEASkeleton AppendSkeletonAnimation(Scene scene, Mesh mesh)
        {
            return null;
        }

        private SEAMesh AppendMesh(Scene scene, Node node, List<Mesh> meshes, SEAObject3D parent)
        {            
            int sIndex = GetIndexByTag(node);

            if (sIndex != -1) return (SEAMesh)Writer.Objects[sIndex];

            List<Animation> anmList = GetAnimation(scene, node.Name);

            SEAGeometry geo = AppendGeometry(scene, node, meshes);

            if (geo != null)
            {
                SEAMesh seaMesh = new SEAMesh(node.Name);

                /*if (meshes[0].HasMeshAnimationAttachments)
                {
                }*/

                Mesh mesh = meshes[0];

                if (Modifiers && geo.jointPerVertex > 0)
                {
                    seaMesh.modifiers.Add((uint)GetIndex(AppendSkeleton(scene, mesh)));
                    seaMesh.animations.Add((uint)GetIndex(AppendSkeletonAnimation(scene, mesh)));
                }

                if (mesh.MaterialIndex != -1)
                {
                    seaMesh.materials.Add(GetIndex(AppendMaterial(scene, scene.Materials[mesh.MaterialIndex])));
                }

                seaMesh.parent = parent != null ? GetIndex(parent) : -1;

                objects.Add(seaMesh);
                Writer.AddObject(seaMesh);

                seaMesh.transform = To3x4Array( node.Transform );
                seaMesh.geometry = GetIndex(geo);

                seaMesh.tag = node;

                return seaMesh;
            }

            return null;
        }

        private SEAObject3D AppendLight(Scene scene, Node node, Light light, SEAObject3D parent)
        {
            int sIndex = GetIndexByTag(node);
            if (sIndex != -1) return (SEAObject3D)Writer.Objects[sIndex];

            SEALight seaLight = null;

            if (light.LightType == LightSourceType.Point)
            {
                SEAPointLight pLight = new SEAPointLight(GetValidString(objects, node.Name));
                pLight.multiplier = 1;
                pLight.color = ToInteger( light.ColorDiffuse );
                pLight.position = ToPositionArray( node.Transform );

                seaLight = pLight;
            }
            else if (light.LightType == LightSourceType.Directional || light.LightType == LightSourceType.Spot)
            {
                SEADirectionalLight dLight = new SEADirectionalLight(GetValidString(objects, node.Name));
                dLight.multiplier = 1;
                dLight.color = ToInteger( light.ColorDiffuse );

                dLight.transform = To3x4Array( node.Transform );

                seaLight = dLight;
            }

            if (seaLight != null)
            {
                seaLight.parent = parent != null ? GetIndex(parent) : -1;
                seaLight.tag = node;

                objects.Add(seaLight);
                Writer.AddObject(seaLight);
            }

            return seaLight;
        }

        private SEACamera AppendCamera(Scene scene, Node node, Camera camera, SEAObject3D parent)
        {
            int sIndex = GetIndexByTag(node);
            if (sIndex != -1) return (SEACamera)Writer.Objects[sIndex];

            SEACamera cam = new SEACamera(GetValidString(objects, node.Name));

            cam.parent = parent != null ? GetIndex(parent) : -1;

            cam.transform = To3x4Array(node.Transform * camera.ViewMatrix);
            cam.fov = camera.FieldOfview;

            objects.Add(cam);
            Writer.AddObject(cam);

            cam.tag = node;

            return cam;
        }

        private SEAObject3D AppendDummy(Scene scene, Node node, SEAObject3D parent)
        {
            int sIndex = GetIndexByTag(node);
            if (sIndex != -1) return (SEACamera)Writer.Objects[sIndex];

            SEADummy dummy = new SEADummy(GetValidString(objects, node.Name));

            dummy.transform = To3x4Array( node.Transform );
            dummy.width = dummy.height = dummy.depth = 100;

            objects.Add(dummy);
            Writer.AddObject(dummy);

            dummy.tag = node;

            return dummy;
        }

        private SEAObject3D AppendObject3D(Scene scene, Node node, SEAObject3D parent)
        {
            SEAObject3D object3d = null;

            /*
                mtx.e00 / scale.x, mtx.e10 / scale.x, mtx.e20 / scale.x,
                mtx.e01 / scale.y, mtx.e11 / scale.y, mtx.e21 / scale.y,
                mtx.e02 / scale.z, mtx.e12 / scale.z, mtx.e22 / scale.z
            */

            //node.Transform = node.Transform * Matrix4x4.FromEulerAnglesXYZ(-90, 0, 0);

            if (node.MeshCount > 0)
            {
                object3d = AppendMesh(scene, node, scene.Meshes, parent);
            }
            else if (!MeshOnly && scene.RootNode != node)
            {
                object unrelatedObject = GetUnrelatedObjectByNode(node, scene);

                if (unrelatedObject is Light)
                {
                    object3d = AppendLight(scene, node, (Light)unrelatedObject, parent);
                }
                else if (unrelatedObject is Camera)
                {
                    object3d = AppendCamera(scene, node, (Camera)unrelatedObject, parent);
                }
                else if (EnabledDummy)
                {
                    object3d = AppendDummy(scene, node, parent);
                }
            }

            foreach (Node children in node.Children)
            {
                AppendObject3D(scene, children, object3d);
            }

            return null;
        }

        private SEAObject3D AppendObject3D(Scene scene, Node node)
        {
            return AppendObject3D(scene, node, null);
        }

        private void AppendScene(Scene scene)
        {
            AppendObject3D(scene, scene.RootNode);

            if (!SceneOnly)
            {
                foreach (Material mat in scene.Materials)
                {
                    AppendMaterial(scene, mat);
                }
            }
        }

        private object GetUnrelatedObjectByNode(Node node, Scene scene)
        {
            foreach (Light light in scene.Lights)
            {
                if (light.Name == node.Name)
                    return light;
            }

            foreach (Camera camera in scene.Cameras)
            {
                if (camera.Name == node.Name)
                    return camera;
            }

            return null;
        }

        private int GetIndexByTag(object tag)
        {
            for (int i = 0; i < Writer.Objects.Count; i++)
            {
                if (Writer.Objects[i].tag == tag)
                    return i;
            }

            return -1;
        }

        private int GetIndex(SEAObject obj)
        {
            return Writer.Objects.IndexOf(obj);
        }

        private string getURL(string url)
        {
            url = url.Replace('\\', '/');

            if (url.Substring(0, 2) == "./")            
            {
                url = url.Substring(2);
            }

            return url;
        }

        private List<Animation> GetAnimation(Scene scene, string name)
        {
            List<Animation> list = new List<Animation>();

            foreach (Animation anm in scene.Animations)
            {
                if (anm.Name == name)
                {
                    list.Add(anm);
                }
            }

            return list;
        }

        private SEAObject AppendTextureFromSlot(Scene scene, TextureSlot slot)
        {
            if (slot.FilePath.Length > 0 && slot.FilePath[0] != '*')
            {
                return AppendTexture(getURL(slot.FilePath));
            }
            else if (slot.TextureIndex < scene.TextureCount)
            {
                return AppendTexture(scene.Textures[slot.TextureIndex]);
            }

            return null;
        }

        private string GetValidString(IEnumerable<SEAObject> objects, string name)
        {
            if (name == null) name = "";

            foreach (SEAObject obj in objects)
            {
                if (obj.Name == name)
                {
                    Regex regex = new Regex("[0-9]+$");

                    int num = 0, numlen = 0;

                    if (regex.IsMatch(name))
                    {
                        Match match = regex.Match(name);

                        num = int.Parse(name.Substring(match.Index));
                        numlen = name.Length - match.Index;

                        name = name.Substring(0, match.Index);
                    }

                Rename:
                    while (true)
                    {
                        string numstr = (++num).ToString();

                        for (int i = 0; i < numlen; i++)
                        {
                            numstr = "0" + numstr;
                        }

                        string newname = name + numstr;

                        foreach (SEAObject obj2 in objects)
                        {
                            if (obj2.Name == newname)
                                goto Rename;
                        }

                        return newname;
                    }
                }
            }

            return name;
        }

        public float[] ToPositionArray(Matrix4x4 matrix)
        {
            return new float[] { matrix.A4, matrix.B4, matrix.C4 };
        }

        public float[] To3x4Array(Matrix4x4 matrix)
        {
            return new float[] { matrix.A1, matrix.A2, matrix.A3, matrix.B1, matrix.B2, matrix.B3, matrix.C1, matrix.C2, matrix.C3, matrix.A4, matrix.B4, matrix.C4 };
        }

        public static int ToInteger(Color4D color)
        {
            return (int)(color.R * 255) | ((int)(color.G * 255) << 8) | ((int)(color.B * 255) << 16) | ((int)(color.A * 255) << 24);
        }

        public static int ToInteger(Color3D color)
        {
            return (int)(color.R * 255) | ((int)(color.G * 255) << 8) | ((int)(color.B * 255) << 16);
        }

        public float ToFloat(Color4D color)
        {
            return (color.R + color.G + color.B + color.A) / 4f;
        }

        public float ToFloat(Color3D color)
        {
            return (color.R + color.G + color.B) / 3f;
        }
    }
}
