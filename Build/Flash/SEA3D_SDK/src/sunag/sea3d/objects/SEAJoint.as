package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAJoint extends SEAObject
	{
		public static const TYPE:String = "bone";
		
		public function SEAJoint(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
	}
}