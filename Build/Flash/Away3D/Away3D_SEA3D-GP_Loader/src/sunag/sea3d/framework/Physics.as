package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.events.AWPEvent;
	
	import sunag.sea3dgp;
	import sunag.sea3d.events.CollisionEvent;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAPhysics;

	use namespace sea3dgp;
	
	public class Physics extends Asset
	{
		sea3dgp static const TYPE:String = 'Physic/';				
		
		public static const STATIC_OBJECT : int = 1;
		public static const KINEMATIC_OBJECT : int = 2;
		public static const NO_CONTACT_RESPONSE : int = 4;
		public static const CUSTOM_MATERIAL_CALLBACK : int = 8;
		public static const CHARACTER_OBJECT : int = 16;
		public static const DISABLE_VISUALIZE_OBJECT : int = 32;
		
		sea3dgp var scope:AWPCollisionObject;	
		
		sea3dgp var tar:Object3D;
		sea3dgp var sp:Shape;
		sea3dgp var collision:Physics;
		sea3dgp var rayCollision:Physics;
		sea3dgp var cls:Boolean;
		sea3dgp var ray:Boolean;
		sea3dgp var rayAdded:Boolean;
		sea3dgp var clsAdded:Boolean;
		sea3dgp var clsCallback:Boolean;
		sea3dgp var cback:Boolean;
		sea3dgp var groupId:int = 1;
		sea3dgp var maskId:int = -1;
		
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
			
			shape = physic.shape.tag;
			
			if (physic.transform)
			{
				scope.transform = physic.transform;
			}
			else
			{
				target = physic.target.tag;
			}
		}
				
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom(asset);
			
			var phy:Physics = asset as Physics;
			
			shape = phy.shape;
			
			scope.transform = phy.scope.transform;
			scope.collisionFlags = scope.collisionFlags;
				
			target = phy.tar;
			maskId = phy.maskId;
			groupId = phy.groupId;
		}
		
		public function get collided():Physics
		{
			return collision;
		}
		
		public function set target(val:Object3D):void
		{
			tar = val;
		}
		
		public function get target():Object3D
		{
			return tar;
		}
			
		public function set mask(val:int):void
		{
			maskId = val;
			
			var s:Scene3D = _scene;
			setScene(null);
			setScene(s);
		}
		
		public function get mask():int
		{
			return maskId;
		}
		
		public function set group(val:int):void
		{
			groupId = val;
			
			var s:Scene3D = _scene;
			setScene(null);
			setScene(s);
		}
		
		public function get group():int
		{
			return groupId;
		}
		
		public function set collisionFlags(val:int):void
		{
			if (cback) val |= AWPCollisionFlags.CF_CUSTOM_MATERIAL_CALLBACK
				
			scope.collisionFlags = val;						
		}
		
		public function get collisionFlags():int
		{
			return scope ? scope.collisionFlags : 0;
		}
		
		public function set shape(val:Shape):void
		{
			sp = val;
		}
		
		public function get shape():Shape
		{
			return sp;
		}
		
		public function get front():Vector3D
		{
			return scope.front;
		}
		
		public function get right():Vector3D
		{
			return scope.right;
		}
		
		public function get up():Vector3D
		{
			return scope.up;
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
				
				if (c && eDict[CollisionEvent.COLLISION_OUT])
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
			var phy:Physics = e.collisionObject.extra as Physics;
			
			ray = true;
			
			if (rayCollision != phy)
			{
				var c:Physics = rayCollision;
				
				rayCollision = phy;
				
				if (c && eDict[CollisionEvent.RAY_OUT])
				{
					dispatchEvent(new CollisionEvent(CollisionEvent.RAY_OUT, c));
				}
				
				if (phy && eDict[CollisionEvent.RAY_OVER])
				{
					dispatchEvent(new CollisionEvent(CollisionEvent.RAY_OVER, phy, e));
				}
			}
			
			if (eDict[CollisionEvent.RAY])
			{			
				dispatchEvent(new CollisionEvent(CollisionEvent.RAY, phy, e));
			}
			
			if (!rayAdded)
			{
				_scene.ray.push( this );
				
				rayAdded = true;				
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