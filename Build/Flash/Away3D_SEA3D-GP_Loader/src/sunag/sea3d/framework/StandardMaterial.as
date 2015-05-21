package sunag.sea3d.framework
{
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.FresnelEnvMapMethod;
	import away3d.materials.methods.LightMapMethod;
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
		sea3dgp var fg:Boolean = true;
		sea3dgp var shadow:Boolean = true;
		sea3dgp var material:TextureMaterial;
		
		sea3dgp var diffuseTex:Texture;
		sea3dgp var specularTex:Texture;
		sea3dgp var normalTex:Texture;
		sea3dgp var lightMapTex:Texture;
		sea3dgp var refractionMap:CubeMap;
		sea3dgp var reflectionMap:CubeMap;
		sea3dgp var fresnelReflectionMap:CubeMap;
		
		private var rimMethod:RimLightMethod;
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
			material.lightPicker = val ? SEA3DGP.lightPicker : null;
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
		
		public function set smooth(val:Boolean):void
		{
			material.smooth = val;
		}
		
		public function get smooth():Boolean
		{
			return material.smooth;
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
				material.alphaThreshold = .5;
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
				if (reflectionMethod && !(reflectionMethod is RefractionEnvMapMethod))
				{
					reflectionMethod.dispose();
					reflectionMethod = null;
				}
				
				if (!reflectionMethod) 
				{
					reflectionMethod = new RefractionEnvMapMethod(reflectionMap.scope, 1.333);
					reflectionMethod.alpha = .5;
					
					onInvalidate();
				}
				else
				{
					reflectionMethod.envMap = reflectionMap.scope;									
				}				
			}
			else if (refractionMap is RefractionEnvMapMethod)
			{
				reflectionMethod.dispose();
				reflectionMethod = null;		
				
				onInvalidate();
			}
		}
		
		public function get refraction():CubeMap
		{
			return refractionMap;
		}
		
		public function set refractionAlpha(alpha:Number):void
		{
			reflectionMethod.alpha = alpha;
		}
		
		public function get refractionAlpha():Number
		{
			return reflectionMethod.alpha;
		}
		
		public function set refractionIOR(ior:Number):void
		{
			reflectionMethod.refractionIndex = ior;
		}
		
		public function get refractionIOR():Number
		{
			return reflectionMethod.refractionIndex;
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
			
			if (shadow && !material.shadowMethod && SEA3DGP.shadowLight)
				material.shadowMethod = SEA3DGP.shadowLight.shadowMapMethod;
			else if (!shadow && material.shadowMethod)
				material.shadowMethod = null;
			
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
		
		override public function dispose():void
		{
			SEA3DGP.events.removeEventListener(SEA3DGPEvent.INVALIDATE_MATERIAL, onInvalidate);
			
			super.dispose();
		}
	}
}