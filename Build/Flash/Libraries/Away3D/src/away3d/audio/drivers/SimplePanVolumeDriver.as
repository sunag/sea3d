package away3d.audio.drivers
{
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import away3d.audio.SoundMixer3D;
	import away3d.audio.SoundTransform3D;

	/**
	 * The Simple pan/volume Sound3D driver will alter the pan and volume properties on the
	 * sound transform object of a regular flash.media.Sound3D representation of the sound. This
	 * is very efficient, but has the drawback that it can only reflect azimuth and distance,
	 * and will disregard elevation. You'll be able to hear whether a   
	*/
	public class SimplePanVolumeDriver extends AbstractSound3DDriver implements ISound3DDriver
	{
		private var _sound_chan : SoundChannel = new SoundChannel();		
		private var _st3D : SoundTransform3D;
		private var _soundMixer3D : SoundMixer3D;
		
		public function SimplePanVolumeDriver()
		{
			super();
			
			_ref_v = new Vector3D();
			_st3D = new SoundTransform3D();
		}		
		
		override public function play(startTime:Number=0, loops:int=int.MAX_VALUE) : void
		{			
			super.play(startTime, loops);					
			
			// Update sound transform first. This has not happened while
			// the sound was not playing, so needs to be done now.
			_updateSoundTransform();
			
			// remove mp3 silence and pause/resume correction
			if (startTime == 0 || _loops == 0) 
			{
				_sound_chan = _src.play(Math.min(_offset + startTime, _src.length), _loops=loops, _st3D.soundTransform);							
				_sound_chan.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);		
			}
			else
			{
				_sound_chan = _src.play(startTime, 0, _st3D.soundTransform);
				_sound_chan.addEventListener(Event.SOUND_COMPLETE, onFirstSoundComplete);		
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			stop();						
		}
		
		override public function pause() : void
		{
			super.pause();		
			
			_position = _sound_chan.position;								
			
			_sound_chan.removeEventListener(Event.SOUND_COMPLETE, onFirstSoundComplete);	
			_sound_chan.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_sound_chan.stop();			
		}			
		
		override public function stop() : void
		{
			super.stop();
			
			_sound_chan.removeEventListener(Event.SOUND_COMPLETE, onFirstSoundComplete);
			_sound_chan.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			_sound_chan.stop();
		}
		
		override public function get position():Number
		{
			return _position = _sound_chan.position;
		}
		
		public override function set volume(val:Number) : void
		{
			_volume = val;
			_st3D.volume = val;
			_updateSoundTransform();
		}
		
		public override function set mute(val:Boolean):void
		{
			_mute = val;
			_st3D.volume = _mute ? 0 : _volume;
			_updateSoundTransform();
		}
		
		public override function set scale(val:Number) : void
		{
			_scale = val;
			_st3D.scale = scale;
		}						
		
		public override function updateReferenceVector(v:Vector3D, soundMixer3D:SoundMixer3D=null) : void
		{
			super.updateReferenceVector(v, _soundMixer3D=soundMixer3D);
			
			// only update sound transform while playing
			if (_state == 1)
				_updateSoundTransform();
		}
								
		private function _updateSoundTransform() : void
		{			
			_st3D.updateFromVector3D( _ref_v );
			
			if (_sound_chan)			
			{
				var snd:SoundTransform = _st3D.soundTransform;
				if (_soundMixer3D) snd.volume *= _soundMixer3D.volume;				
				_sound_chan.soundTransform = snd;
			}
		}
			
		private function onFirstSoundComplete(e:Event):void
		{
			play(0, _loops-1);
		}
		
		private function onSoundComplete(ev : Event) : void
		{
			this.dispatchEvent(ev.clone());
		}
	}
}