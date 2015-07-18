/*
*
* Copyright (c) 2013 Sunag Entertainment
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

package away3d.textures
{
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.events.Object3DEvent;
	
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	public class CubeReflectionTextureTarget extends CubeReflectionTexture
	{
		private var _target:ObjectContainer3D;
		private var _offset:Vector3D;		
		
		public function CubeReflectionTextureTarget(size:int, target:ObjectContainer3D=null)
		{			
			super(size);			
			this.target = target;
		}
		
		public function updateBounds():void			
		{
			_offset = new Vector3D
				(
					(_target.minX+_target.maxX)*.5,
					(_target.minY+_target.maxY)*.5,
					(_target.minZ+_target.maxZ)*.5
				);					
		}
		
		private function onChangePosition(e:Object3DEvent=null):void
		{			
			position = _target.scenePosition.add(_offset);
		}
		
		public function set target(value:ObjectContainer3D):void
		{
			if (_target == value) return;
			
			if (_target)
			{
				_target.removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onChangePosition);
				_target.removeEventListener(Object3DEvent.POSITION_CHANGED, onChangePosition);
			}
									
			if ((_target = value))
			{				
				_target.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onChangePosition, false, 0, true);
				_target.addEventListener(Object3DEvent.POSITION_CHANGED, onChangePosition, false, 0, true);
				
				updateBounds();
				
				onChangePosition();
			}
		}
		
		public function get target():ObjectContainer3D			
		{
			return _target;
		}
		
		public override function dispose():void
		{
			this.target = null;
			super.dispose();		
		}
	}
}