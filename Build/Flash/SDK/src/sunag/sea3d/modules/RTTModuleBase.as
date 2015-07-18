package sunag.sea3d.modules
{
	import sunag.sea3d.objects.SEACubeRender;
	import sunag.sea3d.objects.SEAPlanarRender;
	import sunag.sunag;

	use namespace sunag;
	
	public class RTTModuleBase extends ModuleBase
	{
		public function RTTModuleBase()
		{						
			regClass(SEACubeRender);
			regClass(SEAPlanarRender);
		}
	}
}