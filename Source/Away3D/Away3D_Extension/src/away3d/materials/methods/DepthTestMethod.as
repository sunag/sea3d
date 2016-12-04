package away3d.materials.methods
{
	import flash.display3D.Context3DCompareMode;
	
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;

	use namespace arcane;
	
	public class DepthTestMethod extends EffectMethodBase
	{
		public var depthTest:Boolean;
		public var compareMode:String;
		
		public function DepthTestMethod(depthTest:Boolean=false, compareMode:String=Context3DCompareMode.ALWAYS)
		{
			this.depthTest = depthTest;
			this.compareMode = compareMode;
		}
		
		arcane override function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			super.activate(vo, stage3DProxy);
						
			stage3DProxy._context3D.setDepthTest(depthTest, compareMode);
		}
		
		arcane override function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			return "";
		}
	}
}