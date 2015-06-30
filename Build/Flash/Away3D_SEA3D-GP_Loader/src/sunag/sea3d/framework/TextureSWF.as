package sunag.sea3d.framework
{
	import away3d.materials.utils.SWFPlayer;
	import away3d.textures.VideoTexture;
	
	import sunag.sea3dgp;
	
	use namespace sea3dgp;
	
	public class TextureSWF extends Texture
	{
		sea3dgp var videoTex:VideoTexture
		sea3dgp var player:SWFPlayer;
		
		public function TextureSWF()
		{
			super();
		}
		
		public function load(source:String, width:Number, height:Number):void
		{
			scope = videoTex = new VideoTexture(source, width, height, true, false, player = new SWFPlayer());			
		}
		
		public function set volume(val:Number):void
		{
			player.volume = val;
		}
		
		public function get volume():Number
		{
			return player.volume;
		}
		
		public function play():void
		{
			player.play();
		}
		
		public function stop():void
		{
			player.stop();
		}
	}
}