package sunag.sea3d.modules
{
	import flash.media.Sound;
	
	import away3d.audio.Sound3D;
	import away3d.audio.SoundMixer3D;
	import away3d.sea3d.animation.Sound3DAnimation;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.objects.IAnimator;
	import sunag.sea3d.objects.SEAAnimation;
	import sunag.sea3d.objects.SEAMP3;
	import sunag.sea3d.objects.SEASound;
	import sunag.sea3d.objects.SEASoundMixer;
	import sunag.sea3d.objects.SEASoundPoint;

	use namespace sunag;
	
	public class SoundModule extends SoundModuleBase
	{
		protected var _sound:Vector.<Sound>;
		protected var _sound3d:Vector.<Sound3D>;
		protected var _soundMixer:Vector.<SoundMixer3D>;
		
		sunag var sea3d:SEA3D;
		
		public function SoundModule()
		{
			regRead(SEAMP3.TYPE, readSound);
			regRead(SEASoundMixer.TYPE, readSoundMixer);
			regRead(SEASoundPoint.TYPE, readSoundPoint);
		}
		
		override sunag function reset():void
		{
			_sound = null;
			_soundMixer = null;
			_soundMixer = null;
		}
		
		override public function dispose():void
		{
			for each(var snd3d:Sound3D in _sound3d)
			{
				snd3d.dispose();
			}	
		}
		
		public function get sounds():Vector.<Sound>
		{
			return _sound;
		}
		
		public function get sounds3d():Vector.<Sound3D>
		{
			return _sound3d;
		}
		
		public function getSound(name:String):Sound
		{
			return sea.object[name + ".snd"];
		}	
		
		public function getSound3D(name:String):Sound3D
		{
			return sea.object[name + ".s3d"];
		}
		
		public function getSoundMixer3D(name:String=""):SoundMixer3D
		{
			return sea.object[name + ".smix"];
		}
		
		public function get soundMixers():Vector.<SoundMixer3D>
		{
			return _soundMixer;
		}
		
		protected function readSoundMixer(sea:SEASoundMixer):void
		{
			var soundMixer:SoundMixer3D = new SoundMixer3D();
			soundMixer.name = sea.name;
			soundMixer.volume = sea.volume;
			
			_soundMixer ||= new Vector.<SoundMixer3D>();
			_soundMixer.push(this.sea.object[sea.filename] = sea.tag = soundMixer);	
		}
		
		protected function readSound(sea:SEASound):void
		{
			_sound ||=  new Vector.<Sound>();
			_sound.push(this.sea.object[sea.name + ".snd"] = sea.tag = sea.sound);	
		}
				
		protected function readSoundPoint(sea:SEASoundPoint):void
		{		
			var snd:Sound3D = new Sound3D(sea.sound.tag, sea.mixer ? sea.mixer.tag : null);
			
			snd.volume = sea.volume;
			snd.scaleDistance = sea.distance;
			snd.position = sea.position;
				
			//
			//	Animations
			//
			
			for each(var anm:Object in sea.animations)
			{
				var tag:IAnimator = anm.tag;
				
				if (tag is SEAAnimation)
				{
					sea3d.addAnimation				
						(
							new Sound3DAnimation(snd, (tag as SEAAnimation).tag),
							sea.name, anm
						);
				}
			}
			
			if (sea.autoPlay) 
				snd.play();
			
			snd.name = sea.name;								
			
			sea3d.addSceneObject(sea, snd);
			
			_sound3d ||= new Vector.<Sound3D>();
			_sound3d.push(sea3d.object[sea.name+".s3d"] = sea.tag = snd);					
		}
		
		override sunag function init(sea:SEA):void
		{
			this.sea = sea;
			sea3d = sea as SEA3D;
		}
	}
}