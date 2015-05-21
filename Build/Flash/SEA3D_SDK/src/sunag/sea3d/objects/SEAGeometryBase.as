package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;

	public class SEAGeometryBase extends SEAObject
	{
		public static const TYPE:String = "geom";
		
		public static var JOINT_STRIDE:uint = 3;
						
		public var numVertex:uint = 0;
		public var jointPerVertex:uint = 0;
		
		public var isBig:Boolean = false;				
		
		public function SEAGeometryBase(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}	
	}
}