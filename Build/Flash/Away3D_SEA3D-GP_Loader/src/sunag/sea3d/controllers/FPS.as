package sunag.sea3d.controllers
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.framework.PerspectiveCamera;
	import sunag.sea3d.input.Keyboard;
	import sunag.sea3d.input.KeyboardInput;

	use namespace sea3dgp;
	
	public class FPS extends CameraController
	{
		protected var _camera:PerspectiveCamera;
		protected var _sensibility:Number = .3;
		protected var _referenceX:int;
		protected var _referenceY:int;
		
		public function FPS(camera:PerspectiveCamera)
		{
			_camera = camera;	
			
			SEA3DGP.area.addEventListener(MouseEvent.MOUSE_DOWN, onViewMouseDown);			
			SEA3DGP.area.addEventListener(Event.ENTER_FRAME, onFrame);
			SEA3DGP.area.addEventListener(MouseEvent.MOUSE_WHEEL, onViewMouseWheel);
		}				
		
		override public function dispose():void
		{
			SEA3DGP.area.removeEventListener(MouseEvent.MOUSE_DOWN, onViewMouseDown);
			SEA3DGP.area.removeEventListener(Event.ENTER_FRAME, onFrame);
			SEA3DGP.area.removeEventListener(MouseEvent.MOUSE_WHEEL, onViewMouseWheel);			
		}
		
		protected function onFrame(e:Event):void
		{
			if (!CameraController.actived) return;
			
			var y:Number;
			
			if ( KeyboardInput.isDown( Keyboard.W ) || KeyboardInput.isDown( Keyboard.UP ) )
			{
				y = _camera.scope.y;
				_camera.scope.moveForward( 9 );
				_camera.scope.y = y;
			}
			if ( KeyboardInput.isDown( Keyboard.S ) || KeyboardInput.isDown( Keyboard.DOWN ) )
			{
				y = _camera.scope.y;
				_camera.scope.moveForward( -9 );
				_camera.scope.y = y;
			}
			if ( KeyboardInput.isDown( Keyboard.A ) || KeyboardInput.isDown( Keyboard.LEFT ) )
			{
				y = _camera.scope.y;
				_camera.scope.moveLeft( 7 );
				_camera.scope.y = y;
			}
			if ( KeyboardInput.isDown( Keyboard.D ) || KeyboardInput.isDown( Keyboard.RIGHT ) )
			{
				y = _camera.scope.y;
				_camera.scope.moveLeft( -7 );
				_camera.scope.y = y;
			}
		}
		
		protected function onViewMouseWheel(e:MouseEvent):void
		{
			if (!CameraController.actived || !inView(_camera.view3d))
				return onViewMouseUp(e);
			
			var y:Number = _camera.scope.y;
			_camera.scope.moveForward( e.delta * 10 );
			_camera.scope.y = y;
		}
		
		protected function onViewMouseDown(e:MouseEvent):void
		{
			if (!inView(_camera.view3d))
				return;
			
			SEA3DGP.mouseEnabled = mousePickerOnMove;
			
			_referenceX = SEA3DGP.stage.mouseX;
			_referenceY = SEA3DGP.stage.mouseY;						
			
			SEA3DGP.stage.addEventListener(MouseEvent.MOUSE_MOVE, onViewMouseMove);
			SEA3DGP.stage.addEventListener(MouseEvent.MOUSE_UP, onViewMouseUp);
		}
		
		protected function onViewMouseMove(e:MouseEvent):void
		{
			if (!CameraController.actived || !e.buttonDown)
				return onViewMouseUp(e);
			
			var deltaX:Number = _referenceX - SEA3DGP.stage.mouseX,
				deltaY:Number = _referenceY - SEA3DGP.stage.mouseY;
				
			var rot:Vector3D = _camera.scope.rotation;
			
			rot.x += -deltaY * _sensibility;
			rot.y += -deltaX * _sensibility;	
			
			if (rot.x > 80) rot.x = 80;
			else if (rot.x < -80) rot.x = -80;
			
			_camera.scope.rotation = rot;
			
			_referenceX = SEA3DGP.stage.mouseX;
			_referenceY = SEA3DGP.stage.mouseY;
			
			_camera.dispatchTransform();
		}
		
		protected function onViewMouseUp(e:MouseEvent):void
		{
			SEA3DGP.mouseEnabled = true;
			
			SEA3DGP.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onViewMouseMove);
			SEA3DGP.stage.removeEventListener(MouseEvent.MOUSE_UP, onViewMouseUp);
		}
		
		public function get camera():PerspectiveCamera
		{
			return _camera;
		}
	}
}