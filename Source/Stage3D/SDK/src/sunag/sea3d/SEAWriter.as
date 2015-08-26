package sunag.sea3d
{
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import sunag.events.SEAEvent;
	import sunag.sea3d.config.ConfigWriter;
	import sunag.sea3d.config.IConfigWriter;
	import sunag.sea3d.objects.SEAObject;
	import sunag.utils.ByteArrayUtils;

	public class SEAWriter extends EventDispatcher
	{
		protected var _time:int;
		protected var _timer:Timer;				
		protected var _data:ByteArray;
		protected var _objects:Vector.<SEAObject>;
		protected var _position:int;
		protected var _config:IConfigWriter;
		
		public function SEAWriter(config:IConfigWriter=null):void
		{
			_config = config || new ConfigWriter();
			
			_data = new ByteArray();
			_data.endian = Endian.LITTLE_ENDIAN;
		}
		
		public function get data():ByteArray
		{
			return _data;
		}
		
		public function get position():int
		{
			return _position;
		}
		
		public function get length():uint
		{
			return _objects.length;
		}
		
		public function get objects():Vector.<SEAObject>
		{
			return _objects;
		}
		
		protected function onWriteBody(e:TimerEvent=null):void
		{
			if (_timer)
				stopTimer();
			
			_time = getTimer();
						
			//
			//	BODY
			//
			
			dispatchProgress();
			
			while (_position < _objects.length)
			{
				if (!writeSEAObject(_objects[_position++]))
				{					
					return;
				}
				else if (getTimer() - _time > _config.timeLimit)
				{
					return startTimer();					
				}
			}
			
			writeEnd();
		}
		
		private function dispatchProgress():void
		{
			if (hasEventListener(SEAEvent.PROGRESS))
				dispatchEvent(new SEAEvent(SEAEvent.PROGRESS));
		}
		
		protected function startTimer():void
		{
			_timer = new Timer(1);
			_timer.addEventListener(TimerEvent.TIMER, onWriteBody);
			_timer.start();
		}
		
		protected function stopTimer():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, onWriteBody);
			_timer.stop();
			_timer = null;
		}				
		
		protected function writeHeader():void
		{
			//
			//	HEADER
			//
			
			// 3 bytes - MAGIC
			_data.writeUTFBytes("SEA");
			
			// 3 bytes - SIGNATURE : S3D = SEA3D Standard (focused to a Web File Format)
			_data.writeUTFBytes("S3D");
			
			// 3 bytes - Version
			ByteArrayUtils.writeUnsignedInt24(_data, _config.version);			
			
			// 1 bytes - Protection Method
			_data.writeByte(0);
			
			// 1 bytes - Compress Method		
			switch(_config.compressMethod)
			{
				case "deflate":		
					_data.writeByte(1);
					break;
				
				case "lzma":
					_data.writeByte(2);
					break;
				
				default:
					_data.writeByte(0);
					break;
			}
			
			// 4 bytes - Length
			_data.writeUnsignedInt(_objects.length);
		}
		
		protected function writeEnd():void
		{
			//
			//	END
			//
			
			// 3 bytes
			ByteArrayUtils.writeUnsignedInt24(_data, 0x5EA3D1);	
			
			dispatchProgress();
			
			if (hasEventListener(SEAEvent.COMPLETE))
				dispatchEvent(new SEAEvent(SEAEvent.COMPLETE));
		}
		
		protected function writeSEAObject(sea:SEAObject):Boolean
		{			
			writeObject(sea.typeInt, sea.write(), sea.compressed, sea.streaming, sea.name);		
			return true;
		}
		
		protected function writeObject(typeInt:int, data:ByteArray, compressed:Boolean=true, streaming:Boolean=true, name:String=null):void
		{			
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			var flag:int = 0;
				
			if (name) flag += 1;
			if (compressed) flag += 2;
			if (streaming) flag += 4;
				
			bytes.writeByte(flag);
			bytes.writeUnsignedInt(typeInt);
			
			if (name)
				ByteArrayUtils.writeUTFTiny(bytes, name);
			
			if (compressed && _config.compressMethod)
			{
				data.compress(_config.compressMethod);
			}
			
			bytes.writeBytes(data);
						
			_data.writeUnsignedInt(bytes.length);
			_data.writeBytes(bytes);
		}
				
		public function write(objects:Vector.<SEAObject>):void
		{
			_objects = objects;
									
			writeHeader();			
			onWriteBody();
		}
	}
}