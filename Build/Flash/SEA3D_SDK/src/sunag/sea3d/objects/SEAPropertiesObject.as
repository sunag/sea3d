package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAPropertiesObject extends SEAObject
	{
		public static const TYPE:String = "pobj";
		
		public function SEAPropertiesObject(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}
	}
}