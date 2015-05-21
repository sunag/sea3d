package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;

	use namespace arcane;
	
	public class DummyEffectMethod extends EffectMethodBase
	{
		public var method:EffectMethodBase
		
		public function DummyEffectMethod(method:EffectMethodBase)
		{
			super();
			
			this.method = method;
		}
		
		override arcane function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			return '';
		}
	}
}