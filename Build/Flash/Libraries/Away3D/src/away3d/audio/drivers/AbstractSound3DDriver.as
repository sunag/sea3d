package away3d.audio.drivers
{
	import away3d.arcane;
	import away3d.audio.SoundMixer3D;
	
	import flash.events.EventDispatcher;
	import flash.geom.Vector3D;
	import flash.media.Sound;

	use namespace arcane;
	
	public class AbstractSound3DDriver extends EventDispatcher implements ISound3DDriver
	{
		protected var _ref_v:Vector3D;
		protected var _src:Sound;
		protected var _volume:Number = 1;
		protected var _scale : Number = 1000;		
		protected var _state : int = 0;
		protected var _mute : Boolean;		
		protected var _position : Number = 0;
		protected var _loops : int = 0;
		protected var _offset : int = 35;
		
		public function set sourceSound(val : Sound) : void { _src = val };
		public function get sourceSound() : Sound { return _src; }	
		
		public function get position() : Number { return _position }		
		
		public function set volume(val : Number) : void { _volume = val };		
		public function get volume() : Number { return _volume }		
		
		public function set scale(val : Number) : void { _scale = val };
		public function get scale() : Number { return _scale }					
		
		public function set mute(val : Boolean) : void { _mute = val };	
		public function get mute() : Boolean { return _mute }				
			
		public function set offset(val : int) : void { _offset = val };	
		public function get offset() : int { return _offset }
		
		public function play(startTime:Number=0, loops:int=int.MAX_VALUE) : void
		{
			stop();
			
			_state = 1;
			
			_position = startTime;
			_loops = loops;
			
			if (!_src)
				throw new Error('SimplePanVolumeDriver.play(): No sound source to play.');						
		}
		
		public function pause() : void 
		{
			_state = 2;
		}
		
		public function resume() : void		
		{
			if (_state == 2 || _state == 0)								
				play(_loops > 0 ? 0 : _position, _loops);
		}				
		
		public function stop() : void
		{
			_state = 0;
			_position = 0;
			_loops = 0;
		}		
						
		public function dispose():void
		{
			stop();
		}		
		
		public function updateReferenceVector(v:Vector3D, soundMixer:SoundMixer3D=null):void
		{
			this._ref_v = v;
		}
	}
}