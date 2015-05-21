package sunag.sea3d.modules
{
	import sunag.sunag;
	import sunag.sea3d.objects.SEAData;
	import sunag.sea3d.objects.SEAPoonyaScript;

	use namespace sunag;
	
	public class ScriptingModule extends ModuleBase
	{
		public function ScriptingModule()
		{
			regClass(SEAData);
			regClass(SEAPoonyaScript);
		}		
	}
}