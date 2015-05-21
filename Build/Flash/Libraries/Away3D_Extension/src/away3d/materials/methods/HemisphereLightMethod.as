package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.MethodVO;
	
	use namespace arcane;

	public class HemisphereLightMethod extends EffectMethodBase
	{
		private var _color:uint;
		private var _groundColor:uint;
		private var _colorR:Number;
		private var _colorG:Number;
		private var _colorB:Number;
		private var _groundColorR:Number;
		private var _groundColorG:Number;
		private var _groundColorB:Number;
		private var _intensity:Number;

		public function HemisphereLightMethod(color:uint = 0x99c4ff, groundColor:uint = 0x0f7fff, intensity:Number = .05)
		{
			_intensity = intensity
			
			this.color = color;
			this.groundColor = groundColor;
		}

		/**
		 * @inheritDoc
		 */
		override arcane function initConstants(vo:MethodVO):void
		{
			// const .5
			vo.fragmentData[vo.fragmentConstantsIndex + 7] = .5;
			// light direction (UP vector)
			vo.fragmentData[vo.fragmentConstantsIndex + 8] = 0;
			vo.fragmentData[vo.fragmentConstantsIndex + 9] = 1;
			vo.fragmentData[vo.fragmentConstantsIndex + 10] = 0;
			// const 0
			vo.fragmentData[vo.fragmentConstantsIndex + 11] = 0;
		}

		/**
		 * @inheritDoc
		 */
		override arcane function initVO(vo:MethodVO):void
		{
			vo.needsNormals = true;
			vo.needsView = true;
		}

		public function get color():uint
		{
			return _color;
		}
		
		public function set color(val:uint):void
		{
			_color = val;
			_colorR = ((_color >> 16) & 0xff)/0xff;
			_colorG = ((_color >> 8) & 0xff)/0xff;
			_colorB = (_color & 0xff)/0xff;
		}
		
		public function get groundColor():uint
		{
			return _groundColor;
		}
		
		public function set groundColor(val:uint):void
		{
			_groundColor = val;
			_groundColorR = ((_groundColor >> 16) & 0xff)/0xff;
			_groundColorG = ((_groundColor >> 8) & 0xff)/0xff;
			_groundColorB = (_groundColor & 0xff)/0xff;
		}

		public function get intensity():Number
		{
			return _intensity;
		}
		
		public function set intensity(val:Number):void
		{
			_intensity = val;
		}

		/**
		 * @inheritDoc
		 */
		arcane override function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			var index:int = vo.fragmentConstantsIndex;
			var data:Vector.<Number> = vo.fragmentData;
			data[index] = _colorR;
			data[index + 1] = _colorG;
			data[index + 2] = _colorB;
			data[index + 3] = _intensity;
			data[index + 4] = _groundColorR;
			data[index + 5] = _groundColorG;
			data[index + 6] = _groundColorB;			
		}

		/**
		 * @inheritDoc
		 */
		arcane override function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			var reg1:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var reg2:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var reg3:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var temp:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			var code:String = "";
			
			vo.fragmentConstantsIndex = reg1.index*4;
						
			//float dotProduct = dot( surfaceNormal.xyz, lightDir.xyz );
			code += "dp3 " + temp + ".w, " + _sharedRegisters.normalVarying + ".xyz, " + reg3 + ".xyz \n";			
			
			//float weight = 0.5 * dotProduct + 0.5;
			code += "mul " + temp + ".w, " + temp + ".w, " + reg2 + ".w \n";
			code += "add " + temp + ".w, " + temp + ".w, " + reg2 + ".w \n";					
			//code += "sat " + temp + ".w, " + temp + ".w \n";
						
			//vec3 lighting = mix(gnd, sky, weight)
			code += "mov " + temp + ".xyz, " + reg2 + ".xyz, \n";
			code += "sub " + temp + ".xyz, " + reg1 + ".xyz, " + temp + ".xyz \n";
			code += "mul " + temp + ".xyz, " + temp + ".xyz, " + temp + ".w \n";
			code += "add " + temp + ".xyz, " + temp + ".xyz, " + reg2 + ".xyz \n";
			
			//vec3 lighting = max( lighting * intensity, 0 );
			code += "mul " + temp + ".xyz, " + temp + ".xyz, " + reg1 + ".w \n";
			code += "sat " + temp + ".w, " + temp + ".w \n";
			//code += "max " + temp + ".xyz, " + temp + ".xyz, " + reg3 + ".w \n";						
			
			//color += lighting.xyz;
			code += "add " + targetReg + ".xyz, " + targetReg + ".xyz, " + temp + ".xyz \n";
			//code += "mov " + targetReg + ".xyz, " + temp + ".xyz, \n";
			
			return code;
		}
	}
}
