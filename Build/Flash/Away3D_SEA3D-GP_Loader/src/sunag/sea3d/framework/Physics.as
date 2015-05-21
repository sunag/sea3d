package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.events.AWPEvent;
	
	import sunag.sea3dgp;
	import sunag.sea3d.events.CollisionEvent;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAPhysics;

	use namespace sea3dgp;
	
	public class Physics extends Asset
	{
		sea3dgp static const TYPE:String = 'Physic/';				
		
		sea3dgp var scope:AWPCollisionObject;	
		
		sea3dgp var tar:Object3D;
		sea3dgp var sp:Shape;
		sea3dgp var collision:Physics;
		sea3dgp var cls:Boolean;
		sea3dgp var clsAdded:Boolean;
		sea3dgp var clsCallback:Boolean;
		sea3dgp var cback:Boolean;
		
		public function Physics()
		{
			super(TYPE);	
		}				
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	PHYSICS
			//
			
			var physic:SEAPhysics = sea as SEAPhysics;				
			
			if (physic.transform)
			{
				scope.transform = physic.transform;
			}
			else
			{
				target = physic.tag;
			}
		}
				
		public function get collided():Physics
		{
			return collision;
		}
		
		public function set target(val:Object3D):void
		{
			tar = val;
			scope.skin = val ? val.scope : null;
		}
		
		public function get target():Object3D
		{
			return tar;
		}
			
		public function set shape(val:Shape):void
		{
			sp = val;
		}
		
		public function get shape():Shape
		{
			return sp;
		}
		
		public function set callback(val:Boolean):void
		{
			cback = val;
			updateCallback();
		}
		
		public function get callback():Boolean
		{
			return cback;
		}
		
		protected function updateCallback():void
		{
			if (cback)
			{
				scope.addEventListener(AWPEvent.COLLISION_ADDED, onCollision, false, 0, true);
				scope.addEventListener(AWPEvent.RAY_CAST, onRay, false, 0, true);
			}
			else
			{
				scope.removeEventListener(AWPEvent.COLLISION_ADDED, onCollision);
				scope.removeEventListener(AWPEvent.RAY_CAST, onRay);
			}
		}
		
		protected function onCollision(e:AWPEvent):void
		{						
			var phy:Physics = e.collisionObject.extra as Physics;
			
			cls = true;
			
			if (collision != phy)
			{
				var c:Physics = collision;
				
				collision = phy;
				
				if (collision)
				{
					dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_OUT, c));
				}
				
				if (phy && eDict[CollisionEvent.COLLISION_OVER])
				{
					dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_OVER, phy, e));
				}
			}
			
			if (eDict[CollisionEvent.COLLISION])
			{
				dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION, phy, e));
			}
			
			if (!clsAdded)
			{
				_scene.collided.push( this );
				
				clsAdded = true;				
			}
		}
		
		protected function onRay(e:AWPEvent):void
		{
			if (eDict[CollisionEvent.RAY])
			{			
				dispatchEvent(new CollisionEvent(CollisionEvent.RAY, e.collisionObject.extra as Physics, e));
			}
		}
		
		//
		//	RAY
		//
		
		public function addRay(from:Vector3D, to:Vector3D):void
		{
			scope.addRay(from, to);
		}
		
		public function removeAllRays():void
		{
			scope.removeAllRays();
		}
		
		//
		//	TRANSFORM
		//
		
		public function set position(val:Vector3D):void
		{
			scope.position = val;			
		}
		
		public function get position():Vector3D
		{
			return scope.position;
		}
		
		public function set rotation(val:Vector3D):void
		{
			scope.rotation = val;			
		}		
		
		public function get rotation():Vector3D
		{
			return scope.rotation;
		}
		
		public function set scale(val:Vector3D):void
		{
			scope.scale = val;
		}
		
		public function get scale():Vector3D
		{			
			return scope.scale;
		}
		
		override public function dispose():void
		{
			shape = null;
						
			super.dispose();
		}
	}
}