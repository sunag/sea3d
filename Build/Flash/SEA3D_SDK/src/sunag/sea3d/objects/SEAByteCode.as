package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAByteCode extends SEAObject
	{
		public static const TYPE:String = "bcode";
		
		public function SEAByteCode(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}
	}
}