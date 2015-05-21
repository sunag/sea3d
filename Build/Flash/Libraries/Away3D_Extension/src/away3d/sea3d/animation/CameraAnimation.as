/*
*
* Copyright (c) 2012 Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

package away3d.sea3d.animation
{
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	
	import sunag.sunag;
	import sunag.animation.Animation;
	import sunag.animation.AnimationSet;
	import sunag.animation.data.AnimationFrame;
	
	use namespace sunag;
	
	public class CameraAnimation extends Object3DAnimation
	{
		protected var _camera:Camera3D;
		
		public function CameraAnimation(camera:Camera3D, animationSet:AnimationSet)
		{						
			super(_camera = camera, animationSet);		
		}
		
		public function set camera(value:Camera3D):void
		{
			_camera = value;
		}
		
		public function get camera():Camera3D
		{
			return _camera;
		}				
		
		override protected function updateAnimationFrame(frame:AnimationFrame, kind:Object):void			
		{	
			switch(kind)					
			{
				case Animation.POSITION:						
					if (_relative) 
					{
						_temp = frame.toVector3D();
						
						_comps[0].x = _temp.x;
						_comps[0].y = _temp.y;
						_comps[0].z = _temp.z;
						
						updateRelativeTransform();
					}
					else _camera.position = frame.toVector3D();
					break;							
				case Animation.ROTATION:
					if (_relative) 
					{
						_temp = frame.toRadians();
						
						_comps[1].x = _temp.x;
						_comps[1].y = _temp.y;
						_comps[1].z = _temp.z;
						
						updateRelativeTransform();
					}
					else _camera.rotation = frame.toEuler();
					break;	
				
				case Animation.FOV:						
					(_camera.lens as PerspectiveLens).fieldOfView = frame.x;						
					break;
			}
		}		
	}
}