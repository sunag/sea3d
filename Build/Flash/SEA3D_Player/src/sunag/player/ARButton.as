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
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class ARButton extends Sprite
	{
		private var _color:uint = 0x101212;
		
		private var _bg:Sprite = new Sprite();
		private var _bitmap:Bitmap;
		private var _selected:Boolean = false;
		private var _over:Boolean = false;
		
		private static var _data:BitmapData;
				
		public function ARButton()
		{
			addEventListener(MouseEvent.CLICK, onClick);
			
			if (!_data)
			{
				var _field:TextField = new TextField()
				_field.autoSize = TextFieldAutoSize.LEFT;
				_field.defaultTextFormat = new TextFormat('Verdana',28,0xEEEEEE,null,null,null,null,null,'center');
				_field.text = "AR";
				
				_data = new BitmapData(_field.textWidth, _field.textHeight, true, 0);
				_data.draw(_field);
				
				_field = null;
			}
			
			addChild(_bg);
			addChild(_bitmap=new Bitmap(_data));
			
			_bitmap.alpha = .6;
			_bitmap.x = 5;
			_bitmap.y = 5;
			
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			draw();
		}
		
		protected function onClick(e:MouseEvent):void
		{
			selected = !_selected;
		}
		
		public function set selected(value:Boolean):void
		{
			if (_selected === value) return;
			
			_selected = value;
			
			var e:Event = new Event(Event.CHANGE, false, true);			
			dispatchEvent(e);
			
			if (e.isDefaultPrevented())
			{
				_selected = !_selected;
			}
			
			if (_over) onMouseOver();
			else onMouseOut();
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		private function onMouseOver(e:MouseEvent=null):void
		{
			_over = true;
			_color = _selected ? 0x77FF77 : 0x0077FF;
			draw();
		}
		
		private function onMouseOut(e:MouseEvent=null):void
		{
			_over = false;
			_color = _selected ? 0x77FF77 : 0x101212;
			draw();
		}
		
		private function draw():void
		{
			_bg.graphics.clear();
			_bg.graphics.beginFill(_color, .8);
			_bg.graphics.drawRoundRect(0, 0, 50, 50, 5);						
		}
	}
}