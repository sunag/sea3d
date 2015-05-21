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
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import sunag.utils.TimeStep;
	
	public class ProgressCircle extends Sprite
	{
		private var _infinity:Boolean = false;
		private var _progress:Number = 0;
		private var _message:Shape;
		private var _messageField:TextField;
		private var circle:Shape = new Shape();
		private var field:TextField;
		private var timeStep:TimeStep;
		
		protected static const format:TextFormat = new TextFormat('Verdana',11,0xEEEEEE,null,null,null,null,null,'center');		
		
		public function ProgressCircle()
		{			
			with(graphics)
			{
				beginFill(0x666666,0.2);
				drawCircle(0,0,25);
				drawCircle(0,0,35);
			}

			field = new TextField();			
			
			with(field)
			{			
				defaultTextFormat=format;
				width=height=0;			
				autoSize='center';
				type='dynamic';
				mouseEnabled=false;
			}
			
			field.y -= 9
			
			addChild(field);			
			addChild(circle);
			
			var filter:GlowFilter = new GlowFilter();
			
			filter.color = 0x007DFF;
			filter.blurX = filter.blurY = 16;
			filter.alpha = 1;			
			filter.knockout=true;
			//filter.alpha = .3;
			filter.quality = BitmapFilterQuality.LOW;
						
			circle.filters = [filter];
			
			//filters = [UIManager.occlusion];
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
				_message.y = 50;
				
				_messageField.x = _message.x + 6;
				_messageField.y = _message.y + 2;
				
				with(_message.graphics)
				{
					clear();
					beginFill(0x000000,0.2);
					drawRoundRect(0,0,w,h,9);
				}				
			}
		}
				
		private function set infinity(value:Boolean):void
		{
			if (_infinity == value) return;			
			
			if (value)
			{
				field.text = "...";	
				
				var p:Number = 90;
				
				circle.graphics.clear();
				circle.graphics.lineStyle(5.0, 0x007DFF, 0.7, false, "normal", CapsStyle.NONE);					
				drawArc(circle.graphics, 0, 0, 30, p/360, -p/360, 50);
			}
			else circle.rotation = 0;
			
			if (value)
			{
				timeStep = new TimeStep(60, false);				
			}
			else
			{
				timeStep = null;
			}
			
			if (value) addEventListener(Event.ENTER_FRAME,progressEvent);
			else removeEventListener(Event.ENTER_FRAME,progressEvent);
				
			_infinity = value;			
		}
		
		private function progressEvent(e:Event):void
		{
			timeStep.update();
			circle.rotation += timeStep.deltaTime * 360;
		}
		
		public function get progress():Number
		{
			return _progress;
		}
		
		public function set progress(value:Number):void
		{
			infinity = isNaN(value) || value == Infinity;
			
			if (!_infinity)
			{
				_progress = value;
				var p:Number = value * 360;
				field.text = String(int(value*100));	
				circle.graphics.clear();
				circle.graphics.lineStyle(5.0, 0x007DFF, 0.7, false, "normal", CapsStyle.NONE);					
				drawArc(circle.graphics, 0, 0, 30, p/360, -p/360, 50);
			}
		}
		
		private function drawArc(g:Graphics, centerX:Number, centerY:Number, radius:Number, startAngle:Number, arcAngle:Number, steps:int):void
		{					
			var twoPI:Number = 2 * Math.PI;
			
			startAngle += -90/360;
										
			var angleStep:Number = arcAngle/steps;
						
			var xx:Number = centerX + Math.cos(startAngle * twoPI) * radius;
			var yy:Number = centerY + Math.sin(startAngle * twoPI) * radius;
						
			g.moveTo(xx, yy);
						
			for(var i:int=1; i<=steps; i++)
			{							
				var angle:Number = startAngle + i * angleStep;
								
				xx = centerX + Math.cos(angle * twoPI) * radius;
				yy = centerY + Math.sin(angle * twoPI) * radius;
				
				g.lineTo(xx, yy);
			}
		}
	}
}