package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.LayeredDiffuseMethod;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class Multilayer extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
		
		[Embed (source="../assets/LayeredTexture-NoAnimated.sea",mimeType="application/octet-stream")]
		private var SimpleScene:Class;
		
		public function Multilayer()
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
			sea3d.load(new URLRequest("../assets/LayeredTexture.sea"));
		}
		
		private function onEnterFrame(e:Event):void
		{		
			/**
			 * Interaction
			 * Cloud
			 * */
			
			var cloud:Mesh = sea3d.getMesh("Plane003");
			
			// (Multi-Sub Objects)
			var cloudMaterial:TextureMaterial = TextureMaterial(cloud.subMeshes[0].material);
			// Single Object
			//var cloudMaterial:TextureMaterial = TextureMaterial(cloud.material);
			
			var cloudDiffuse:LayeredDiffuseMethod = LayeredDiffuseMethod(cloudMaterial.diffuseMethod);			
						
			cloudDiffuse.layers[0].offsetU += .001;
			cloudDiffuse.layers[1].offsetU += .002;
				
			// Interative
			cloudDiffuse.layers[0].scaleU = .5 + (stage.mouseX / stage.stageWidth);
			cloudDiffuse.layers[0].scaleV = .5 + (stage.mouseY / stage.stageHeight);
			
			// Adding Layer Example "Not use here :)"
			//cloudDiffuse.addLayer(new LayeredTexture(yourTexture));
			
			/**
			 * Interaction
			 * BlendTexture
			 * */
			
			var plane:Mesh = sea3d.getMesh("Plane001");
			
			// (Multi-Sub Objects)
			var planeMaterial:TextureMaterial = TextureMaterial(plane.subMeshes[0].material);
			// Single Object
			//var planeMaterial:TextureMaterial = TextureMaterial(plane.material);
			
			var planeDiffuse:LayeredDiffuseMethod = LayeredDiffuseMethod(planeMaterial.diffuseMethod);			
			
			planeDiffuse.layers[0].scaleU += .001;
			planeDiffuse.layers[0].scaleV += .001;
			
			planeDiffuse.layers[1].offsetU -= .001;
			planeDiffuse.layers[1].offsetU -= .001;
			
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