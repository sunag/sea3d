package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import away3d.container.SparticleContainer;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.events.LoaderEvent;
	import away3d.loaders.misc.SingleFileLoader;
	import away3d.loaders.parsers.Parsers;
	import away3d.loaders.parsers.ParticleGroupParser;
	
	import sunag.animation.AnimationPlayer;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	import sunag.sea3d.modules.ParticleModule;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class SparticleLoad extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		private var player:AnimationPlayer;
		private var particle:ParticleModule;
		
		public function SparticleLoad()
		{
			/**
			 * Basic config.
			 * */
			
			stage.stageFocusRect = false;
			stage.showDefaultContextMenu=false;	
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
						
			view = new View3D();			
			view.backgroundColor = stage.color;
			view.antiAlias = 4;
			addChild(view);
			addChild(new AwayStats(view));
						
			/**
			 * Play All Animation 
			 * */			
			
			player = new AnimationPlayer();
			
			// play root animation
			player.play();
			
			/**
			 * Config
			 * */			
			
			var config:DefaultConfig = new DefaultConfig();
			config.player = player;
			
			/**
			 * <sea3d.container> contains all elements loaded.
			 * add objects in scene container
			 * */
			
			config.container = view.scene;
			
			/**
			 * Enable Sparticle Parser
			 * */	
			
			SingleFileLoader.enableParser(ParticleGroupParser);
			
			Parsers.enableAllBundled();
			
			/**
			 * Init loader
			 * */			
			
			sea3d = new SEA3D(config);
			
			sea3d.addModule( particle = new ParticleModule() );
			
			sea3d.addEventListener(SEAEvent.COMPLETE, onComplete);			
			sea3d.load(new URLRequest("../assets/Sparticle.sea"));						
		}
		
		private function onEnterFrame(e:Event):void
		{		
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{						
			/**
			 * <Camera01> Camera contained in MAX file.
			 * <sea3d.get...> Using for get element.			 
			 * */						
			
			view.camera = sea3d.getCamera("Camera01");			
			
			/**
			 * Interaction
			 * */
			
			var container:SparticleContainer = particle.getParticleContainer("fire") as SparticleContainer;
			
			if (container.particleGroup)
			{
				trace( "sync loaded", container.particleGroup );								
			}
			else
			{
				container.addEventListener(LoaderEvent.RESOURCE_COMPLETE, function(e:LoaderEvent):void
				{
					trace( "async lodaded", container.particleGroup );										
										
					//container.particleGroup.animator.stop();
					//container.particleGroup.animator.start(); // Use AutoPlay in SEA3D Studio
				});
			}
			
			/**
			 * Start render and update.
			 * */
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}