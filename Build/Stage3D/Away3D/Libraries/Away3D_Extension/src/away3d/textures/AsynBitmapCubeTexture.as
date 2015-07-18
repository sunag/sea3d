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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import away3d.arcane;
	
	import sunag.utils.BitmapUtils;
	
	use namespace arcane;

	public class AsynBitmapCubeTexture extends BitmapCubeTexture
	{
		private static const bitmap:BitmapData = new BitmapData(1,1,false,0x999999);
		
		private var _posX:Loader;
		private var _negX:Loader;		
		private var _posY:Loader;
		private var _negY:Loader;	
		private var _posZ:Loader;
		private var _negZ:Loader;		
		
		private var pX:BitmapData;
		private var nX:BitmapData;
		private var pY:BitmapData;
		private var nY:BitmapData;
		private var pZ:BitmapData;
		private var nZ:BitmapData;
		private var count:int = 0;		
		
		public function AsynBitmapCubeTexture(posX : *=null, negX : *=null, posY : *=null, negY : *=null, posZ : *=null, negZ : *=null)
		{
			super(bitmap,bitmap,bitmap,bitmap,bitmap,bitmap);
			
			load(posX, negX, posY, negY, posZ, negZ);
		}		
		
		public function load(posX : *, negX : *, posY : *, negY : *, posZ : *, negZ : *):void
		{
			_posX = new Loader();
			_negX = new Loader();		
			_posY = new Loader();
			_negY = new Loader();		
			_posZ = new Loader();
			_negZ = new Loader();
			
			loaderData(_posX, posX);
			loaderData(_negX, negX);
			loaderData(_posY, posY);
			loaderData(_negY, negY);
			loaderData(_posZ, posZ);
			loaderData(_negZ, negZ);
			
			_posX.contentLoaderInfo.addEventListener(Event.COMPLETE, onPosX);
			_negX.contentLoaderInfo.addEventListener(Event.COMPLETE, onNegX);
			_posY.contentLoaderInfo.addEventListener(Event.COMPLETE, onPosY);
			_negY.contentLoaderInfo.addEventListener(Event.COMPLETE, onNegY);
			_posZ.contentLoaderInfo.addEventListener(Event.COMPLETE, onPosZ);
			_negZ.contentLoaderInfo.addEventListener(Event.COMPLETE, onNegZ);
		}
		
		private function loaderData(loader:Loader, data:*):void
		{
			if (data is ByteArray) loader.loadBytes(data);
			else if (data is URLRequest) loader.load(data);
			else if (data is String) loader.load(new URLRequest(data));
			else throw new Error("Invalid data format.");
		}
		
		private function onPosX(e:Event):void
		{			
			_posX.contentLoaderInfo.removeEventListener(Event.COMPLETE, onPosX);									
			pX = BitmapUtils.powerOfTwoBitmapData( Bitmap(LoaderInfo(e.target).content).bitmapData, 1024 );
			_posX.unload();
			_posX = null;
			if (++count == 6) applyCubeMap();
		}
		
		private function onNegX(e:Event):void
		{			
			_negX.contentLoaderInfo.removeEventListener(Event.COMPLETE, onNegX);						
			nX = BitmapUtils.powerOfTwoBitmapData( Bitmap(LoaderInfo(e.target).content).bitmapData, 1024 );
			_negX.unload();
			_negX = null;
			if (++count == 6) applyCubeMap();
		}
		
		private function onPosY(e:Event):void
		{			
			_posY.contentLoaderInfo.removeEventListener(Event.COMPLETE, onPosY);									
			pY = BitmapUtils.powerOfTwoBitmapData( Bitmap(LoaderInfo(e.target).content).bitmapData, 1024 );
			_posY.unload();
			_posY = null;
			if (++count == 6) applyCubeMap();
		}
		
		private function onNegY(e:Event):void
		{			
			_negY.contentLoaderInfo.removeEventListener(Event.COMPLETE, onNegY);						
			nY = BitmapUtils.powerOfTwoBitmapData( Bitmap(LoaderInfo(e.target).content).bitmapData, 1024 );
			_negY.unload();
			_negY = null;
			if (++count == 6) applyCubeMap();
		}
		
		private function onPosZ(e:Event):void
		{			
			_posZ.contentLoaderInfo.removeEventListener(Event.COMPLETE, onPosY);									
			pZ = BitmapUtils.powerOfTwoBitmapData( Bitmap(LoaderInfo(e.target).content).bitmapData, 1024 );
			_posZ.unload();
			_posZ = null;
			if (++count == 6) applyCubeMap();
		}
		
		private function onNegZ(e:Event):void
		{			
			_negZ.contentLoaderInfo.removeEventListener(Event.COMPLETE, onNegZ);						
			nZ = BitmapUtils.powerOfTwoBitmapData( Bitmap(LoaderInfo(e.target).content).bitmapData, 1024 );
			_negZ.unload();
			_negZ = null;
			if (++count == 6) applyCubeMap();
		}
		
		private function applyCubeMap():void
		{
			setCubeMap(pX, nX, pY, nY, pZ, nZ);
			
			pX = nX = pY = nY = pZ = nZ = null;
			
			if (hasEventListener(Event.COMPLETE))
				dispatchEvent(new Event(Event.COMPLETE));
		}			
	}
}
