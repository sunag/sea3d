package sunag.sea3d.config
{
	import sunag.sea3d.SEA;

	public class ConfigWriter implements IConfigWriter
	{
		private var _timeLimit:int;
		private var _version:int = SEA.VERSION;
		private var _compressMethod:String = "deflate";
		
		public function ConfigWriter(timeLimit:int=100):void
		{
			_timeLimit = timeLimit;
		}
		
		public function set timeLimit(value:int):void
		{
			_timeLimit = value;
		}
		
		public function get timeLimit():int
		{
			return _timeLimit;
		}
		
		public function set compressMethod(val:String):void
		{
			_compressMethod = val;
		}
		
		public function get compressMethod():String
		{
			return _compressMethod;
		}
		
		public function set version(val:int):void
		{
			_version = val;
		}
		
		public function get version():int
		{
			return _version;
		}
	}
}