package sunag.sea3d.events
{
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class ProgressEvent extends Event
	{		
		public static const DOWLOAD_PROGRESS:String = "downloadProgress";
		
		public var loaded:Number;
		public var total:Number;	
		
		function ProgressEvent(type:String, loaded:Number, total:Number)
		{
			super(type);
			
			this.loaded = loaded;
			this.total = total;
		}
		
		public function get percent():Number
		{
			return loaded / total;
		}
	}
}