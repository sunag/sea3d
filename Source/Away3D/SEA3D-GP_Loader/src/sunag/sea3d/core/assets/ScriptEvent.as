package sunag.sea3d.core.assets
{
	import sunag.sea3d.events.Event;
	
	public class ScriptEvent extends Event
	{
		public static const COMPLETE:String = "complete";
		
		public function ScriptEvent(type:String)
		{
			super(type);
		}
	}
}