package sunag.sea3d.framework
{
	import away3d.entities.ParticleGroup;
	import away3d.events.LoaderEvent;
	import away3d.library.assets.IAsset;
	import away3d.loaders.AssetLoader;
	
	import sunag.sea3dgp;
	import sunag.sea3d.core.assets.Reference;
	import sunag.sea3d.events.Event;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEASparticle;

	use namespace sea3dgp;
	
	public class Sparticle extends Particle
	{
		sea3dgp var reference:Reference;
		
		sea3dgp var loader:AssetLoader;
		sea3dgp var particle:ParticleGroup;
		
		public function Sparticle()
		{
		}
		
		//
		//	LOADER
		//
		
		protected function onLoadComplete(e:LoaderEvent):void
		{
			var assets:Vector.<IAsset> = loader.baseDependency.assets;
			container = particle = assets[assets.length-1] as ParticleGroup;			
			loader = null;
			dispatchEvent( new Event(Event.COMPLETE) );
		}
				
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	REFERENCE
			//
			
			var sparticle:SEASparticle = sea as SEASparticle;
			
			if (sparticle.reference)
			{
				reference = sparticle.reference.tag;
			}
			
			loader = new away3d.loaders.AssetLoader();			
			loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onLoadComplete);
			loader.loadData(sparticle.source, '', reference ? reference.context : null);
		}
	}
}