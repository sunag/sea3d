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
	import flash.events.EventDispatcher;
	
	import sunag.sunag;
	import sunag.events.AnimationEvent;

	use namespace sunag;
	
	/**
	 * Dispatched when the animation is completed.
	 * 
	 * @see sunag.animation.AnimationEvent
	 */
	[Event(name="complete",type="sunag.events.AnimationEvent")]
	
	public class AnimationState extends EventDispatcher
	{
		sunag var _node:AnimationNode;
		sunag var _offset:Number = 0;
		sunag var _weight:Number = 0;
		sunag var _time:Number = 0;		
		
		sunag var oldWeight:Number = 0;		
		sunag var notifyCompleted:Boolean = false;
		sunag var positiveTime:Boolean = true;
		
		public function AnimationState(node:AnimationNode)
		{
			_node = node;
		}
		
		public function get node():AnimationNode
		{
			return _node;
		}
		
		public function set weight(value:Number):void
		{
			_weight = value;
		}
		
		public function get weight():Number
		{			
			return _weight;
		}
		
		public function set time(val:Number):void
		{
			if (positiveTime && val < 0)
				val = 0;
			
			_node.time = _time = val;
		}
		
		public function get time():Number
		{
			return _time;
		}
		
		public function set frame(value:Number):void
		{
			_node.frame = value;
			_time = _node._time;
		}
		
		public function get frame():Number
		{
			if (_node._time !== _time) update();
			return _node.frame;
		}
		
		public function set position(value:Number):void
		{
			_node.position = value;
			_time = _node._time;
		}
		
		public function get position():Number
		{
			if (_node._time !== _time) update();
			return _node.position;
		}
		
		public function set offset(val:Number):void
		{
			_offset = val;
		}
		
		public function get offset():Number
		{
			return _offset;
		}
		
		public function update():void
		{
			_node.time = _time;
		}
		
		sunag function dispatchComplete():void
		{
			dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE));
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			switch(type)
			{
				case AnimationEvent.COMPLETE:
					notifyCompleted = true;
					break;
			}
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			super.removeEventListener(type, listener, useCapture);
			
			switch(type)
			{
				case AnimationEvent.COMPLETE:
					notifyCompleted = false;
					break;
			}
		}
	}
}