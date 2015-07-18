package sunag.sea3d.framework
{
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicNormalMethod;
	import away3d.materials.methods.BlendNormalMethod;
	import away3d.materials.methods.ColorReplaceMethod;
	import away3d.materials.methods.DetailMapMethod;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.EnvSphereMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.LightMapMethod;
	import away3d.materials.methods.PlanarReflectionMethod;
	import away3d.materials.methods.RefractionEnvMapMethod;
	import away3d.materials.methods.RimLightMethod;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.engine.SEA3DGPEvent;
	import sunag.sea3d.engine.TopLevel;
	import sunag.sea3d.objects.SEAMaterial;
	import sunag.sea3d.objects.SEAObject;
	import sunag.utils.BlendMode;
	
	use namespace sea3dgp;
	
	public class StandardMaterial extends Material
	{
		sea3dgp var cache:Boolean = SEA3DGP.config.cacheableMaterial;
		
		sea3dgp var fg:Boolean = true;
		sea3dgp var shadow:Boolean = true;
		sea3dgp var material:TextureMaterial;
		
		sea3dgp var diffuseTex:Texture;
		sea3dgp var specularTex:Texture;		
		sea3dgp var normalTex:Texture;
		sea3dgp var dtlTex:Texture;
		sea3dgp var secNormalTex:Texture;
		sea3dgp var lightMapTex:Texture;
		sea3dgp var refractionMap:CubeMap;
		sea3dgp var reflectionMap:CubeMap;
		sea3dgp var reflectionSphereMap:Texture;
		sea3dgp var fresnelReflectionMap:CubeMap;		
		sea3dgp var rttPlanar:RTTPlanar;
		sea3dgp var mk:Texture;
		
		sea3dgp var mLights:Array;
		sea3dgp var mPicker:StaticLightPicker;
		
		private var rimMethod:RimLightMethod;
		private var crMethod:ColorReplaceMethod;
		private var detailMethod:DetailMapMethod;
		private var lightMapMethod:LightMapMethod;
		private var refractionMethod:*;
		private var reflectionMethod:*;
		
		function StandardMaterial()
		{
			super(material = new TextureMaterial(null, true, true, true));
			
			material.lightPicker = SEA3DGP.lightPicker;
			
			material.autoWriteDepth = false;
			material.specular = 0;
			material.gloss = 50;
			material.specularColor = 0xFFFFFF; 
			material.ambientColor = 0x000000;
			material.color = 0xFFFFFF
			
			SEA3DGP.events.addEventListener(SEA3DGPEvent.INVALIDATE_MATERIAL, onInvalidate);			
		}
		
		//
		//	MATERIAL
		//
		
		public function set lights(val:Array):void
		{
			if (val && val.length)
			{
				var lightList:Array = [];
				var count:int = 0;
				
				for each(var light:Light in val)
				{
					lightList[count++] = light.scope;
				}
				
				if (!mPicker)
					mPicker = new StaticLightPicker(lightList);
				else				
					mPicker.lights = lightList;	
				
				// invalidate
				receiveLights = receiveLights;
			}
			else
			{
				mLights = null;
				mPicker = null;
			}
		}
		
		public function get lights():Array
		{
			return mLights || [];
		}
		
		public function set depthMask(val:Boolean):void
		{
			material.writeDepth = val;
		}
		
		public function get depthMask():Boolean
		{
			return material.writeDepth;
		}
		
		public function set fog(val:Boolean):void
		{
			fg = val;
			onInvalidate();
		}
		
		public function get fog():Boolean
		{
			return fg;
		}
		
		public function set receiveLights(val:Boolean):void
		{			
			material.lightPicker = val ? (mPicker || SEA3DGP.lightPicker) : null;
		}
		
		public function get receiveLights():Boolean
		{
			return material.lightPicker != null;
		}
		
		public function set receiveShadows(val:Boolean):void
		{
			shadow = val;
			onInvalidate();
		}
		
		public function get receiveShadows():Boolean
		{
			return shadow;
		}
		
		public function set doubleSided(val:Boolean):void
		{
			material.bothSides = val;
		}
		
		public function get doubleSided():Boolean
		{
			return material.bothSides;
		}
		
		public function set repeat(val:Boolean):void
		{
			material.repeat = val;
		}
		
		public function get repeat():Boolean
		{
			return material.repeat;
		}				
		
		public function set alpha(val:Number):void
		{
			material.alpha = val;
		}
		
		public function get alpha():Number
		{
			return material.alpha;
		}
		
		public function set blendMode(val:String):void
		{
			material.blendMode = val;
		}
		
		public function get blendMode():String
		{
			return material.blendMode;
		}
		
		//
		//	DEFAULT
		//
		
		public function set ambientColor(color:Number):void
		{			
			material.ambientColor = color;
		}
		
		public function get ambientColor():Number
		{
			return material.ambientColor;
		}
		
		public function set color(color:Number):void
		{			
			material.color = color;
		}
		
		public function get color():Number
		{
			return material.color;
		}
		
		public function set specularColor(color:Number):void
		{			
			material.specularColor = color;
		}
		
		public function get specularColor():Number
		{
			return material.specularColor;
		}
		
		public function set specular(intensity:Number):void
		{			
			material.specular = intensity;
		}
		
		public function get specular():Number
		{
			return material.specular;
		}
		
		public function set gloss(sheen:Number):void
		{			
			material.gloss = sheen;
		}
		
		public function get gloss():Number
		{
			return material.gloss;
		}
		
		//
		//	DIFFUSE MAP
		//
		
		public function set diffuseMap(tex:Texture):void
		{			
			if (tex && tex.transparent)
			{
				material.alphaBlending = true;
				material.alphaThreshold = SEA3DGP.config.alphaThreshold;
			}
			else
			{
				material.alphaBlending = false;
			}
			
			if ((diffuseTex = tex))
			{
				material.texture = diffuseTex.scope;
			}
			else material.texture = null;
		}
		
		public function get diffuseMap():Texture
		{
			return diffuseTex;
		}
		
		//
		//	SPECULAR MAP
		//
		
		public function set specularMap(tex:Texture):void
		{			
			if ((specularTex = tex))
			{
				material.specularMap = specularTex.scope;
			}
			else material.specularMap = null;
		}
		
		public function get specularMap():Texture
		{
			return specularTex;
		}
		
		//
		//	COLOR REPLACE
		//
		
		public function set colorReplace(val:Boolean):void
		{
			if (colorReplace == val) return;
			
			if (crMethod)
			{
				if (crMethod.enabledWrapLighting)
				{
					crMethod.enabledColorReplace = false;						
				}
				else
				{
					material.diffuseMethod = new BasicDiffuseMethod();
					
					crMethod.dispose();
					crMethod = null;
				}								
			}
						
			if (val)
			{
				if (crMethod)
				{
					crMethod.enabledColorReplace = true;
				}
				else
				{
					crMethod = new ColorReplaceMethod();
				}
				
				material.diffuseMethod = crMethod;
			}
		}
		
		public function get colorReplace():Boolean
		{
			return crMethod != null && crMethod.enabledColorReplace;
		}
		
		public function set red(val:Number):void
		{
			crMethod.red = val;
		}
		
		public function get red():Number
		{
			return crMethod.red;
		}
		
		public function set green(val:Number):void
		{
			crMethod.green = val;
		}
		
		public function get green():Number
		{
			return crMethod.green;
		}
		
		public function set blue(val:Number):void
		{
			crMethod.blue = val;
		}
		
		public function get blue():Number
		{
			return crMethod.blue;
		}
		
		public function set mask(val:Texture):void
		{
			mk = val;
			crMethod.mask = mk ? mk.scope : null;
		}
		
		public function get mask():Texture
		{			
			return mk;
		}
		
		//
		//	RIM
		//
		
		public function set rimBlendMode(blendMode:String):void
		{			
			if (blendMode)
			{
				if (rimMethod)
				{
					rimMethod.blendMode = blendMode;
				}
				else
				{
					rimMethod = new RimLightMethod(0x999999, .5, 2, blendMode);					
					
					onInvalidate();
				}
			}
			else if (rimMethod)
			{
				material.removeMethod( rimMethod );
				
				rimMethod.dispose();
				rimMethod = null;
				
				onInvalidate();
			}			
		}
		
		public function get rimBlendMode():String
		{
			return rimMethod ? rimMethod.blendMode : '';
		}
		
		public function set rimColor(color:Number):void
		{
			rimMethod.color = color;
		}
		
		public function get rimColor():Number
		{
			return rimMethod.color;
		}
		
		public function set rimStrength(strength:Number):void
		{
			rimMethod.strength = strength;
		}
		
		public function get rimStrength():Number
		{
			return rimMethod.strength;
		}
		
		public function set rimPower(power:Number):void
		{
			rimMethod.power = power;
		}
		
		public function get rimPower():Number
		{
			return rimMethod.power;
		}
		
		//
		//	WRAP LIGHTING
		//
		
		public function set enabledWrapLighting(val:Boolean):void
		{
			if (enabledWrapLighting == val) return;
			
			if (val)
			{
				if (!crMethod)
				{
					crMethod = new ColorReplaceMethod();
					crMethod.enabledColorReplace = false;
					crMethod.enabledWrapLighting = true;
				}
				else if (!crMethod.enabledWrapLighting)
				{
					crMethod.enabledWrapLighting = true;
				}
			}
			else
			{
				if (crMethod && !crMethod.enabledColorReplace)
				{
					material.diffuseMethod = new BasicDiffuseMethod();
					
					crMethod.dispose();
					crMethod = null;
				}
			}
		}
		
		public function get enabledWrapLighting():Boolean
		{
			return crMethod != null && crMethod.enabledWrapLighting;
		}
		
		public function set wrapStrength(val:Number):void
		{
			crMethod.wrapFactor = val;
		}
		
		public function get wrapStrength():Number
		{
			return crMethod.wrapFactor;
		}
		
		public function set wrapColor(val:Number):void
		{
			crMethod.wrapColor = val;
		}
		
		public function get wrapColor():Number
		{
			return crMethod.wrapColor;
		}
		
		//
		//	DETAIL MAP
		//
		
		public function set detailMap(tex:Texture):void
		{			
			if ((dtlTex = tex))
			{
				if (detailMethod)
				{
					detailMethod.texture = dtlTex.scope;
				}
				else
				{
					detailMethod = new DetailMapMethod(dtlTex.scope);
				}								
			}
			else if (detailMethod)
			{
				detailMethod.dispose();
				detailMethod = null;
			}
		}
		
		public function get detailMap():Texture
		{
			return dtlTex;
		}
		
		public function set detailMapScale(val:Number):void
		{
			detailMethod.scale = val;
		}
		
		public function get detailMapScale():Number
		{
			return detailMethod.scale;
		}
		
		//
		//	NORMAL MAP
		//
		
		public function set normalMap(tex:Texture):void
		{			
			if ((normalTex = tex))
			{
				material.normalMap = normalTex.scope;
			}
			else material.normalMap = null;
		}
		
		public function get normalMap():Texture
		{
			return normalTex;
		}
		
		//
		//	SECONDARY NORMAL MAP
		//
		
		public function set secondaryNormalMap(tex:Texture):void
		{
			material.normalMap = null;
			
			if ((secNormalTex = tex))
			{
				material.normalMethod = new BlendNormalMethod(normalTex.scope, secNormalTex.scope);
			}
			else material.normalMethod = new BasicNormalMethod();
		}
		
		public function get secondaryNormalMap():Texture
		{
			return secNormalTex;
		}
		
		//
		//	LIGHT MAP
		//
		
		public function set lightMap(tex:Texture):void
		{			
			if ((lightMapTex = tex))
			{
				if (!lightMapMethod) 
				{
					lightMapMethod = new LightMapMethod(lightMap.scope, BlendMode.MULTIPLY, true);
					
					onInvalidate();
				}	
				else
				{
					lightMapMethod.texture = lightMap.scope;
				}
			}
			else if (lightMapMethod)
			{
				lightMapMethod.dispose();
				lightMapMethod = null;		
				
				onInvalidate();
			}			
		}
		
		public function get lightMap():Texture
		{
			return lightMapTex;
		}
		
		public function set lightMapChannel(channel:Number):void
		{
			lightMapMethod.useSecondaryUV = channel > 0;
		}
		
		public function get lightMapChannel():Number
		{
			return int(lightMapMethod.useSecondaryUV);
		}
		
		public function set lightMapBlendMode(blendMode:String):void
		{
			lightMapMethod.blendMode = blendMode;
		}
		
		public function get lightMapBlendMode():String
		{
			return lightMapMethod.blendMode;
		}
		
		//
		//	REFRACTION
		//
		
		public function set refraction(cube:CubeMap):void
		{
			if ((refractionMap = cube))
			{
				if (refractionMethod && !(refractionMethod is RefractionEnvMapMethod))
				{
					refractionMethod.dispose();
					refractionMethod = null;
				}
				
				if (!refractionMethod) 
				{
					refractionMethod = new RefractionEnvMapMethod(reflectionMap.scope, 1.333);
					refractionMethod.alpha = .5;
					
					onInvalidate();
				}
				else
				{
					refractionMethod.envMap = reflectionMap.scope;									
				}				
			}
			else if (refractionMap is RefractionEnvMapMethod)
			{
				refractionMethod.dispose();
				refractionMethod = null;		
				
				onInvalidate();
			}
		}
		
		public function get refraction():CubeMap
		{
			return refractionMap;
		}
		
		public function set refractionAlpha(alpha:Number):void
		{
			refractionMethod.alpha = alpha;
		}
		
		public function get refractionAlpha():Number
		{
			return refractionMethod.alpha;
		}
		
		public function set refractionIOR(ior:Number):void
		{
			refractionMethod.refractionIndex = ior;
		}
		
		public function get refractionIOR():Number
		{
			return refractionMethod.refractionIndex;
		}
		
		public function set animateUVs(val:Boolean):void
		{
			material.animateUVs = val;		
		}
		
		public function get animateUVs():Boolean
		{
			return material.animateUVs;					
		}
		
		//
		//	REFLECTION
		//
		
		public function set reflectionSphere(tex:Texture):void
		{
			if ((reflectionSphereMap = tex))
			{
				if (reflectionMethod && !(reflectionMethod is EnvSphereMethod))
				{
					reflectionMethod.dispose();
					reflectionMethod = null;
				}
				
				if (!reflectionMethod) 
				{
					reflectionMethod = new EnvSphereMethod(reflectionSphereMap.scope, .5);
					
					onInvalidate();
				}
				else
				{
					reflectionMethod.envMap = reflectionSphereMap.scope;									
				}				
			}
			else if (reflectionMethod is EnvSphereMethod)
			{
				reflectionMethod.dispose();
				reflectionMethod = null;		
				
				onInvalidate();
			}
		}
		
		public function get reflectionSphere():Texture
		{
			return reflectionSphereMap;
		}
		
		public function set reflection(cube:CubeMap):void
		{
			if ((reflectionMap = cube))
			{
				if (reflectionMethod && !(reflectionMethod is EnvMapMethod))
				{
					reflectionMethod.dispose();
					reflectionMethod = null;
				}
				
				if (!reflectionMethod) 
				{
					reflectionMethod = new EnvMapMethod(reflectionMap.scope, .5);
					
					onInvalidate();
				}
				else
				{
					reflectionMethod.envMap = reflectionMap.scope;									
				}				
			}
			else if (reflectionMethod is EnvMapMethod)
			{
				reflectionMethod.dispose();
				reflectionMethod = null;		
				
				onInvalidate();
			}
		}
		
		public function get reflection():CubeMap
		{
			return reflectionMap;
		}
		
		public function set mirrorReflection(rtt:RTTPlanar):void
		{
			if ((rttPlanar = rtt))
			{
				if (reflectionMethod)
				{
					reflectionMethod.dispose();
					reflectionMethod = null;
				}
				
				reflectionMethod = new PlanarReflectionMethod(rttPlanar.planar);
			}
			else if (reflectionMethod is PlanarReflectionMethod)
			{
				reflectionMethod.dispose();
				reflectionMethod = null;
			}
		}
		
		public function get mirrorReflection():RTTPlanar
		{
			return rttPlanar;
		}
		
		public function set fresnelReflection(cube:CubeMap):void
		{
			if ((fresnelReflectionMap = cube))
			{
				if (reflectionMethod && !(reflectionMethod is FresnelEnvMapMethod))
				{
					reflectionMethod.dispose();
					reflectionMethod = null;
				}
				
				if (!reflectionMethod) 
				{
					reflectionMethod = new FresnelEnvMapMethod(fresnelReflectionMap.scope, .5);
					
					onInvalidate();
				}
				else
				{
					reflectionMethod.envMap = fresnelReflectionMap.scope;									
				}				
			}
			else if (reflectionMethod is FresnelEnvMapMethod)
			{
				reflectionMethod.dispose();
				reflectionMethod = null;		
				
				onInvalidate();
			}
		}
		
		public function get fresnelReflection():CubeMap
		{
			return fresnelReflectionMap;
		}
		
		public function set reflectionAlpha(alpha:Number):void
		{
			reflectionMethod.alpha = alpha;
		}
		
		public function get reflectionAlpha():Number
		{
			return reflectionMethod.alpha;
		}
		
		public function set reflectionPower(power:Number):void
		{
			reflectionMethod.fresnelPower = power;
		}
		
		public function get reflectionPower():Number
		{
			return reflectionMethod.fresnelPower;
		}
		
		public function set reflectionNormal(normal:Number):void
		{
			reflectionMethod.normalReflectance = normal;
		}
		
		public function get reflectionNormal():Number
		{
			return reflectionMethod.normalReflectance;
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	MATERIAL
			//
			
			var std:SEAMaterial = sea as SEAMaterial;
			
			alpha = std.alpha;
			
			depthMask = std.depthMask;
			blendMode = std.blendMode;
			
			fog = std.receiveFog;
			shadow = std.receiveShadows;						
			
			repeat = std.repeat;
			doubleSided = std.doubleSided;			
			receiveLights = std.receiveLights;
			
			for each(var tech:Object in std.technique)
			{
				switch(tech.kind)
				{
					case SEAMaterial.DEFAULT:
						material.ambientColor = tech.ambientColor;
						material.diffuseMethod.diffuseColor = tech.diffuseColor;
						material.specularColor = tech.specularColor;
						
						material.gloss = tech.gloss;
						material.specular = tech.specular;
						break;
					
					case SEAMaterial.DIFFUSE_MAP:							
						diffuseMap = tech.texture.tag;
						break;
					
					case SEAMaterial.SPECULAR_MAP:							
						specularMap = tech.texture.tag;
						break;
					
					case SEAMaterial.NORMAL_MAP:							
						normalMap = tech.texture.tag;
						break;
					
					case SEAMaterial.REFRACTION:	
						refraction = tech.texture.tag;
						refractionAlpha = tech.alpha;
						refractionIOR = tech.ior;
						break;
					
					case SEAMaterial.REFLECTION:
						reflection = tech.texture.tag;
						reflectionAlpha = tech.alpha;
						break;
					
					case SEAMaterial.FRESNEL_REFLECTION:
						fresnelReflection = tech.texture.tag;
						reflectionAlpha = tech.alpha;
						reflectionPower = tech.power;
						reflectionNormal = tech.normal;
						break;
					
					case SEAMaterial.RIM:							
						rimBlendMode = tech.blendMode;
						rimColor = tech.color;
						rimStrength = tech.strength;
						rimPower = tech.power;
						break;
					
					case SEAMaterial.LIGHT_MAP:							
						lightMap = tech.texture.tag;
						lightMapChannel = tech.channel;
						lightMapBlendMode = tech.blendMode;
						break;
					
					case SEAMaterial.MIRROR_REFLECTION:
						mirrorReflection = tech.texture.tag;
						reflectionAlpha = tech.alpha;						
						break;
					
					case SEAMaterial.BLEND_NORMAL_MAP:
						normalMap = tech.texture.tag;
						secondaryNormalMap = tech.secondaryTexture.tag;
						break;
					
					case SEAMaterial.DETAIL_MAP:
						detailMap = tech.texture.tag;	
						detailMapScale = tech.scale;
						break;
					
					case SEAMaterial.WRAP_LIGHTING:
						enabledWrapLighting = true;
						wrapStrength = tech.strength;
						wrapColor = tech.color;								
						break;
					
					case SEAMaterial.COLOR_REPLACE:
						colorReplace = true;
						red = tech.red;
						green = tech.green;
						blue = tech.blue;			
						if (tech.mask) mask = tech.mask.tag;
						break;
					
					case SEAMaterial.REFLECTION_SPHERICAL:
						reflectionSphere = tech.texture.tag;
						reflectionAlpha = tech.alpha;
						break;
					
					default:
						TopLevel.warn("Material Technique not found: ", tech.kind);
						break;
				}
			}
			
			onInvalidate();
		}
		
		//
		//	UPDATE
		//
		
		protected function onInvalidate(e:SEA3DGPEvent=null):void
		{
			while ( material.numMethods ) 
				material.removeMethod( material.getMethodAt( 0 ) );
			
			if (shadow && SEA3DGP.shadowLight && material.shadowMethod != SEA3DGP.shadowLight.shadowMapMethod)
				material.shadowMethod = SEA3DGP.shadowLight.shadowMapMethod;
			else if (material.shadowMethod && (!SEA3DGP.shadowLight || !shadow))
				material.shadowMethod = null;
			
			if (detailMethod)
				material.addMethod(detailMethod);
			
			if (reflectionMethod)
				material.addMethod(reflectionMethod);
			
			if (reflectionMethod)
				material.addMethod(reflectionMethod);
			
			if (lightMapMethod)
				material.addMethod(lightMapMethod);
			
			if (rimMethod)
				material.addMethod(rimMethod);
			
			if (fg && SEA3DGP.fogMtd)
				material.addMethod(SEA3DGP.fogMtd);
		}
		
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom(asset);
			
			var mat:StandardMaterial = asset as StandardMaterial;
			
			alpha = mat.alpha;
			receiveLights = mat.receiveLights;
			receiveShadows = mat.receiveShadows;
			fog = mat.fog;
			blendMode = mat.blendMode;
			depthMask = mat.depthMask;
			repeat = mat.repeat;
			doubleSided = mat.doubleSided;
			ambientColor = mat.ambientColor;
			color = mat.color;
			specularColor = mat.specularColor;
			specular = mat.specular;
			gloss = mat.gloss;
			
			diffuseMap = mat.diffuseMap;
			specularMap = mat.specularMap;
			normalMap = mat.normalMap;
			
			animateUVs = mat.animateUVs;
			
			if (enabledWrapLighting = mat.enabledWrapLighting)
			{
				wrapStrength = mat.wrapStrength;
				wrapColor = mat.wrapColor;				
			}
			
			if (colorReplace = mat.colorReplace)
			{
				red = mat.red;
				green = mat.green;
				blue = mat.blue;
				mask = mat.mask;
			}
			
			if (rimBlendMode = mat.rimBlendMode)
			{
				rimColor = mat.rimColor;
				rimStrength = mat.rimStrength;
				rimPower = mat.rimPower;
			}
			
			if (lightMap = mat.lightMap)
			{
				lightMapChannel = mat.lightMapChannel;
				lightMapBlendMode = mat.lightMapBlendMode;
			}
			
			if (refraction = mat.refraction)
			{
				refractionAlpha = mat.refractionAlpha;
				refractionIOR = mat.refractionIOR;
			}
			
			if (reflection = mat.reflection)
			{				
				reflectionAlpha = mat.reflectionAlpha;
			}
			
			if (fresnelReflection = mat.fresnelReflection)
			{
				reflectionAlpha = mat.reflectionAlpha;
				reflectionPower = mat.reflectionPower;
				reflectionNormal = mat.reflectionNormal;
			}
		}
		
		override public function clone(force:Boolean=false):Asset
		{
			var clone:StandardMaterial;
			
			if (cache && !force) 
				clone = this;
			else
			{
				clone = new StandardMaterial();
				clone.copyFrom(this);
			}
			
			return clone;	
		}
		
		override public function dispose():void
		{
			SEA3DGP.events.removeEventListener(SEA3DGPEvent.INVALIDATE_MATERIAL, onInvalidate);
			
			super.dispose();
		}
	}
}