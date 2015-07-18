package sunag.sea3d.input 
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class MouseInput extends InputBase
	{	
		sea3dgp static var stage:Stage;
		sea3dgp static var bDown:Boolean = false;
		
		sea3dgp static function init(stage:Stage):void
		{
			KeyboardInput.stage = stage;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouse);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouse);
		}
		
		sea3dgp static function onMouse(e:MouseEvent):void
		{
			bDown = e.buttonDown;
		}
		
		public static function get buttonDown():Boolean
		{
			return bDown;
		}
	}
}