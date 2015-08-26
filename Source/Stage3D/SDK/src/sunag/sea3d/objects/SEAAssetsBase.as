package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAAssetsBase extends SEAObject
	{
		public static const TYPE:String = "SEA";
		
		public function SEAAssetsBase(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}
	}
}