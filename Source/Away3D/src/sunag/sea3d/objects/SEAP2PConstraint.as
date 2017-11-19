package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;
	
	public class SEAP2PConstraint extends SEAConstraint
	{
		public static const TYPE:String = "p2pc";
		
		public function SEAP2PConstraint(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
	}
}