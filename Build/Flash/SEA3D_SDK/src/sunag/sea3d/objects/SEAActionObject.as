package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAActionObject extends SEAObject
	{
		public static const TYPE:String = "acto";
		
		public function SEAActionObject(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}
	}
}