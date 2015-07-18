package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;

	use namespace arcane;
	
	public class DynamicHemisphereLightMethod extends HemisphereLightMethod
	{
		public static const instance : DynamicHemisphereLightMethod = new DynamicHemisphereLightMethod();
		
		private var _enabled : Boolean = false;
		
		public function DynamicHemisphereLightMethod(color:uint = 0x99c4ff, groundColor:uint = 0x0f7fff, intensity:Number = .05)
		{
			super(color, groundColor, intensity);
		}
		
		override arcane function initVO(vo : MethodVO) : void
		{
			if (_enabled) 
				return super.initVO(vo);
		}
		
		override arcane function initConstants(vo : MethodVO) : void
		{
			if (_enabled) 
				return super.initConstants(vo);
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			if (_enabled) 
				return super.activate(vo, stage3DProxy);
		}
		
		arcane override function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			if (_enabled) return super.getFragmentCode(vo, regCache, targetReg);
			else return '';
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value) return;
			_enabled = value;
			invalidateShaderProgram();
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
	}
}