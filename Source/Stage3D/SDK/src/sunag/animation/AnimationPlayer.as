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

package sunag.animation
{
	import flash.utils.getTimer;
	
	import sunag.sunag;

	use namespace sunag;
	
	public class AnimationPlayer extends AnimationBroadcaster implements IAnimationPlayer
	{
		public static const DRAGGING:String = "dragging";
		public static const PLAYING:String = "playing";
		public static const PAUSED:String = "paused";
		
		sunag var _animation:Vector.<Animation> = new Vector.<Animation>();
		
		sunag var _duration : Number = 0;
		
		private var _state:String = DRAGGING;
		
		public function addAnimation(value:Animation):void
		{
			value.autoUpdate = false;
			value.play(_currentAnimation);		
			_animation.push( value );
		}
		
		public function removeAnimation(value:Animation):void
		{
			_animation.splice( _animation.indexOf(value), 1);
		}
		
		public function get animations():Vector.<Animation>
		{
			return _animation;
		}
		
		public function set position(value:Number):void
		{
			_time = value * _duration;			
		}
		
		public function get position():Number
		{			
			var p:Number = _time / _duration;			
			return p > 1 ? p - int(p) : p;
		}
		
		public function get duration():Number
		{
			return _duration;
		}
		
		override protected function setAnimation(name:String, blendSpeed:Number):void
		{
			super.setAnimation(name, blendSpeed);
			
			for each(var anm:Animation in _animation)			
				anm.play(name, blendSpeed);	
					
			if (_animation.length > 0)
				_duration = _animation[0].currentDuration;
		}
		
		override public function reset(name:String, offset:Number=0):void
		{
			for each(var anm:Animation in _animation)			
				anm.reset(name, offset);			
		}
			
		public function updateAnimation():void
		{
			for each(var anm:Animation in _animation)
			{		
				if (!anm._currentAnimation) continue;
				
				anm._delta = _delta;
				anm._time = _time;				
				
				anm.updateState();
				anm.updateAnimation();
			}
		}
		
		public function updateTime(time:Number, absoluteTime:Number, updateAnimation:Boolean=true):void
		{
			_delta = (absoluteTime - _absoluteTime) * _timeScale;
			_absoluteTime = absoluteTime;
			_time = time; 
			
			if (updateAnimation) this.updateAnimation();			
		}
		
		override public function update(time:Number):void
		{
			super.update(time);
			updateAnimation();
		}
		
		public function set state(val:String):void
		{
			_state = val;
		}
		
		public function get state():String
		{
			return _state;
		}
		
		public function updatePlayer():void
		{
			switch(_state)
			{					
				case DRAGGING:
					updateTime(time, getTimer());						
					break
				
				case PLAYING:
					update(getTimer());						
					break;
				
				case PAUSED:
					updateTime(time, getTimer(), false);
					break;					
			}	
		}
	}
}