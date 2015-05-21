package sunag.sea3d.gui
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	public class ProgressCircle extends Sprite
	{
		public static const GREEN:uint = 0x33FF66;
		public static const BLUE:uint = 0x007DFF;
		
		private var _infinity:Boolean = false;
		private var _progress:Number = 0;
		private var _message:Shape;
		private var _messageField:TextField;
		private var _color:uint = BLUE;
		private var circle:Shape = new Shape();
		private var field:TextField;
		
		protected static const format:TextFormat = new TextFormat('Verdana',11,0xEEEEEE,null,null,null,null,null,'center');		
		
		public function ProgressCircle()
		{			
			with(graphics)
			{
				beginFill(0x464646,0.9);
				drawCircle(0,0,20);
				drawCircle(0,0,25);
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
			
			field.y -= 8;
			
			addChild(field);			
			addChild(circle);
			
			/*
			var filter:GlowFilter = new GlowFilter();
			
			filter.color = _color;
			filter.blurX = filter.blurY = 3;
			filter.alpha = 1;			
			filter.knockout=true;
			filter.quality = BitmapFilterQuality.LOW;
						
			circle.filters = [filter];
			*/
		}
		
		public function set color(val:uint):void
		{
			if (_color == val) return;
			_color = val;
			progress = _progress;
		}
		
		public function get color():uint
		{
			return _color;
		}			
		
		public function get radius():Number
		{
			return 35;
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
				
		public function set infinity(value:Boolean):void
		{
			if (_infinity == value) return;			
			
			if (value)
			{
				field.text = "...";	
				
				var p:Number = 90;
				
				circle.graphics.clear();
				circle.graphics.lineStyle(5.0, _color, 0.7, false, "normal", CapsStyle.NONE);					
				
				drawArc(circle.graphics, 0, 0, 23, p/360, -p/360, 30);			
			}
			else 
			{
				field.text = "";
				
				circle.graphics.clear();
				
				circle.rotation = 0;		
			}
			
			if (value) addEventListener(Event.ENTER_FRAME,progressEvent);
			else removeEventListener(Event.ENTER_FRAME,progressEvent);
				
			_infinity = value;			
		}
		
		public function get infinity():Boolean
		{
			return _infinity;
		}
		
		private function progressEvent(e:Event):void
		{
			circle.rotation = (getTimer()/3.6) % 360;
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
				circle.graphics.lineStyle(5.0, _color, 0.7, false, "normal", CapsStyle.NONE);					
				drawArc(circle.graphics, 0, 0, 23, p/360, -p/360, 30);
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