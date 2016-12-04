package sunag.sea3d.framework
{
	import away3d.materials.utils.SimpleVideoPlayer;
	import away3d.textures.WebcamTexture;
	
	import sunag.sea3dgp;
	
	use namespace sea3dgp;
	
	public class TextureWebcam extends Texture
	{
		sea3dgp var webcam:WebcamTexture
		sea3dgp var player:SimpleVideoPlayer;
		
		public function TextureWebcam()
		{
			super(scope = webcam = new WebcamTexture());
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