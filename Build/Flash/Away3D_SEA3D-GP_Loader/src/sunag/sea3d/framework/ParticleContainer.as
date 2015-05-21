package sunag.sea3d.framework
{
	import flash.utils.getTimer;
	
	import away3d.animators.AnimatorBase;
	import away3d.containers.ObjectContainer3D;
	import away3d.sea3d.animation.Object3DAnimation;
	
	import sunag.sea3dgp;
	import sunag.sea3d.events.Event;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAParticleContainer;

	use namespace sea3dgp;
	
	public class ParticleContainer extends Object3D
	{
		sea3dgp var container:ObjectContainer3D;
		sea3dgp var part:Particle;	
		sea3dgp var partContainer:ObjectContainer3D;
		sea3dgp var particleAnimator:AnimatorBase;
				
		sea3dgp var playtime:Number;
		
		public function ParticleContainer()
		{
			super(container = new ObjectContainer3D(), Object3DAnimation);
		}
		
		protected function onComplete(e:Event):void
		{			
			part.removeEventListener(Event.COMPLETE, onComplete);
			particleContainer = part.content;
		}
		
		public function set particle(val:Particle):void
		{
			part = val;
			
			if (part.container)
			{
				particleContainer = part.content;
			}
			else
			{
				part.addEventListener(Event.COMPLETE, onComplete);
			}
		}
		
		public function get particle():Particle
		{
			return part;
		}
		
		public function get playingParticle():Boolean
		{
			return particleAnimator.isPlaying;
		}
		
		public function play(offset:Number=0):void
		{
			particleAnimator.start();
			particleAnimator.time += offset;
		}
		
		public function stop():void
		{		
			particleAnimator.stop();			
		}
		
		public function set time(val:Number):void
		{
			particleAnimator.time = val;
		}
		
		public function get time():Number
		{
			return particleAnimator.time;
		}
		
		sea3dgp function set particleContainer(val:ObjectContainer3D):void
		{
			if (partContainer)
			{
				partContainer.dispose();				
			}
			
			partContainer = val;
			
			if (partContainer)
			{
				container.addChild( partContainer );
				
				particleAnimator = partContainer.hasOwnProperty('animator') ? partContainer['animator'] : null;
				
				if (particleAnimator && playtime > 0)
				{
					play( getTimer() - playtime );
				}
			}
			else
			{
				particleAnimator = null;
			}
		}
		
		//
		//	LOADER
		//
		
		override public function clone():Asset			
		{
			var asset:ParticleContainer = new ParticleContainer();
			asset.copyFrom( this );
			return asset;
		}
		
		sea3dgp override function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var p:ParticleContainer = asset as ParticleContainer;
			
			playtime = p.playtime;
			particle = p.particle;			
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	PARTICLE CONTAINER
			//
			
			var p:SEAParticleContainer = sea as SEAParticleContainer;
			
			if (p.autoPlay)			
				playtime = getTimer();							
			
			particle = p.particle.tag;
			
			container.transform = p.transform;
		}
	}
}