package sunag.sea3d.modules
{
	import sunag.sea3d.objects.SEABox;
	import sunag.sea3d.objects.SEACapsule;
	import sunag.sea3d.objects.SEACollisionSensor;
	import sunag.sea3d.objects.SEACone;
	import sunag.sea3d.objects.SEAGeometryShape;
	import sunag.sea3d.objects.SEARigidBody;
	import sunag.sea3d.objects.SEASphere;
	import sunag.sea3d.objects.SEAStaticGeometryShape;
	import sunag.sunag;

	use namespace sunag;
	
	public class PhysicsModuleBase extends ModuleBase
	{
		public function PhysicsModuleBase()
		{
			regClass(SEASphere);
			regClass(SEABox);			
			regClass(SEACone);
			regClass(SEACapsule);
			regClass(SEAStaticGeometryShape);
			regClass(SEAGeometryShape);
			
			regClass(SEARigidBody);
			regClass(SEACollisionSensor);
		}
	}
}