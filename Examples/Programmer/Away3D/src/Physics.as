package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	import sunag.sea3d.modules.ActionModule;
	import sunag.sea3d.modules.PhysicsModule;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class Physics extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		
		private var physicsWorld:AWPDynamicsWorld;
		private var debugDraw:AWPDebugDraw;
		
		public function Physics()
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
						
			//
			//	AWAY3D PHYSICS
			//
			
			physicsWorld = AWPDynamicsWorld.getInstance();
			physicsWorld.initWithDbvtBroadphase();
			
			debugDraw = new AWPDebugDraw(view, physicsWorld);
			debugDraw.debugMode = 
				AWPDebugDraw.DBG_DrawConstraints | 
				AWPDebugDraw.DBG_DrawConstraintLimits | 
				AWPDebugDraw.DBG_DrawRay | 
				AWPDebugDraw.DBG_DrawTransform | 
				AWPDebugDraw.DBG_DrawCollisionShapes;
			
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
			sea3d.addModule(new PhysicsModule(physicsWorld));
			sea3d.addModule(new ActionModule()); // for camera look at command
			
			sea3d.addEventListener(SEAEvent.COMPLETE, onComplete);			
			sea3d.load(new URLRequest("../assets/Physics.sea"));						
		}
		
		private function onEnterFrame(e:Event):void
		{		
			physicsWorld.step( view.deltaTime );
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{						
			/**
			 * <Camera001> Camera contained in MAX file.
			 * <sea3d.get...> Using for get element.			 
			 * */						
			
			view.camera = sea3d.getCamera("Camera");			
			
			/**
			 * Start render and update.
			 * */
			
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
	}
}