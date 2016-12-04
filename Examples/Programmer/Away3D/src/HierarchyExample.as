package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.DefaultConfig;
	
	[SWF(width="1024", height="632", backgroundColor="0x2f3032", frameRate="60")]
	public class HierarchyExample extends Sprite
	{
		private var view:View3D;
		private var sea3d:SEA3D;
				
		public function HierarchyExample()
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
			
			view.scene.addChild( config.container = new ObjectContainer3D() );
			config.container.name = "sea3d";
			
			/**
			 * Init loader
			 * */			
			
			sea3d = new SEA3D(config);
						
			sea3d.addEventListener(SEAEvent.COMPLETE, onComplete);			
			sea3d.load(new URLRequest("../assets/Hierarchy.sea"));
		}
		
		private function onEnterFrame(e:Event):void
		{		
			/**
			 * Interaction
			 * */	
			var sphere1:Mesh = sea3d.getMesh("Sphere01");
			sphere1.rotationY += 1;
				
			var sphere2:Mesh = sea3d.getMesh("Sphere02");
			sphere2.rotationY += 3;
			
			view.render();
		}
		
		private function getDeps(container:ObjectContainer3D, deps:Array, path:String=""):Array
		{
			var isRoot:Boolean = path.length == 0;
			
			if (container.name) 
			{
				if (container.numChildren > 0)
				{
					path += container.name + " <- ";
				
					for(var i:int=0;i<container.numChildren;i++)
					{
						getDeps(container.getChildAt(i), deps, path)
					}					
				}
				else deps.push(path + container.name);
			}
			
			return deps;
		}
		
		private function onComplete(e:SEAEvent):void
		{
			// Get Deps List
			trace(getDeps(sea3d.config.container, []).join("\n"));
			
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