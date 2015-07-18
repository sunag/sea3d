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
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;

	public class ProgressBar extends Sprite
	{
		private var _bg:Sprite = new Sprite();
		private var _progressBar:Sprite = new Sprite();
						
		private var _width:int = 600;
		private var _height:int = 13;
		
		private var _position:Number = 0;
		private var _progress:Number = 0;
		
		private var _dragging:Boolean = false;
		
		public function ProgressBar()
		{			
			addChild(_bg);
			addChild(_progressBar);
			
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 1);
			
			draw();
		}
		
		private function onMouseMove(e:MouseEvent=null):void
		{
			position = this.mouseX / _width;
			dispatchEvent(new PlayerEvent(PlayerEvent.DRAGGING));
		}
		
		private function onMouseDown(e:MouseEvent):void
		{
			_dragging = true;
			
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 1);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 1);
			
			onMouseMove();
			
			e.stopImmediatePropagation();
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			_dragging = false;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp, false);
		}
		
		public function get dragging():Boolean
		{
			return _dragging;
		}
		
		public function set progress(value:Number):void
		{
			if (value > 1 ) value = 1;
			else if (value < 0) value = 0;
			
			_progress = value;
			draw();
		}
		
		public function get progress():Number
		{
			return _progress;
		}
		
		public function set position(value:Number):void
		{
			if (value > 1 ) value = 1;
			else if (value < 0 || isNaN(value)) value = 0;
			
			_position = value;
			draw();
		}
		
		public function get position():Number
		{
			return _position;
		}
		
		private function draw():void
		{
			_bg.graphics.clear();
			//_bg.graphics.lineStyle(null,0x999999,.3);
			_bg.graphics.beginFill(0x101212,.8);
			_bg.graphics.drawRect(0, 0, _width, _height);
			_bg.graphics.endFill();
			
			_progressBar.graphics.clear();
			var m:Matrix = new Matrix;
			m.createGradientBox(_bg.width, _bg.height, Math.PI/2);
			
			_progressBar.graphics.beginGradientFill(GradientType.LINEAR, [0x00FF7D,0x00FF7D], [0.2,0.5],[0,130], m);
			_progressBar.graphics.drawRect(1, 1, (_bg.width - 2) * _progress, _bg.height - 2);			
			
			_progressBar.graphics.beginGradientFill(GradientType.LINEAR, [0x007DFF,0x0077FF], [0.4,0.8],[0,130], m);
			_progressBar.graphics.drawRect(1, 1, (_bg.width - 2) * _position, _bg.height - 2);
			
			_progressBar.graphics.endFill();
		}
		
		public override function set width(value:Number):void { _width = value; draw(); }
		public override function get width():Number { return _width; }
		
		public override function set height(value:Number):void { _height = value; draw(); }
		public override function get height():Number { return _height; }
	}
}