package sunag.sea3d.framework
{
	

	public class Animation extends Asset
	{
		private static const TYPE:String = 'Animation/';
						
		public static function getAsset(name:String):Animation
		{
			return Animation.getAsset(TYPE+name) as Animation;
		}
		
		public function Animation()
		{
			super(TYPE);
		}
		
		public function get names():Array
		{
			return [];
		}
	}
}