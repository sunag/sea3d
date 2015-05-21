package sunag.sea3d.framework
{
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.events.AWPEvent;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	
	use namespace sea3dgp;
	
	public class RigidBody extends Physics
	{
		sea3dgp var rb:AWPRigidBody;
		sea3dgp var _mass:Number;
		sea3dgp var _friction:Number = .5;
		sea3dgp var _restitution:Number = 0;
		
		sea3dgp var _linearDamping:Number = 0;
		sea3dgp var _angularDamping:Number = 0;
		
		public function RigidBody(shape:Shape=null, target:Object3D=null, mass:Number=0)
		{
			_mass = mass;
			
			this.shape = shape;
			this.target = target;					
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			if (_scene == scene) return;
			
			if ( _scene && rb )
			{
				_scene.physics.splice( _scene.physics.indexOf(this), 1);
				
				SEA3DGP.world.removeRigidBody( rb );
			}
			
			super.setScene( scene );
			
			if ( scene && rb )
			{
				_scene.physics.push( this );
				
				SEA3DGP.world.addRigidBody( rb );				
			}
		}
		
		override public function set shape(val:Shape):void
		{
			if (sp == val) return;
			
			if (sp)			
			{
				if (_scene) SEA3DGP.world.removeRigidBody( rb, true );				
				scope = rb = null;
			}
						
			if ((sp=val))
			{
				scope = rb = new AWPRigidBody(sp.scope, tar ? tar.scope : null, _mass);
				rb.friction = _friction;
				rb.restitution = _restitution;
				rb.linearDamping = _linearDamping;
				rb.angularDamping = _angularDamping;
				rb.extra = this;
				
				updateCallback();
				
				if (_scene)
				{
					SEA3DGP.world.addRigidBody( rb );
				}
			}
		}
		
		public function set mass(val:Number):void
		{			
			rb.mass = _mass = val;
		}
		
		public function get mass():Number
		{			
			return _mass;
		}
		
		public function set friction(val:Number):void
		{			
			rb.friction = _friction = val;
		}
		
		public function get friction():Number
		{			
			return _friction;
		}
		
		public function set restitution(val:Number):void
		{			
			rb.restitution = _restitution = val;
		}
		
		public function get restitution():Number
		{			
			return _restitution;
		}
		
		public function set linearDamping(val:Number):void
		{			
			rb.linearDamping = _linearDamping = val;
		}
		
		public function get linearDamping():Number
		{			
			return _linearDamping;
		}
		
		public function set angularDamping(val:Number):void
		{			
			rb.angularDamping = _angularDamping = val;
		}
		
		public function get angularDamping():Number
		{			
			return _angularDamping;
		}
	}
}