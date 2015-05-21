package sunag.sea3d.objects
{
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	public class SEACollisionSensor extends SEAPhysics
	{
		public static const TYPE:String = "pcs";
		
		public function SEACollisionSensor(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
	}
}