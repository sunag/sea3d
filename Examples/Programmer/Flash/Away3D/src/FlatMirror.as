package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.textures.PlanarReflectionTextureTarget;
	
	import sunag.animation.AnimationPlayer;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	import sunag.sea3d.modules.RTTModule;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class FlatMirror extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		private var renderToTextureModule:RTTModule;
		private var player:AnimationPlayer;
		
		public function FlatMirror()
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
			 * Config
			 * */			
			
			var config:DefaultConfig = new DefaultConfig();
			config.player = player;
			
			/**
			 * <sea3d.container> contains all elements loaded.
			 * add objects in scene container
			 * */
			
			config.container = view.scene
			
			/**
			 * Init loader
			 * */			
			
			sea3d = new SEA3D(config);			
						
			sea3d.addModule(renderToTextureModule = new RTTModule());
			
			sea3d.addEventListener(SEAEvent.COMPLETE, onComplete);			
			sea3d.load(new URLRequest("../assets/FlatMirror.sea"));				
		}
		
		private function onEnterFrame(e:Event):void
		{		
			/**
			 * Interaction
			 * */	
			var mesh:Mesh = sea3d.getMesh("Teapot01");			
			mesh.rotationY += 1;
			
			for each(var planarReflection:PlanarReflectionTextureTarget in renderToTextureModule.planarReflections)
			{
				planarReflection.render(view);
			}
			
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
			 * Start render and update.
			 * */
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}