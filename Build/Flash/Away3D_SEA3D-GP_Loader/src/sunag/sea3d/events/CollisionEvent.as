package sunag.sea3d.events
{
	import flash.geom.Vector3D;
	
	import awayphysics.events.AWPEvent;
	
	import sunag.sea3dgp;
	import sunag.sea3d.framework.Physics;
	
	use namespace sea3dgp;
	
	public class CollisionEvent extends Event
	{
		public static const COLLISION:String = "collision";
		public static const COLLISION_OVER:String = "collisionOver";
		public static const COLLISION_OUT:String = "collisionOut";
		public static const RAY:String = "ray";
		
		sea3dgp var e:AWPEvent;
		
		public var collided:Physics;
		
		public function CollisionEvent(type:String, collided:Physics, e:AWPEvent=null)
		{
			super(type);
			
			this.e = e;
			this.collided = collided;
		}				
		
		public function get localA():Vector3D
		{
			return e.manifoldPoint.localPointA;
		}
		
		public function get worldB():Vector3D
		{
			return e.collisionObject.worldTransform.transform.transformVector(e.manifoldPoint.localPointB);
		}
		
		public function get localB():Vector3D
		{
			return e.manifoldPoint.localPointB;
		}
		
		public function get normalB():Vector3D
		{
			return e.manifoldPoint.normalWorldOnB;
		}
		
		public function get impulse():Number
		{
			return e.manifoldPoint.appliedImpulse;
		}
	}
}