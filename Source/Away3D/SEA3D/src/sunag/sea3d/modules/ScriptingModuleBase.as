package sunag.sea3d.modules
{
	import sunag.sunag;
	import sunag.sea3d.objects.SEAData;
	import sunag.sea3d.objects.SEAPoonyaScript;

	use namespace sunag;
	
	public class ScriptingModuleBase extends ModuleBase
	{
		public function ScriptingModuleBase()
		{
			regClass(SEAData);
			regClass(SEAPoonyaScript);
		}		
	}
}