package sunag.sea3d.events
{
	public class Object3DEvent extends Event
	{
		public static const TRANSFORM:String = "transform";		
		
		public function Object3DEvent(type:String)
		{
			super(type);			
		}
	}
}