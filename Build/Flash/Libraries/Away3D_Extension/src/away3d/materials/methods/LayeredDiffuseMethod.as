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

package away3d.materials.methods
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.textures.Texture2DBase;
	
	use namespace arcane;
	
	public class LayeredDiffuseMethod extends BasicDiffuseMethod
	{
		private var _enabledOffset:Boolean = true;
		private var _enabledScale:Boolean = true;
		
		protected var _layers:Vector.<LayeredTexture> = new Vector.<LayeredTexture>();						
		protected var _layersData:Array;
				
		public function LayeredDiffuseMethod()
		{						
			super();
			validLayers();
		}
				
		override arcane function initVO(vo : MethodVO) : void
		{
			super.initVO(vo);			
			
			var multiUV:Boolean = false;
			
			for each(var layer:LayeredTexture in _layers)
			{
				if (layer.texture && layer.textureUVChannel > 0 || layer.mask && layer.maskUVChannel > 0)
				{
					multiUV = true;
				}												
			}
			
			vo.needsSecondaryUV = multiUV;
		}
		
		override arcane function initConstants(vo:MethodVO):void
		{
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;
			
			data[index] = 1;
			data[index+1] = .5;
		}
		
		public override function set texture(value:Texture2DBase):void
		{						
			if (_layers.length > 0)			
				super.texture = _layers[0].texture = value;			
			
			validLayers();
		}
				
		public function addLayer(layer:LayeredTexture):void
		{
			_layers.push(layer);
					
			layer.addEventListener(Event.CHANGE, onLayerChange);
			
			validLayers();
			validTextures();
			invalidateShaderProgram();
		}
		
		public function removeLayer(layer:LayeredTexture):void
		{											
			_layers.splice(_layers.indexOf(layer), 1);
			
			layer.removeEventListener(Event.CHANGE, onLayerChange);
			
			validLayers();
			validTextures();
			invalidateShaderProgram();
		}
		
		private function onLayerChange(e:Event):void
		{
			invalidateShaderProgram();
		}
		
		public function set layers(val:Vector.<LayeredTexture>):void
		{
			while(_layers.length) removeLayer(_layers[0]);
			
			for each(var layer:LayeredTexture in val)
			{
				addLayer(layer);
			}
		}
		
		public function get layers():Vector.<LayeredTexture>
		{
			return _layers;
		}
		
		public function cloneLayers():Vector.<LayeredTexture>
		{
			var layers:Vector.<LayeredTexture> = new Vector.<LayeredTexture>(_layers.length);
			
			for (var i:int = 0; i < layers.length; i++)
			{
				layers[i] = _layers[i].clone();
			}
			
			return layers;
		}
		
		private function validTextures():void
		{
			var texBase:Texture2DBase = _layers.length > 0 ? _layers[0].texture : null;
			
			_useTexture = texBase != null;
			
			if (texture != texBase) 
				texture = texBase;				
		}
		
		override public function copyFrom(method : ShadingMethodBase) : void
		{
			var diff : BasicDiffuseMethod = BasicDiffuseMethod(method);
			alphaThreshold = diff.alphaThreshold;
			diffuseAlpha = diff.diffuseAlpha;
			diffuseColor = diff.diffuseColor;
		}
		
		private function validLayers():void
		{
			if (_layers.length > 4) 
				throw new Error("More than 4 layers is not supported!");
		}
		
		public function set enabledOffset(value:Boolean):void
		{
			if (_enabledOffset == value) return;
			_enabledOffset = value;
			invalidateShaderProgram();
		}
		
		public function get enabledOffset():Boolean
		{
			return _enabledOffset;
		}
		
		public function set enabledScale(value:Boolean):void
		{
			if (_enabledScale == value) return;
			_enabledScale = value;
			invalidateShaderProgram();
		}
		
		public function get enabledScale():Boolean
		{
			return _enabledScale;
		}
		
		arcane override function getFragmentPostLightingCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			// Init
			_layersData = [];
			
			var layersDic:Dictionary = new Dictionary;
			
			var code : String = "";
			var target : ShaderRegisterElement;
			
			// incorporate input from ambient
			if (vo.numLights > 0) {
				if (_shadowRegister)
					code += "mul " + _totalLightColorReg + ".xyz, " + _totalLightColorReg + ".xyz, " + _shadowRegister + ".w\n";
				code += "add " + targetReg + ".xyz, " + _totalLightColorReg + ".xyz, " + targetReg + ".xyz\n" +
					"sat " + targetReg + ".xyz, " + targetReg + ".xyz\n";
				regCache.removeFragmentTempUsage(_totalLightColorReg);
				
				target = regCache.getFreeFragmentVectorTemp();
				regCache.addFragmentTempUsages(target, 1);
			}
			else
				target = targetReg;
			
			if (!_useTexture) 
				throw new Error("LayeredDiffuseMethod requires a diffuse texture!");
			
			// CreatTemp
			var temp : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp, 1);
			var temp2 : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();						
			regCache.addFragmentTempUsages(temp2, 1);			
			var blend : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(blend, 1);
			
			// Alpha					
			var constReg : ShaderRegisterElement = regCache.getFreeFragmentConstant();			
			var alphaReg : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			
			if (_enabledOffset)
			{
				var offsetUReg : ShaderRegisterElement = regCache.getFreeFragmentConstant();
				var offsetVReg : ShaderRegisterElement = regCache.getFreeFragmentConstant();
			}
			
			if (_enabledScale)
			{
				var scaleUReg : ShaderRegisterElement = regCache.getFreeFragmentConstant();
				var scaleVReg : ShaderRegisterElement = regCache.getFreeFragmentConstant();	
			}
			
			// Const
			var one : String = constReg + ".x";
			var half : String = constReg + ".y";
			
			var texReg : ShaderRegisterElement, maskReg : ShaderRegisterElement;
			
			vo.fragmentConstantsIndex = constReg.index*4;			
			
			// First Layer
			_diffuseInputRegister = regCache.getFreeTextureReg();		
			vo.texturesIndex = _diffuseInputRegister.index;
			
			// layers
			layersDic[_layers[0].texture] = _diffuseInputRegister;
			addLayerData(_diffuseInputRegister.index, _layers[0].texture);			
			
			var uvReg : ShaderRegisterElement;
			
			uvReg = _layers[0].textureUVChannel > 0 ? 
				_sharedRegisters.secondaryUVVarying : 
				_sharedRegisters.uvVarying;
			
			// First Layer Code
			code += "mov " + temp + ".zw , " + uvReg + ".zw\n";
			
			if (_enabledOffset)
			{
				code +=	"add " + temp + ".x , " + uvReg + ".x , " + offsetUReg + ".x\n" +
						"add " + temp + ".y , " + uvReg + ".y , " + offsetVReg + ".x\n";
			}
			else
			{
				code +=	"mov " + temp + ".xy , " + uvReg + ".xy\n";
			}
			
			if (_enabledScale)
				code += "mul " + temp + ".x , " + temp + ".x , " + scaleUReg + ".x\n" +
						"mul " + temp + ".y , " + temp + ".y , " + scaleVReg + ".x\n";
					
			code += getSplatSampleCode(vo, target, _diffuseInputRegister, temp, _layers[0].repeat);
									
			code += "mul " + target + ".w , " + target + ".w , " + alphaReg + ".x\n";						
			
			// alpha
			if (_layers[0].mask)
			{				
				uvReg = _layers[0].maskUVChannel > 0 ? 
					_sharedRegisters.secondaryUVVarying : 
					_sharedRegisters.uvVarying;
				
				if (!layersDic[_layers[0].mask])
				{
					layersDic[_layers[0].mask] = maskReg = regCache.getFreeTextureReg();
					addLayerData(maskReg.index, _layers[0].mask);									
				}
				else maskReg = layersDic[_layers[0].mask];
				
				code += getSplatSampleCode(vo, temp2, maskReg, uvReg, _layers[0].repeat) + 	
						"mul " + target + ".w , " + target + ".w , " + temp2 + ".x\n";								
			}
			
			var comps : Array = [ ".x",".y",".z",".w" ];
			for(var i:int=1;i<_layers.length;i++)
			{
				var layer:LayeredTexture = _layers[i];
												
				if (!layersDic[layer.texture])				
				{
					layersDic[layer.texture] = texReg = regCache.getFreeTextureReg();
					addLayerData(texReg.index, layer.texture);				
				}
				else texReg = layersDic[layer.texture];				
				
				uvReg = _layers[i].textureUVChannel > 0 ? 
					_sharedRegisters.secondaryUVVarying : 
					_sharedRegisters.uvVarying;
				
				if (_enabledOffset)
				{
					code += "add " + temp + ".x , " + uvReg + ".x , " + offsetUReg + comps[i] + "\n" +
							"add " + temp + ".y , " + uvReg + ".y , " + offsetVReg + comps[i] + "\n";
				}
				else
				{
					code +=	"mov " + temp + ".xy , " + uvReg + ".xy\n";
				}
				
				if (_enabledScale)
				{
					code +=	"mul " + temp + ".x , " + temp + ".x , " + scaleUReg + comps[i] + "\n" +
							"mul " + temp + ".y , " + temp + ".y , " + scaleVReg + comps[i] + "\n";
				}
						
				code += getSplatSampleCode(vo, blend, texReg, temp, layer.repeat);
						
				// Blending		
				if (layer.blendMode != LayeredTexture.NORMAL)
				{				
					var baseColor:ShaderRegisterElement, blendColor:ShaderRegisterElement,
						blendLum:String, baseLum:String, minRGB:String, maxRGB:String;
					
					// Reference
					// https://github.com/Barliesque/EasyAGAL/blob/master/src/com/barliesque/shaders/macro/Blend.as
					
					switch(layer.blendMode)
					{						
						case LayeredTexture.ADD:
							code += "add " + blend + ".xyz , " + blend + ".xyz , " + target + ".xyz\n";
							break;
						case LayeredTexture.SUBTRACT:
							code += "sub " + blend + ".xyz , " + target + ".xyz , " + blend + ".xyz\n";								
							break;	
						case LayeredTexture.DIFERENCE:
							code += "sub " + blend + ".xyz , " + blend + ".xyz , " + target + ".xyz\n";									
							break;	
						case LayeredTexture.MULTIPLY:
							code += "mul " + blend + ".xyz , " + blend + ".xyz , " + target + ".xyz\n";
							break;
						case LayeredTexture.DIVIDE:
							code += "div " + blend + ".xyz , " + target + ".xyz , " + blend + ".xyz\n";
							break;
						
						case LayeredTexture.DARKEN:
							code += "min " + blend + ".xyz , " + blend + ".xyz , " + target + ".xyz\n";
							break;
						case LayeredTexture.LIGHTEN:
							code += "max " + blend + ".xyz , " + blend + ".xyz , " + target + ".xyz\n";
							break;
						
						case LayeredTexture.COLORBURN:
							code += "sub " + temp + ".xyz , " + target + ".xyz , " + one + "\n" +									
									"add " + temp + ".xyz , " + temp + ".xyz , " + blend + ".xyz\n" +
									"div " + blend + ".xyz , " + temp + ".xyz , " + blend + ".xyz\n";
							break;											
						case LayeredTexture.LINEARBURN:
							code += "sub " + temp + ".xyz , " + target + ".xyz , " + one + "\n" +									
									"add " + blend + ".xyz , " + temp + ".xyz , " + blend + ".xyz\n";
							break;
						
						case LayeredTexture.SCREEN:
							code += "mul " + temp + ".xyz , " + blend + ".xyz , " + target + ".xyz\n" +									
									"sub " + temp + ".xyz , " + blend + ".xyz , " + temp + ".xyz\n" +
									"add " + blend + ".xyz , " + temp + ".xyz , " + target + ".xyz\n";
							break;
						
						case LayeredTexture.COLORDODGE:
							code += "sub " + temp + ".xyz , " + one + " , " + blend + ".xyz\n" +									
									"div " + blend + ".xyz , " + target + ".xyz , " + temp + ".xyz\n";									
							break;
						
						case LayeredTexture.LINEARLIGHT:
							code += "sub " + temp + ".xyz , " + target + ".xyz , " + one + "\n" +									
									"add " + temp + ".xyz , " + one + ".xyz , " + blend + ".xyz\n" +
									"add " + blend + ".xyz , " + temp + ".xyz , " + blend + ".xyz\n";									
							break;
						
						case LayeredTexture.SOFTLIGHT:
							// dest = ( Base - 2*Base*Blend + 2*Blend ) * Base
							code += "add " + temp + ".xyz , " + target + ".xyz , " + target + ".xyz\n" +									
									"mul " + temp + ".xyz , " + temp + ".xyz , " + blend + ".xyz\n" +
									"sub " + temp + ".xyz , " + target + ".xyz , " + temp + ".xyz\n" +
									"add " + temp + ".xyz , " + temp + ".xyz , " + blend + ".xyz\n" +
									"add " + temp + ".xyz , " + temp + ".xyz , " + blend + ".xyz\n" +
									"mul " + blend + ".xyz , " + temp + ".xyz , " + target + ".xyz\n";																
							break;
						
						/*case "fake-overlay":
						// High:  temp = 1 - ((1 - blend) * (1 - base) * 2)
						code += "sub " + temp2 + ".xyz , " + one + " , " + blend + ".xyz\n" +									
								"sub " + temp + ".xyz , " + one + " , " + target + ".xyz\n" +
								"mul " + temp2 + ".xyz , " + temp2 + ".xyz , " + temp + ".xyz\n" +
								"add " + temp2 + ".xyz , " + temp2 + ".xyz , " + temp2 + ".xyz\n" +
								"sub " + temp2 + ".xyz , " + one + " , " + temp2 + ".xyz\n" +
								
								// (source >= .5) = 1 or 0
								"sge " + temp + ".xyz , " + target + ".xyz , " + half + "\n" +
								// temp = 1 or 0
								"mul " + blend + ".xyz , " + temp2 + ".xyz , " + temp2 + ".xyz\n";*/
						
						case LayeredTexture.OVERLAY:
						case LayeredTexture.HARDLIGHT:	
							if (layer.blendMode == LayeredTexture.OVERLAY)
							{
								baseColor = target;
								blendColor = blend;
							}
							else
							{
								baseColor = blend;
								blendColor = target;
							}
							
							// High:  temp = 1 - ((1 - blend) * (1 - base) * 2)
							code += "sub " + temp2 + ".xyz , " + one + " , " + blendColor + ".xyz\n" +									
									"sub " + temp + ".xyz , " + one + " , " + baseColor + ".xyz\n" +
									"mul " + temp2 + ".xyz , " + temp2 + ".xyz , " + temp + ".xyz\n" +
									"add " + temp2 + ".xyz , " + temp2 + ".xyz , " + temp2 + ".xyz\n" +
									"sub " + temp2 + ".xyz , " + one + " , " + temp2 + ".xyz\n" +
						
									// (source >= .5) = 1 or 0
									"sge " + temp + ".xyz , " + baseColor + ".xyz , " + half + "\n" +
									// temp = 1 or 0
									"mul " + temp + ".xyz , " + temp2 + ".xyz , " + temp + ".xyz\n" +
							
							// Low:  temp2 = 2 * base * blend									
									"mul " + temp2 + ".xyz , " + blendColor + ".xyz , " + baseColor + ".xyz\n" +
									"add " + temp2 + ".xyz , " + temp2 + ".xyz , " + temp2 + ".xyz\n" +
									
									// (source < .5) = 1 or 0
									// temp.x = 1 or 0 
									// no slot avalible =S
									"slt " + temp2 + ".w , " + baseColor + ".x , " + half + "\n" +									
									"mul " + temp2 + ".x , " + temp2 + ".x , " + temp2 + ".w\n" +
									
									"slt " + temp2 + ".w , " + baseColor + ".y , " + half + "\n" +									
									"mul " + temp2 + ".y , " + temp2 + ".y , " + temp2 + ".w\n" +
									
									"slt " + temp2 + ".w , " + baseColor + ".z , " + half + "\n" +									
									"mul " + temp2 + ".z , " + temp2 + ".z , " + temp2 + ".w\n" +
							
							// High or Low?							
									// ...and combine results
									"add " + blend + ".xyz , " + temp + ".xyz , " + temp2 + ".xyz\n";						
							break;
						
						/*case "pinlight":
							// darken = min(base, 2*Blend);
							code += "add " + temp2 + ".xyz , " + blend + ".xyz , " + blend + ".xyz\n" +									
									"min " + temp2 + ".xyz , " + target + ".xyz , " + temp2 + ".xyz\n" +
									
									// (source >= .5) = 1 or 0
									"sge " + temp + ".xyz , " + baseColor + ".xyz , " + half + "\n" +
									// temp = 1 or 0
									"mul " + temp + ".xyz , " + temp2 + ".xyz , " + temp + ".xyz\n" +
									
									// lighten = max(base, 2*Blend-1)
									"add " + temp2 + ".xyz , " + blend + ".xyz , " + blend + ".xyz\n" +	
									"sub " + temp2 + ".xyz , " + temp2 + ".xyz , " + one + "\n" +
									"max " + temp2 + ".xyz , " + temp2 + ".xyz , " + target + ".xyz\n" +
									
									// (source < .5) = 1 or 0
									// temp.x = 1 or 0 
									// no slot avalible =S
									"slt " + temp2 + ".w , " + baseColor + ".x , " + half + "\n" +									
									"mul " + temp2 + ".x , " + temp2 + ".x , " + temp2 + ".w\n" +
									
									"slt " + temp2 + ".w , " + baseColor + ".y , " + half + "\n" +									
									"mul " + temp2 + ".y , " + temp2 + ".y , " + temp2 + ".w\n" +
									
									"slt " + temp2 + ".w , " + baseColor + ".z , " + half + "\n" +									
									"mul " + temp2 + ".z , " + temp2 + ".z , " + temp2 + ".w\n" +
									
									// High or Low?							
									// ...and combine results
									"add " + blend + ".xyz , " + temp + ".xyz , " + temp2 + ".xyz\n";
							break;*/
						
						case LayeredTexture.HARDMIX:
							code += "sub " + blend + ".xyz , " + one + " , " + blend + ".xyz\n" +
									"slt " + blend + ".xyz , " + blend + ".xyz , " + target + ".xyz\n";																											
							break;
						
						case LayeredTexture.AVERAGE:
							code += "add " + temp + ".xyz , " + blend + ".xyz , " + target + ".xyz\n" +
									"mul " + blend + ".xyz , " + temp + ".xyz , " + half + "\n";
							break;
						
						case LayeredTexture.REFLECT:
						case LayeredTexture.GLOW:
							if (layer.blendMode == LayeredTexture.REFLECT)
							{
								baseColor = target;
								blendColor = blend;
							}
							else
							{
								baseColor = blend;
								blendColor = target;
							}
							
							code += "mul " + temp + ".xyz , " + baseColor + ".xyz , " + baseColor + ".xyz\n" +
									"sub " + temp2 + ".xyz , " + one + " , " + blendColor + "\n" +
									"div " + blend + ".xyz , " + temp + ".xyz , " + temp2 + ".xyz\n";
							break;
						
						case LayeredTexture.NEGATION:
							code += "sub " + temp + ".xyz , " + one + " , " + target + ".xyz\n" +
									"sub " + temp + ".xyz , " + temp + ".xyz , " + blend + "\n" +
									"abs " + temp + ".xyz , " + temp + ".xyz\n" +
									"sub " + blend + ".xyz , " + one + " , " + temp + ".xyz\n";
							break;
						
						case LayeredTexture.GRAINEXTRACT:
							code += "sub " + temp + ".xyz , " + target + ".xyz , " + blend + ".xyz\n" +
									"add " + temp + ".xyz , " + temp + ".xyz , " + half + "\n";
							break;
						
						case LayeredTexture.EXCLUSION:
							code += "mul " + temp + ".xyz , " + blend + ".xyz , " + target + ".xyz\n" +
									"add " + temp + ".xyz , " + temp + ".xyz , " + temp + ".xyz\n" +
									"sub " + temp + ".xyz , " + blend + ".xyz , " + temp + ".xyz\n" +
									"add " + blend + ".xyz , " + temp + ".xyz , " + target + "\n";
							break;
						
						case LayeredTexture.PHOENIX:
							// dest = min(A,B) - max(A,B) + 1.0
							code += "min " + temp + ".xyz , " + blend + ".xyz , " + target + ".xyz\n" +
									"max " + temp2 + ".xyz , " + blend + ".xyz , " + target + ".xyz\n" +
									"sub " + temp + ".xyz , " + temp + ".xyz , " + temp2 + ".xyz\n" +
									"add " + blend + ".xyz , " + temp + ".xyz , " + one + "\n";
							break;
						
						case LayeredTexture.LIGHTERCOLOR:		
						case LayeredTexture.DARKERCOLOR: 
							blendLum = temp.toString() + ".x"; 
							baseLum = temp.toString() + ".y"; 
							minRGB = temp.toString() + ".z";
							maxRGB = temp.toString() + ".w";
							
							code += "min " + minRGB + " , " + blend + ".x , " + blend + ".y\n" +
									"min " + minRGB + " , " + minRGB + " , " + blend + ".z\n" +
									"max " + maxRGB + " , " + blend + ".x , " + blend + ".y\n" +
									"max " + maxRGB + " , " + maxRGB + " , " + blend + ".z\n" +									
									"add " + blendLum + " , " + minRGB + " , " + maxRGB + "\n" +
									
									"min " + minRGB + " , " + target + ".x , " + target + ".y\n" +
									"min " + minRGB + " , " + minRGB + " , " + target + ".z\n" +
									"max " + maxRGB + " , " + target + ".x , " + target + ".y\n" +
									"max " + maxRGB + " , " + maxRGB + " , " + target + ".z\n" +									
									"add " + baseLum + " , " + minRGB + " , " + maxRGB + "\n";
							
							if (layer.blendMode == LayeredTexture.LIGHTERCOLOR)
							{
								code += "slt " + temp2 + ".w , " + blendLum + " , " + baseLum + "\n" +
										"mul " + temp2 + ".xyz , " + blend + ".xyz , " + baseLum + ".w\n" +
										
										"sge " + temp + ".w , " + blendLum + " , " + baseLum + "\n" +
										"mul " + temp2 + ".xyz , " + target + ".xyz , " + temp + ".w\n";
							}
							else
							{
								code += "slt " + temp2 + ".w , " + blendLum + " , " + baseLum + "\n" +
										"mul " + temp2 + ".xyz , " + target + ".xyz , " + baseLum + ".w\n" +
										
										"sge " + temp + ".w , " + blendLum + " , " + baseLum + "\n" +
										"mul " + temp2 + ".xyz , " + blend + ".xyz , " + temp + ".w\n";
							}
									
							code += "mul " + temp2 + ".xyz , " + target + ".xyz , " + temp + ".xyz\n";									
							break;
					}
				}
				
				// alpha
				if (layer.mask)
				{
					if (!layersDic[layer.mask])				
					{
						layersDic[layer.mask] = maskReg = regCache.getFreeTextureReg();
						addLayerData(maskReg.index, layer.mask);				
					}
					else maskReg = layersDic[layer.mask];
					
					uvReg = _layers[i].maskUVChannel > 0 ? 
						_sharedRegisters.secondaryUVVarying : 
						_sharedRegisters.uvVarying;
					
					code += getSplatSampleCode(vo, temp2, maskReg, uvReg, layer.repeat) + 	
							"mul " + temp2 + ".x , " + temp2 + ".x , " + alphaReg + comps[i] + "\n";					
				}	
				else
				{
					code += "mov " + temp2 + ".x , " + alphaReg + comps[i] + "\n";
				}	
				
				code += "mul " + temp2 + ".x , " + temp2 + ".x , " + blend + ".w\n" +				
						"sub " + temp2 + ".y , " + one + " , " + temp2 + ".x\n"; // invert alpha
				
				// mix = invIntensity * backPixel + intensity * blendImg
				code += "mul " + blend + " , " + blend + " , " + temp2 + ".x\n" +
						"mul " + target + " , " + target + " , " + temp2 + ".y\n" + 						
						"add " + target + " , " + target + " , " + blend + "\n";
			}
			
			// RemoveTemp
			regCache.removeFragmentTempUsage(temp);	
			regCache.removeFragmentTempUsage(temp2);
			regCache.removeFragmentTempUsage(blend);	
			
			if (vo.numLights == 0)
				return code;
			
			code += "mul " + targetReg + ".xyz, " + target + ".xyz, " + targetReg + ".xyz\n" +
					"mov " + targetReg + ".w, " + target + ".w\n";
			
			regCache.removeFragmentTempUsage(target);
						
			return code;
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{									
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;
			
			for each(var tex:Object in _layersData)
			{
				stage3DProxy._context3D.setTextureAt(tex.index, tex.texture.getTextureForStage3D(stage3DProxy));
			}
			
			for (var i:int=0;i<_layers.length;i++)			
			{
				var offset:int = 0;
				
				data[index+(offset+=4)+i] = _layers[i].alpha;
				
				if (_enabledOffset)				
				{
					data[index+(offset+=4)+i] = _layers[i].offsetU;
					data[index+(offset+=4)+i] = _layers[i].offsetV;
				}
				
				if (_enabledScale)
				{
					data[index+(offset+=4)+i] = _layers[i].scaleU;
					data[index+(offset+=4)+i] = _layers[i].scaleV;				
				}																		
			}
		}
				
		protected function getSplatSampleCode(vo : MethodVO, targetReg : ShaderRegisterElement, inputReg : ShaderRegisterElement, uvReg : ShaderRegisterElement, repeat:Boolean = true) : String
		{
			// TODO: not used
			var wrap : String = repeat ? "wrap" : "clamp";
			var filter : String;
			
			if (vo.useSmoothTextures) filter = vo.useMipmapping ? "linear,miplinear" : "linear";
			else filter = vo.useMipmapping ? "nearest,mipnearest" : "nearest";
			
			return "tex " + targetReg + ", " + uvReg + ", " + inputReg + " <2d," + filter + "," + wrap + ">\n";
		}
		
		private function addLayerData(index:int, texture:Texture2DBase):void
		{
			_layersData.push({index:index, texture:texture});
		}
	}
}