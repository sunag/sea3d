package sunag.sea3d.events
{
	import flash.geom.Vector3D;
	
	import sunag.sea3dgp;

	public class TouchEvent extends Event
	{
		sea3dgp static var MouseDict:Object = 
			{
				click : CLICK,			
				doubleClick : DOUBLE_CLICK,
				mouseDown : TOUCH_DOWN,
				mouseMove : TOUCH_MOVE,
				mouseOut : TOUCH_OUT,
				mouseOver : TOUCH_OVER,
				mouseUp : TOUCH_UP,
				mouseWheel : WHELL
			}
		
		public static const CLICK:String = "click";
		public static const DOUBLE_CLICK:String = "doubleClick";
		public static const TOUCH_DOWN:String = "touchDown";
		public static const TOUCH_MOVE:String = "touchMove";
		public static const TOUCH_OUT:String = "touchOut";
		public static const TOUCH_OVER:String = "touchOver";
		public static const TOUCH_UP:String = "touchUp";
		public static const WHELL:String = "whell";
		
		public var position:Vector3D;
		public var normal:Vector3D;
		public var delta:Number;
		
		public function TouchEvent(type:String, position:Vector3D, normal:Vector3D, delta:Number)
		{
			super(type);		
			
			this.position = position;
			this.normal = normal;
			this.delta = delta;
		}
	}
}