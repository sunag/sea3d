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
	import away3d.morph.MorphNode;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class MorphSharedExample extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		private var mesh:Mesh;
		private var morpher:MorphAnimator; 
		private var sea3dMorph:SEA3D;
		
		public function MorphSharedExample()
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
			 * use morph cpu			 
			 * */			
			
			config.forceMorphCPU = true; // allows more than 2 morph same time
			
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
			
			if (morpher.containsMorph("OpenTeapot"))
			{
				morpher.setWeight("OpenTeapot", (stage.stageHeight - (stage.mouseY + 200)) / (stage.stageHeight / 1.6));
			}
			
			view.render();
		}
		
		private function onComplete(e:SEAEvent):void
		{			
			mesh = sea3d.getMesh("Teapot01");			
			morpher = mesh.animator as MorphAnimator;
			
			trace("MorphGPU:",!morpher.animationSet.usesCPU);
			
			trace("<-- actual morphs");
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
			
			/**
			 * Load shared morpher
			 * */
			
			sea3dMorph = new SEA3D(sea3d.config);
			sea3dMorph.addEventListener(SEAEvent.COMPLETE, onCompleteMorph);
			sea3dMorph.load(new URLRequest("../assets/SharedMorph.sea"));			
		}
		
		private function onCompleteMorph(e:SEAEvent):void
		{	
			// actual morphs
			var targetMorpher:MorphAnimationSet = morpher.animationSet as MorphAnimationSet;
			
			// new morphs
			var morphAnimationSet:MorphAnimationSet = sea3dMorph.getMorphAnimationSet("Teapot01");
			
			trace("<-- new morphs");				
			for each(var node:MorphNode in morphAnimationSet.morphs)
			{
				trace(node.name);
				targetMorpher.addMorph(node);
				
				// changes influence
				//morpher.setWeight(node.name, 1);
			}
			trace("-->");
		}
	}
}