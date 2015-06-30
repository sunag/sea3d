/*
*
* Copyright (c) 2015 Sunag Entertainment
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
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.textures.Texture2DBase;
	
	use namespace arcane;
		
	public class ColorReplaceMethod extends BasicDiffuseMethod
	{
		private var _wrapDataRegister:ShaderRegisterElement;
		private var _wrapColorRegister:ShaderRegisterElement;
		private var _wrapFactor:Number;
		private var _factor:Number;
		
		private var _wrapColor:uint;
		private var _wrapColorR:Number;
		private var _wrapColorG:Number;
		private var _wrapColorB:Number;
		
		//--
		
		private var _red:uint;
		private var _redR:Number;
		private var _redG:Number;
		private var _redB:Number;
		
		private var _green:uint;
		private var _greenR:Number;
		private var _greenG:Number;
		private var _greenB:Number;
		
		private var _blue:uint;
		private var _blueR:Number;
		private var _blueG:Number;
		private var _blueB:Number;
		
		protected var _mask:Texture2DBase;
		
		protected var _enabledWrapLighting:Boolean = false;
		protected var _enabledColorReplace:Boolean = false;
		
		/**
		 * Creates a new ColorReplaceMethod.
		 */
		public function ColorReplaceMethod()
		{
			super();
			
			red = 0xFF0000;
			green = 0x00FF00;
			blue = 0x0000FF;
			
			wrapColor = 0;
			wrapFactor = .5;
			
			_enabledColorReplace = true;
		}
		
		public function set enabledWrapLighting(val:Boolean):void
		{
			if (_enabledWrapLighting == val) return;
			_enabledWrapLighting = val;
			invalidateShaderProgram();
		}
		
		public function get enabledWrapLighting():Boolean
		{
			return _enabledWrapLighting;
		}
		
		public function set enabledColorReplace(val:Boolean):void
		{
			if (_enabledColorReplace == val) return;
			_enabledColorReplace = val;
			invalidateShaderProgram();
		}
		
		public function get enabledColorReplace():Boolean
		{
			return _enabledColorReplace;
		}
		
		/**
		 * @inheritDoc
		 */
		arcane override function cleanCompilationData():void
		{
			super.cleanCompilationData();
			_wrapDataRegister = null;
			_wrapColorRegister = null;
		}
		
		/**
		 * @inheritDoc
		 */
		arcane override function getFragmentPreLightingCode(vo:MethodVO, regCache:ShaderRegisterCache):String
		{
			var code:String = super.getFragmentPreLightingCode(vo, regCache);
			
			if (_enabledWrapLighting)
			{
				_isFirstLight = true;
				_wrapDataRegister = regCache.getFreeFragmentConstant();
				_wrapColorRegister = regCache.getFreeFragmentConstant();
				
				vo.secondaryFragmentConstantsIndex = _wrapDataRegister.index*4;
			}
			
			return code;
		}
		
		/**
		 * @inheritDoc
		 */
		arcane override function getFragmentCodePerLight(vo:MethodVO, lightDirReg:ShaderRegisterElement, lightColReg:ShaderRegisterElement, regCache:ShaderRegisterCache):String
		{
			if (!_enabledWrapLighting)
				return super.getFragmentCodePerLight(vo, lightDirReg, lightColReg, regCache);
			
			var code:String = "";
			var t:ShaderRegisterElement;
			var c:ShaderRegisterElement;
			
			// write in temporary if not first light, so we can add to total diffuse colour
			if (_isFirstLight)
				t = _totalLightColorReg;							
			else {
				t = regCache.getFreeFragmentVectorTemp();
				regCache.addFragmentTempUsages(t, 1);
			}
			
			code += "dp3 " + t + ".x, " + lightDirReg + ".xyz, " + _sharedRegisters.normalFragment + ".xyz\n" +
				"add " + t + ".y, " + t + ".x, " + _wrapDataRegister + ".x\n" +
				"mul " + t + ".y, " + t + ".y, " + _wrapDataRegister + ".y\n" +
				"sat " + t + ".w, " + t + ".y\n" +
				"mul " + t + ".xz, " + t + ".w, " + lightDirReg + ".wz\n";
			
			if (_modulateMethod != null)
				code += _modulateMethod(vo, t, regCache, _sharedRegisters);									
			
			code += "mul " + t + ".xyz, " + t + ".x, " + lightColReg + "\n";
			
			//	APPLY COLOR
			c = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(c, 1);			
			code += "mul " + c + ".xyz, " + t + ".w, " + _wrapColorRegister + ".xyz\n";												
			code += "add " + t + ".xyz, " + t + ".xyz, " + c + ".xyz\n";
			regCache.removeFragmentTempUsage(c);
			// --
			
			if (!_isFirstLight) {								
				code += "add " + _totalLightColorReg + ".xyz, " + _totalLightColorReg + ".xyz, " + t + ".xyz\n";
				regCache.removeFragmentTempUsage(t);
			}
			
			_isFirstLight = false;
			
			return code;
		}
		
		/**
		 * The color
		 */
		public function get wrapColor():uint
		{
			return _wrapColor;
		}
		
		public function set wrapColor(value:uint):void
		{
			_wrapColor = value;
			_wrapColorR = ((value >> 16) & 0xff)/0xff;
			_wrapColorG = ((value >> 8) & 0xff)/0xff;
			_wrapColorB = (value & 0xff)/0xff;
		}
		
		/**
		 * A factor to indicate the amount by which the light is allowed to wrap.
		 */
		public function get wrapFactor():Number
		{
			return _wrapFactor;
		}
		
		public function set wrapFactor(value:Number):void
		{
			_wrapFactor = value;
			_factor = 1/(_wrapFactor + 1);
		}
		
		//--
		
		
		public function set mask(val:Texture2DBase):void
		{
			if (_mask == val) return;
			
			if (Boolean(_mask) != Boolean(val))
				invalidateShaderProgram();
		
			_mask = val;
		}
		
		public function get mask():Texture2DBase
		{
			return _mask;
		}
		
		public function get red():uint
		{
			return _red;
		}
		
		public function set red(val:uint):void
		{
			_red = val;
			_redR = ((val >> 16) & 0xff)/0xff;
			_redG = ((val >> 8) & 0xff)/0xff;
			_redB = (val & 0xff)/0xff;
		}
		
		public function get green():uint
		{
			return _green;
		}
		
		public function set green(val:uint):void
		{
			_green = val;
			_greenR = ((val >> 16) & 0xff)/0xff;
			_greenG = ((val >> 8) & 0xff)/0xff;
			_greenB = (val & 0xff)/0xff;
		}
		
		public function get blue():uint
		{
			return _blue;
		}
		
		public function set blue(val:uint):void
		{
			_blue = val;
			_blueR = ((val >> 16) & 0xff)/0xff;
			_blueG = ((val >> 8) & 0xff)/0xff;
			_blueB = (val & 0xff)/0xff;
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function getFragmentPostLightingCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			if (!_enabledColorReplace)
				return super.getFragmentPostLightingCode(vo, regCache, targetReg);
			
			var code:String = "";
			var albedo:ShaderRegisterElement;
			var cutOffReg:ShaderRegisterElement;
			
			// incorporate input from ambient
			if (vo.numLights > 0) {
				if (_shadowRegister)
					code += applyShadow(vo, regCache);
				albedo = regCache.getFreeFragmentVectorTemp();
				regCache.addFragmentTempUsages(albedo, 1);
			} else
				albedo = targetReg;
			
			if (_useTexture) {
				_diffuseInputRegister = regCache.getFreeTextureReg();
				vo.texturesIndex = _diffuseInputRegister.index;
				code += getTex2DSampleCode(vo, albedo, _diffuseInputRegister, _texture);
				if (_textureThreshold && _alphaThreshold > 0) {
					cutOffReg = regCache.getFreeFragmentConstant();
					vo.fragmentConstantsIndex = cutOffReg.index*4;
					code += "sub " + albedo + ".w, " + albedo + ".w, " + cutOffReg + ".x\n" +
						"kil " + albedo + ".w\n" +
						"add " + albedo + ".w, " + albedo + ".w, " + cutOffReg + ".x\n";
				}												
			} else {
				_diffuseInputRegister = regCache.getFreeFragmentConstant();
				vo.fragmentConstantsIndex = _diffuseInputRegister.index*4;
				code += "mov " + albedo + ", " + _diffuseInputRegister + "\n";
			}
			
			//
			//	COLOR REPLACE
			//
			
			var total:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(total, 1);
			
			var temp:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			regCache.addFragmentTempUsages(temp, 1);
			
			var redReg:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var greenReg:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var blueReg:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			
			if (_useTexture)
				vo.fragmentConstantsIndex = redReg.index*4;					
			
			// colors
			code += "mul " + total + ".xyz, " + redReg + ".xyz, " + albedo + ".x\n";	
			
			code += "mul " + temp + ".xyz, " + greenReg + ".xyz, " + albedo + ".y\n";
			code += "add " + total + ".xyz, " + total + ".xyz, " + temp + ".xyz\n";
			
			code += "mul " + temp + ".xyz, " + blueReg + ".xyz, " + albedo + ".z\n";
			code += "add " + total + ".xyz, " + total + ".xyz, " + temp + ".xyz\n";
			
			// mask
			if (_mask)
			{
				var maskReg:ShaderRegisterElement = regCache.getFreeTextureReg();
				
				code += getTex2DSampleCode(vo, temp, maskReg, _mask);
				
				code += "sub " + total + ".xyz, " + total + ".xyz, " + albedo + ".xyz\n";
				code += "mul " + total + ".xyz, " + total + ".xyz, " + temp + ".xyz\n";
				code += "add " + total + ".xyz, " + total + ".xyz, " + albedo + ".xyz\n";
				
				/* 
				// inv
				code += "sub " + albedo + ".xyz, " + albedo + ".xyz, " + total + ".xyz\n";
				code += "mul " + albedo + ".xyz, " + albedo + ".xyz, " + temp + ".xyz\n";
				code += "add " + total + ".xyz, " + albedo + ".xyz, " + total + ".xyz\n";
				*/
			}
			
			// apply
			code += "mov " + albedo + ".xyz, " + total + ".xyz\n";
			
			regCache.removeFragmentTempUsage(total);
			regCache.removeFragmentTempUsage(temp);
			
			if (vo.numLights == 0)
				return code;
			
			code += "sat " + _totalLightColorReg + ", " + _totalLightColorReg + "\n";
			
			if (_useAmbientTexture) {
				code += "mul " + albedo + ".xyz, " + albedo + ", " + _totalLightColorReg + "\n" +
					"mul " + _totalLightColorReg + ".xyz, " + targetReg + ", " + _totalLightColorReg + "\n" +
					"sub " + targetReg + ".xyz, " + targetReg + ", " + _totalLightColorReg + "\n" +
					"add " + targetReg + ".xyz, " + albedo + ", " + targetReg + "\n";
			} else {
				code += "add " + targetReg + ".xyz, " + _totalLightColorReg + ", " + targetReg + "\n";
				if (_useTexture) {
					code += "mul " + targetReg + ".xyz, " + albedo + ", " + targetReg + "\n" +
						"mov " + targetReg + ".w, " + albedo + ".w\n";
				} else {
					code += "mul " + targetReg + ".xyz, " + albedo + ", " + targetReg + "\n" +
						"mov " + targetReg + ".w, " + albedo + ".w\n";
				}
			}
			
			regCache.removeFragmentTempUsage(_totalLightColorReg);
			regCache.removeFragmentTempUsage(albedo);
			
			return code;
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			super.activate(vo, stage3DProxy);
			
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;			
			var secIndex:int = vo.secondaryFragmentConstantsIndex;
						
			if (_enabledWrapLighting)
			{
				data[secIndex] = _wrapFactor;
				data[secIndex + 1] = _factor;
				
				data[secIndex + 4] = _wrapColorR;
				data[secIndex + 5] = _wrapColorG;
				data[secIndex + 6] = _wrapColorB;
			}
			
			if (_enabledColorReplace)
			{
				if (_mask)
				{
					stage3DProxy._context3D.setTextureAt(vo.texturesIndex+1, _mask.getTextureForStage3D(stage3DProxy));
				}
				
				if (!_useTexture) 
					index += 4;
				
				data[index] = _redR;
				data[index + 1] = _redG;
				data[index + 2] = _redB;
				data[index + 3] = 1;
				
				data[index + 4] = _greenR;
				data[index + 5] = _greenG;
				data[index + 6] = _greenB;
				data[index + 7] = 1;
				
				data[index + 8] = _blueR;
				data[index + 9] = _blueG;
				data[index + 10] = _blueB;
				data[index + 11] = 1;
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
	}
}
