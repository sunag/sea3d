package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class BlendTexture extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		
		public function BlendTexture()
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
			
			/**
			 * <sea3d.container> contains all elements loaded.
			 * add objects in scene container
			 * */
			
			config.container = view.scene;
			
			/**
			 * Init loader
			 * */			
			
			sea3d = new SEA3D(config);
						
			sea3d.addEventListener(SEAEvent.COMPLETE, onComplete);			
			sea3d.load(new URLRequest("../assets/BlendTexture.sea"));		
		}
		
		private function onEnterFrame(e:Event):void
		{						
			// Remove comments for custom effect in first plane (Normal)
			/*
			var mesh:Mesh = sea3d.getMesh("Plane001");
			var diffuse:LayeredDiffuseMethod = LayeredDiffuseMethod(TextureMaterial(mesh.material).diffuseMethod);			
			
			diffuse.layers[1].blendMode = LayeredTexture.INVERT;
			*/						
			
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{
			/**
			 * <Camera001> Camera contained in MAX file.
			 * <sea3d.get...> Using for get element.		 
			 * */						
			
			view.camera = sea3d.getCamera("Camera001");
						
			/**
			 * Start render and update.
			 * */
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}