package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAShape extends SEAObject
	{
		public static const TYPE:String = "shpe";
		
		public function SEAShape(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}
	}
}