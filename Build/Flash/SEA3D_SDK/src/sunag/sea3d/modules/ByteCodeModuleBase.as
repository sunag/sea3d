package sunag.sea3d.modules
{
	import sunag.sunag;
	import sunag.sea3d.objects.SEAABC;

	use namespace sunag;
	
	public class ByteCodeModuleBase extends ModuleBase
	{
		public function ByteCodeModuleBase()
		{
			regClass(SEAABC);			
		}	
	}
}