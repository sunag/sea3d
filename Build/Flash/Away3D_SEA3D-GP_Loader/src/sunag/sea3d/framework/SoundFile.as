package sunag.sea3d.framework
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class SoundFile extends Asset
	{
		sea3dgp static const TYPE:String = 'Sound/';
		
		sea3dgp var scope:Sound;
		
		function SoundFile()
		{
			super(TYPE);
			
			scope = new Sound();
		}
		
		public function play(volume:Number=1, startTime:Number=0):void
		{
			scope.play(startTime, 1, new SoundTransform(volume));			
		}
		
		public function get length():Number
		{
			return scope.length;
		}
		
		public function load(url:String):void
		{
			scope.load(new URLRequest(url));
		}
		
		sea3dgp function soundPlay(volume:Number=1, startTime:Number=0):SoundChannel
		{
			var channel:SoundChannel = scope.play(startTime, 1);
			channel.soundTransform = new SoundTransform(volume);
			return channel;
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	SOUND
			//
			
			sea.data.position = 0;
			
			scope.loadCompressedDataFromByteArray(sea.data, sea.data.length);		
		}
	}
}