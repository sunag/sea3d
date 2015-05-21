package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.sea3d.animation.CameraAnimation;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAPerspectiveCamera;
	
	use namespace sea3dgp;
	
	public class PerspectiveCamera extends sunag.sea3d.framework.Camera3D
	{						
		sea3dgp var lens:PerspectiveLens;
		
		public function PerspectiveCamera()
		{
			super(new away3d.cameras.Camera3D(lens = new PerspectiveLens()), CameraAnimation);
			lens.near = 1;
			lens.far = 6000;
		}
		
		public function set fov(fov:Number):void
		{
			lens.fieldOfView = fov;
		}
		
		public function get fov():Number
		{
			return lens.fieldOfView;
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
				
			lens.fieldOfView = SEAPerspectiveCamera(sea).fov;
		}
				
		override public function unproject(x:Number, y:Number, plane:Vector3D=null):Vector3D
		{
			var plane:Vector3D = plane || Vector3D.Y_AXIS;
			var unproject:Vector3D = view3d.unproject( x, y );
			
			var cam:Vector3D = camera.scenePosition;
			var d0:Number = plane.x*cam.x + plane.y*cam.y + plane.z*cam.z;
			var d1:Number = plane.x*unproject.x + plane.y*unproject.y + plane.z*unproject.z;
			var mag:Number = d1/( d1 - d0 );
			
			return new Vector3D
			(			
				unproject.x + ( cam.x - unproject.x )*mag,
				unproject.y + ( cam.y - unproject.y )*mag,
				unproject.z + ( cam.z - unproject.z )*mag
			);			
		}
		
		override public function clone():Asset			
		{
			var asset:PerspectiveCamera = new PerspectiveCamera();
			asset.copyFrom( this );
			return asset;
		}
		
		sea3dgp override function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var cam:PerspectiveCamera = asset as PerspectiveCamera;			
			fov = cam.fov;
		}
	}
}