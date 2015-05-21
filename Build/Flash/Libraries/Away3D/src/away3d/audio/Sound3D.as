package away3d.audio
{
	import away3d.arcane;
	import away3d.audio.drivers.*;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.events.Object3DEvent;
	import away3d.events.Scene3DEvent;
	import away3d.events.SoundMixerEvent;
	import away3d.events.View3DEvent;
	
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.media.Sound;
	
	use namespace arcane;
	
	/**
	 * Dispatched when end of sound stream is reached (bubbled from the internal sound object).
	 */
	[Event(name="soundComplete", type="flash.events.Event")]

	/**
	 * <p>A sound source/emitter object that can be positioned in 3D space, and from which all audio
	 * playback will be transformed to simulate orientation.</p>
	 * 
	 * <p>The Sound3D object works much in the same fashion as primitives, lights and cameras, in that
	 * it can be added to a scene and positioned therein. It is the main object, in the 3D sound API,
	 * which the programmer will interact with.</p>
	 * 
	 * <p>Actual sound transformation is performed by a driver object, which is defined at the time of
	 * creation by the driver ini variable, the default being a simple pan/volume driver.</p>
	 * 
	 * @see SimplePanVolumeDriver  
	*/
	public class Sound3D extends ObjectContainer3D
	{
		protected var _refv : Vector3D = new Vector3D();
		protected var _driver : ISound3DDriver;
		protected var _sound : Sound;
		protected var _views : Vector.<View3D>;
		protected var _cameras : Vector.<Camera3D> = new Vector.<Camera3D>();
		protected var _state : int = 0;
		protected var _soundMixer3D:SoundMixer3D;
		
		
		/**
		 * Create a Sound3D object, representing the sound source used for playback of a flash Sound object. 
		 * 
		 * @param sound 		The flash Sound object that is played back from this Sound3D object's position.
		 * For realistic results, this should be a <em>mono</em> (single-channel, non-stereo) sound stream.
		 * @param soundMixer3D	To control several sounds simultaneously..		 
		 * @param driver		Sound3D driver to use when applying simulation effects. Defaults to SimplePanVolumeDriver.
		 * @param init 			[optional] An initialisation object for specifying default instance properties.
		*/
		public function Sound3D(sound:Sound = null, soundMixer3D : SoundMixer3D = null, driver : ISound3DDriver = null, volume:Number = 1, scale:Number = 1000)
		{			
			_sound = sound;
			_driver = driver || new SimplePanVolumeDriver();			
			_driver.sourceSound = _sound;			
			_driver.volume = volume;
			_driver.scale = scale;
			
			_driver.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			addEventListener(Object3DEvent.SCENE_CHANGED, onSceneChanged);			
			addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onSceneTransformChanged);
			
			this.soundMixer3D = soundMixer3D;
		}		
		
		public function set sound(val:Sound):void
		{
			_driver.sourceSound = _sound = val;
		}
		
		public function get sound():Sound
		{
			return _sound;
		}
		
		public function get driver():ISound3DDriver
		{
			return _driver;
		}
		
		protected function onChangeSoundMixerVolume(e:SoundMixerEvent):void
		{
			update();
		}	
		
		protected function onSoundMixerCommand(e:SoundMixerEvent):void
		{			
			switch (e.command)
			{
				case "play":
					play();
					break;
				
				case "pause":
					pause();
					break;
				
				case "stop":
					stop();
					break;
				
				case "resume":
					resume();
					break;
				
				case "togglePlayPause":
					togglePlayPause();
					break;
				
				case "dispose":
					soundMixer3D = null;
					break;
				
				case "disposeSounds":
					dispose();
					break;
			}
		}
		
		/**
		 * Defines the overall (master) volume of the 3D sound, after any
		 * positional adjustments to volume have been applied. This value can
		 * equally well be cotrolled by modifying the volume property on the
		 * driver used by this Sound3D instance.
		 * 
		 * @see ISound3DDriver.volume
		*/
		public function get volume() : Number
		{
			return _driver.volume;
		}
		public function set volume(val : Number) : void
		{
			_driver.volume = val;
		}
		
		public function get soundPosition() : Number
		{
			return _driver.position;
		}
		
		/**
		 * Defines a scale value used by the driver when adjusting sound 
		 * intensity to simulate distance. The default number of 1000 means
		 * that sound volume will near the hearing threshold as the distance
		 * between listener and sound source approaches 1000 Away3D units.
		 * 
		 * @see ISound3DDriver.scale
		*/ 
		public function get scaleDistance() : Number
		{
			return _driver.scale;
		}
		public function set scaleDistance(val : Number) : void
		{
			_driver.scale = val;
		}
		
		/**
		 * Set initial start sound. Usually removes the initial silence of MP3, try values of 23ms at 35ms.
		 */
		public function get offset() : int
		{
			return _driver.offset;
		}
		public function set offset(val : int) : void
		{
			_driver.offset = val;
		}
				
		public function get soundMixer3D() : SoundMixer3D
		{
			return _soundMixer3D;
		}
		public function set soundMixer3D(val : SoundMixer3D) : void
		{
			if (_soundMixer3D == val)
				return;
			
			if (_soundMixer3D)
			{					
				_soundMixer3D._sounds.splice(_soundMixer3D._sounds.indexOf(this), 1);
				_soundMixer3D.removeEventListener(SoundMixerEvent.CHANGE_VOLUME, onChangeSoundMixerVolume);
				_soundMixer3D.removeEventListener(SoundMixerEvent.COMMAND, onSoundMixerCommand);
			}
			
			_soundMixer3D = val;
			
			if (_soundMixer3D)
			{
				_soundMixer3D._sounds.push(this);
				_soundMixer3D.addEventListener(SoundMixerEvent.CHANGE_VOLUME, onChangeSoundMixerVolume);
				_soundMixer3D.addEventListener(SoundMixerEvent.COMMAND, onSoundMixerCommand);
			}
			
			update();
		}
		
		/**
		 * Returns a boolean indicating whether or not the sound is currently
		 * playing.
		*/
		public function get playing() : Boolean
		{
			return _state == 1;
		}
				
		/**
		 * Returns a boolean indicating whether or not playback is currently
		 * paused.
		*/
		public function get paused() : Boolean
		{
			return _state == 2;
		}
				
		/**
		 * Start (or resume, if paused) playback. 
		*/
		public function play(startTime:Number=0, loops:int=int.MAX_VALUE) : void
		{
			_state = 1;
			_driver.play(startTime, loops);
		}		
		
		/**
		 * Pause playback. Resume using play(). 
		*/
		public function pause() : void
		{
			_state = 2;
			_driver.pause();
		}
		
		public function resume() : void
		{
			_state = 1;
			_driver.resume();
		}
				
		/**
		 * Stop and rewind sound file. Replay (from the beginning) using play().
		 * To temporarily pause playback, allowing you to resume from the same point,
		 * use pause() instead.
		 * 
		 * @see pause()
		*/
		public function stop() : void
		{
			_state = 0;
			_driver.stop();
		}
		
		/**
		 * Alternate between pausing and resuming playback of this sound. If called
		 * while sound is paused (or stopped), this will resume playback. When 
		 * called during playback, it will pause it.
		*/
		public function togglePlayPause() : void
		{
			if (_state == 1) this.pause();
			else this.play();
		}
				
		/**
		 * @internal
		 * When scene changes, mute if object was removed from scene. 
		*/
		private function onSceneChanged(ev : Object3DEvent = null) : void
		{			
			if (_oldScene)
				_oldScene.removeEventListener(Scene3DEvent.CHANGE_VIEW3D, onChangeView3D);
			
			onChangeView3D();
			
			if (_scene)
			{
				if (!_oldScene && _state == 1) _driver.resume();
				_scene.addEventListener(Scene3DEvent.CHANGE_VIEW3D, onChangeView3D);
			}
			else _driver.pause();
		}
						
		private function onChangeView3D(ev : Scene3DEvent = null):void
		{
			var view3d:View3D;
			
			for each(view3d in _views)			
				view3d.removeEventListener(View3DEvent.CHANGE_CAMERA, onCameraChanged);			
			
			if (_scene) _views = _scene.views3D.concat();
			else _views = null;
			
			for each(view3d in _views)			
				view3d.addEventListener(View3DEvent.CHANGE_CAMERA, onCameraChanged);	
			
			onCameraChanged();
		}
		
		private function onCameraChanged(ev : View3DEvent = null) : void
		{
			var cam:Camera3D;
			var view3d:View3D;
			
			for each (cam in _cameras)
				cam.removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onSceneTransformChanged);
			
			// reload cameras
			_cameras.length = 0;
			
			for each(view3d in _views)	
				_cameras.push(view3d.camera);
			// --
				
			for each (cam in _cameras)
				cam.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onSceneTransformChanged);
				
			update();
		}
		
		private function onSceneTransformChanged(ev : Object3DEvent) : void
		{
			update();
		}
		
		private function onSoundComplete(ev : Event) : void
		{
			dispatchEvent(ev.clone());
		}
		
		override public function dispose():void 
		{
			super.dispose();
			
			_driver.dispose();			
			_driver.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			
			soundMixer3D = null;
			
			removeEventListener(Object3DEvent.SCENE_CHANGED, onSceneChanged);			
			removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onSceneTransformChanged);
		}
		
		/**
		 * @internal
		 * When scene transform changes, calculate the relative vector between the listener/reference object
		 * and the position of this sound source, and update the driver to use
		 * this as the reference vector.
		 */
		private function update():void
		{
			var pos:Vector3D = scenePosition;
			var nearestCamera:Camera3D;
			var nearest:Number = Number.MAX_VALUE;
			
			// Multiview
			for each(var view3d:View3D in _views)
			{
				// stage : So it plays if View3D is added to the stage.
				if (view3d.stage && 
					Vector3D.distance(view3d.camera.scenePosition, pos) < nearest)
				{
					nearestCamera = view3d.camera;
				}							
			}
			
			if (nearestCamera)
				_refv = nearestCamera.inverseSceneTransform.transformVector(sceneTransform.position);							
			
			_driver.updateReferenceVector(_refv, _soundMixer3D);
		}											
	}
}
