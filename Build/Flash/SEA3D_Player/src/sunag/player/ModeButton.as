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
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	public class ModeButton extends Sprite
	{
		public static const FREE:String = "free";
		public static const ORBIT:String = "orbit";
		public static const FIXED:String = "lock";
		
		private var _color:uint = 0x101212;
		private var _mode:String = ORBIT;
		private var _over:Boolean = false;
		private var _maker:ProgressMarker;		
		
		private var _bg:Sprite = new Sprite();
		
		public function ModeButton()
		{
			_maker = new ProgressMarker();				
			_maker.x = 25;
			_maker.visible = false;
			
			addChild(_bg);
			addChild(_maker);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onInvalidateMouse);
			addEventListener(MouseEvent.CLICK, onMouseClick);
			addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);
			
			draw();						
		}
		
		private function onInvalidateMouse(e:MouseEvent):void
		{
			e.stopImmediatePropagation();
		}
		
		public function set mode(val:String):void
		{
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			switch(_mode = val)
			{				
				case FIXED:
					stage.mouseLock = true;
					stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
					stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					break;
				
				default:
					if (stage.mouseLock) 
						stage.mouseLock = false;	
					break;
			}
					
			update();
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		public function get mode():String
		{
			return _mode;
		}
		
		private function onMouseClick(e:MouseEvent):void
		{
			switch(_mode)
			{
				case FREE: 
					mode = ORBIT; 
					break;
				case ORBIT: 
					if (stage.displayState == StageDisplayState.FULL_SCREEN ||
						stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
					{
						mode = FIXED;
					}
					else
					{
						mode = FREE;
					}					
					break;
				case FIXED: 
					mode = FREE; 
					break;
			}
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			mode = FREE;		
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.ESCAPE)
			{
				mode = FREE;								
			}
		}
				
		private function update():void
		{
			if (_over) onMouseOver();
			else onMouseOut();
		}
				
		private function onMouseOver(e:MouseEvent=null):void
		{
			switch(_mode)
			{
				case FREE: _maker.text = "Free"; break;
				case ORBIT: _maker.text = "Orbit"; break;
				case FIXED: _maker.text = "Fixed"; break;
			}
						 
			 _maker.visible = _over = true;			
			_color = _mode == FIXED ? 0xFF7700 : 0x0077FF;			
			draw();
		}
		
		private function onMouseOut(e:MouseEvent=null):void
		{			
			_maker.visible = _over = false;
			_color = 0x101212;			
			draw();
		}
		
		private function draw():void
		{
			_bg.graphics.clear();						
			_bg.graphics.beginFill(_color, .8);
			_bg.graphics.drawRoundRect(0, 0, 50, 50, 5);						
			_bg.graphics.endFill();
			
			_bg.graphics.beginFill(0xCCCCCC,.8);
			_bg.graphics.drawCircle(25,25,15);
			_bg.graphics.drawCircle(25,25,17);
			
			if (_mode != FREE)
			{
				_bg.graphics.drawCircle(25,25,5);
			}
		}
	}
}