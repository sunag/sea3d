package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAPrimitive extends SEAGeometryBase
	{
		public static const TYPE:String = "prim";
		
		public function SEAPrimitive(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}
	}
}