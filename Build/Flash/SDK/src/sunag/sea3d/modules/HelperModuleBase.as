package sunag.sea3d.modules
{
	import sunag.sea3d.objects.SEADummy;
	import sunag.sea3d.objects.SEALine;
	import sunag.sunag;

	use namespace sunag;
	
	public class HelperModuleBase extends ModuleBase
	{
		public function HelperModuleBase()
		{			
			regClass(SEALine);						
			regClass(SEADummy);
		}		
	}
}