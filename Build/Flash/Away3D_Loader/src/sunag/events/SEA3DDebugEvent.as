package sunag.events
{
	import flash.events.Event;
	
	public class SEA3DDebugEvent extends Event
	{
		public static const WARN:String = "warn";
		
		public var message:String;
		
		public function SEA3DDebugEvent(type:String, message:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.message = message;
		}
	}
}