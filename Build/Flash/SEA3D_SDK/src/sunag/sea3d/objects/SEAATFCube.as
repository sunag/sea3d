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

package sunag.sea3d.objects
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	
	public class SEAATFCube extends SEACubeBase
	{
		public static const TYPE:String = "atfc";
		
		private var _loader:Loader;
		private var _callback:Function;
		
		public var bitmapData:BitmapData;	
		
		public function SEAATFCube(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		public function set loading(val:Boolean):void
		{
			if (_loader && !val) 
			{
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
				_loader.unloadAndStop();
				_loader = null;
			}			
		}
		
		public function get loading():Boolean
		{
			return _loader != null;
		}				
		
		public function loadBitmap(callback:Function):void
		{
			_callback = callback;
			_loader = new Loader();			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.loadBytes(data);
		}
		
		private function onComplete (e:Event):void
		{							
			bitmapData = Bitmap(LoaderInfo(e.target).content).bitmapData;	
			
			loading = false;			
			
			_callback(this);
			
			_callback = null;
		}
	}
}