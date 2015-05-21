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
	import away3d.filters.tasks.Filter3DColorBalanceTask;
	
	import flash.geom.Vector3D;

	public class ColorBalanceFilter3D extends Filter3DBase
	{
		private var _colorBalance : Filter3DColorBalanceTask;

		public function ColorBalanceFilter3D(preserveLuminance:Boolean=false)
		{
			super();
			_colorBalance = new Filter3DColorBalanceTask(preserveLuminance);
			addTask(_colorBalance);			
		}
		
		public function set shadows(value:Vector3D):void
		{
			_colorBalance.shadows = value;
		}
		
		public function get shadows():Vector3D
		{
			return _colorBalance.shadows;
		}
		
		public function set midtones(value:Vector3D):void
		{
			_colorBalance.midtones = value;
		}
		
		public function get midtones():Vector3D
		{
			return _colorBalance.midtones;
		}
		
		public function set highlights(value:Vector3D):void
		{
			_colorBalance.highlights = value;
		}
		
		public function get highlights():Vector3D
		{
			return _colorBalance.highlights;
		}
		
		public function set amount(value:Number):void
		{
			_colorBalance.amount = value;
		}				
		
		public function get amount():Number
		{
			return _colorBalance.amount;
		}
		
		public function get preserveLuminance():Boolean
		{
			return _colorBalance.preserveLuminance;
		}
	}
}
