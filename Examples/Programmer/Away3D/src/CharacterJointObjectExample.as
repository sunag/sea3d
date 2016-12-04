package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;
	
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.JointObject;
	import away3d.entities.Mesh;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	import sunag.utils.TimeStep;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class CharacterJointObjectExample extends Sprite
	{
		private var view:View3D;		
		private var sea3d:SEA3D;		
		private var keyState:Array = [];
		private var timeStep:TimeStep = new TimeStep(stage.frameRate);
		private var modelItem:Mesh;
		
		private var player:Mesh;
		private var animator:SkeletonAnimator;
		
		[Embed (source="../assets/CharacterJointObject.sea",mimeType="application/octet-stream")]
		private var Character:Class;
		
		public function CharacterJointObjectExample()
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
			 * Update initial position of character
			 * necessary to use JointObject
			 * */
			
			config.updateGlobalPose = true;
			
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
			sea3d.load(new URLRequest("../assets/CharacterJointObject.sea"));	
			
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
			
			//modelItem.rotate(Vector3D.Y_AXIS, timeStep.delta); 			
			
			//view.camera.lookAt(player.position);
			
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{		
			player = sea3d.getMesh("Player");
			animator = player.animator as SkeletonAnimator;
			
			animator.play("idle");
			
			modelItem = sea3d.getMesh("Hat");
			
			var jointObject:JointObject = modelItem.parent as JointObject; 
			
			trace("Model(\"" + player.name + "\") <- Bone(\"" + jointObject.jointName + "\") <- Model(\"" + modelItem.name + "\")");
					
			/**
			 * e.g: Manual creation of an JointObject
			 * */
			
			//var jointObject:JointObject = JointObject.fromName(player, "Base HumanHead", true);
			//jointObject.addChild( modelItem );
			//scene.addChild( jointObject );
			
			/**
			 * remove joint object	 	
			 * */
			
			//jointObject.dispose();			
			
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