/*
*
* Copyright (c) 2013 Sunag Entertainment
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

package sunag.sea3d
{
	import away3d.arcane;
	import away3d.animator.IMorphAnimator;
	import away3d.animator.MorphAnimationSet;
	import away3d.animator.MorphAnimator;
	import away3d.animator.MorphGeometry;
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.VertexAnimationSet;
	import away3d.animators.VertexAnimator;
	import away3d.animators.data.JointPose;
	import away3d.animators.data.Skeleton;
	import away3d.animators.data.SkeletonJoint;
	import away3d.animators.data.SkeletonPose;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.nodes.VertexClipNode;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.ISubGeometry;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.core.base.SubGeometry;
	import away3d.entities.Entity;
	import away3d.entities.JointObject;
	import away3d.entities.Mesh;
	import away3d.entities.Sprite3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.loaders.misc.AssetLoaderContext;
	import away3d.materials.IPassMaterial;
	import away3d.materials.ITextureMaterial;
	import away3d.materials.ITranslucentMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.AlphaMaskMethod;
	import away3d.materials.methods.BlendNormalMethod;
	import away3d.materials.methods.CelDiffuseMethod;
	import away3d.materials.methods.CelSpecularMethod;
	import away3d.materials.methods.DetailMapMethod;
	import away3d.materials.methods.DynamicFogMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.LayeredDiffuseMethod;
	import away3d.materials.methods.LayeredTexture;
	import away3d.materials.methods.LightMapMethod;
	import away3d.materials.methods.OutlineMethod;
	import away3d.materials.methods.PlanarReflectionMethod;
	import away3d.materials.methods.RefractionEnvMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.materials.methods.ShadowMapMethodBase;
	import away3d.materials.methods.SubsurfaceScatteringDiffuseMethod;
	import away3d.materials.methods.VertexColorMethod;
	import away3d.morph.MorphNode;
	import away3d.sea3d.animation.CameraAnimation;
	import away3d.sea3d.animation.DirectionalLightAnimation;
	import away3d.sea3d.animation.LayeredDiffuseMethodAnimation;
	import away3d.sea3d.animation.LayeredTextureAnimation;
	import away3d.sea3d.animation.MeshAnimation;
	import away3d.sea3d.animation.MorphAnimation;
	import away3d.sea3d.animation.PointLightAnimation;
	import away3d.sea3d.animation.SkeletonAnimation;
	import away3d.sea3d.animation.TextureAnimation;
	import away3d.sea3d.animation.VertexAnimation;
	import away3d.textures.ATFCubeTexture;
	import away3d.textures.ATFTexture;
	import away3d.textures.AsynBitmapCubeTexture;
	import away3d.textures.AsynBitmapTexture;
	import away3d.textures.AsynSingleBitmapCubeTexture;
	import away3d.textures.BitmapCubeTexture;
	import away3d.textures.CubeTextureBase;
	import away3d.textures.Texture2DBase;
	import away3d.tools.SkeletonTools;
	import away3d.tools.utils.GeomUtil;
	
	import sunag.sunag;
	import sunag.animation.Animation;
	import sunag.animation.AnimationNode;
	import sunag.animation.AnimationSet;
	import sunag.animation.IAnimationPlayer;
	import sunag.animation.data.AnimationData;
	import sunag.sea3d.config.IConfig;
	import sunag.sea3d.mesh.MeshData;
	import sunag.sea3d.objects.IAnimator;
	import sunag.sea3d.objects.SEAATF;
	import sunag.sea3d.objects.SEAATFCube;
	import sunag.sea3d.objects.SEAAnimation;
	import sunag.sea3d.objects.SEACamera;
	import sunag.sea3d.objects.SEAComposite;
	import sunag.sea3d.objects.SEAContainer3D;
	import sunag.sea3d.objects.SEACubeMap;
	import sunag.sea3d.objects.SEADirectionalLight;
	import sunag.sea3d.objects.SEAFileInfo;
	import sunag.sea3d.objects.SEAGIF;
	import sunag.sea3d.objects.SEAGeometry;
	import sunag.sea3d.objects.SEAGeometryData;
	import sunag.sea3d.objects.SEAGeometryDelta;
	import sunag.sea3d.objects.SEAJPEG;
	import sunag.sea3d.objects.SEAJPEGXR;
	import sunag.sea3d.objects.SEAJointObject;
	import sunag.sea3d.objects.SEAMaterial;
	import sunag.sea3d.objects.SEAMesh;
	import sunag.sea3d.objects.SEAMesh2D;
	import sunag.sea3d.objects.SEAModifier;
	import sunag.sea3d.objects.SEAMorph;
	import sunag.sea3d.objects.SEAMorphAnimation;
	import sunag.sea3d.objects.SEAObject3D;
	import sunag.sea3d.objects.SEAOrthographicCamera;
	import sunag.sea3d.objects.SEAPNG;
	import sunag.sea3d.objects.SEAPerspectiveCamera;
	import sunag.sea3d.objects.SEAPointLight;
	import sunag.sea3d.objects.SEAReference;
	import sunag.sea3d.objects.SEASingleCube;
	import sunag.sea3d.objects.SEASkeleton;
	import sunag.sea3d.objects.SEASkeletonAnimation;
	import sunag.sea3d.objects.SEATexture;
	import sunag.sea3d.objects.SEATextureURL;
	import sunag.sea3d.objects.SEAUVWAnimation;
	import sunag.sea3d.objects.SEAVertexAnimation;
	import sunag.sea3d.textures.Layer;
	import sunag.utils.DataTable;
	
	use namespace sunag;
	
	public class SEA3D extends SEA
	{								
		protected var _shadow:ShadowMapMethodBase;
		
		protected var _config:IConfig;
				
		protected var _camera:Vector.<Camera3D>;
		protected var _mesh:Vector.<Mesh>;
		protected var _cubemap:Vector.<CubeTextureBase>;
		protected var _material:Vector.<MaterialBase>;
		protected var _texture:Vector.<Texture2DBase>;
		protected var _light:Vector.<LightBase>;
		protected var _reference:Vector.<AssetLoaderContext>;
		protected var _animation:Vector.<Animation>;
		protected var _animationSet:Vector.<AnimationSet>;
		protected var _composite:Vector.<LayeredDiffuseMethod>;			
		protected var _object3d:Vector.<ObjectContainer3D>;		
		protected var _morphAnimation:Vector.<Mesh>;
		protected var _vertexAnimation:Vector.<Mesh>;
		protected var _skeletonAnimation:Vector.<Mesh>;
		protected var _morphAnimationSet:Vector.<MorphAnimationSet>;
		protected var _skeletonAnimationSet:Vector.<SkeletonAnimationSet>;
		protected var _vertexAnimationSet:Vector.<VertexAnimationSet>;
		protected var _skeleton:Vector.<away3d.animators.data.Skeleton>;	
		protected var _jointObject:Vector.<JointObject>;				
		protected var _sprite3D:Vector.<Sprite3D>;			
		
		sunag var _matTechRead:Object = {};
			
		/**
		 * Creates a new SEA3D loader 
		 * @param config Settings of loader
		 * 
		 * @see SEA3DManager
		 * @see SEA3DDebug
		 */
		public function SEA3D(config:IConfig)
		{
			super(config);						
			
			_config = config;									
									
			// SEA3D				
			_typeRead[SEACubeMap.TYPE] = readCubeTexture;
			_typeRead[SEASingleCube.TYPE] = readSingleCubeTexture;				
			_typeRead[SEAComposite.TYPE] = readComposite;
			_typeRead[SEAMaterial.TYPE] = readMaterial;
			_typeRead[SEAAnimation.TYPE] = 
			_typeRead[SEAUVWAnimation.TYPE] = readAnimation;
			_typeRead[SEAMorph.TYPE] = readMorph;
			_typeRead[SEAMorphAnimation.TYPE] = readMorphAnimation;
			_typeRead[SEASkeleton.TYPE] = readSkeleton;
			_typeRead[SEASkeletonAnimation.TYPE] = readSkeletonAnimation;
			_typeRead[SEAGeometry.TYPE] = readGeometry;
			_typeRead[SEAGeometryDelta.TYPE] = readGeometry;			
			_typeRead[SEAMesh.TYPE] = readMesh;				
			_typeRead[SEAMesh2D.TYPE] = readSprite3D;
			_typeRead[SEAPerspectiveCamera.TYPE] = readPerspectiveCamera;
			_typeRead[SEAOrthographicCamera.TYPE] = readOrthographicCamera;
			_typeRead[SEADirectionalLight.TYPE] = readDirectionalLight;
			_typeRead[SEAPointLight.TYPE] = readPointLight;					
			_typeRead[SEAFileInfo.TYPE] = readFileInfo;
			_typeRead[SEAJointObject.TYPE] = readJointObject;
			_typeRead[SEAContainer3D.TYPE] = readContainer3D;
			_typeRead[SEATextureURL.TYPE] = readTextureURL;
			_typeRead[SEAReference.TYPE] = readReference;
			
			// UNIVERSAL
			_typeRead[SEAJPEG.TYPE] = 
			_typeRead[SEAJPEGXR.TYPE] = 
			_typeRead[SEAPNG.TYPE] = 
			_typeRead[SEAGIF.TYPE] = readBitmapTexture;				
			
			// ADOBE FLASH PLAYER
			_typeRead[SEAATF.TYPE] = readATFTexture; 
			_typeRead[SEAATFCube.TYPE] = readATFCubeTexture;
			
			// MATERIAL
			_matTechRead[SEAMaterial.DEFAULT] = applyDefaultTechnique;
			_matTechRead[SEAMaterial.COMPOSITE_TEXTURE] = applyCompositeTextureTechnique;
			_matTechRead[SEAMaterial.DIFFUSE_MAP] = applyDiffuseMapTechnique;
			_matTechRead[SEAMaterial.SPECULAR_MAP] = applySpecularMapTechnique;
			_matTechRead[SEAMaterial.REFLECTION] = applyReflectionTechnique;
			_matTechRead[SEAMaterial.MIRROR_REFLECTION] = applyMirrorTechnique;
			_matTechRead[SEAMaterial.REFRACTION] = applyRefractionTechnique;
			_matTechRead[SEAMaterial.NORMAL_MAP] = applyNormalMapTechnique;
			_matTechRead[SEAMaterial.FRESNEL_REFLECTION] = applyFresnelReflectionTechnique;
			_matTechRead[SEAMaterial.RIM] = applyRimTechnique;
			_matTechRead[SEAMaterial.LIGHT_MAP] = applyLightMapTechnique;
			_matTechRead[SEAMaterial.DETAIL_MAP] = applyDetailMapTechnique;
			_matTechRead[SEAMaterial.TRANSLUCENT] = applyTranslucentTechnique;
			_matTechRead[SEAMaterial.CEL] = applyCelTechnique;
			_matTechRead[SEAMaterial.BLEND_NORMAL_MAP] = applyBlendNormalMapTechnique;
			_matTechRead[SEAMaterial.ALPHA_MAP] = applyAlphaMapTechnique;
			_matTechRead[SEAMaterial.VERTEX_COLOR] = applyVertexColorTechnique;
		}
		
		//
		//	Protected
		//
		
		protected function readMaterial(sea:SEAMaterial):void
		{
			var mat:IPassMaterial = _config.createMaterial();					
			
			mat.repeat = true;
			mat.smooth = true;			
			mat.mipmap = _config.mipmap;
			mat.writeDepth = sea.depthMask;
			mat.autoWriteDepth = _config.autoWriteDepth;
			
			mat.bothSides = sea.doubleSided;
			
			for each(var tech:Object in sea.technique)
				_matTechRead[tech.kind](mat, tech);												
			
			if (mat is ITranslucentMaterial)
			{
				ITranslucentMaterial(mat).alpha = sea.alpha;					
			}
				
			mat.blendMode = sea.blendMode;
			
			if (_config.lightPicker && sea.receiveLights)
				mat.lightPicker = _config.lightPicker;
			
			if (_config.containsShadow && sea.receiveShadows) 
				mat.shadowMethod = _config.getShadowMapMethod() as ShadowMapMethodBase;
						
			if (_config.enabledFog && sea.receiveFog)
				mat.addMethod(DynamicFogMethod.instance);
			
			mat.name = sea.name;
						
			_material ||= new Vector.<MaterialBase>();
			_material.push(object[sea.name + '.mtl'] = sea.tag = mat);			
		}				
		
		protected function applyDefaultTechnique(mat:IPassMaterial, tech:Object):void
		{
			mat.ambientColor = tech.ambientColor;
			mat.diffuseMethod.diffuseColor = tech.diffuseColor;
			mat.specularColor = tech.specularColor;
			
			mat.gloss = tech.gloss;
			mat.specular = tech.specular;
		}
		
		protected function applyCompositeTextureTechnique(mat:ITextureMaterial, tech:Object):void
		{
			var tex:SEAComposite = tech.composite;
			
			if (mat is ITranslucentMaterial)
			{								
				ITranslucentMaterial(mat).alphaBlending = 
					tex.firstTexture.map.transparent;
			}
			
			mat.repeat = tex.firstTexture.repeat;
			
			mat.diffuseMethod = tex.tag;
		}
		
		protected function applyDiffuseMapTechnique(mat:ITextureMaterial, tech:Object):void
		{
			mat.texture = tech.texture.tag;	
			
			if (mat is ITranslucentMaterial)
			{
				if ( (ITranslucentMaterial(mat).alphaBlending = tech.texture.transparent) )
				{
					ITranslucentMaterial(mat).alphaThreshold = .3;
				}
			}
		}
		
		protected function applySpecularMapTechnique(mat:IPassMaterial, tech:Object):void
		{			
			mat.specularMap = tech.texture.tag;				
		}
		
		protected function applyNormalMapTechnique(mat:IPassMaterial, tech:Object):void
		{						
			mat.normalMap = tech.texture.tag;
		}
		
		protected function applyRefractionTechnique(mat:IPassMaterial, tech:Object):void
		{
			var method:RefractionEnvMapMethod = new RefractionEnvMapMethod(tech.texture.tag, tech.ior);
			method.alpha = tech.alpha;
			
			mat.addMethod(method);
		}
		
		protected function applyReflectionTechnique(mat:IPassMaterial, tech:Object):void
		{				
			mat.addMethod( new EnvMapMethod(tech.texture.tag, tech.alpha) );		
		}
		
		protected function applyFresnelReflectionTechnique(mat:IPassMaterial, tech:Object):void
		{
			var fresnelShader:FresnelEnvMapMethod = new FresnelEnvMapMethod(tech.texture.tag, tech.alpha);				
			
			fresnelShader.fresnelPower = tech.power;
			fresnelShader.normalReflectance = tech.normal;
			
			mat.addMethod( fresnelShader );	
		}
		
		protected function applyMirrorTechnique(mat:IPassMaterial, tech:Object):void
		{
			var planarMethod:PlanarReflectionMethod = new PlanarReflectionMethod(tech.texture.tag, tech.alpha);
			
			if (mat.normalMap)
				planarMethod.normalDisplacement = _config.normalDisplacement;
			
			mat.addMethod(planarMethod);
		}
		
		protected function applyRimTechnique(mat:IPassMaterial, tech:Object):void
		{			
			mat.addMethod(new RimLightMethod(tech.color, tech.strength, tech.power, tech.blendMode));
		}
		
		protected function applyLightMapTechnique(mat:IPassMaterial, tech:Object):void
		{			
			mat.addMethod(new LightMapMethod(tech.texture.tag, tech.blendMode,  tech.channel > 0));
		}
		
		protected function applyDetailMapTechnique(mat:IPassMaterial, tech:Object):void
		{			
			mat.addMethod(new DetailMapMethod(tech.texture.tag, tech.scale));
		}
		
		protected function applyTranslucentTechnique(mat:IPassMaterial, tech:Object):void
		{			
			var trans:SubsurfaceScatteringDiffuseMethod = new SubsurfaceScatteringDiffuseMethod();
			
			trans.scatterColor = tech.color;
			trans.translucency = tech.translucency;			
			trans.scattering = tech.scattering;
			
			mat.diffuseMethod = trans;
		}				
		
		protected function applyCelTechnique(mat:IPassMaterial, tech:Object):void
		{
			mat.diffuseMethod = new CelDiffuseMethod(tech.levels);
			mat.specularMethod = new CelSpecularMethod(tech.specularCutOff);
			
			CelDiffuseMethod(mat.diffuseMethod).smoothness = tech.smoothness;
			CelSpecularMethod(mat.specularMethod).smoothness = tech.smoothness;						
						
			mat.addMethod(new OutlineMethod(tech.color, tech.size));	
		}
		
		protected function applyBlendNormalMapTechnique(mat:IPassMaterial, tech:Object):void
		{
			var blendNormal:BlendNormalMethod = new BlendNormalMethod(tech.texture.tag, tech.secondaryTexture.tag, tech.animate);
			
			if (blendNormal.animate)
			{
				blendNormal.animate1OffsetX = tech.offsetX0;
				blendNormal.animate1OffsetY = tech.offsetY0;
				
				blendNormal.animate2OffsetX = tech.offsetX1;
				blendNormal.animate2OffsetY = tech.offsetY1;
			}
			else
			{
				blendNormal.water1OffsetX = tech.offsetX0;
				blendNormal.water1OffsetY = tech.offsetY0;
				
				blendNormal.water2OffsetX = tech.offsetX1;
				blendNormal.water2OffsetY = tech.offsetY1;
			}	
			
			mat.normalMethod = blendNormal;
		}
			
		protected function applyAlphaMapTechnique(mat:IPassMaterial, tech:Object):void
		{
			mat.addMethod(new AlphaMaskMethod(tech.texture));
			
			if (mat is ITranslucentMaterial)
			{
				ITranslucentMaterial(mat).alphaBlending = true;
				ITranslucentMaterial(mat).alphaThreshold = .5;
			}
		}
		
		protected function applyVertexColorTechnique(mat:IPassMaterial, tech:Object):void
		{
			mat.addMethod(new VertexColorMethod(tech.blendMode));
		}
		
		protected function readComposite(sea:SEAComposite):void
		{
			var diffuse:LayeredDiffuseMethod = new LayeredDiffuseMethod(),
				animation:Vector.<AnimationSet>,
				animationLayer:Vector.<LayeredTexture>;
			
			for(var i:int=0;i<sea.layer.length;i++)
			{
				var layer:Layer = sea.layer[i],				
					diffuseLayer:LayeredTexture = null;
				
				if (layer.texture)
				{
					diffuseLayer = new LayeredTexture(layer.texture.map.tag);				
					diffuseLayer.textureUVChannel = layer.texture.channel;
					
					if (layer.mask)
					{					
						diffuseLayer.mask = layer.mask.map.tag;
						diffuseLayer.maskUVChannel = layer.mask.channel;	
					}
					
					diffuseLayer.alpha = layer.opacity;
					diffuseLayer.blendMode = layer.blendMode;
					diffuseLayer.offsetU = layer.texture.offsetU;
					diffuseLayer.offsetV = layer.texture.offsetV;
					diffuseLayer.scaleU = layer.texture.scaleU;
					diffuseLayer.scaleV = layer.texture.scaleV;
					
					//
					//	Animations
					//
					
					for each(var anm:Object in layer.texture.animations)
					{
						if (!animation)
						{
							animation = new Vector.<AnimationSet>();
							animationLayer = new Vector.<LayeredTexture>();
						}
						
						animation.push( SEAAnimation(anm.tag).tag );
						animationLayer.push( diffuseLayer );
					}
					
					diffuse.addLayer(diffuseLayer);
				}
			}
			
			if (animation)
			{
				addAnimation(new LayeredDiffuseMethodAnimation(animation, animationLayer), sea.name, anm);
			}
			
			_composite ||= new Vector.<LayeredDiffuseMethod>();				
			_composite.push(object[sea.filename] = sea.tag = diffuse);
		}
				
		protected function readMorph(sea:SEAMorph):void
		{
			var morphs:Vector.<MorphNode> = new Vector.<MorphNode>(sea.node.length);
			 
			for(var i:int=0;i<morphs.length;i++)
			{
				var md:MeshData = sea.node[i];				 					
				morphs[i] = new MorphNode(md.name, md.vertex, md.normal);
			}
						
			var morph:MorphAnimationSet = new MorphAnimationSet(morphs, _config.forceCPU || _config.forceMorphCPU);
			
			_morphAnimationSet ||= new Vector.<MorphAnimationSet>();
			_morphAnimationSet.push(object[sea.filename] = sea.tag = morph);
		}
				
		protected function readMorphAnimation(sea:SEAMorphAnimation):void
		{
			var anmSet:AnimationSet = new AnimationSet();
						
			var node:AnimationNode, 
				anmData:Object,
				anmList:Array = sea.morph;
			
			for each(var seq:Object in sea.sequence)
			{
				node = new AnimationNode(seq.name, sea.frameRate, seq.count, seq.repeat, seq.intrpl);
				
				for each(anmData in anmList)
				{						
					node.addData( new AnimationData(anmData.kind, DataTable.FLOAT, anmData.data, seq.start) );						
				}
				
				anmSet.addAnimation( node );
			}
							
			_animationSet ||= new Vector.<AnimationSet>();
			_animationSet.push(object[sea.name + '.#anm'] = sea.tag = anmSet);
		}
		
		protected function readAnimation(sea:SEAAnimation):void
		{
			var anmSet:AnimationSet = new AnimationSet();
			
			var node:AnimationNode,
				anmData:Object,
				anmList:Array = sea.dataList;
					
			for each(var seq:Object in sea.sequence)
			{
				node = new AnimationNode(seq.name, sea.frameRate, seq.count, seq.repeat, seq.intrpl);
				
				for each(anmData in anmList)
				{						
					node.addData( new AnimationData(anmData.kind, anmData.type, anmData.data, seq.start * anmData.blockSize) );
				}
				
				anmSet.addAnimation( node );
			}
						
			_animationSet ||= new Vector.<AnimationSet>();
			_animationSet.push(object[sea.name + '.#anm'] = sea.tag = anmSet);
		}		
		
		protected function readSkeletonAnimation(sea:SEASkeletonAnimation):void
		{
			var data:Vector.<SkeletonClipNode> = new Vector.<SkeletonClipNode>();
						
			for each(var seq:Object in sea.sequence)		
			{
				var clip:SkeletonClipNode = new SkeletonClipNode();
				
				clip.name = seq.name;
				clip.looping = seq.repeat;
				clip.frameRate = sea.frameRate;
				
				var start:int = seq.start;
				var end:int = start + seq.count;
				
				for (var i:int=start;i<end;i++)
				{
					var pose:Array = sea.pose[i];
					var len:uint = pose.length;
					
					var sklPose:SkeletonPose = new SkeletonPose();			
					sklPose.jointPoses.length = len;
					
					for (var j:int=0;j<len;j++)
					{				
						var jointPose:JointPose = sklPose.jointPoses[j] = new JointPose();
						var jointData:Object = pose[j];
						
						jointPose.translation.x = jointData.x;
						jointPose.translation.y = jointData.y;
						jointPose.translation.z = jointData.z;
						
						jointPose.orientation.x = jointData.qx;
						jointPose.orientation.y = jointData.qy;
						jointPose.orientation.z = jointData.qz;
						jointPose.orientation.w = jointData.qw;
					}
					
					clip.addFrame(sklPose);				
				}
				
				data[data.length] = clip;
			}
						
			object[sea.name + '.skla'] = sea.tag = data;
		}	
		
		protected function readATFCubeTexture(sea:SEAATFCube):void
		{
			var cube:ATFCubeTexture = new ATFCubeTexture(sea.data);			
			cube.name = sea.name;	
			
			_cubemap ||= new Vector.<CubeTextureBase>();
			_cubemap.push(object[sea.name + '.cube'] = sea.tag = cube);
		}
		
		protected function readCubeTexture(sea:SEACubeMap):void
		{
			var cube:AsynBitmapCubeTexture = new AsynBitmapCubeTexture
				(
					sea.faces[1], 
					sea.faces[0],	
					sea.faces[3],
					sea.faces[2],
					sea.faces[5],
					sea.faces[4]
				);
			
			cube.name = sea.name;	
			
			_cubemap ||= new Vector.<CubeTextureBase>();
			_cubemap.push(object[sea.name + '.cube'] = sea.tag = cube);
		}
		
		protected function readSingleCubeTexture(sea:SEASingleCube):void
		{
			var cube:AsynSingleBitmapCubeTexture = new AsynSingleBitmapCubeTexture((sea as SEASingleCube).face);
			
			cube.name = sea.name;	
			
			_cubemap ||= new Vector.<BitmapCubeTexture>();
			_cubemap.push(object[sea.name + '.cube'] = sea.tag = cube);
		}
		
		protected function readATFTexture(sea:SEAATF):void
		{
			var tex:ATFTexture = new ATFTexture( sea.data );
			tex.name = sea.name;	
			
			_texture ||= new Vector.<Texture2DBase>();
			_texture.push(object[sea.name + '.tex'] = sea.tag = tex);	
		}
		
		protected function readTextureURL(sea:SEATextureURL):void
		{
			var tex:AsynBitmapTexture = new AsynBitmapTexture( sea.url );
			tex.name = sea.name;	
			
			_texture ||= new Vector.<Texture2DBase>();
			_texture.push(object[sea.name + '.tex'] = sea.tag = tex);	
		}
		
		protected function readBitmapTexture(sea:SEATexture):void
		{	
			var tex:AsynBitmapTexture = new AsynBitmapTexture( sea.data );
			tex.name = sea.name;	
			
			_texture ||= new Vector.<Texture2DBase>();
			_texture.push(object[sea.name + '.tex'] = sea.tag = tex);		
		}
		
		protected function readSprite3D(sea:SEAMesh2D):void
		{
			var sprite:Sprite3D = new Sprite3D(sea.material ? sea.material.tag : null, sea.width, sea.height);
			
			sprite.position = sea.position;
						
			_sprite3D ||= new Vector.<Sprite3D>();
			_sprite3D.push(object[sea.filename] = sprite);
			
			addSceneObject(sea, sprite);			
		}
				
		protected function readGeometry(sea:SEAGeometryData):void
		{
			var	geo:Geometry = new Geometry(),
				index:Vector.<uint>;
				
			geo.name = sea.name;
			
			if (sea.numVertex < 0xFFFE && !_config.forceCompactGeometry)
			{
				// skeleton
				if (sea.jointPerVertex > 0)
				{
					for each(index in sea.indexes)			
					{						
						var skinSubGeo:SkinnedSubGeometry = new SkinnedSubGeometry(sea.jointPerVertex);
						
						skinSubGeo.updateIndexData(index);					
						skinSubGeo.fromVectors
							(
								sea.vertex, 
								sea.uv && sea.uv.length > 0 ? sea.uv[0] : null, 
								sea.normal, 
								sea.tangent, 
								sea.uv && sea.uv.length > 1 ? sea.uv[1] : null
							);						
						
						skinSubGeo.arcane::updateJointIndexData(sea.joint);
						skinSubGeo.arcane::updateJointWeightsData(sea.weight);					
						
						geo.addSubGeometry(skinSubGeo);
					}	
				}
				else
				{
					for each(index in sea.indexes)			
					{
						var stdSubGeo:SubGeometry = new SubGeometry();
						
						stdSubGeo.updateIndexData(index);
						
						stdSubGeo.updateVertexData(sea.vertex);
						
						if (sea.uv) 
						{
							stdSubGeo.updateUVData(sea.uv[0]);
							if (sea.uv.length > 1) stdSubGeo.updateSecondaryUVData(sea.uv[1]);
						}
						else stdSubGeo.autoGenerateDummyUVs = true;
						
						if (sea.normal) stdSubGeo.updateVertexNormalData(sea.normal);
						else stdSubGeo.autoDeriveVertexNormals = true;
						
						if (sea.tangent) stdSubGeo.updateVertexTangentData(sea.tangent);
						else stdSubGeo.autoDeriveVertexTangents = true;
						
						geo.addSubGeometry(stdSubGeo);	
					}
				}
			}
			else
			{
				for each(index in sea.indexes)			
				{
					for each(var iGeo:ISubGeometry in GeomUtil.fromVectors
						(
							sea.vertex, 
							index, 
							sea.uv ? sea.uv[0] : null, 
							sea.normal, 
							sea.tangent, 
							sea.weight, 
							sea.joint, 
							sea.uv ? sea.uv[1] : null
						))
					{
						geo.addSubGeometry( iGeo );
					}
				}
			}
			
			sea.tag = geo;
		}
					
		protected function readMesh(sea:SEAMesh):void
		{	
			//
			//	Mesh
			//
			
			var mesh:Mesh = new Mesh(sea.geometry.tag); 
			
			mesh.transform = sea.transform;			
			mesh.castsShadows = sea.castShadow;
			
			//
			//	Material
			//
						
			if (sea.material)
			{	
				// single-material
				if (sea.material.length == 1)
				{
					mesh.material = sea.material[0].tag;
				}
				// multi-material
				else if (sea.geometry.tag.subGeometries.length == sea.material.length)
				{
					for(var i:int = 0; i < sea.material.length; i++) 
					{
						mesh.subMeshes[i].material = sea.material[i].tag;
					}
				}
			}
			else
			{
				mesh.material = null;
			}
			
			//
			//	Modifiers
			//
			
			var skeleton:Skeleton, morph:IMorphAnimator;
			
			for each(var mod:SEAModifier in sea.modifiers)
			{
				if (mod is SEASkeleton)
				{
					skeleton = (mod as SEASkeleton).tag;
				}									
				else if (mod is SEAMorph)
				{
					if (skeleton)
					{
						// CPU Morph Animation
						morph = new MorphGeometry( (mod as SEAMorph).tag, sea.geometry.tag );
						
						object[sea.name + '.mphg'] = morph; 
					}
					else
					{
						// GPU/CPU Morph Animation
						morph = new MorphAnimator( (mod as SEAMorph).tag );
						mesh.animator = morph as MorphAnimator;										
					}										
				}
			}
						
			//
			//	Animations
			//
			
			for each(var anm:Object in sea.animations)
			{
				var tag:IAnimator = anm.tag;
				
				if (tag is SEAUVWAnimation)
				{
					addAnimation(new TextureAnimation((tag as SEAUVWAnimation).tag, mesh), sea.name, anm);		
				}
				else if (tag is SEAAnimation)
				{
					addAnimation(new MeshAnimation(mesh, (tag as SEAAnimation).tag), sea.name, anm);		
				}
				else if (tag is SEASkeletonAnimation)
				{
					var sklAnm:SkeletonAnimator = new SkeletonAnimator
						(
							createSkeletonSet(tag as SEASkeletonAnimation, sea.geometry.jointPerVertex), 
							skeleton, 
							_config.forceCPU || _config.forceSkeletonCPU
						);
										
					if (_config.updateGlobalPose)
						SkeletonTools.poseFromSkeleton(sklAnm.globalPose, skeleton);
					
					mesh.animator = sklAnm;
					
					_skeletonAnimation ||= new Vector.<Mesh>();
					_skeletonAnimation.push(mesh);	
					
					addAnimation
					(
						new away3d.sea3d.animation.SkeletonAnimation(mesh.animator as SkeletonAnimator), 
						sea.name, anm
					);
				}
				else if (tag is SEAVertexAnimation)
				{
					mesh.animator = new VertexAnimator(createVertexAnimationSet(tag as SEAVertexAnimation, mesh.geometry));
					
					_vertexAnimation ||= new Vector.<Mesh>();
					_vertexAnimation.push(mesh);	
					
					addAnimation
					(										
						new VertexAnimation(mesh.animator as VertexAnimator),					
						sea.name, anm
					);
				}
				else if (tag is SEAMorphAnimation)
				{
					_morphAnimation ||= new Vector.<Mesh>();
					_morphAnimation.push(mesh);	
					
					addAnimation
					(
						new MorphAnimation(SEAMorphAnimation(tag).tag, morph),
						sea.name, anm
					);
				}
			}
			
			//
			//	Common
			//					
						
			_mesh ||= new Vector.<Mesh>();
			_mesh.push(object[sea.filename] = mesh);
			
			addSceneObject(sea, mesh);
		}				
										
		protected function readSkeleton(sea:SEASkeleton):away3d.animators.data.Skeleton
		{
			var skeleton:away3d.animators.data.Skeleton = new away3d.animators.data.Skeleton();			
			var joints:Array = sea.joint;
			
			for(var i:int=0;i<joints.length;i++)
			{
				var jointData:Object = joints[i];	
				
				var sklJoint:SkeletonJoint = skeleton.joints[i] = new SkeletonJoint();
				sklJoint.name = jointData.name;
				sklJoint.parentIndex = jointData.parentIndex;
				sklJoint.inverseBindPose = jointData.inverseBindMatrix;
			}
			
			_skeleton ||= new Vector.<away3d.animators.data.Skeleton>();
			_skeleton.push(object[sea.name + '.skl'] = sea.tag = skeleton);			
			
			return skeleton;
		}
		
		protected function readContainer3D(sea:SEAContainer3D):void
		{
			var container:ObjectContainer3D = new ObjectContainer3D();
			container.transform = sea.transform;
			
			addSceneObject(sea, container);
		}
		
		protected function readJointObject(sea:SEAJointObject):void
		{			
			var jointObj:JointObject = new JointObject(sea.target.tag, sea.joint, _config.autoUpdate);
			
			_jointObject ||= new Vector.<JointObject>();
			_jointObject.push(object[jointObj.name + '.jnt'] = sea.tag = jointObj);
						
			addSceneObject(sea, jointObj);
			
			if (_config.updateGlobalPose)
				jointObj.update();
		}
			
		protected function readCamera(sea:SEACamera, lens:LensBase):void
		{
			//
			// Lens
			//
			
			lens.near = _config.cameraNear;
			lens.far = _config.cameraFar;
			
			//
			//	Camera
			//
			
			var cam:Camera3D = new Camera3D(lens);
			
			cam.transform = sea.transform;
			
			//
			//	Animations
			//
			
			for each(var anm:Object in sea.animations)
			{
				var tag:IAnimator = anm.tag;
				
				if (tag is SEAAnimation)
				{
					addAnimation(new CameraAnimation(cam, (tag as SEAAnimation).tag), sea.name, anm);		
				}
			}
			
			//
			//	Common
			//											
			
			_camera ||= new Vector.<Camera3D>();
			_camera.push(object[sea.filename] = cam);	
			
			addSceneObject(sea, cam);
		}
		
		protected function readOrthographicCamera(sea:SEAOrthographicCamera):void
		{
			readCamera(sea, new OrthographicLens(1));
		}
		
		protected function readPerspectiveCamera(sea:SEAPerspectiveCamera):void
		{
			readCamera(sea, new PerspectiveLens(sea.fov));
		}
		
		protected function readPointLight(sea:SEAPointLight):void
		{
			var light:PointLight = new PointLight();
			
			light.position = sea.position;
			
			readLight
			(
				light, 
				sea.name, 
				sea.color, 
				sea.intensity
			);
									
			//
			//	Animations
			//
			
			for each(var anm:Object in sea.animations)
			{
				var tag:IAnimator = anm.tag;
				
				if (tag is SEAAnimation)
				{
					addAnimation(new PointLightAnimation(light, (tag as SEAAnimation).tag), sea.name, anm);		
				}
			}
			
			//
			//	Common
			//
			
			if (sea.attenuation)
			{
				light.radius = sea.attenuation.start;
				light.fallOff = sea.attenuation.end;				
			}			
			else
			{
				light.radius = 0xFFFFFFFF;
				light.fallOff = 0xFFFFFFFF;
			}
			
			addSceneObject(sea, light);
		}
		
		protected function readReference(sea:SEAReference):void
		{
			var context:AssetLoaderContext = new AssetLoaderContext();
			
			for each(var ref:Object in sea.refs)
			{
				context.mapUrlToData(ref.name, ref.data);
			}
			
			_reference ||=  new Vector.<AssetLoaderContext>();
			_reference.push(object[sea.name + '.refs'] = sea.tag = context);
		}
		
		protected function readDirectionalLight(sea:SEADirectionalLight):void
		{
			var light:DirectionalLight = new DirectionalLight();
			
			light.transform = sea.transform;
			
			readLight
			(
				light, 
				sea.name, 
				sea.color, 
				sea.intensity
			);
			
			//
			//	Animations
			//
			
			for each(var anm:Object in sea.animations)
			{
				var tag:IAnimator = anm.tag;
				
				if (tag is SEAAnimation)
				{
					addAnimation(new DirectionalLightAnimation((tag as SEAAnimation).tag, light), sea.name, anm);		
				}
			}
			
			//
			//	Common
			//									
				
			if (_config.enabledShadow && sea.shadow && !_shadow)
			{				
				// if not added in previous materials
				var applyShadow:Boolean = !_config.containsShadow;
				
				light.shadowMapper = _config.getShadowMapper();
				
				_shadow = _config.getShadowMapMethod(light);
				_shadow.alpha = sea.shadow.opacity;
				
				if ( applyShadow )
				{
					for each(var mat:IPassMaterial in _material)
					{
						mat.shadowMethod = _shadow;
					}
				}
			}
			
			addSceneObject(sea, light);
		}		
		
		protected function readLight(light:LightBase, name:String, color:int, intensity:Number):void
		{
			light.color = color;
			light.diffuse = intensity;
			light.specular = intensity;			
			
			light.ambientColor = 0xFFFFFF;
			light.ambient = 1;
			
			if (_config.addLightInPicker)
			{
				var picker:StaticLightPicker = _config.lightPicker;
				
				if (picker)
				{
					picker.lights.push(light)
					picker.lights = picker.lights;			
				}
			}
			
			_light ||=  new Vector.<LightBase>();
			_light.push(object[name + '.lht'] = light);
		}
				
		//
		//  Utils
		//
				
		sunag function createSkeletonSet(sea:SEASkeletonAnimation, jointPerVertex:int=4):SkeletonAnimationSet
		{
			if (sea.tag is SkeletonAnimationSet)
				return sea.tag;
			
			var sklClipList:Vector.<SkeletonClipNode> = sea.tag;
			
			var sklAnmSet:SkeletonAnimationSet = new SkeletonAnimationSet(jointPerVertex);
			sklAnmSet.name = sea.name;
			
			for(var i:int=0;i<sklClipList.length;i++)			
				sklAnmSet.addAnimation(sklClipList[i]);	
			
			_skeletonAnimationSet ||= new Vector.<SkeletonAnimationSet>();
			_skeletonAnimationSet.push(object[sea.name + '.#skl'] = sea.tag = sklAnmSet);
			
			return sklAnmSet;
		}
		
		sunag function createVertexAnimationSet(sea:SEAVertexAnimation, ref:Geometry):VertexAnimationSet
		{
			if (sea.tag)
				return sea.tag;
			
			var i:int = 0, 
				frames:Vector.<Geometry> = new Vector.<Geometry>(sea.frame.length),
				anmSet:VertexAnimationSet = new VertexAnimationSet();
			
			while (i < frames.length)
			{
				var frame:MeshData = sea.frame[i];				
				var geo:Geometry = new Geometry();
				
				for each(var refSG:SubGeometry in ref.subGeometries)
				{
					var frameSG:SubGeometry = new SubGeometry();
					
					frameSG.updateIndexData(refSG.indexData);
					
					frameSG.fromVectors
						(
							frame.vertex,
							refSG.UVData,
							frame.normal ? frame.normal : null,
							refSG.vertexTangentData,
							refSG.secondaryUVData
						);
					
					geo.addSubGeometry(frameSG);
				}	
				
				frames[i++] = geo;
			}
			
			for each(var seq:Object in sea.sequence)		
			{
				var clip:VertexClipNode = new VertexClipNode();
				
				clip.name = seq.name;
				clip.looping = seq.repeat;
				clip.frameRate = sea.frameRate;
				
				var start:int = seq.start;
				var end:int = seq.start + seq.count;
				
				for (var j:int=start;j<end;j++)			
					clip.addFrame(frames[j]);
				
				anmSet.addAnimation(clip);				
			}
			
			_vertexAnimationSet ||= new Vector.<VertexAnimationSet>();
			_vertexAnimationSet.push(object[sea.name + '.#vtx'] = sea.tag = anmSet);
			
			return anmSet;
		}
					
		sunag function addSceneObject(sea:SEAObject3D, obj3d:ObjectContainer3D):void
		{
			obj3d.name = sea.name;				
			
			if (sea.properties)			
				obj3d.extra = sea.properties.attribs;			
			
			if (sea.parent)
			{
				sea.parent.tag.addChild(obj3d);
			}
			else if (_config.container) _config.container.addChild(obj3d);			
			
			if (sea.isStatic && obj3d is Entity)
			{				
				Entity(obj3d).staticNode = true;
			}
			
			_object3d ||= new Vector.<ObjectContainer3D>();
			_object3d.push(object[sea.name + '.o3d'] = sea.tag = obj3d);
		}
		
		sunag function addAnimation(anm:Animation, name:String, config:Object):void
		{			
			anm._name = name;
									
			anm.autoUpdate = _config.autoUpdate;
			anm.blendMethod = _config.animationBlendMethod;
			
			anm.relative = config.relative;
			
			if (_config.player)	
				_config.player.addAnimation(anm);				
						
			_animation ||= new Vector.<Animation>();
			_animation.push(object[name + '.anm'] = anm);
		}			
		
		//
		//	Public Methods ( GET )
		//
			
		/**
		 * Global animation player  
		 */
		public function get player():IAnimationPlayer
		{
			return _config.player;
		}
				
		/**
		 * Root of all children of the scene.
		 */
		public function get container():*
		{
			return _config.container;
		}								
		
		/**
		 * Config object  
		 */
		public function get config():IConfig
		{
			return _config;
		}
							
		/**
		 * JointObject is any object attached to the skeleton of a model. As eyes on the head for example.
		 */
		public function get jointObjects():Vector.<JointObject>
		{
			return _jointObject;
		}
		
		/**
		 * Multi/Materials textures and advanced techniques of blend.
		 */
		public function get composites():Vector.<LayeredDiffuseMethod>
		{
			return _composite;
		}
		
		/**
		 * List of all animations of the SEA3D
		 */
		public function get animations():Vector.<Animation>
		{
			return _animation;			
		}		
		
		/**
		 * List of all shared animation (AnimationSet)
		 */
		public function get animationsSet():Vector.<AnimationSet>
		{
			return _animationSet;
		}	
		
		/**
		 * List of all skeletons
		 */
		public function get skeleton():Vector.<away3d.animators.data.Skeleton>
		{
			return _skeleton;
		}
		
		/**
		 * List of all shared skeleton animation
		 */
		public function get skeletonAnimationsSet():Vector.<SkeletonAnimationSet>
		{
			return _skeletonAnimationSet;
		}
		
		/**
		 * List of all shared vertex animation
		 */
		public function get vertexAnimationsSet():Vector.<VertexAnimationSet>
		{
			return _vertexAnimationSet;
		}
		
		/**
		 * List of all meshes containing skeleton animator 
		 */
		public function get skeletonAnimations():Vector.<Mesh>
		{
			return _skeletonAnimation;
		}
		
		/**
		 * List of all meshes containing morph animator 
		 */
		public function get morphAnimations():Vector.<Mesh>
		{
			return _morphAnimation;
		}
		
		/**
		 * List of all meshes containing vertex animator 
		 */
		public function get vertexAnimations():Vector.<Mesh>
		{
			return _vertexAnimation;
		}
		
		/**
		 * List of all lights
		 */
		public function get lights():Vector.<LightBase>
		{
			return _light;
		}
		
		/**
		 * List of all references
		 */
		public function get references():Vector.<AssetLoaderContext>
		{
			return _reference;
		}
		
		/**
		 * List of all textures
		 */
		public function get textures():Vector.<Texture2DBase>
		{
			return _texture;
		}

		/**
		 * List of all materials
		 */
		public function get materials():Vector.<MaterialBase>
		{
			return _material;
		}
		
		/**
		 * List of all cubemaps
		 */
		public function get cubemaps():Vector.<CubeTextureBase>
		{
			return _cubemap;
		}
		
		/**
		 * List of all meshes
		 */
		public function get meshes():Vector.<Mesh>
		{
			return _mesh;
		}
		
		/**
		 * List of all Sprite3D
		 */
		public function get sprites3D():Vector.<Sprite3D>
		{
			return _sprite3D;
		}
				
		/**
		 * List of all cameras
		 */
		public function get cameras():Vector.<Camera3D>
		{
			return _camera;
		}		
		
		/**
		 * List of all child contained in the SEA file (ObjectContainer3D)
		 * 
		 * @see #getObject3D()
		 */
		public function get objects3d():Vector.<ObjectContainer3D>
		{
			return _object3d;
		}
		
		/**
		 * Returns one Camera3D.		 
		 * Use <b>getAnimation</b> to get the camera animator.
		 * 
		* @param name Name of the object. Example:<b>Camera001</b>
		 * 
		 * @see #getAnimation()
		 * @see away3d.sea3d.animation.CameraAnimation
		 */		
		public function getCamera(name:String):Camera3D
		{
			return object[name + '.cam'];
		}
					
		/**
		 * Returns one Light.		 
		 * Use <b>getAnimation</b> to get the light animator.
		 * 
		 * @param name Name of the object. Example:<b>Light001</b>
		 * 
		 * @see #getAnimation()
		 * @see away3d.sea3d.animation.LightAnimationBase
		 */
		public function getLight(name:String):LightBase
		{
			return object[name + '.lht'];
		}
		
		/**
		 * Returns one CubeTextureBase.
		 * 
		 * @param name CubeMap slot name
		 */
		public function getCubeMap(name:String):CubeTextureBase
		{
			return object[name + '.cube'];
		}
			
		/**
		 * Returns one Texture2D.
		 * 
		 * @param name of the texture
		 */
		public function getTexture(name:String):Texture2DBase
		{
			return object[name + '.tex'];
		}
		
		/**
		 * Returns one Composite Texture in LayeredTexture.
		 * This texture may be of any slot, including Diffuse, Normal and Specular.
		 * 
		 * @param name Name of composite texture.
		 */
		public function getComposite(name:String):LayeredDiffuseMethod
		{
			return object[name + '.ctex'];
		}
		
		/**
		 * Get a material based on its name
		 * 
		 * @param name Material name
		 */
		public function getMaterial(name:String):MaterialBase
		{
			return object[name + '.mtl'];
		}
		
		/**
		 * Returns one Mesh.		 
		 * Use <b>getAnimation</b> to get the mesh animator.
		 * 
		 * @param name Name of the object. Example:<b>Box001</b>
		 * 
		 * @see #getAnimation()
		 * @see #morphAnimations
		 * @see #skeletonAnimations
		 * @see #vertexAnimations
		 * @see away3d.sea3d.animation.MeshAnimation
		 */
		public function getMesh(name:String):Mesh
		{
			return object[name + '.m3d'];
		}
		
		/**
		 * Returns one Animator.		 
		 * @return Returns a Animator. Base of all animation of the SEA3D.
		 */
		public function getAnimation(name:String):Animation
		{
			return object[name + '.anm'];
		}
		
		/**
		 * Returns one Single Layer TextureAnimation.		 
		 * @param textureName Texture name
		 */
		public function getTextureAnimation(textureName:String):TextureAnimation
		{
			return getAnimation(textureName) as TextureAnimation;
		}
		
		/**
		 * Returns one MultiLayer TextureAnimation.		 
		 * @param textureName Texture name		 
		 * @param index Layer of the texture
		 */
		public function getTextureLayeredAnimation(textureName:String, index:int=0):LayeredTextureAnimation
		{
			return getAnimation(textureName + ":" + index) as LayeredTextureAnimation;
		}
		
		/**
		 * Base of all animation objects by exception of dynamic mesh (e.g: SkeletonAnimation, VertexAnimation).	 
		 * @param name Typically the object name, material or texture
		 */
		public function getAnimationSet(name:String):AnimationSet
		{
			return object[name + '.#anm'];
		}
		
		/**
		 * Base of all MorphAnimation	 
		 ** @param name Typically the object name
		 */
		public function getMorphAnimationSet(name:String):MorphAnimationSet
		{
			return object[name + '.mph'];
		}
		
		/**
		 * Base of all CPU MorphAnimation. Typically Skeleton Morph Animation
		 * @param name Typically the object name
		 */
		public function getMorphGeometry(name:String):MorphGeometry
		{
			return object[name + '.mphg'];
		}
			
		/**
		 * Gets a child contained in the SEA file
		 * @param name Object name
		 */
		public function getObject3D(name:String):ObjectContainer3D
		{
			return object[name + '.o3d'];
		}
		
		/**
		 * Gets a Sprite3D
		 * @param name Object name
		 */
		public function getSprite3D(name:String):Sprite3D
		{
			return object[name + '.m2d'];
		}
		
		/**
		 * Base all takes skeleton animations	 
		 * @param name Typically the object Mesh name
		 */
		public function getSkeletonAnimationSet(name:String):SkeletonAnimationSet
		{
			return object[name + '.#skl'];
		}
				
		/**
		 * Get Skeleton Animations of a Mesh
		 * @param name Typically the object Mesh name
		 */
		public function getSkeletonAnimationNodes(name:String):Vector.<SkeletonClipNode>
		{
			return object[name + '.skla'];
		}			
		
		/**
		 * Base all takes vertex animations	 
		 * @param name Typically the object Mesh name
		 */
		public function getVertexAnimationSet(name:String):VertexAnimationSet
		{
			return object[name + '.#vtx'];
		}
		
		/**
		 * Skeleton of the Mesh object
		 * @param name Typically the object Mesh name
		 */
		public function getSkeleton(name:String):away3d.animators.data.Skeleton
		{
			return object[name + '.skl'];
		}
		
		/**
		 * JointObject is any object attached to the skeleton of a model. As eyes on the head for example.
		 * @param mesh Mesh name
		 * @param joint Joint name (Bone name)
		 */
		public function getJointObject(joint:String):JointObject
		{
			return object[joint + '.jnt'];
		}
								
		//
		//	System
		//
		
		override protected function reset():void
		{
			super.reset();
			
			_mesh =			
			_morphAnimation =
			_vertexAnimation =
			_skeletonAnimation = null;
			
			_camera = null;			
			_jointObject = null;
			_cubemap = null;
			_material = null;
			_texture = null;
			_skeleton = null;
			_skeletonAnimationSet = null;
			_vertexAnimationSet = null;
			_light = null;
			_composite = null;
			_morphAnimationSet = null;
			_sprite3D = null;
						
			_animationSet = null;
			_animation = null;
			_object3d = null;			
			_shadow = null;
		}
		
		public override function dispose():void
		{
			for each(var mesh:Mesh in _mesh) 
				mesh.dispose();
				
			for each(var s3d:Sprite3D in _sprite3D) 
				s3d.dispose();
				
			for each(var camera:Camera3D in _camera)
				camera.dispose();							
			
			for each(var joint:JointObject in _jointObject)
				joint.dispose();
				
			for each(var cubemap:CubeTextureBase in _cubemap)
				cubemap.dispose();
			
			for each(var material:MaterialBase in _material)
				material.dispose();		
			
			for each(var texture:Texture2DBase in _texture)
				texture.dispose();	
			
			for each(var skl:Skeleton in _skeleton)
				skl.dispose();
						
			for each(var sklAnm:SkeletonAnimationSet in _skeletonAnimationSet)
				sklAnm.dispose();	
			
			for each(var vtxAnm:VertexAnimationSet in _vertexAnimationSet)
				vtxAnm.dispose();									
				
			for each(var light:LightBase in _light)
				light.dispose();
			
			for each(var composite:LayeredDiffuseMethod in _composite)
				composite.dispose();
			
			for each(var morphAnmSet:MorphAnimationSet in _morphAnimationSet)
				morphAnmSet.dispose();						
						
			for each(var obj3d:ObjectContainer3D in _object3d)
				obj3d.dispose();									
				
			super.dispose();
		}								
	}
}