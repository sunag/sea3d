package sunag.sea3d.controllers
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.framework.Camera3D;

	public class Orbit extends CameraController
	{
		protected var _camera:Camera3D;
		protected var _sensibility:Number = .3;
		protected var _referenceX:int;
		protected var _referenceY:int;
		protected var _center:Vector3D = new Vector3D();
		protected var _distance:Number = 1500;
		protected var _height:Number = 800;
		
		use namespace sea3dgp;
		
		public function Orbit(camera:Camera3D)
		{
			_camera = camera;
			_camera.scope.y = _height;
			_camera.scope.lookAt(_center);
			_camera.dispatchTransform();
			
			SEA3DGP.area.addEventListener(MouseEvent.MOUSE_DOWN, onViewMouseDown);			
			SEA3DGP.area.addEventListener(Event.ENTER_FRAME, onFrame);
			SEA3DGP.area.addEventListener(MouseEvent.MOUSE_WHEEL, onViewWheel);
		}
		
		override public function dispose():void
		{
			SEA3DGP.area.removeEventListener(MouseEvent.MOUSE_DOWN, onViewMouseDown);			
			SEA3DGP.area.removeEventListener(Event.ENTER_FRAME, onFrame);
			SEA3DGP.area.removeEventListener(MouseEvent.MOUSE_WHEEL, onViewWheel);
		}
		
		protected function onFrame(e:Event):void
		{
			
		}
		
		public function set center(val:Vector3D):void
		{
			_center = val.clone();
			_camera.scope.lookAt( _center );
		}
		
		public function get center():Vector3D
		{
			return _center;
		}
		
		protected function limDist(val:Number):Number
		{
			if (Math.abs(val) < 400) val = val < 0 ? -400 : 400;
			else if (Math.abs(val) > 2500) val = val < 0 ? -2500 : 2500;
			
			return val;
		}
		
		protected function onViewWheel(e:MouseEvent):void
		{
			if (!inView(_camera.view3d))
				return;
			
			var pos:Vector3D = _camera.scope.position;
			
			var distX:Number = pos.x - _center.x;
			var distY:Number = pos.z - _center.z;
			
			distX += -e.delta * (distX / 200);
			distY += -e.delta * (distY / 200);
				
			distX = limDist(distX);
			distY = limDist(distY);
			
			_camera.scope.x = _center.x + distX;
			_camera.scope.z = _center.z + distY;
			
			_camera.scope.lookAt( _center );
			
			_camera.dispatchTransform();
		}
		
		protected function onViewMouseDown(e:MouseEvent):void
		{
			if (!inView(_camera.view3d))
				return;
			
			_referenceX = SEA3DGP.stage.mouseX;
			_referenceY = SEA3DGP.stage.mouseY;
			
			SEA3DGP.stage.addEventListener(MouseEvent.MOUSE_MOVE, onViewMouseMove);
			SEA3DGP.stage.addEventListener(MouseEvent.MOUSE_UP, onViewMouseUp);
		}
		
		protected function updateDistance():void
		{
			var angle:Vector3D = _camera.position
				
			_camera.scope.y = _height;
		}
		
		protected function onViewMouseMove(e:MouseEvent):void
		{
			if (!CameraController.actived || !e.buttonDown)
				return onViewMouseUp(e);
			
			var deltaX:Number = (_referenceX - SEA3DGP.stage.mouseX) * _sensibility,
				deltaY:Number = (_referenceY - SEA3DGP.stage.mouseY) * _sensibility;
			
			_height += deltaY * 10;		
			
			if (_height < 0) _height = 0;
			if (_height > 3000) _height = 3000;
									
			var mat:Matrix3D = _camera.scope.transform;										
			
			mat.appendRotation(-deltaX, Vector3D.Y_AXIS, _center);			
			
			_camera.scope.transform = mat;	
			
			updateDistance();
			
			_camera.scope.lookAt( _center );
			
			_referenceX = SEA3DGP.stage.mouseX;
			_referenceY = SEA3DGP.stage.mouseY;
			
			_camera.dispatchTransform();
		}
		
		protected function onViewMouseUp(e:MouseEvent):void
		{
			SEA3DGP.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onViewMouseMove);
			SEA3DGP.stage.removeEventListener(MouseEvent.MOUSE_UP, onViewMouseUp);
		}
		
		public function get camera():Camera3D
		{
			return _camera;
		}
	}
}