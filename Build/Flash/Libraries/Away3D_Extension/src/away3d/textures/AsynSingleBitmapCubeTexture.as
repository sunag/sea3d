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
	import away3d.materials.utils.MipmapGenerator;
	import away3d.tools.utils.TextureUtils;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display3D.textures.TextureBase;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import sunag.utils.BitmapUtils;
	
	use namespace arcane;

	public class AsynSingleBitmapCubeTexture extends BitmapCubeTexture
	{
		private static const bitmap:BitmapData = new BitmapData(1,1,false,0x999999);
		
		private var _loader:Loader;
		
		public function AsynSingleBitmapCubeTexture(data : *)
		{
			super(bitmap,bitmap,bitmap,bitmap,bitmap,bitmap);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			
			if (data is ByteArray) _loader.loadBytes(data);
			else if (data is URLRequest) _loader.load(data);
			else if (data is String) _loader.load(new URLRequest(data));
			else throw new Error("Invalid data format.");
		}		
		
		private function onComplete (event:Event):void
		{							
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);			
			
			var bitmapData:BitmapData = BitmapUtils.powerOfTwoBitmapData( Bitmap(LoaderInfo(event.target).content).bitmapData );
			
			setCubeMap(bitmapData, bitmapData, bitmapData, bitmapData, bitmapData, bitmapData);
			
			_loader.unload();
			_loader = null;
			
			if (hasEventListener(Event.COMPLETE))
				dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}
