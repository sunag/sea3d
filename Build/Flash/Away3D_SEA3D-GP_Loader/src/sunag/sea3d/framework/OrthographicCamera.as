package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.sea3d.animation.CameraAnimation;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAOrthographicCamera;
	
	use namespace sea3dgp;
	
	public class OrthographicCamera extends sunag.sea3d.framework.Camera3D
	{						
		sea3dgp var lens:OrthographicLens;
		
		public function OrthographicCamera()
		{
			super(new away3d.cameras.Camera3D(lens = new OrthographicLens()), CameraAnimation);
		}
		
		public function set height(height:Number):void
		{
			lens.projectionHeight = height;
			dispatchTransform();
		}
		
		public function get height():Number
		{
			return lens.projectionHeight;
		}
		
		override public function clone():Asset			
		{
			var asset:OrthographicCamera = new OrthographicCamera();
			asset.copyFrom( this );
			return asset;
		}
		
		//
		//	LOADER
		//
		
		override public function unproject(x:Number, y:Number, plane:Vector3D=null):Vector3D
		{
			return view3d.unproject( x, y );		
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			lens.projectionHeight = SEAOrthographicCamera(sea).height;
		}
		
		sea3dgp override function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );	
			
			var cam:OrthographicCamera = asset as OrthographicCamera;			
			height = cam.height;
		}				
	}
}