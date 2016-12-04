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

package sunag.utils
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import sunag.sunag;
	
	use namespace sunag
	
	public class TimeStep
	{
		private var oldTime:int=0;		
		
		sunag var _fixedFrameRate:Number=0;
		sunag var _frameRate:Number=0;		
		sunag var _deltaTime:Number=0;
		sunag var _delta:Number=0;
		sunag var _timeScale:Number=1;		
		sunag var _time:Number = 0;
		sunag var _step:int = 0;
		
		private var _broadcaster : Sprite;
		
		public function TimeStep(fixedFrameRate:Number=60, autoUpdate:Boolean=true)
		{
			_fixedFrameRate = fixedFrameRate;
			this.autoUpdate = autoUpdate;
			update();
		}
		
		/**
		 * Return total time
		 * */
		public function get time():Number
		{
			return _time;
		}
		
		public function set autoUpdate(value:Boolean):void
		{
			if (value == autoUpdate) return;
			
			if (_broadcaster)
			{
				_broadcaster.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_broadcaster = null;
			}			
			
			if (value)
			{
				_broadcaster = new Sprite;
				_broadcaster.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 1000);
			}
		}
		
		private function onEnterFrame(e:Event):void 
		{
			update();
		}
		
		public function get autoUpdate():Boolean
		{
			return _broadcaster != null;
		}
		
		/**
		 * Update time step.
		 * @param sameFrame Use to update the <b>delta</b> and <b>deltaTime</b> within the same frame. 
		 * */
		public function update(sameFrame:Boolean=false):void
		{			
			var time:int = getTimer();		
			
			_step = time - oldTime;
			_deltaTime =  _step / 1000;			
			
			if (_deltaTime > .25) 
				_deltaTime = .25;			
			
			_delta = _deltaTime * _fixedFrameRate;
			
			if (!sameFrame)
			{	
				oldTime = time;				
				
				_time += _step * _timeScale;
			}
		}
		
		/**
		 * Return delta time
		 * */
		public function get deltaTime():Number
		{
			return _deltaTime * _timeScale;
		}
		
		/**
		 * Calculates the delta with the same <b>frame rate</b> of the application
		 * 
		 * @see #fixedFrameRate
		 * */
		public function get delta():Number
		{
			return _delta * _timeScale;
		}
		
		/**
		 * Calculates the coefficient of delta with the same <b>frame rate</b> of the application
		 * 
		 * @param friction
		 * @see #delta
		 * */
		public function getDeltaCoff(friction:Number):Number
		{
			return Math.pow(friction, delta)
		}
		
		/**
		 * Return time in milliseconds of an update to another
		 * */
		public function get step():int
		{
			return _step;
		}
		
		/**
		 * Return time <b>delta</b> in milliseconds of an update to another.
		 * */
		public function get deltaStep():Number
		{
			return _step * _timeScale;
		}
		
		/**
		 * Return actual frame rate
		 * */
		public function get frameRate():Number
		{
			return 1000 / _step;
		}
		
		/**
		 * Value of frame rate of the application for calculating the delta value
		 * 
		 * @see #delta
		 * */
		public function set fixedFrameRate(value:Number):void
		{
			_fixedFrameRate = value;
		}
		
		public function get fixedFrameRate():Number
		{
			return _fixedFrameRate;
		}
		
		/**
		 * Time scale
		 * 
		 * @see #delta
		 * @see #deltaTime
		 * */
		public function set timeScale(value:Number):void
		{
			_timeScale = value;
		}
		
		public function get timeScale():Number
		{
			return _timeScale;
		}
	}
}