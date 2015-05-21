package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAUVWAnimation extends SEAAnimation
	{
		public static const TYPE:String = "auvw";
		
		public function SEAUVWAnimation(name:String, sea:SEA)
		{
			super(name, sea, TYPE);
		}
	}
}