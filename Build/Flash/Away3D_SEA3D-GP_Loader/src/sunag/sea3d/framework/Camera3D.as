package sunag.sea3d.framework
{
	import flash.display.BitmapData;
	import flash.geom.Vector3D;
	
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DProxy;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.objects.SEACamera;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class Camera3D extends Object3D
	{
		sea3dgp static const NULL:away3d.cameras.Camera3D = new away3d.cameras.Camera3D();
		
		sea3dgp var camera:away3d.cameras.Camera3D;
		sea3dgp var view3d:View3D;
		
		public function Camera3D(camera:away3d.cameras.Camera3D, animatorClass:Class=null)
		{
			super(this.camera = camera, animatorClass);
		}
		
		sea3dgp function renderToBitmap(data:BitmapData):void
		{
			var w:int = view3d.width,
				h:int = view3d.height;
			
			var proxy:Stage3DProxy = SEA3DGP.proxy;
			
			proxy.clear();			
			
			view3d.width = data.width;
			view3d.height = data.height;
			
			view3d.render();
			
			proxy.context3D.drawToBitmapData( data );
			
			view3d.width = w;
			view3d.height = h;																	
		}
		
		public function project(v3d:Vector3D):Vector3D
		{
			return view3d.project(v3d);			
		}
		
		public function unproject(x:Number, y:Number, plane:Vector3D=null):Vector3D
		{
			return view3d.unproject( x, y );		
		}
		
		public function get mouseX():Number
		{
			return view3d.mouseX;
		}
		
		public function get mouseY():Number
		{
			return view3d.mouseY;
		}
		
		public function get screenWidth():Number
		{
			return view3d.width;
		}
		
		public function get screenHeight():Number
		{
			return view3d.height;
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	CAMERA
			//
			
			var cam:SEACamera = sea as SEACamera;
			
			camera.transform = cam.transform;
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			var idx:int = SEA3DGP.cameras.indexOf( this );
			
			if (idx != -1)
				SEA3DGP.setCamera(idx, null);
		}
	}
}