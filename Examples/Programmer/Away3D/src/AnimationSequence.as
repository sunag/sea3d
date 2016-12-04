package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.sea3d.animation.CameraAnimation;
	
	import sunag.animation.AnimationBlendMethod;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class AnimationSequence extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		private var cameraAnm:CameraAnimation;
		
		public function AnimationSequence()
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
			config.animationBlendMethod = AnimationBlendMethod.EASING;			
			
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
			sea3d.load(new URLRequest("../assets/AnimationSequence.sea"));							
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{
				case Keyboard.NUMBER_1:
					cameraAnm.play("anm1", .5, 0);
					break;
				
				case Keyboard.NUMBER_2:
					cameraAnm.play("anm2", .5, 0);
					break;
				
				case Keyboard.NUMBER_3:
					cameraAnm.play("anm3", .5, 0);
					break;
			}
		}
		
		private function onEnterFrame(e:Event):void
		{										
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{						
			/**
			 * <Camera001> Camera contained in MAX file.
			 * <sea3d.get...> Using for get element.			 
			 * */						
			
			view.camera = sea3d.getCamera("Camera001");			
			cameraAnm = sea3d.getAnimation("Camera001") as CameraAnimation;
						
			/**
			 * for soft animation transition
			 * */
			
			// seted in config
			//cameraAnm.blendMethod = AnimationBlendMethod.EASING;
			//cameraAnm.easeSpeed = 1; // 2 is Default
						
			/**
			 * Start render and update.
			 * */
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
	}
}