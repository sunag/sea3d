package away3d.audio
{
	import away3d.arcane;
	import away3d.events.SoundMixerEvent;
	
	import flash.events.EventDispatcher;

	use namespace arcane;
	
	public class SoundMixer3D extends EventDispatcher
	{
		private var _name:String = "";
		private var _volume:Number;
		
		arcane var _sounds:Vector.<Sound3D> = new Vector.<Sound3D>();
		
		public function SoundMixer3D(volume:Number=1)
		{
			this.volume = volume;
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get name():String
		{
			return _name;
		}
				
		public function set volume(value:Number):void
		{
			if (_volume == value)
				return;
			
			_volume = value;
			
			if (hasEventListener(SoundMixerEvent.CHANGE_VOLUME))
				dispatchEvent(new SoundMixerEvent(SoundMixerEvent.CHANGE_VOLUME, this));
		}
		
		public function get volume():Number
		{
			return _volume;
		}
		
		public function get sounds():Vector.<Sound3D>
		{
			return _sounds.concat();
		}
		
		public function pause():void
		{
			dispatchCommand("pause");
		}
		
		public function resume():void
		{
			dispatchCommand("resume");
		}
		
		public function play():void
		{
			dispatchCommand("play");
		}
		
		public function stop():void
		{
			dispatchCommand("stop");
		}
		
		public function togglePlayPause():void
		{
			dispatchCommand("togglePlayPause");
		}
		
		public function dispose():void
		{
			dispatchCommand("dispose");
		}
		
		public function disposeSounds():void
		{
			dispatchCommand("disposeSounds");
		}
		
		protected function dispatchCommand(command:String):void
		{
			if (hasEventListener(SoundMixerEvent.COMMAND))
				dispatchEvent(new SoundMixerEvent(SoundMixerEvent.COMMAND, this, command));
		}
	}
}