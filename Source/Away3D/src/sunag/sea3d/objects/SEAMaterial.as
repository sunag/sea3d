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

package sunag.sea3d.objects
{
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.utils.BlendMode;
	import sunag.utils.ByteArrayUtils;
	
	use namespace sunag;
	
	public class SEAMaterial extends SEAMaterialBase implements IAnimation
	{
		public static const TYPE:String = "mat";	
		
		public static const PHONG:uint = 0;
		public static const COMPOSITE_TEXTURE:uint = 1;
		public static const DIFFUSE_MAP:uint = 2;
		public static const SPECULAR_MAP:uint = 3;
		public static const REFLECTION:uint = 4;
		public static const REFRACTION:uint = 5;
		public static const NORMAL_MAP:uint = 6;
		public static const FRESNEL_REFLECTION:uint = 7;
		public static const RIM:uint = 8;		
		public static const LIGHT_MAP:uint = 9;
		public static const DETAIL_MAP:uint = 10;
		public static const CEL:uint = 11;
		public static const TRANSLUCENT:uint = 12;
		public static const BLEND_NORMAL_MAP:uint = 13;
		public static const MIRROR_REFLECTION:uint = 14;
		public static const AMBIENT_MAP:uint = 15;		
		public static const ALPHA_MAP:uint = 16;
		public static const EMISSIVE_MAP:uint = 17;
		public static const VERTEX_COLOR:uint = 18;
		public static const WRAP_LIGHTING:uint = 19;	
		public static const COLOR_REPLACE:uint = 20;
		public static const REFLECTION_SPHERICAL:uint = 21;
		public static const ANISOTROPIC:uint = 22;
		public static const EMISSIVE:uint = 23;
		public static const PHYSICAL:uint = 24;
		public static const ROUGHNESS_MAP:uint = 25;
		public static const METALNESS_MAP:uint = 26;
		public static const REFLECTIVITY:uint = 27;
		public static const CLEAR_COAT:uint = 28;
		public static const FLACCIDITY:uint = 29;
		
		public var animations:Array;				
		
		public var doubleSided:Boolean;
		public var repeat:Boolean;	
		
		public var depthWrite:Boolean;
		public var depthTest:Boolean;
		
		public var premultipliedAlpha:Boolean;
		
		public var alpha:Number = 1;	
		public var blendMode:String = BlendMode.NORMAL;
		
		public var receiveShadows:Boolean;
		public var receiveLights:Boolean;
		public var receiveFog:Boolean;
		
		public var technique:Array = [];	
		
		public function SEAMaterial(name:String, sea:SEA)
		{
			super(name, TYPE, sea);										
		}	
		
		override public function load():void
		{
			var attrib:uint = data.readUnsignedShort(),
				methodAttrib:uint;
			
			doubleSided = (attrib & 1) != 0;
			
			receiveLights = (attrib & 2) == 0;
			receiveShadows = (attrib & 4) == 0;
			receiveFog = (attrib & 8) == 0;
			
			repeat = (attrib & 16) == 0;
			
			if (attrib & 32)
				alpha = data.readFloat();
			
			if (attrib & 64)
				blendMode = ByteArrayUtils.readBlendMode(data);
			
			if (attrib & 128)
				animations = SEAAnimationBase.readAnimationList(data, sea);
			
			depthWrite = (attrib & 256) == 0;
			depthTest = (attrib & 512) == 0;
			
			premultipliedAlpha = (attrib & 1024) != 0;
			
			var count:int = data.readUnsignedByte();
			
			for (var i:int = 0; i < count;++i)
			{
				var kind:uint = data.readUnsignedShort();
				var size:uint = data.readUnsignedShort();				
				var pos:uint = data.position;
				var tech:Object;	
				
				switch(kind)
				{
					case PHONG:
						tech =
							{
								ambientColor:ByteArrayUtils.readUnsignedInt24(data),
								diffuseColor:ByteArrayUtils.readUnsignedInt24(data),
								specularColor:ByteArrayUtils.readUnsignedInt24(data),
								
								specular:data.readFloat(),
								gloss:data.readFloat()
							}
						break;
					case COMPOSITE_TEXTURE:						
						tech = diffuseMap =
							{
								composite:sea.getSEAObject(data.readUnsignedInt())							
							}
						break;
					case DIFFUSE_MAP:
					case SPECULAR_MAP:
					case NORMAL_MAP:
					case AMBIENT_MAP:
					case ALPHA_MAP:
					case EMISSIVE_MAP:
					case ROUGHNESS_MAP:						
					case METALNESS_MAP:	
						tech =
							{
								texture:sea.getSEAObject(data.readUnsignedInt())			
							}
							
						if (kind == DIFFUSE_MAP) diffuseMap = tech;
						
						break;
					case REFLECTION:
					case FRESNEL_REFLECTION:
						tech =
							{
								texture:sea.getSEAObject(data.readUnsignedInt()),
								alpha:data.readFloat()				
							}
						
						if (kind == FRESNEL_REFLECTION)
						{
							tech.power = data.readFloat();
							tech.normal = data.readFloat();
						}		
						break;
					case REFRACTION:
						tech =
							{
								texture:sea.getSEAObject(data.readUnsignedInt()),
								alpha:data.readFloat(),
								ior:data.readFloat()						
							}
						break;					
					case RIM:
						tech = 
							{
								color:ByteArrayUtils.readUnsignedInt24(data),
								strength:data.readFloat(),								
								power:data.readFloat(),			
								blendMode:ByteArrayUtils.readBlendMode(data)
							}
						break;	
					case LIGHT_MAP:
						tech = 
							{
								texture:sea.getSEAObject(data.readUnsignedInt()),
								channel:data.readUnsignedByte(),
								blendMode:ByteArrayUtils.readBlendMode(data)											
							}
						break;
					case DETAIL_MAP:
						tech = 
							{
								texture:sea.getSEAObject(data.readUnsignedInt()),
								scale:data.readFloat(),
								blendMode:ByteArrayUtils.readBlendMode(data)
							}
						break;
					case CEL:
						tech = 
							{
								color:ByteArrayUtils.readUnsignedInt24(data),
								levels:data.readUnsignedByte(),
								size:data.readFloat(),
								specularCutOff:data.readFloat(),
								smoothness:data.readFloat()						
							}
						break;	
					case TRANSLUCENT:
						tech = 
							{						
								translucency:data.readFloat(),
								scattering:data.readFloat()
							}
						break;
					case BLEND_NORMAL_MAP:
						methodAttrib = data.readUnsignedByte();  
						
						tech = 
							{						
								texture:sea.getSEAObject(data.readUnsignedInt()),
								secondaryTexture:sea.getSEAObject(data.readUnsignedInt())								
							};
						
						if (methodAttrib & 1)
						{
							tech.offsetX0 = data.readFloat();
							tech.offsetY0 = data.readFloat();
							
							tech.offsetX1 = data.readFloat();
							tech.offsetY1 = data.readFloat();
						}
						else
						{
							tech.offsetX0 = tech.offsetY0 = 							
							tech.offsetX1 = tech.offsetY1 = 0
						}
						
						tech.animate = methodAttrib & 2;	
						break;
					case MIRROR_REFLECTION:
						tech =
							{
								texture:sea.getSEAObject(data.readUnsignedInt()),
								alpha:data.readFloat()				
							}
						break;
					case VERTEX_COLOR:
						tech = 
							{	
								blendMode:ByteArrayUtils.readBlendMode(data)
							}
						break;	
					case WRAP_LIGHTING:
						tech = 
						{
							color:ByteArrayUtils.readUnsignedInt24(data),
							strength:data.readFloat()
						}
						break;
					case COLOR_REPLACE:	
						methodAttrib = data.readUnsignedByte();  
						
						tech = 
							{
								red:ByteArrayUtils.readUnsignedInt24(data),
								green:ByteArrayUtils.readUnsignedInt24(data),
								blue:ByteArrayUtils.readUnsignedInt24(data)
							}
						
						if (methodAttrib & 1)										
							tech.mask = sea.getSEAObject(data.readUnsignedInt());
						
						if (methodAttrib & 2)
							tech.alpha = data.readFloat();
						break;
					case REFLECTION_SPHERICAL:
						tech =
						{
							texture:sea.getSEAObject(data.readUnsignedInt()),
							alpha:data.readFloat()				
						}	
						break;
					case PHYSICAL:
						tech =
						{
							color:ByteArrayUtils.readUnsignedInt24(data),
							roughness:data.readFloat(),
							metalness:data.readFloat()
						}
						break;
					case REFLECTIVITY:	
						methodAttrib = data.readUnsignedByte(); 
						
						tech = 
						{
							strength:data.readFloat()
						}
						
						if (methodAttrib & 1)
							tech.mask = sea.getSEAObject(data.readUnsignedInt());
						break;
					case CLEAR_COAT:	
						tech =
						{
							strength:data.readFloat(),
							roughness:data.readFloat()
						}
						break;
					case FLACCIDITY:
						methodAttrib = data.readUnsignedByte(); 
						
						tech =
						{
							target:sea.getSEAObject(data.readUnsignedInt()),
							scale:data.readFloat(),
							spring:data.readFloat(),
							damping:data.readFloat()
						}
						
						if (methodAttrib & 1)
							tech.mask = sea.getSEAObject(data.readUnsignedInt());
						break;
					default:				
						trace("MaterialTechnique not found:", kind.toString(16));
						data.position = pos += size;
						continue;
						break;
				}
				
				/*if (data.position != pos + size)
					trace("MaterialTechnique invalid:", kind.toString(16));*/
				
				tech.kind = kind;
				
				technique.push(tech);								
				
				data.position = pos += size;
			}	
		}
	}
}