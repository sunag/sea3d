/* Copyright (c) 2013 Sunag Entertainment
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE. */

package sunag.controller 
{
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Matrix3D;
    import flash.geom.Vector3D;
    import flash.ui.Keyboard;
    
    import away3d.cameras.Camera3D;
    import away3d.core.math.Matrix3DUtils;

	public class FreeCameraController
	{
		private var _stage : Stage;
		private var _target : Vector3D;
		private var _camera : Camera3D;
		private var _speed : Vector3D = new Vector3D();
		private var _drag:Boolean = false;
		private var _referenceX : Number = 0;
		private var _referenceY : Number = 0;
		private var _shift:Boolean = false;
		private var _ctrl:Boolean = false;
		private var _pivot:Vector3D;
		private var _mouseLock:Boolean = false;
		private var _keys:Object = {};
		private var _orbit:Matrix3D = new Matrix3D();

		public function FreeCameraController(camera : Camera3D, stage : Stage)
		{
			_stage = stage;
			_target = new Vector3D();
			_camera = camera;

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);				
		}

		public function set pivot(val:Vector3D):void
		{
			_pivot = val;
		}
		
		public function get mode():Vector3D
		{
			return _pivot;
		}
	
		public function dispose() : void
		{
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
            _stage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);	
		}

		public function get stage():Stage
		{
			return _stage;
		}
		
		public function get target() : Vector3D
		{
			return _target;
		}

		public function set target(value : Vector3D) : void
		{
			_target = value;
		}

		public function update() : void
		{		
			if (_drag) updateTarget();
			
			var value:Number = 1;
			
			if (_ctrl) value /= 10;
			if (_shift) value *= 5;
			
			if (_keys[Keyboard.W] || _keys[Keyboard.UP])
			{
				_speed.z += value;
			}
			if (_keys[Keyboard.S] || _keys[Keyboard.DOWN])
			{
				_speed.z -= value;
			}			
			if (_keys[Keyboard.A] || _keys[Keyboard.LEFT])
			{
				_speed.w += value;
			}
			if (_keys[Keyboard.D] || _keys[Keyboard.RIGHT])
			{
				_speed.w -= value;
			}
									
			// update
			
			var t:Matrix3D = _camera.transform.clone();
			
			if (_pivot)
			{
				t.appendRotation(-_speed.x + (_speed.w/3), Vector3D.Y_AXIS, _pivot);
				t.appendRotation(-_speed.y, Matrix3DUtils.getRight(t), _pivot);
				
				_camera.transform = t;
				_camera.lookAt(_pivot);
				
				_camera.moveForward(_speed.z * (Vector3D.distance(_pivot, t.position) / 1000));
			}
			else
			{						
				t.appendRotation(-_speed.x, Vector3D.Y_AXIS, _camera.transform.position);
				t.appendRotation(-_speed.y, Matrix3DUtils.getRight(t), _camera.transform.position);		
				
				_camera.transform = t;
				
				_camera.moveLeft(_speed.w);
				_camera.moveForward(_speed.z);
			}																
			
			_speed.scaleBy(.70);
			_speed.w *= .70;
		}

		private function onMouseMove(e:MouseEvent):void
		{
			if (_mouseLock)
			{
				_speed.x += -e.movementX / 30;
				_speed.y += -e.movementY / 30;
			}
			_mouseLock = stage.mouseLock;
		}
		
		private function updateTarget() : void
		{
			var mouseX : Number = _stage.mouseX;
			var mouseY : Number = _stage.mouseY;
			
			_speed.x += (_referenceX - mouseX) / 18;
			_speed.y += (_referenceY - mouseY) / 18;
			
			_referenceX = _stage.mouseX;
			_referenceY = _stage.mouseY;
		}

		private function onKeyDown(e:KeyboardEvent):void
		{
			_shift = e.shiftKey;
			_ctrl = e.ctrlKey;
			_keys[e.keyCode] = true;
		}
		
		private function onKeyUp(e:KeyboardEvent):void
		{
			_shift = e.shiftKey;
			_ctrl = e.ctrlKey;
			delete _keys[e.keyCode];
		}
		
		private function onMouseDown(event : MouseEvent) : void
		{
			if (_stage.mouseLock) return;
			
			_drag = true;			
			_referenceX = _stage.mouseX;
			_referenceY = _stage.mouseY;
		}

		private function onMouseUp(event : MouseEvent) : void
		{
			_drag = false;
		}

        private function onMouseWheel(event:MouseEvent) : void
        {
            _speed.z += event.delta;
        }
	}
}
