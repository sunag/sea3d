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
	import away3d.lights.DirectionalLight;
	import away3d.lights.shadowmaps.DynamicCascadeShadowMapMethod;
	import away3d.lights.shadowmaps.DynamicNearShadowMapMethod;
	import away3d.lights.shadowmaps.DynamicShadowMapper;
	import away3d.lights.shadowmaps.IDynamicShadow;
	
	import sunag.animation.AnimationPlayer;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DynamicConfig;
	import sunag.sea3d.config.ShadowMethod;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class DynamicShadowsNormal extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		private var player:AnimationPlayer;
		private var config:DynamicConfig;
		
		public function DynamicShadowsNormal()
		{
			/**
			 * Basic config.
			 * */
			
			stage.stageFocusRect = false;
			stage.showDefaultContextMenu=false;	
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
									
			//	DynamicScene3D is needed to run correctly DynamicShadows. 			
			
			view = new View3D(new DynamicScene3D());			
			view.backgroundColor = stage.color;
			view.camera.lens.near = 1;
			view.camera.lens.far = 1000;
			view.antiAlias = 4;
			addChild(view);
			addChild(new AwayStats(view));	
			
			/**
			 * Config
			 * */	
			
			config = new DynamicConfig();
			config.enabledShadow = true; // true is default
									
			//config.shadowMethod = ShadowMethod.CASCADE; // cascade is default
			config.shadowMethod = ShadowMethod.NEAR; // free up more slots in agal.
			config.player = new AnimationPlayer();
			
			//
			//	NEAR CONFIG
			//
			
			DynamicNearShadowMapMethod.instance.coverageRatio = .1;			
			DynamicNearShadowMapMethod.instance.fadeRatio = .1;
			DynamicNearShadowMapMethod.instance.epsilon = .06;
			
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
			sea3d.load(new URLRequest("../assets/ShadowsAndNormalMap.sea"));
			
			addEventListener(MouseEvent.CLICK, onShadowEnabled);
		}
		
		private function onShadowEnabled(e:MouseEvent):void
		{			
			var light:DirectionalLight = sea3d.getLight("Direct001") as DirectionalLight;
			
			var dynamicShadow:IDynamicShadow =
				config.shadowMethod == ShadowMethod.CASCADE 
				? 
				DynamicCascadeShadowMapMethod.instance
				: 
				DynamicNearShadowMapMethod.instance;
						
			light.shadowMapper = 
				light.shadowMapper ? null : new DynamicShadowMapper( dynamicShadow );			
			
			trace("Shadow " + (light.shadowMapper ? "Enabled" : "Disable") );
		}
		
		private function onEnterFrame(e:Event):void
		{		
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{	
			AnimationPlayer(config.player).play();
				
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