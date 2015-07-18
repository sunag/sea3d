package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.states.AnimationStateBase;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AnimationStateEvent;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	import sunag.utils.TimeStep;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class CharacterExample extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;		
		private var keyState:Array = [];
		private var timeStep:TimeStep = new TimeStep(stage.frameRate);
		
		private var player:Mesh;
		private var animator:SkeletonAnimator;
		
		public function CharacterExample()
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
			 * use cpu
			 * */
			
			//config.forceSkeletonCPU = true;
			
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
			sea3d.load(new URLRequest("../assets/Character.sea"));	
			
			/**
			 * Interactive
			 * */
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			keyState[e.keyCode] = true;
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			delete keyState[e.keyCode];
		}
		
		private function getKeyState(code:int):Boolean
		{
			return keyState[code];
		}
		
		private function onEnterFrame(e:Event):void
		{
			var running:Boolean = false;
						
			animator.playbackSpeed = 1;
									
			if (animator.activeAnimationName == "pass#1")
			{
				
			}			
			else if (animator.activeAnimationName == "run" || animator.activeAnimationName == "idle")
			{								
				if (getKeyState(Keyboard.UP))
				{
					running = true;
					player.moveBackward(5 * timeStep.delta);
				}
				if (getKeyState(Keyboard.DOWN))
				{
					running = true;
					player.moveForward(5 * timeStep.delta);
					animator.playbackSpeed = -1;
				}
				
				if (getKeyState(Keyboard.LEFT))
				{
					player.rotationY -= 5 * timeStep.delta;
				}
				if (getKeyState(Keyboard.RIGHT))
				{
					player.rotationY += 5 * timeStep.delta;
				}	
				
				if (running)
				{
					if (animator.activeAnimationName != "run") 
					{
						animator.play("run", new CrossfadeTransition(.3));	
					}
				}
				else
				{
					if (animator.activeAnimationName != "idle") 
					{
						animator.play("idle", new CrossfadeTransition(.3));	
					}
				}
				
				if (getKeyState(Keyboard.SPACE))
				{
					animator.play("pass#1", new CrossfadeTransition(.3), 0);					
				}
			}
			
			//view.camera.lookAt(player.position);
			
			view.render();
		}
		
		private function onPassDone(e:AnimationStateEvent):void
		{			
   			animator.play("idle", new CrossfadeTransition(.3));
		}
		
		private function onComplete(e:SEAEvent):void
		{		
			player = sea3d.getMesh("Player");
			animator = player.animator as SkeletonAnimator;
						 								
			// list sequences
			trace("<--");
			var sklAnimationSet:SkeletonAnimationSet = animator.animationSet as SkeletonAnimationSet;
			for(var i:int=0;i<sklAnimationSet.animationNames.length;i++)
				trace(sklAnimationSet.animationNames[i]);
			trace("-->");
			
			// play animation
			animator.play("idle");
			
			// call function onPassDone when "pass#1" animation is completed		
			AnimationStateBase(animator.getAnimationStateByName("pass#1")).addEventListener(AnimationStateEvent.PLAYBACK_COMPLETE, onPassDone);
			
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