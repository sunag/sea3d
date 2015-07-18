package away3d.container
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.ParticleGroup;
	
	public class SparticleContainer extends ObjectContainer3D
	{
		private var _autoPlay:Boolean = false;
		private var _particleGroup:ParticleGroup;
		
		public function SparticleContainer()
		{
			super();
		}
		
		public function set particleGroup(val:ParticleGroup):void
		{			
			if (_particleGroup == val) return;
			
			if (_particleGroup)
			{
				removeChild( _particleGroup );
			}
			
			_particleGroup = val;
			
			if (_particleGroup)
			{
				addChild( _particleGroup );
				
				if (_autoPlay)
				{
					_particleGroup.animator.start();
				}
			}
		}
		
		public function get particleGroup():ParticleGroup
		{
			return _particleGroup;
		}
		
		public function set autoPlay(val:Boolean):void
		{			
			if (_autoPlay == val) return;
			
			_autoPlay = val;
			
			if (_autoPlay && _particleGroup)
			{
				_particleGroup.animator.start();
			}
		}
		
		public function get autoPlay():Boolean
		{
			return _autoPlay;
		}
	}
}