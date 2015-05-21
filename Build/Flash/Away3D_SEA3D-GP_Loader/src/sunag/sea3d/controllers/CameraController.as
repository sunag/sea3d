package sunag.sea3d.controllers
{
	import away3d.containers.View3D;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.IDisposable;

	use namespace sea3dgp;
	
	public class CameraController implements IDisposable
	{
		public static const DEACTIVE:int = 0;
		public static const ACTIVE:int = 1;		
		
		sea3dgp static var st:int = ACTIVE;				
		
		public static function set state(val:int):void
		{
			st = val;
		}
		
		public static function get state():int
		{
			return st;
		}
		
		public static function get actived():Boolean			
		{
			return st == ACTIVE;
		}
		
		public var mousePickerOnMove:Boolean = false;
		
		public function inView(v:View3D):Boolean
		{
			return v.getBounds(v.parent).contains(v.mouseX, v.mouseY);
		}
		
		public function dispose():void
		{			
		}
	}
}