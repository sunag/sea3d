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
	import away3d.filters.tasks.Filter3DVibrance;

	public class VibranceFilter3D extends Filter3DBase
	{
		private var _vibrance : Filter3DVibrance;

		public function VibranceFilter3D(vibrance:Number=1)
		{
			super();
			_vibrance = new Filter3DVibrance(vibrance);
			addTask(_vibrance);			
		}
		
		public function set vibrance(value:Number):void
		{
			_vibrance.vibrance = value;
		}
		
		public function get vibrance():Number
		{
			return _vibrance.vibrance;
		}		
	}
}
