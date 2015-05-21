/* Copyright (c) 2013 Sunag Entertainment
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE. */

package sunag.progressbar
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import sunag.display.BlackSprite;

	public class ProgressCircleLoader extends ProgressCircle
	{
		private var _loader:URLLoader = new URLLoader();
		private var _stage:Stage;
		private var _bs:BlackSprite = new BlackSprite();
		
		public function ProgressCircleLoader()
		{
			super();
			
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener(ProgressEvent.PROGRESS, onProgressDownload);
			
			_bs.visible = false;
		}
				
		public function get backScreen():BlackSprite
		{
			return _bs;
		}
		
		private function onResize(e:Event=null):void
		{					
			_bs.width = stage.stageWidth;
			_bs.height = stage.stageHeight;
			
			x = Math.round(stage.stageWidth/2);
			y = Math.round(stage.stageHeight/2);
		}
		
		public function set stage(value:Stage):void
		{
			if (value)
			{
				_stage = value;
			
				_stage.addChild(_bs);
				_stage.addChild(this);
				
				onResize();
				
				_stage.addEventListener(Event.RESIZE, onResize);
			}
			else if (_stage)
			{
				_stage.removeChild(_bs);
				_stage.removeChild(this);
				
				_stage.removeEventListener(Event.RESIZE, onResize);
				
				_stage = null;
			}
		}
		
		public function load(request:URLRequest, stage:Stage=null):void
		{
			stage = stage;
			progress = NaN;
			_loader.load(request);			
		}
	
		public function dispose():void
		{			
			stage = null;
			_loader.removeEventListener(ProgressEvent.PROGRESS, onProgressDownload);
		}
		
		private function onProgressDownload(e:ProgressEvent):void
		{
			progress = e.bytesLoaded / e.bytesTotal;
		}
		
		public function get data():ByteArray
		{
			return _loader.data;
		}
		
		public function get loader():URLLoader
		{
			return _loader;
		}
	}
}