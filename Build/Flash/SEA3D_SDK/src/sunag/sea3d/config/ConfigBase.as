package sunag.sea3d.config
{
	public class ConfigBase implements IConfigBase
	{
		public static const HIGH:uint = 0;
		public static const NORMAL:uint = 1;
		public static const LOW:uint = 2;
		public static const VERY_LOW:uint = 3;
		
		private var _timeLimit:int;
		private var _streaming:Boolean;
		private var _forceStreaming:Boolean;
		
		public function ConfigBase(timeLimit:int=100):void
		{
			_timeLimit = timeLimit;
			_streaming = true;
			_forceStreaming = false;
		}
		
		public function set forceStreaming(value:Boolean):void
		{
			_forceStreaming = value;
		}
		
		public function get forceStreaming():Boolean
		{
			return _forceStreaming;
		}
		
		public function set streaming(value:Boolean):void
		{
			_streaming = value;
		}
		
		public function get streaming():Boolean
		{
			return _streaming;
		}
		
		public function set timeLimit(value:int):void
		{
			_timeLimit = value;
		}
		
		public function get timeLimit():int
		{
			return _timeLimit;
		}
	}
}