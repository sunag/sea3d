package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import away3d.container.DynamicScene3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.materials.lightpickers.DynamicLightPicker;
	import away3d.materials.methods.DynamicFogMethod;
	
	import sunag.animation.AnimationPlayer;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DynamicConfig;
	import sunag.sea3d.modules.ActionModule;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class DynamicFog extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		private var player:AnimationPlayer;
		
		public function DynamicFog()
		{
			/**
			 * Basic config.
			 * */
			
			stage.stageFocusRect = false;
			stage.showDefaultContextMenu=false;	
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
									
			//	DynamicScene3D is needed to run correctly DynamicLightPicker. 			
			
			view = new View3D(new DynamicScene3D());		
			view.backgroundColor = stage.color;
			view.antiAlias = 4;
			addChild(view);
			addChild(new AwayStats(view));	
			
			/**
			 * Config
			 * */	
			
			//
			//	Enabled Fog in environment on SEA3D Exporter
			//
			//	You can use both for DefaultConfig or DynamicConfig
			//
			
			// for multi-lights
			var config:DynamicConfig = new DynamicConfig();
			config.enabledFog = true; 
			
			/**
			 * <sea3d.container> contains all elements loaded.
			 * add objects in scene container
			 * */
			
			config.container = view.scene;
			
			/**
			 * Init loader
			 * */			
			
			sea3d = new SEA3D(config);
			
			// Is needed to run Fog
			sea3d.addModule(new ActionModule());
			
			sea3d.addEventListener(SEAEvent.COMPLETE, onComplete);			
			sea3d.load(new URLRequest("../assets/DynamicLights.sea"));	
			
			addEventListener(MouseEvent.CLICK, onFogEnabled);
			addEventListener(MouseEvent.MOUSE_MOVE, onFogColor);
		}
		
		private function onFogColor(e:MouseEvent):void
		{
			DynamicFogMethod.instance.fogColor = 
				(stage.mouseX / stage.stageWidth) * 255 +
				(((stage.mouseY / stage.stageHeight) * 255) << 8);			
		}
		
		private function onFogEnabled(e:MouseEvent):void
		{
			DynamicFogMethod.instance.enabled = !DynamicFogMethod.instance.enabled;						
			trace("Fog " + (DynamicFogMethod.instance.enabled ? "Enabled" : "Disable") );
		}
		
		private function onEnterFrame(e:Event):void
		{		
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{	
			trace("Mesh count:", sea3d.meshes ? sea3d.meshes.length : 0 );
			trace("Light count:", sea3d.lights ? sea3d.lights.length : 0 );
			trace("Light per object:", DynamicLightPicker.instance.pointLightLimit + DynamicLightPicker.instance.directionalLightLimit);
			
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