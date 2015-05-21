package sunag.sea3d.events
{
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class Event
	{		
		public static const UPDATE:String = "update";
		public static const COMPLETE:String = "complete";
		
		public var type:String;		
		public var target:Object;
		
		public var preventDefault:Boolean = false;
		
		function Event(type:String)
		{
			this.type = type;
		}
	}
}