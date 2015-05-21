package sunag.sea3d.framework
{
	import awayphysics.collision.dispatch.AWPCollisionObject;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	
	use namespace sea3dgp;
	
	public class CollisionSensor extends Physics
	{
		public function CollisionSensor(shape:Shape=null, target:Object3D=null)
		{
			this.shape = shape;
			this.target = target;
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			if (_scene == scene) return;
			
			if ( _scene && scope )
			{
				_scene.physics.splice( _scene.physics.indexOf(this), 1);
				
				SEA3DGP.world.removeCollisionObject( scope );
			}
			
			super.setScene( scene );
			
			if ( scene && scope )
			{
				_scene.physics.push( this );
			
				SEA3DGP.world.addCollisionObject( scope );				
			}
		}
		
		override public function set shape(val:Shape):void
		{
			if (sp == val) return;
			
			if (sp)			
			{
				if (_scene) SEA3DGP.world.removeCollisionObject( scope, true );				
				scope = null;
			}
						
			if ((sp=val))
			{
				scope = new AWPCollisionObject(sp.scope, tar ? tar.scope : null);
				scope.extra = this;
				
				updateCallback();
				
				if (_scene)
				{
					SEA3DGP.world.addCollisionObject( scope );
				}
			}
		}				
	}
}