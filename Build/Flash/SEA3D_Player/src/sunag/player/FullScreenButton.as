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
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class FullScreenButton extends Sprite
	{
		private var _color:uint = 0x101212;
		
		private var _bg:Sprite = new Sprite();
		private var _sprite:Sprite = new Sprite();
		
		private var _accepted:Boolean;
		private var _playerBase:PlayerBase;
		
		public function FullScreenButton(playerBase:PlayerBase)
		{
			_playerBase = playerBase;
			
			addChild(_bg);
			addChild(_sprite);
			
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
		
		private function onMouseClick(e:MouseEvent):void
		{
			if (stage.displayState == StageDisplayState.NORMAL)
			{
				_accepted = !ExternalInterface.available;
				stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				stage.addEventListener(FullScreenEvent.FULL_SCREEN_INTERACTIVE_ACCEPTED, onAccepted, false, 0, true);
			}			
			else
			{
				_accepted = true;
				stage.displayState = StageDisplayState.NORMAL;				
			}
		}
		
		private function onAccepted(e:FullScreenEvent):void
		{
			_accepted = true;
			_playerBase.updatePanel();
		}
		
		public function get enabled():Boolean
		{
			return _accepted;
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
			_sprite.graphics.beginFill(0xCCCCCC,.8);
			_sprite.graphics.drawRect(10,10,30,30);
			_sprite.graphics.drawRect(12,12,26,26);
			
			_sprite.graphics.drawRect(20,10,10,2);			
			_sprite.graphics.drawRect(20,38,10,2);
			
			_sprite.graphics.drawRect(10,20,2,10);
			_sprite.graphics.drawRect(38,20,2,10);
		}
	}
}