package sunag.sea3d.modules
{
	import sunag.sunag;
	import sunag.sea3d.objects.SEABox;
	import sunag.sea3d.objects.SEACapsule;
	import sunag.sea3d.objects.SEACarController;
	import sunag.sea3d.objects.SEACharacterController;
	import sunag.sea3d.objects.SEACollisionSensor;
	import sunag.sea3d.objects.SEACompound;
	import sunag.sea3d.objects.SEACone;
	import sunag.sea3d.objects.SEAConeTwistConstraint;
	import sunag.sea3d.objects.SEAConvexGeometry;
	import sunag.sea3d.objects.SEACylinder;
	import sunag.sea3d.objects.SEAHingeConstraint;
	import sunag.sea3d.objects.SEAP2PConstraint;
	import sunag.sea3d.objects.SEARigidBody;
	import sunag.sea3d.objects.SEASphere;
	import sunag.sea3d.objects.SEATriangleGeometry;

	use namespace sunag;
	
	public class PhysicsModuleBase extends ModuleBase
	{
		public function PhysicsModuleBase()
		{
			regClass(SEASphere);
			regClass(SEABox);			
			regClass(SEACone);
			regClass(SEACapsule);
			regClass(SEACylinder);
			regClass(SEATriangleGeometry);
			regClass(SEAConvexGeometry);
			regClass(SEACompound);
			
			regClass(SEAP2PConstraint);
			regClass(SEAHingeConstraint);
			regClass(SEAConeTwistConstraint);
			
			regClass(SEARigidBody);
			regClass(SEACollisionSensor);
			
			regClass(SEACharacterController);
			regClass(SEACarController);
		}
	}
}