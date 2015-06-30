package sunag.sea3d.framework
{
	import away3d.materials.utils.SimpleVideoPlayer;
	import away3d.textures.VideoTexture;
	
	import sunag.sea3dgp;
	
	use namespace sea3dgp;
	
	public class TextureVideo extends Texture
	{
		sea3dgp var videoTex:VideoTexture
		sea3dgp var player:SimpleVideoPlayer;
		
		public function TextureVideo()
		{
			super();
		}
		
		public function load(source:String, width:Number, height:Number):void
		{
			scope = videoTex = new VideoTexture(source, width, height, true, false, player = new SimpleVideoPlayer());			
		}
		
		public function set volume(val:Number):void
		{
			player.volume = val;
		}
		
		public function get volume():Number
		{
			return player.volume;
		}
		
		public function play(time:Number=0):void
		{
			player.play();
		}
		
		public function pause():void
		{
			player.pause();
		}
		
		public function stop():void
		{
			player.stop();
		}
	}
}