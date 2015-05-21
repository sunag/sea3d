package sunag.sea3d.controllers
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.framework.OrthographicCamera;
	import sunag.sea3d.input.Keyboard;
	import sunag.sea3d.input.KeyboardInput;

	use namespace sea3dgp;
	
	public class TopNavitation extends CameraController
	{
		protected var _camera:OrthographicCamera;
		protected var _sensibility:Number = 1;
		protected var _referenceX:int;
		protected var _referenceY:int;
		
		public function TopNavitation(camera:OrthographicCamera)
		{
			_camera = camera;			
			_camera.view3d.addEventListener(MouseEvent.MOUSE_DOWN, onViewMouseDown);			
			_camera.view3d.addEventListener(Event.ENTER_FRAME, onFrame);
			SEA3DGP.content.addEventListener(MouseEvent.MOUSE_WHEEL, onViewMouseWheel);
			SEA3DGP.content.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onViewMouseMiddleDown);
		}				
		
		override public function dispose():void
		{			
			_camera.view3d.removeEventListener(MouseEvent.MOUSE_DOWN, onViewMouseDown);			
			_camera.view3d.removeEventListener(Event.ENTER_FRAME, onFrame);
			SEA3DGP.content.removeEventListener(MouseEvent.MOUSE_WHEEL, onViewMouseWheel);
			SEA3DGP.content.removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onViewMouseMiddleDown);			
		}
		
		protected function onFrame(e:Event):void
		{
			if (!CameraController.actived) return;
			
			const speed:Number = 8;
			
			if ( KeyboardInput.isDown( Keyboard.W ) || KeyboardInput.isDown( Keyboard.UP ) )
			{
				_camera.scope.moveUp( speed );
				_camera.dispatchTransform();
			}
			if ( KeyboardInput.isDown( Keyboard.S ) || KeyboardInput.isDown( Keyboard.DOWN ) )
			{
				_camera.scope.moveUp( -speed );
				_camera.dispatchTransform();
			}
			if ( KeyboardInput.isDown( Keyboard.A ) || KeyboardInput.isDown( Keyboard.LEFT ) )
			{
				_camera.scope.moveLeft( speed );
				_camera.dispatchTransform();
			}
			if ( KeyboardInput.isDown( Keyboard.D ) || KeyboardInput.isDown( Keyboard.RIGHT ) )
			{
				_camera.scope.moveLeft( -speed );				
				_camera.dispatchTransform();
			}			
		}
		
		sea3dgp function onViewMouseMiddleDown(e:MouseEvent):void
		{
			onViewMouseDown(e);
		}
		
		sea3dgp function onViewMouseDown(e:MouseEvent):void
		{
			SEA3DGP.mouseEnabled = mousePickerOnMove;
			
			_referenceX = SEA3DGP.stage.mouseX;
			_referenceY = SEA3DGP.stage.mouseY;
			
			SEA3DGP.stage.addEventListener(MouseEvent.MOUSE_MOVE, onViewMouseMove);
			SEA3DGP.stage.addEventListener(MouseEvent.MOUSE_UP, onViewMouseUp);
		}
		
		sea3dgp function onViewMouseMove(e:MouseEvent):void
		{
			if (!CameraController.actived || !e.buttonDown)
				return onViewMouseUp(e);
			
			var deltaX:Number = _referenceX - SEA3DGP.stage.mouseX,
				deltaY:Number = _referenceY - SEA3DGP.stage.mouseY;
				
			var pos:Vector3D = _camera.scope.position;
			
			pos.x += deltaX * _sensibility;
			pos.z += -deltaY * _sensibility;	
			
			_camera.scope.position = pos;
			
			_referenceX = SEA3DGP.stage.mouseX;
			_referenceY = SEA3DGP.stage.mouseY;
			
			_camera.dispatchTransform();
		}
		
		sea3dgp function onViewMouseWheel(e:MouseEvent):void
		{
			_camera.lens.projectionHeight += -e.delta * 10;
			
			if (_camera.lens.projectionHeight < 100) 
				_camera.lens.projectionHeight = 100;
			
			_camera.dispatchTransform();
		}
		
		protected function onViewMouseUp(e:MouseEvent):void
		{
			SEA3DGP.mouseEnabled = true;
			
			SEA3DGP.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onViewMouseMove);
			SEA3DGP.stage.removeEventListener(MouseEvent.MOUSE_UP, onViewMouseUp);
		}
		
		public function get camera():OrthographicCamera
		{
			return _camera;
		}
	}
}