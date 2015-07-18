package away3d.loaders
{
	import away3d.container.SparticleContainer;
	import away3d.entities.ParticleGroup;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.IAsset;
	
	public class SparticleLoader extends AssetLoader
	{
		protected var _particleGroup:ParticleGroup;
		protected var _clone:Boolean;
		protected var _waiting:Vector.<SparticleContainer>;
		
		public function SparticleLoader()
		{		
			addEventListener(LoaderEvent.RESOURCE_COMPLETE, onComplete);
		}
		
		private function onComplete(e:LoaderEvent):void
		{
			var assets:Vector.<IAsset> = baseDependency.assets;
			_particleGroup =  assets[assets.length-1] as ParticleGroup;
			
			for each(var obj3d:SparticleContainer in _waiting)
			{
				if (_clone)
				{										
					obj3d.particleGroup = _particleGroup.clone() as ParticleGroup;
				}
				else
				{				
					obj3d.particleGroup = _particleGroup;				
					_clone = true;
				}
				
				obj3d.dispatchEvent( e );
			}
		}
		
		public function get particleGroup():ParticleGroup
		{
			return _particleGroup;
		}
		
		public function createContainer():SparticleContainer
		{
			var obj3d:SparticleContainer = new SparticleContainer();
			
			if (_particleGroup)
			{
				if (_clone)
				{										
					obj3d.particleGroup = _particleGroup.clone() as ParticleGroup;
				}
				else
				{				
					obj3d.particleGroup = _particleGroup;				
					_clone = true;
				}
			}
			else
			{
				_waiting ||= new Vector.<SparticleContainer>();
				_waiting.push( obj3d );
			}
			
			return obj3d;
		}
	}
}