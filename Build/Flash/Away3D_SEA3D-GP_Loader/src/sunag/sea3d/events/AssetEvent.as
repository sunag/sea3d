package sunag.sea3d.events
{
	

	public class AssetEvent extends Event
	{
		public static const RENAME:String = "rename";
		
		public function AssetEvent(type:String)
		{
			super(type);			
		}
	}
}