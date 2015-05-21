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
	
	public class SEACubeMap extends SEACubeBase
	{
		public static const TYPE:String = "cmap";
		
		public var format:String;
		public var faces:Vector.<ByteArray>;		
							
		private var _loaders:Vector.<Loader>;
		private var _callback:Function;
		
		public var bitmaps:Vector.<BitmapData>;
		
		public function SEACubeMap(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		public function set loading(val:Boolean):void
		{
			if (_loaders && !val) 
			{
				for each(var loader:Loader in _loaders)
				{
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onCubeBitmap);
					loader.unloadAndStop();
				}				
				
				_loaders = null;
			}			
		}
		
		public function get loading():Boolean
		{
			return _loaders != null;
		}		
		
		public function loadBitmaps(callback:Function):void
		{
			_callback = callback;
			
			bitmaps = new Vector.<BitmapData>(6, true);
			_loaders = new Vector.<Loader>(6, true);
			
			for(var i:int = 0; i < 6; i++)
			{
				_loaders[i] = new Loader();
				_loaders[i].contentLoaderInfo.addEventListener(Event.COMPLETE, onCubeBitmap);
				_loaders[i].loadBytes(faces[i]);
			}
		}
		
		private function onCubeBitmap(e:Event):void
		{
			var index:int = _loaders.indexOf( (e.target as LoaderInfo).loader );									
			
			bitmaps[index] = (_loaders[index].content as Bitmap).bitmapData;
			
			for(var i:int = 0; i < 6; i++)
				if (!bitmaps[i]) return;
			
			loading = false;
			
			_callback(this);
			_callback = null;	
		}
		
		public override function load():void
		{
			format = data.readUTFBytes(4);
			
			faces = new Vector.<ByteArray>(6, true);
			
			for(var i:int = 0; i < 6; i++)
			{
				var size:uint = data.readUnsignedInt();
				faces[i] = new ByteArray();			
				faces[i].writeBytes(data, data.position, size);			
				data.position += size;		
			}			
		}
	}
}