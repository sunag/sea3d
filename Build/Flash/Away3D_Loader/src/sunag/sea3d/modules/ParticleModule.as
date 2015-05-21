package sunag.sea3d.modules
{
	import away3d.container.SparticleContainer;
	import away3d.containers.ObjectContainer3D;
	import away3d.loaders.SparticleLoader;
	import away3d.sea3d.animation.Object3DAnimation;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.objects.IAnimator;
	import sunag.sea3d.objects.SEAAnimation;
	import sunag.sea3d.objects.SEAParticleContainer;
	import sunag.sea3d.objects.SEASparticle;

	use namespace sunag;
	
	public class ParticleModule extends ParticleModuleBase
	{
		protected var _sparticles:Vector.<SparticleLoader>;
		protected var _containers:Vector.<ObjectContainer3D>;		
		
		sunag var sea3d:SEA3D;
		
		public function ParticleModule()
		{
			regRead(SEASparticle.TYPE, readSparticle);
			regRead(SEAParticleContainer.TYPE, readParticleContainer);
		}
		
		override sunag function reset():void
		{
			_sparticles = null;
			_containers = null;
		}
		
		override public function dispose():void
		{
			for each(var sparticle:SparticleLoader in _sparticles)
			{
				//sparticle.dispose();
			}	
			
			for each(var c3d:SparticleContainer in _containers)
			{
				c3d.dispose();
			}			
		}
		
		public function get sparticles():Vector.<SparticleLoader>
		{
			return _sparticles;
		}
		
		public function get containers():Vector.<ObjectContainer3D>
		{
			return _containers;
		}
		
		public function getSparticle(name:String):SparticleLoader
		{
			return sea.object[name + ".awp"];
		}	
		
		public function getParticleContainer(name:String):ObjectContainer3D
		{
			return sea.object[name + ".p3d"];
		}
				
		protected function readSparticle(sea:SEASparticle):void
		{
			var sparticle:SparticleLoader = new SparticleLoader();			
			sparticle.loadData(sea.source, '', sea.reference ? sea.reference.tag : null);	
			
			_sparticles ||=  new Vector.<SparticleLoader>();
			_sparticles.push(this.sea.object[sea.name + '.awp'] = sea.tag = sparticle);
		}
		
		protected function readParticleContainer(sea:SEAParticleContainer):void
		{
			var obj3d:SparticleContainer = SparticleLoader(sea.particle.tag).createContainer();
			
			obj3d.autoPlay = sea.autoPlay;
			obj3d.transform = sea.transform;
			
			//
			//	Animations
			//
			
			for each(var anm:Object in sea.animations)
			{
				var tag:IAnimator = anm.tag;
				
				if (tag is SEAAnimation)
				{
					sea3d.addAnimation				
						(
							new Object3DAnimation(obj3d, (tag as SEAAnimation).tag),
							sea.name, anm
						);
				}
			}
			
			sea3d.addSceneObject(sea, obj3d);
			
			_containers ||=  new Vector.<ObjectContainer3D>();
			_containers.push(this.sea.object[sea.name + '.p3d'] = sea.tag = obj3d);
		}
		
		override sunag function init(sea:SEA):void
		{
			this.sea = sea;
			sea3d = sea as SEA3D;
		}
	}
}