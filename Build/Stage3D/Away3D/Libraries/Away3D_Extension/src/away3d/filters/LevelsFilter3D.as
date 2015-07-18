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

package away3d.filters
{
	import away3d.filters.tasks.Filter3DLevelsTask;
	
	import flash.geom.Point;

	public class LevelsFilter3D extends Filter3DBase
	{
		private var _levels : Filter3DLevelsTask;

		public function LevelsFilter3D(red:Point=null, green:Point=null, blue:Point=null, rgb:Point=null)
		{
			super();
			_levels = new Filter3DLevelsTask(red,green,blue,rgb);
			addTask(_levels);			
		}
		
		public function set red(value:Point):void
		{
			_levels.red = value;
		}
		
		public function get red():Point
		{
			return _levels.red;
		}
		
		public function set green(value:Point):void
		{
			_levels.green = value;
		}
		
		public function get green():Point
		{
			return _levels.green;
		}
		
		public function set blue(value:Point):void
		{
			_levels.blue = value;
		}
		
		public function get blue():Point
		{
			return _levels.blue;
		}
		
		public function set rgb(value:Point):void
		{
			_levels.rgb = value;
		}
		
		public function get rgb():Point
		{
			return _levels.rgb;
		}
	}
}
