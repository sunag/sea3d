package away3d.events
{
	import away3d.audio.SoundMixer3D;
	
	import flash.events.Event;
	
	public class SoundMixerEvent extends Event
	{
		public static const COMMAND : String = "command";
		public static const CHANGE_VOLUME : String = "change";
		
		public var soundMixer : SoundMixer3D;
		public var command : String;
		
		public function SoundMixerEvent(type : String, soundMixer : SoundMixer3D, command:String=null)
		{
			this.soundMixer = soundMixer;
			this.command = command;
			super(type);
		}
	}
}
