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
	
	import sunag.sea3d.SEA;
	import sunag.sea3d.objects.SEAObject;
	
	public class SEAEvent extends Event
	{				
		public static const COMPLETE_OBJECT:String = "completeObject";
		public static const LOAD_OBJECT:String = "loadObject";
		public static const READ_OBJECT:String = "readObject";
		
		/**
		 * Dispatched when the SEA3D is loaded.
		 * 
		 * @eventType sunag.events.SEAEvent
		 * @see sunag.sea3d.SEA3D
		 */
		public static const COMPLETE:String = "complete";
		
		/**
		 * Dispatched when there loading progress.
		 * 
		 * @eventType sunag.events.SEAEvent
		 * @see sunag.sea3d.SEA3D
		 */
		public static const PROGRESS:String = "progress";
		
		/**
		 * Dispatched when there downloading progress.
		 * 
		 * @eventType sunag.events.SEAEvent
		 * @see sunag.sea3d.SEA3D
		 */
		public static const STREAMING_PROGRESS:String = "streamingProgress";
		
		/**
		 * Dispatched if hover loading error.
		 * 
		 * @eventType sunag.events.SEAEvent
		 * @see sunag.sea3d.SEA3D
		 */
		public static const ERROR:String = "error";
		
		public var object:SEAObject;
		public var error:String;
		public var time:int;		
		
		public function SEAEvent(type:String, object:SEAObject=null, error:String=null, time:int=-1, bubbles:Boolean=false, cancelable:Boolean=false)
		{			
			this.object = object;
			this.error = error;
			this.time = time;
			super(type, bubbles, cancelable);
		}
		
		public function get progress():Number
		{
			return currentTarget.position / currentTarget.length;
		}
		
		public function get sea():SEA
		{
			return currentTarget as SEA;
		}
		
		public override function clone():Event
		{
			return new SEAEvent(type, object, error, time, bubbles, cancelable);
		}
	}
}