package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.sea3d.animation.MeshAnimation;
	
	import sunag.animation.Animation;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class IndividualAnimationManual extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		private var typeAnimation:int = 0;
		private var meshAnimation:Animation;
		
		public function IndividualAnimationManual()
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
			config.forceMorphCPU = true; //BUG IN BETA VERSION USING MORPH GPU
			
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
			sea3d.load(new URLRequest("../assets/SimpleScene.sea"));
			
			/**
			 * Interactive
			 * */
			
			stage.addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(MouseEvent.DOUBLE_CLICK, onClick);
		}
		
		private function onClick(e:MouseEvent):void
		{
			typeAnimation = (typeAnimation+1) % 3;			
			
			if (typeAnimation == 0)
				trace("time step");
			else if (typeAnimation == 1)
				trace("frame rate");
			else if (typeAnimation == 2)
				trace("position");
		}
		
		private function onEnterFrame(e:Event):void
		{
			/**
			 * Custom TimeScale
			 * */
			
			var center:Number = stage.mouseX - (stage.stageWidth/2);				
			
			if (typeAnimation == 0)
			{
				meshAnimation.timeScale = center / (stage.stageWidth/12);				
				meshAnimation.update(getTimer());
			}
			else if (typeAnimation == 1)
			{
				meshAnimation.getStateByName().frame++;
				meshAnimation.updateAnimation();
			}
			else if (typeAnimation == 2)
			{
				meshAnimation.getStateByName().position = center / (stage.stageWidth/2);
				meshAnimation.updateAnimation();
			}	
									
			/**
			 * Render
			 * */
			
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{
			/**
			 * Get Animation
			 * */
			
			meshAnimation = sea3d.getAnimation("Teapot01") as MeshAnimation;			
			meshAnimation.autoUpdate = false;
			meshAnimation.play();
			
			/**
			 * Count of animation in the file.		 
			 * */
			
			if (sea3d.animations)
				trace("AnimationCount:", sea3d.animations.length);stage.addEventListener(MouseEvent.CLICK, onClick);
			
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