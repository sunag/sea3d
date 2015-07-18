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
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getTimer;
	
	import sunag.sunag;
	import sunag.events.AnimationEvent;
	
	use namespace sunag;
	
	/**
	 * Dispatched when a command is fired.
	 * 
	 * @see sunag.animation.AnimationEvent
	 */
	[Event(name="command",type="sunag.events.AnimationEvent")]	
	
	/**
	 * Dispatched when the transition is completed.
	 * 
	 * @see sunag.animation.AnimationEvent
	 */
	[Event(name="transitionComplete",type="sunag.events.AnimationEvent")]
	
	public class AnimationBroadcaster extends EventDispatcher
	{
		sunag var _name:String;
		
		sunag var _timeScale : Number = 1;		
		sunag var _time : Number = 0;
		sunag var _absoluteTime : Number = 0;
		sunag var _delta : Number = 0;
		
		sunag var _currentAnimation:String;
		sunag var _blendSpeed:Number = 0;
		sunag var _easeSpeed:Number = 2;
		
		sunag var _autoUpdate : Boolean = true;
		
		sunag var calledTransitionCompleted:Boolean = false;
		sunag var notifyTransitionCompleted:Boolean = false;
				
		private var _playing:Boolean = false;
		private var _broadcaster : Sprite = new Sprite();
		
		public function set time(value:Number):void
		{
			_time = value;					
		}
		
		public function set absoluteTime(val:Number):void
		{
			_absoluteTime = val;
		}
		
		public function get absoluteTime():Number
		{
			return _absoluteTime;
		}
		
		public function get time():Number
		{
			return _time;
		}
		
		public function get easeSpeed() : Number
		{
			return _easeSpeed;
		}
		
		public function set easeSpeed(value : Number) : void
		{			
			_easeSpeed = value;
		}
		
		public function get blendSpeed() : Number
		{
			return _blendSpeed;
		}
		
		public function set blendSpeed(value : Number) : void
		{			
			_blendSpeed = value;
		}
		
		public function get currentAnimation() : String
		{
			return _currentAnimation;
		}
		
		public function set currentAnimation(value : String) : void
		{			
			setAnimation(value, _blendSpeed);
		}
		
		/**
		 * The amount by which passed time should be scaled. Used to slow down or speed up animations.
		 */
		public function get timeScale() : Number
		{
			return _timeScale;
		}
		
		public function set timeScale(value : Number) : void
		{			
			_timeScale = value;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function set name(value : String) : void
		{			
			_name = value;
		}
		
		public function set autoUpdate(value:Boolean):void
		{
			if (_autoUpdate == value) return;
				
			_autoUpdate = value;
			
			if (_autoUpdate)
				start();
			else
				stop();
		}
		
		public function get autoUpdate():Boolean
		{
			return _autoUpdate;
		}
				
		public function get playing():Boolean
		{
			return _playing;
		}
		
		protected function setAnimation(name:String, blendSpeed:Number):void
		{
			_currentAnimation = name;
			_blendSpeed = blendSpeed;
		}
		
		public function reset(name:String, offset:Number=0):void
		{
			
		}
		
		/**
		 * Play an animation
		 * 
		 * @param name Animation name
		 * @param blendSpeed Speed ​​in milliseconds
		 * @param offset Start animation time ​​in milliseconds
		 */
		public function play(name:String="root", blendSpeed:Number=0, offset:Number=NaN):void
		{								
			calledTransitionCompleted = false;
									
			setAnimation(name, blendSpeed);			
			
			if (_autoUpdate && !_playing) 
				start();			
			
			if (!isNaN(offset))
				reset(name, offset);
			
			if (hasEventListener(AnimationEvent.COMMAND))
				dispatchEvent(new AnimationEvent(AnimationEvent.COMMAND, "play"));					
		}
		
		/**
		 * Resumes the automatic playback clock controling
		 */
		public function start():void
		{
			if (!_autoUpdate || _playing) return;
					
			_playing = true;
			
			if (!_broadcaster.hasEventListener(Event.ENTER_FRAME))
			{
				_absoluteTime = getTimer();
				_broadcaster.addEventListener(Event.ENTER_FRAME, onEnterFrame, false, 0, true);
			}			
		}
		
		/**
		 * Stop the automatic playback clock controling
		 */
		public function stop():void
		{
			if (!_playing) return;
			
			_playing = false;						
			
			if (hasEventListener(AnimationEvent.COMMAND))
				dispatchEvent(new AnimationEvent(AnimationEvent.COMMAND, "stop"));
			
			if (_broadcaster.hasEventListener(Event.ENTER_FRAME))
				_broadcaster.removeEventListener(Event.ENTER_FRAME, onEnterFrame);										
		}
				
		/**
		 * For AutoUpdate Only
		 * */
		protected function onEnterFrame(e:Event):void
		{
			update(getTimer());
		}
		
		/**
		 * Update animation time. Use "<b>autoUpdate=false</b>" for manual update.
		 * 
		 * @see #updateTime()
		 * @see #updateState()
		 * @see #updateAnimation()
		 * */
		public function update(time:Number):void
		{	
			_delta = (time - _absoluteTime) * _timeScale;			
			_time += _delta;	
			_absoluteTime = time;
		}
						
		/**
		 * Update absolute animation time and delta.
		 * 
		 * @see #update(time)
		 * */
		public function updateAbsolute(time:Number, delta:Number):void
		{
			_absoluteTime = _time = time;
			_delta = delta;
		}
				
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			switch(type)
			{
				case AnimationEvent.TRANSITION_COMPLETE:
					notifyTransitionCompleted = true;
					break;
			}
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener, useCapture);
			
			switch(type)
			{
				case AnimationEvent.TRANSITION_COMPLETE:
					notifyTransitionCompleted = false;
					break;
			}
		}				
	}
}