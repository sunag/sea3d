package sunag.sea3d.modules
{
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	import awayphysics.collision.shapes.AWPCapsuleShape;
	import awayphysics.collision.shapes.AWPCollisionShape;
	import awayphysics.collision.shapes.AWPConeShape;
	import awayphysics.collision.shapes.AWPConvexHullShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.objects.SEABox;
	import sunag.sea3d.objects.SEACapsule;
	import sunag.sea3d.objects.SEACollisionSensor;
	import sunag.sea3d.objects.SEACone;
	import sunag.sea3d.objects.SEAGeometryShape;
	import sunag.sea3d.objects.SEARigidBody;
	import sunag.sea3d.objects.SEAShape;
	import sunag.sea3d.objects.SEASphere;
	import sunag.sea3d.objects.SEAStaticGeometryShape;

	use namespace sunag;
	
	public class PhysicsModule extends PhysicsModuleBase
	{
		protected var _cs:Vector.<AWPCollisionObject>;
		protected var _rb:Vector.<AWPRigidBody>;
		protected var _shape:Vector.<AWPCollisionShape>;	
		protected var _world:AWPDynamicsWorld;
		
		sunag var sea3d:SEA3D;
		
		public function PhysicsModule(world:AWPDynamicsWorld=null)
		{			
			regRead(SEABox.TYPE, readShape);					
			regRead(SEASphere.TYPE, readShape);
			regRead(SEACone.TYPE, readShape);
			regRead(SEACapsule.TYPE, readShape);
			regRead(SEAStaticGeometryShape.TYPE, readShape);
			regRead(SEAGeometryShape.TYPE, readShape);			
			
			regRead(SEARigidBody.TYPE, readRigidBody);
			regRead(SEACollisionSensor.TYPE, readCollisionSensor);
			
			//
			//	Physic World
			//
			
			_world = world;
		}
		
		public function set world(val:AWPDynamicsWorld):void
		{
			_world = val;
		}
		
		public function get world():AWPDynamicsWorld
		{
			return _world;
		}
		
		override sunag function reset():void
		{
			_rb = null;
			_shape = null;			
		}
		
		public function get shapes():Vector.<AWPCollisionShape>
		{
			return _shape;
		}
		
		public function get rigidBody():Vector.<AWPRigidBody>
		{
			return _rb;
		}
		
		public function get collisionSensor():Vector.<AWPCollisionObject>
		{
			return _cs;
		}
		
		protected function readRigidBody(sea:SEARigidBody):void
		{
			var rb:AWPRigidBody = new AWPRigidBody(sea.shape.tag, sea.target ? sea.target.tag : null, sea.mass);
			
			rb.friction = sea.friction;
			rb.restitution = sea.restitution;
			
			rb.linearDamping = sea.linearDamping;
			rb.angularDamping = sea.angularDamping;			
			
			rb.transform = sea.target ? sea.target.tag.transform : sea.transform;
			
			if (_world)
			{
				_world.addRigidBody(rb);
			}									
			
			_rb ||= new Vector.<AWPRigidBody>();
			_rb.push(this.sea.object[sea.filename] = sea.tag = rb);
		}
		
		protected function readCollisionSensor(sea:SEACollisionSensor):void
		{
			var cs:AWPCollisionObject = new AWPCollisionObject(sea.shape.tag, sea.target ? sea.target.tag : null);
			
			cs.transform = sea.target ? sea.target.tag.transform : sea.transform;
			
			if (_world)
			{
				_world.addCollisionObject(cs);
			}		
			
			_cs ||= new Vector.<AWPCollisionObject>();
			_cs.push(this.sea.object[sea.filename] = sea.tag = cs);
		}
		
		protected function readShape(sea:SEAShape):void
		{	
			var shape:AWPCollisionShape;
						
			if (sea is SEASphere)
			{
				var sph:SEASphere = sea as SEASphere;
				shape = new AWPSphereShape(sph.radius);
			}
			else if (sea is SEABox)
			{
				var box:SEABox = sea as SEABox;
				shape = new AWPBoxShape(box.width, box.height, box.depth);
			}
			else if (sea is SEACone)
			{
				var cone:SEACone = sea as SEACone;
				shape = new AWPConeShape(cone.radius, cone.height);
			}
			else if (sea is SEACapsule)
			{
				var cap:SEACapsule = sea as SEACapsule;
				shape = new AWPCapsuleShape(cap.radius, cap.height);
			}
			else if (sea is SEAGeometryShape)
			{
				var geo:SEAGeometryShape = sea as SEAGeometryShape;
				shape = new AWPConvexHullShape(geo.geometry.tag, geo.subGeometryIndex);
			}
			else if (sea is SEAStaticGeometryShape)
			{
				var staticGeo:SEAStaticGeometryShape = sea as SEAStaticGeometryShape;
				shape = new AWPBvhTriangleMeshShape(staticGeo.geometry.tag, staticGeo.subGeometryIndex, true);
			}
			
			_shape ||= new Vector.<AWPCollisionShape>();
			_shape.push(this.sea.object[sea.name + ".shpe"] = sea.tag = shape);
		}
		
		override public function dispose():void
		{						
			for each(var shape:AWPCollisionShape in _shape)
			{
				shape.dispose();
			}
			
			for each(var rb:AWPRigidBody in _rb)
			{
				rb.dispose();
			}	
			
			if (_world)
			{
				_world.cleanWorld();
			}
		}
				
		public function getRigidBody(name:String):AWPRigidBody
		{
			return sea.object[name + ".rb"];
		}
		
		public function getCollisionSensor(name:String):AWPCollisionObject
		{
			return sea.object[name + ".pcs"];
		}
		
		public function getShape(name:String):AWPCollisionShape
		{
			return sea.object[name + ".shpe"];
		}
		
		override sunag function init(sea:SEA):void
		{
			this.sea = sea;
			sea3d = sea as SEA3D;
		}
	}
}