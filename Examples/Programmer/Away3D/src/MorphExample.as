package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import away3d.animator.MorphAnimationSet;
	import away3d.animator.MorphAnimator;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class MorphExample extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		private var mesh:Mesh;
		private var morpher:MorphAnimator; 
		
		public function MorphExample()
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
			config.enabledShadow = false;
			
			/**
			 * use morph cpu
			 * */			
			
			//config.forceMorphCPU = true; // allows more than 2 morph same time or use in DynamicScene3D
			
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
		}
		
		private function onEnterFrame(e:Event):void
		{		
			/**
			 * Get MorphModifier
			 * */	
			mesh = sea3d.getMesh("Teapot01");			
			morpher = mesh.animator as MorphAnimator;
									
			/**
			 * Change Weights Morphs
			 * */
			morpher.setWeight("OldTeapot", stage.mouseX / stage.stageWidth);
			morpher.setWeight("Sphere", (stage.stageHeight - stage.mouseY) / stage.stageHeight);
			
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{			
			mesh = sea3d.getMesh("Teapot01");			
			morpher = mesh.animator as MorphAnimator;
			
			trace("MorphGPU:",!morpher.animationSet.usesCPU);
			
			trace("<--");
			var morphAnimationSet:MorphAnimationSet = morpher.animationSet as MorphAnimationSet;
			for(var i:int=0;i<morphAnimationSet.morphs.length;i++)
				trace(morphAnimationSet.morphs[i].name);
			trace("-->");
				
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