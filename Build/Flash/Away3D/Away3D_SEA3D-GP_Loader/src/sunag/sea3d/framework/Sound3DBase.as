package sunag.sea3d.framework
{
	import away3d.audio.Sound3D;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEASound3DBase;

	use namespace sea3dgp;
	
	public class Sound3DBase extends Object3D
	{
		sea3dgp var sound3d:Sound3D;
		sea3dgp var soundFile:SoundFile;
		
		public var autoPlay:Boolean = false;
		
		public function Sound3DBase(scope:Sound3D, animatorClass:Class=null)
		{						
			super(sound3d = scope, animatorClass);
		}
		
		public function set sound(val:SoundFile):void
		{			
			soundFile = val;
			sound3d.sound = soundFile ? soundFile.scope : null;
		}
		
		public function get sound():SoundFile
		{
			return soundFile;
		}
		
		public function set volume(val:Number):void
		{			
			sound3d.volume = val;
		}
		
		public function get volume():Number
		{
			return sound3d.volume;
		}
		
		public function play(startTime:Number=0, loops:Number=65535):void
		{
			sound3d.play(startTime, loops);
		}
		
		public function get soundPosition():Number
		{
			return sound3d.soundPosition;
		}
		
		public function stop():void
		{
			sound3d.stop();
		}
		
		//
		//	LOADER
		//
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			super.setScene(scene);
			
			if (autoPlay && scene)
			{
				play();
			}
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	SOUND3D BASE
			//
			
			var seaSound:SEASound3DBase = sea as SEASound3DBase;
			
			sound = seaSound.sound.tag;
			sound3d.volume = seaSound.volume;	
			
			autoPlay = seaSound.autoPlay;			
		}
		
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom(asset);
			
			var s:Sound3DBase = asset as Sound3DBase;
			autoPlay = s.autoPlay;		
			sound3d.volume = s.sound3d.volume;
			sound = s.sound;
		}				
	}
}