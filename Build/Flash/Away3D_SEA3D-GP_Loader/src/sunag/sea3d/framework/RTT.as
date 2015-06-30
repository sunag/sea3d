package sunag.sea3d.framework
{
	import away3d.textures.TextureProxyBase;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class RTT extends Asset
	{
		sea3dgp static const TYPE:String = 'RTT/';
		
		sea3dgp var rtt:TextureProxyBase;
		
		public function RTT()
		{
			super(TYPE);
		}
	}
}