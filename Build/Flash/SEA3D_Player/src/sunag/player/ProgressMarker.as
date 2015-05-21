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
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	public class ProgressMarker extends Sprite
	{
		private var _mark:Sprite = new Sprite();
		private var _messageField:TextField;
		private var _message:Shape;
		
		protected static const format:TextFormat = new TextFormat('Verdana',11,0xEEEEEE,null,null,null,null,null,'center');
		
		public function ProgressMarker()
		{
			addChild(_mark);
			
			var _th:int = 7;
			_mark.graphics.beginFill(0x101212,0.9);
			_mark.graphics.moveTo(0, 0);
			_mark.graphics.lineTo(_th*2, 0);
			_mark.graphics.lineTo(_th, _th);
			_mark.graphics.lineTo(0, 0);
			_mark.x = -_th;
			_mark.y = -_th;
		}
		
		public function get text():String
		{
			return _messageField.htmlText;
		}
		
		public function set text(value:String):void
		{					
			_setText(value, false);
		}
		
		public function get htmlText():String
		{
			return _messageField.htmlText;
		}
		
		public function set htmlText(value:String):void
		{					
			_setText(value, true);
		}
		
		private function _setText(value:String, isHtml:Boolean):void
		{
			if (!_message && value) 			
			{
				_message = new Shape();
				addChild(_message);
				
				_messageField = new TextField();			
				
				with(_messageField)
				{			
					defaultTextFormat=format;
					width=height=0;			
					autoSize='center';					
					type='dynamic';					
					mouseEnabled=false;		
				}
				
				addChild(_messageField);
			}
			else if (_message && !value) 
			{
				removeChild(_message);
				removeChild(_messageField);
				_message = null;
				_messageField = null;
			}	
			
			if (value)
			{
				isHtml ? _messageField.htmlText = value : _messageField.text = value;								
				
				var w:int = _messageField.textWidth + 16;
				var h:int = _messageField.textHeight + 8;
				
				_message.x = -w/2;
				_message.y = -_mark.height - h;
				
				_messageField.x = _message.x + 6;
				_messageField.y = _message.y + 2;
				
				with(_message.graphics)
				{
					clear();
					beginFill(0x101212,0.9);
					drawRoundRect(0,0,w,h,9);
				}				
			}
		}
	}
}