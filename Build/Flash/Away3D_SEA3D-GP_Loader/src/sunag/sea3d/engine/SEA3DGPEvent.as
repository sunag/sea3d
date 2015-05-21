package sunag.sea3d.engine
{
	import flash.events.Event;
	
	public class SEA3DGPEvent extends Event
	{
		public static const INVALIDATE_MATERIAL:String = "invalidateMaterial";
		
		public function SEA3DGPEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}