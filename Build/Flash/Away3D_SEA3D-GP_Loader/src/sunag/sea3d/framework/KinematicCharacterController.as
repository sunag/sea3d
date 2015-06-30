package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	
	import awayphysics.collision.dispatch.AWPGhostObject;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.events.AWPEvent;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class KinematicCharacterController extends Physics
	{
		sea3dgp var ctrl:AWPKinematicCharacterController;
		sea3dgp var _stepHeight:Number;
		sea3dgp var _ghost:AWPGhostObject;
		sea3dgp var _mass:Number = 0;
		
		public function KinematicCharacterController(shape:Shape=null, target:Object3D=null, stepHeight:Number=0.1)
		{
			_stepHeight = stepHeight;
			
			this.shape = shape;
			this.target = target;					
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			if (_scene == scene) return;
			
			if ( _scene && ctrl )
			{
				_scene.physics.splice( _scene.physics.indexOf(this), 1);
				
				SEA3DGP.world.removeCharacter( ctrl );
			}
			
			super.setScene( scene );
			
			if ( scene && ctrl )
			{
				_scene.physics.push( this );
				
				SEA3DGP.world.addCharacter(ctrl);			
			}
		}
		
		private function onCollisionAdded(e:AWPEvent):void 
		{
			if (e.collisionObject is AWPRigidBody && 
				!(e.collisionObject.collisionFlags & AWPCollisionFlags.CF_STATIC_OBJECT) &&
				!(e.collisionObject.collisionFlags & AWPCollisionFlags.CF_NO_CONTACT_RESPONSE)) 
			{
				var body:AWPRigidBody = AWPRigidBody(e.collisionObject);
				var force:Vector3D = e.manifoldPoint.normalWorldOnB.clone();
				force.scaleBy(-_mass);
				body.applyForce(force, e.manifoldPoint.localPointB);
			}
		}
		
		public function set mass(val:Number):void
		{
			if (_mass == val) return;
						
			var invalidate:Boolean = (_mass > 0) != (val > 0)
			
			_mass = val;
			
			if (invalidate && _ghost)
			{
				if (_mass > 0)
				{
					_ghost.addEventListener(AWPEvent.COLLISION_ADDED, onCollisionAdded, false, 0, true);
				}
				else
				{
					_ghost.removeEventListener(AWPEvent.COLLISION_ADDED, onCollisionAdded);
				}
			}
		}
		
		public function get mass():Number
		{
			return _mass;
		}		
		
		override public function set shape(val:Shape):void
		{
			if (sp == val) return;
			
			if (sp)			
			{
				if (_scene) SEA3DGP.world.removeCharacter( ctrl, true );
				scope = null;
				ctrl = null;
			}
						
			if ((sp=val))
			{
				_ghost = new AWPGhostObject(sp.scope);
				_ghost.collisionFlags = AWPCollisionFlags.CF_CHARACTER_OBJECT;			
				
				if (_mass > 0)
					_ghost.addEventListener(AWPEvent.COLLISION_ADDED, onCollisionAdded, false, 0, true);
				
				ctrl = new AWPKinematicCharacterController(_ghost, _stepHeight);
				
				scope = _ghost;
				scope.extra = this;
				
				updateCallback();
				
				if (_scene)
				{
					SEA3DGP.world.addCharacter(ctrl);
				}
			}
		}
		
		public function setWalkDirection(dir:Vector3D):void
		{
			ctrl.setWalkDirection(dir);
		}
	}
}