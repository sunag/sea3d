/**
 * @about: http://www.max-did-it.com/index.php/2013/07/11/properly-rendering-x-ray-silhouette-effect-in-away-3d/
 * */
package away3d.materials.methods
{
	import flash.display3D.Context3DCompareMode;
	
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;

	use namespace arcane;
	
	public class XRayMethod extends EffectMethodBase
	{
		// Member Fields
		
		private var _xrayColor:uint;
		
		private var _xrayR:Number = 0;
		private var _xrayG:Number = 0;
		private var _xrayB:Number = 0;
		private var _xrayA:Number = 1;
		
		// Member Property
		
		public function get xrayColor():uint
		{
			return _xrayColor;
		}
		
		public function set xrayColor(value:uint):void
		{
			_xrayColor = value;
			updateXray();
		}
		
		public function get xrayAlpha():Number
		{
			return _xrayA;
		}
		
		public function set xrayAlpha(value:Number):void
		{
			_xrayA = value;
		}
		
		// Member Functions
		
		arcane override function activate(vo:MethodVO, 
										  stage3DProxy:Stage3DProxy):void
		{
			super.activate(vo, stage3DProxy);
			
			var index:int = vo.fragmentConstantsIndex;
			var data:Vector.<Number> = vo.fragmentData;
			data[index] = _xrayR;
			data[index + 1] = _xrayG;
			data[index + 2] = _xrayB;
			data[index + 3] = _xrayA;
			
			stage3DProxy._context3D.setDepthTest(false,
				Context3DCompareMode.GREATER);
		}
		
		arcane override function getFragmentCode(vo:MethodVO,
												 regCache:ShaderRegisterCache,
												 targetReg:ShaderRegisterElement):String
		{
			var code:String = "";
			var output:ShaderRegisterElement = targetReg;
			
			var xrayInputRegister:ShaderRegisterElement
			= regCache.getFreeFragmentConstant();
			vo.fragmentConstantsIndex
				= xrayInputRegister.index * 4;
			code += "mov " + output + ", "
				+ xrayInputRegister + "\n";
			
			return code;
		}
		
		private function updateXray():void
		{
			_xrayR = ((_xrayColor >> 16) & 0xff) / 0xff;
			_xrayG = ((_xrayColor >> 8) & 0xff) / 0xff;
			_xrayB = (_xrayColor & 0xff) / 0xff;
		}
		
	}
}