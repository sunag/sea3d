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

package sunag.player
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	public class UploadButton extends Sprite
	{
		private var _color:uint = 0x101212;
		
		private var _bg:Sprite = new Sprite();
		private var _sprite:Sprite = new Sprite();
		
		private var _fileReference:FileReference = new FileReference();
		private var _fileFilter:Array;
		private var _data:ByteArray;
		
		public function UploadButton()
		{
			addEventListener(MouseEvent.CLICK, onUpload);
			
			_fileReference.addEventListener(Event.SELECT, onFileSelected);
			_fileReference.addEventListener(Event.COMPLETE, onFileLoaded);
						
			addChild(_bg);
			addChild(_sprite);
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			draw();
		}
		
		public function get data():ByteArray
		{
			return _data;
		}
		
		public function set fileFilter(value:Array):void
		{
			_fileFilter = value;
		}
		
		public function get fileFilter():Array
		{
			return _fileFilter;
		}
		
		private function onUpload(e:MouseEvent):void
		{
			if (_fileFilter) _fileReference.browse(_fileFilter);
		}
		
		private function onFileSelected(e:Event):void
		{
			_fileReference.load();
		}
		
		private function onFileLoaded(e:Event):void
		{
			_data = _fileReference.data;	
			dispatchEvent(new PlayerEvent(PlayerEvent.UPLOAD));			
		}
		
		private function onMouseOver(e:MouseEvent):void
		{
			_color = 0x0077FF;
			draw();
		}
		
		private function onMouseOut(e:MouseEvent):void
		{
			_color = 0x101212;
			draw();
		}
		
		private function draw():void
		{
			_bg.graphics.clear();
			_bg.graphics.beginFill(_color, .8);
			_bg.graphics.drawRoundRect(0, 0, 50, 50, 5);			
			
			_sprite.graphics.clear();
			
			_sprite.x = _sprite.y = 0;
			
			var _th:int = 15;
			_sprite.graphics.beginFill(0xCCCCCC,0.8);
			_sprite.graphics.moveTo(0, 0);
			_sprite.graphics.lineTo(_th*2, 0);
			_sprite.graphics.lineTo(_th, -_th);
			_sprite.graphics.lineTo(0, 0);
			_sprite.graphics.drawRect(10, 0, 10, 13); 
			_sprite.x = 10;
			_sprite.y = 25;
		}
	}
}