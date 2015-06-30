/*
*
* Copyright (c) 2014 Sunag Entertainment
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

package away3d.filters
{
	import away3d.filters.tasks.Filter3DVignette;

	public class VignetteFilter3D extends Filter3DBase
	{
		private var _vignette : Filter3DVignette;

		public function VignetteFilter3D(cx:Number=0.5, cy:Number=0.5, amount:Number=0.7, radius:Number=1.0, size:Number=.40, sepia:Boolean=false)
		{
			super();
			_vignette = new Filter3DVignette(cx, cy, amount, radius, size, sepia);
			addTask(_vignette);			
		}
		
		/** Center X position of effect relative to Display Object being filtered */
		public function get centerX():Number { return _vignette.centerX; }
		public function set centerX(value:Number):void { _vignette.centerX = value; }
		
		/** Center Y position of effect relative to Display Object being filtered */
		public function get centerY():Number { return _vignette.centerY; }
		public function set centerY(value:Number):void { _vignette.centerY = value; }
		
		/** Amount of effect (smaller value is less noticeable) */
		public function get amount():Number { return _vignette.amount; }
		public function set amount(value:Number):void { _vignette.amount = value; }
		
		/** Size of effect */
		public function get size():Number { return _vignette.size; }
		public function set size(value:Number):void { _vignette.size = value; }
		
		/** Radius of vignette center */
		public function get radius():Number { return _vignette.radius; }
		public function set radius(value:Number):void { _vignette.radius = value; }
		
		/** Apply a sepia color to Display Object being filtered */
		public function get useSepia():Boolean { return _vignette.useSepia; }
		public function set useSepia(value:Boolean):void { _vignette.useSepia = value; }	
	}
}
