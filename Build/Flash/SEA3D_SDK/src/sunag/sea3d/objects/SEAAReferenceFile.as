package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAAReferenceFile extends SEAObject
	{
		public static const TYPE:String = "reff";
		
		public function SEAAReferenceFile(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
	}
}