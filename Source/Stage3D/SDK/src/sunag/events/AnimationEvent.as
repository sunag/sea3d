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

package sunag.events
{
	import flash.events.Event;
	
	public class AnimationEvent extends Event
	{	
		public static const COMPLETE:String = "complete";
		public static const COMMAND:String = "command";
		public static const TRANSITION_COMPLETE:String = "transitionComplete";
		
		public var command:String;
		
		public function AnimationEvent(type:String, command:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{			
			this.command = command;
			
			super(type, bubbles, cancelable);
		}
		
		public override function clone():Event
		{
			return new AnimationEvent(type, command, bubbles, cancelable);
		}
	}
}