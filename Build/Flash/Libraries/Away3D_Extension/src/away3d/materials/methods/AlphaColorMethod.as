package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	
	use namespace arcane;
	
	public class AlphaColorMethod extends EffectMethodBase
	{
		/**
		 * @inheritDoc
		 */
		arcane override function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{				
			return "mov " + targetReg + ".xyz , " + targetReg + ".w \n";
		}
	}
}
