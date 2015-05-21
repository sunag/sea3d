package sunag.sea3d.loader
{
	import flash.events.Event;
	
	public class LoaderEvent extends Event
	{
		public static const PROGRESS:String = "progress";
		public static const COMPLETE:String = "complete";
		
		public function LoaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public function get loader():Loader
		{
			return target as Loader;
		}
		
		override public function clone():Event
		{
			return new LoaderEvent(type, bubbles, cancelable);
		}
	}
}