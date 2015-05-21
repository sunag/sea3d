/*
*
* Copyright (c) 2013 Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

package sunag.sea3d
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
	import flash.utils.getTimer;
	
	import sunag.sunag;
	import sunag.events.SEAEvent;
	import sunag.sea3d.config.ConfigBase;
	import sunag.sea3d.config.IConfigBase;
	import sunag.sea3d.modules.ModuleBase;
	import sunag.sea3d.objects.SEAATF;
	import sunag.sea3d.objects.SEAATFCube;
	import sunag.sea3d.objects.SEAAnimation;
	import sunag.sea3d.objects.SEAComposite;
	import sunag.sea3d.objects.SEAContainer3D;
	import sunag.sea3d.objects.SEACubeMap;
	import sunag.sea3d.objects.SEACubeURL;
	import sunag.sea3d.objects.SEADirectionalLight;
	import sunag.sea3d.objects.SEAFileInfo;
	import sunag.sea3d.objects.SEAGIF;
	import sunag.sea3d.objects.SEAGeometry;
	import sunag.sea3d.objects.SEAGeometryDelta;
	import sunag.sea3d.objects.SEAJPEG;
	import sunag.sea3d.objects.SEAJPEGXR;
	import sunag.sea3d.objects.SEAJointObject;
	import sunag.sea3d.objects.SEAMaterial;
	import sunag.sea3d.objects.SEAMesh;
	import sunag.sea3d.objects.SEAMesh2D;
	import sunag.sea3d.objects.SEAMorph;
	import sunag.sea3d.objects.SEAMorphAnimation;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAOrthographicCamera;
	import sunag.sea3d.objects.SEAPNG;
	import sunag.sea3d.objects.SEAPerspectiveCamera;
	import sunag.sea3d.objects.SEAPointLight;
	import sunag.sea3d.objects.SEAPoonyaScript;
	import sunag.sea3d.objects.SEAProperties;
	import sunag.sea3d.objects.SEAReference;
	import sunag.sea3d.objects.SEASingleCube;
	import sunag.sea3d.objects.SEASkeleton;
	import sunag.sea3d.objects.SEASkeletonAnimation;
	import sunag.sea3d.objects.SEATextureURL;
	import sunag.sea3d.objects.SEAUVWAnimation;
	import sunag.sea3d.objects.SEAVertexAnimation;
	import sunag.utils.ByteArrayUtils;
	
	use namespace sunag;
	
	public class SEA extends EventDispatcher
	{
		/**
		 * Version of the SEA3D in VVSSBB format
		 * V = Version | S = Subversion | B = Build  		 
		 */
		public static const VERSION:int = 16500;
		
		public var tag:*;
		
		//
		//	Struct	
		//
		
		sunag var _configBase:IConfigBase;
		
		private var _startTime:uint = 0;
		private var _endTime:uint = 0;
		private var _bytesTotal:uint = 0;
		private var _timer:Timer;		
		sunag var _objects:Vector.<SEAObject> = new Vector.<SEAObject>();				
		private var _position:uint = 0;		
		sunag var _length:uint = 0;		
		private var _time:int;
		
		private var _ansyObject:SEAObject;
		private var _ansyList:Vector.<SEAObject>;
		
		protected var _version:uint;		
		
		protected var _compressionAlgorithm:String;
		protected var _protectionAlgorithm:String;		
			
		//
		//	Stream
		//
		
		private var _streamSequence:StreamSequence;
		private var _dataPosition:uint;
		private var _urlStream:URLStream;
		private var _data:ByteArray;
		private var _typeLength:int;		
		private var _progressEvent:SEAEvent;
		private var _streamEvent:SEAEvent;
		
		//
		//	Extension
		//
		
		sunag var _typeRead:Object = {};
		sunag var _typeClass:Object = {};
			
		sunag var _modules:Vector.<ModuleBase>;
		
		sunag var object:Object = {};
		sunag var sea:Object = {};
		
		/**
		 * Dispatched when the SEA3D is loaded.
		 * 
		 * @eventType sunag.events.SEAEvent
		 * @see sunag.sea3d.SEA3D
		 */
		[Event(name="complete",type="sunag.events.SEAEvent")]
		
		/**
		 * Dispatched when there loading progress.
		 * 
		 * @eventType sunag.events.SEAEvent
		 * @see sunag.sea3d.SEA3D
		 */
		[Event(name="progress",type="sunag.events.SEAEvent")]
		
		/**
		 * Dispatched if hover loading error.
		 * 
		 * @eventType sunag.events.SEAEvent
		 * @see sunag.sea3d.SEA3D
		 */
		[Event(name="error",type="sunag.events.SEAEvent")]
		
		/**
		 * Creates a new SEA loader 
		 * @param config Settings file loading
		 */
		public function SEA(configBase:IConfigBase=null)
		{
			_configBase = configBase || new ConfigBase();
			
			_streamSequence = new StreamSequence();		
			
			_streamSequence.addCallback(readHead);
			_streamSequence.addCallback(readBody);
			
			_typeClass[SEACubeMap.TYPE] = SEACubeMap;
			_typeClass[SEASingleCube.TYPE] = SEASingleCube;
			_typeClass[SEAPNG.TYPE] = SEAPNG;
			_typeClass[SEAGIF.TYPE] = SEAGIF;
			_typeClass[SEAJPEG.TYPE] = SEAJPEG;
			_typeClass[SEAJPEGXR.TYPE] = SEAJPEGXR;
			_typeClass[SEAATF.TYPE] = SEAATF;
			_typeClass[SEAATFCube.TYPE] = SEAATFCube;
			_typeClass[SEAComposite.TYPE] = SEAComposite;
			_typeClass[SEAMaterial.TYPE] = SEAMaterial;
			_typeClass[SEAAnimation.TYPE] = SEAAnimation;
			_typeClass[SEAUVWAnimation.TYPE] = SEAUVWAnimation;
			_typeClass[SEAVertexAnimation.TYPE] = SEAVertexAnimation;
			_typeClass[SEASkeleton.TYPE] = SEASkeleton;
			_typeClass[SEASkeletonAnimation.TYPE] = SEASkeletonAnimation;
			_typeClass[SEAMorph.TYPE] = SEAMorph;
			_typeClass[SEAMorphAnimation.TYPE] = SEAMorphAnimation;
			_typeClass[SEAMesh.TYPE] = SEAMesh;						
			_typeClass[SEAPerspectiveCamera.TYPE] = SEAPerspectiveCamera;
			_typeClass[SEAOrthographicCamera.TYPE] = SEAOrthographicCamera;
			_typeClass[SEAProperties.TYPE] = SEAProperties;		
			_typeClass[SEADirectionalLight.TYPE] = SEADirectionalLight;			
			_typeClass[SEAPointLight.TYPE] = SEAPointLight;			
			_typeClass[SEAMesh2D.TYPE] = SEAMesh2D;
			_typeClass[SEAGeometry.TYPE] = SEAGeometry;
			_typeClass[SEAGeometryDelta.TYPE] = SEAGeometryDelta;
			_typeClass[SEAContainer3D.TYPE] = SEAContainer3D;
			_typeClass[SEAJointObject.TYPE] = SEAJointObject;
			_typeClass[SEAPoonyaScript.TYPE] = SEAPoonyaScript;
			_typeClass[SEATextureURL.TYPE] = SEATextureURL;
			_typeClass[SEACubeURL.TYPE] = SEACubeURL;
			_typeClass[SEAReference.TYPE] = SEAReference;
			
			_typeRead[SEAFileInfo.TYPE] = readFileInfo;
		}
		
		//
		//	Stream Methods
		//
		
		public static function getStructVersion(data:flash.utils.ByteArray):uint
		{
			var position:uint = data.position, v:uint = 0;
			if (data.readUTFBytes(3) === "SEA")
			{
				if ((data.readUnsignedByte() << 16 | 
					data.readUnsignedByte() << 8 | 
					data.readUnsignedByte()) == 0x5EA3D1) v = 1;
				else v = 2;
			}
			data.position = position;
			return v;
		}
		
		public function get data():ByteArray
		{
			return _data;			
		}
		
		protected function readHead():Boolean
		{
			if (_data.bytesAvailable < 16)
				return false;
												
			_startTime = getTimer();			
			
			// 3 bytes - MAGIC
			if (_data.readUTFBytes(3) != "SEA")
				throw new Error("Invalid SEA3D format.");			
						
			// 3 bytes - SIGNATURE : S3D = SEA3D Standard (focused to a Web File Format)
			var sign:String = _data.readUTFBytes(3);
			if (sign != "S3D")
				trace("Warning: Signature \"" + sign + "\" not recognized.");
			
			// 3 bytes
			_version = ByteArrayUtils.readUnsignedInt24(_data);
								
			// 1 bytes
			switch(_data.readUnsignedByte())
			{
				case 0:
					break;
				
				default:					
					throw new Error("Protection method not is compatible.");
					break;
			}
			
			// 1 bytes
			switch(_data.readUnsignedByte())
			{				
				case 0:
					_compressionAlgorithm = null;
					break;
				
				case 1:
					_compressionAlgorithm = "deflate";
					break;
				
				case 2:
					_compressionAlgorithm = "lzma";
					break;
				
				default:					
					throw new Error("Compression method not is compatible.");
					break;
			}
						
			// 4 bytes
			_length = _data.readUnsignedInt();
			
			// update position
			_dataPosition = _data.position;
			
			/*
			var differentVersion:int = version - VERSION;
			
			if (differentVersion < 0)
				trace("Warning: File contains an old version of SEA3D.");
			else if (differentVersion > 0)
				trace("Warning: File was designed for a newer version of SEA3D.");
			*/
			
			return true;
		}		
				
		/**
		 * Get and load a SEAObject
		 * @param index Index of the file
		 */
		public function getSEAObject(index:uint):SEAObject
		{
			var sea:SEAObject = _objects[index];
			
			if (_ansyList)
			{
				if (!sea.complete)
				{
					sea.load();
					
					_ansyList.push( sea );					
				}
			}			
			else if (!sea.complete)
			{
				sea.load();
				
				if (_typeRead[sea.type])
					_typeRead[sea.type](sea);
				
				sea.complete = true;
				
				if (hasEventListener(SEAEvent.COMPLETE_OBJECT))
					dispatchEvent(new SEAEvent(SEAEvent.COMPLETE_OBJECT, sea));				
			}
			
			return sea;
		}
						
		public function getAnsySEAObject(index:uint):void
		{						
			_ansyObject = _objects[index];
			_ansyList = new Vector.<SEAObject>();					
			
			_ansyObject.load();
			
			if (_timer)
				stopTimer();
			
			startTimerObject();
		}
		
		private function onLoadAnsySEAObject(e:TimerEvent):void
		{
			stopTimer();
			
			var timeStart:uint = getTimer();						
			
			while (_ansyList.length)
			{
				var obj:SEAObject = _ansyList.pop();
								
				if (obj.complete)
					continue;
				
				var time:int = getTimer();
				var timelapsed:uint = time - timeStart;				
				
				if (_typeRead[sea.type])
					_typeRead[sea.type](sea);
				
				sea.complete = true;
				
				var t:int = getTimer();
				
				if (hasEventListener(SEAEvent.COMPLETE_OBJECT))
					dispatchEvent(new SEAEvent(SEAEvent.COMPLETE_OBJECT, obj, null, t - time));
				
				if (timelapsed > _configBase.timeLimit) 
				{
					dispatchProgress();
					startTimerObject();
					return;
				}
			}						
		}
		
		/**
		 * Check if contains a SEAObject from file index.
		 * @param index Index of the file
		 */
		public function contains(index:uint):Boolean
		{
			return index < _objects.length;
		}
		
		/**
		 * Get the file index from filename.
		 * @param name Name of the file
		 */
		public function getSEAObjectIndex(name:String):int
		{
			return sea[name] ? sea[name].index : -1;
		}
		
		/**
		 * Returns true if it contains an SEA3D object already loaded
		 * @param ns Namespace of an object. Example: <b>Box001.m3d</b>
		 */
		public function containsObject(name:String):Boolean
		{
			return getSEAObjectIndex(name) != -1;
		}
		
		/**
		 * Returns or load one SEA3D object
		 * @param ns Namespace of an object. Example: <b>Box001.m3d</b>
		 */
		public function getObject(name:String):*
		{
			return getSEAObject( getSEAObjectIndex(name) ).tag;
		}
		
		public function get compressionAlgorithm():String
		{
			return _compressionAlgorithm;
		}
		
		public function close():void
		{
			if (_urlStream)
			{								
				_urlStream.close();
				onStreamComplete();
			}
		}
		
		public function get protectionAlgorithm():String
		{
			return _protectionAlgorithm;
		}
		
		private function dispatchProgress():void
		{
			if (hasEventListener(SEAEvent.PROGRESS))
				dispatchEvent(_progressEvent || (_progressEvent=new SEAEvent(SEAEvent.PROGRESS)));
		}
		
		protected function readBody():Boolean
		{
			var timeStart:uint = getTimer();						
			
			while (_position < _length)
			{
				var timelapsed:uint = getTimer() - timeStart;
				
				var seaObject:SEAObject = loadSEAObject();	
					
				if (!seaObject)			
				{
					dispatchProgress();
					return false;
				}
				
				if (hasEventListener(SEAEvent.READ_OBJECT))
					dispatchEvent(new SEAEvent(SEAEvent.READ_OBJECT, seaObject));
				
				if ((seaObject.streaming && _configBase.streaming) || _configBase.forceStreaming)
				{																
					if (_typeRead[seaObject.type])
						_typeRead[seaObject.type](seaObject);
				
					seaObject.complete = true;
					
					var time:int = getTimer();
					
					if (hasEventListener(SEAEvent.COMPLETE_OBJECT))
						dispatchEvent(new SEAEvent(SEAEvent.COMPLETE_OBJECT, seaObject, null, time - _time));
					
					_time = time;
				}
				else
				{
					_time = getTimer();
				}				
				
				if (timelapsed > _configBase.timeLimit && _position < _length) 
				{
					dispatchProgress();
					return false;
				}					
			}									
			
			return readComplete();
		}		
		
		protected function readComplete():Boolean
		{
			_data.position = _dataPosition;
			
			if (_data.bytesAvailable < 3)
				return false;
			
			if (ByteArrayUtils.readUnsignedInt24(_data) != 0x5EA3D1)
				trace("Warning: SEA3D file is corrupted.");
									
			return true;
		}
				
		protected function loadSEAObject():SEAObject
		{
			_data.position = _dataPosition;
			
			if (_data.bytesAvailable < 4)
				return null;
			
			var size:uint = _data.readUnsignedInt();			
			var position:uint = _data.position;
			
			if (_data.bytesAvailable < size)
				return null;
									
			_time = getTimer();		
			
			var flag:uint = _data.readUnsignedByte();
			var type:String = _data.readUTFBytes(4);
			var name:String = flag & 1 ? ByteArrayUtils.readUTFTiny(_data) : "";
			
			var bytes:ByteArray;
			
			size -= _data.position - position;
			position = _data.position;		
			
			bytes = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			bytes.writeBytes(_data, position, size);
			bytes.position = 0;			
			
			var seaObject:SEAObject; 									
			
			if (_typeClass[type])
			{				
				seaObject = new _typeClass[type](name, this);
				seaObject.compressed = (flag & 2) != 0;
				seaObject.streaming = (flag & 4) != 0;
				
				if (seaObject.compressed && _compressionAlgorithm)
					bytes.uncompress(_compressionAlgorithm);
				
				seaObject.data = bytes;
								
				if (hasEventListener(SEAEvent.LOAD_OBJECT))
					dispatchEvent(new SEAEvent(SEAEvent.LOAD_OBJECT, seaObject));
				
				if ((seaObject.streaming && _configBase.streaming)  || _configBase.forceStreaming)
				{
					seaObject.load();
					
					/*
					// only for developer mode
					if (bytes.bytesAvailable > 0)
						trace("Caution! Not all data have been processed of the object: \"" + seaObject.filename + "\"");
					*/
				}
			}
			else
			{
				seaObject = new SEAObject(name, type, this)
				trace("Unknown format \"" + type + "\" of file \"" + name + "\". Add a module referring for this format.");
			}
			
			seaObject.index = _position;
			
			_objects.push(sea[seaObject.filename] = seaObject);						
												
			_dataPosition = position += size;
						
			++_position;
			
			return seaObject;
		}
		
		public function read(sea:SEAObject):Boolean
		{
			if (!_typeRead[sea.type]) 
				return false;			
			
			_typeRead[sea.type](sea);	
			
			return true;
		}
		
		private function onTimer(e:TimerEvent):void
		{
			if (_timer)
				stopTimer();
			
			_streamSequence.run();
			
			if (_streamSequence.completed) complete();
			else startTimer();					
		}
		
		private function startTimerObject():void
		{
			_timer = new Timer(1);
			_timer.addEventListener(TimerEvent.TIMER, onLoadAnsySEAObject);
			_timer.start();
		}
		
		private function startTimer():void
		{
			_timer = new Timer(1);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			_timer.start();
		}
		
		private function stopTimer():void
		{
			_timer.removeEventListener(TimerEvent.TIMER, onLoadAnsySEAObject);
			_timer.removeEventListener(TimerEvent.TIMER, onTimer);
			_timer.stop();
			_timer = null;
		}
					
		protected function complete():void
		{			
			_endTime = getTimer();			
							
			dispatchProgress();
			
			if (hasEventListener(SEAEvent.COMPLETE))
				dispatchEvent(new SEAEvent(SEAEvent.COMPLETE));
		}
		
		/**
		 * Number of objects to be loaded
		 *
		 * @see #position		 		 		 
		 * @see #objects		 		 		
		 */
		public function get length():uint
		{
			return _length;
		}
		
		/**
		 * Bytes position (read).
		 *
		 * @see #bytesLoaded	 		 		 
		 * @see #bytesTotal		 		 		
		 */
		public function get bytesPosition():uint
		{
			return _dataPosition;
		}
		
		/**
		 * Bytes loaded.
		 *	 		 		 
		 * @see #bytesTotal		 		 		
		 */
		public function get bytesLoaded():uint
		{
			return _data ? _data.length : 0;
		}
		
		/**
		 * Bytes loaded.
		 *	 		 		 
		 * @see #bytesLoaded		 		 		
		 */
		public function get bytesTotal():uint
		{
			return _bytesTotal;
		}
		
		/**
		 * Current loaded position
		 * 
		 * @see #length		 		 		 
		 * @see #objects			 		
		 */
		public function get position():uint
		{
			return _position;
		}
				
		/**
		 * Unload all loaded data, but not dispose objects.
		 * 
		 * @see #length		 		 		 
		 * @see #objects			 		
		 */
		public function unload():void
		{
			var sea:Object = this.sea;
			var objects:Vector.<SEAObject> = _objects;
						
			reset();			
			
			for each(var obj:SEAObject in objects)
			{				
				if (obj.complete)
					obj.dispose();
			}
			
			_length = _position = objects.length;
			_objects = objects;
			
			this.sea = sea; 							
		}				
		
		protected function reset():void
		{
			if (_urlStream)
			{
				_urlStream.close();
				onStreamComplete();
			}
			
			_data = null;			
			
			if (_timer)
				stopTimer();
					
			object = {};
			sea = {};
			
			_streamSequence.position = 
				_dataPosition = 
				_position = 
				_length = 0;
			
			_objects = new Vector.<SEAObject>();
			
			for each(var module:ModuleBase in _modules)			
				module.reset();	
		}
				
		/**
		 * Loads a SEA3D file from a URL.
		 * @param request URLRequest
		 */
		public function load(request:URLRequest):void
		{
			reset();
						
			_urlStream = new URLStream();
			_urlStream.endian = Endian.LITTLE_ENDIAN;
			
			_urlStream.addEventListener(ProgressEvent.PROGRESS, onStreamProgress, false, 0, true);
			_urlStream.addEventListener(Event.COMPLETE, onStreamComplete, false, 0, true);
			_urlStream.addEventListener(IOErrorEvent.IO_ERROR, onURLStreamEvents, false, 0, true);
			_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLStreamEvents, false, 0, true);
			_urlStream.load(request);
			
			_data = new ByteArray();
			_data.endian = Endian.LITTLE_ENDIAN;
					
			_bytesTotal = 0;
			
			startTimer();
		}		
		
		/**
		 * Loads a SEA3D file from a ByteArray.
		 * @param bytes ByteArray
		 */
		public function loadBytes(bytes:ByteArray):void
		{
			reset();
			
			_data = bytes;
			_data.endian = Endian.LITTLE_ENDIAN;
			
			_bytesTotal = _data.length;
			
			startTimer();
		}
		
		private function onURLStreamEvents(evt:Event):void
		{
			dispatchEvent(evt);			
		}
		
		private function onStreamProgress(evt:ProgressEvent):void
		{			
			_bytesTotal = evt.bytesTotal;
			
			while (_urlStream.bytesAvailable)	
				_urlStream.readBytes(_data, _data.length);
			
			if (hasEventListener(SEAEvent.STREAMING_PROGRESS))
				dispatchEvent(_streamEvent || (_streamEvent=new SEAEvent(SEAEvent.STREAMING_PROGRESS)));
		}
		
		private function onStreamComplete(evt:Event=null):void
		{
			_urlStream.removeEventListener(ProgressEvent.PROGRESS, onStreamProgress);
			_urlStream.removeEventListener(Event.COMPLETE, onStreamComplete);
			_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, onURLStreamEvents);
			_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onURLStreamEvents);
			
			_urlStream = null;
		}
										
		/**
		 * Returns the info of the file. Usually name, copyright and date of development.
		 */		
		public function getFileInfo():Object
		{
			return object["file.inf"];
		}
		
		protected function readFileInfo(sea:SEAFileInfo):void
		{
			object[sea.filename] = sea.info;
		}	
		
		/**
		 * Total processing time
		 */
		public function get totalTime():uint
		{
			if (_startTime === 0) return 0;
			else if (_endTime === 0) return getTimer() - _startTime;
			return _endTime - _startTime;
		}
				
		/**
		 * Returns the version of the SEA3D file
		 * 
		 * @see #subversion
		 */
		public function get version():int
		{
			return _version;
		}
		
		
		/**
		 * ConfigBase object  
		 */
		public function get configBase():IConfigBase
		{
			return _configBase;
		}

		/**
		 * Returns the version of the SEA3D file in string
		 * 
		 * @see #subversion
		 */
		public function get versionString():String
		{
			// Max = 16777215 - VVSSBB  | V = Version | S = Subversion | B = Buildversion
			var v:String = _version.toString(), l:uint = v.length;			
			return v.substring(0, l-4) + "." + v.substring(l-4,l-3) + "." + v.substring(l-3,l-2) + "." + parseFloat(v.substring(l-2, l)).toString();			
		}
		
		/**
		 * Dispose all files
		 */
		public function dispose():void
		{						
			for each(var module:ModuleBase in _modules)			
				module.dispose();			
			
			for each(var obj:SEAObject in _objects)			
				obj.dispose();
			
			reset();
		}
		
		/**
		 * Get list of objects of the SEA3D file
		 * 
		 * @see #length
		 */
		public function get objects():Vector.<SEAObject>
		{
			return _objects;
		}
				
		/**
		 * Modules are extensions of the SEA3D
		 */
		public function get modules():Vector.<ModuleBase>
		{
			return _modules;
		}
		
		/**
		 * Adds a new module. 
		 * <p>Use ".modules" to get modules</p>   
		 * 
		 * @see #modules
		 */
		public function addModule(module:ModuleBase):void
		{
			if (!_modules) 
				_modules = new Vector.<ModuleBase>();				
			
			module.init(this);			
			_modules.push(module);
			
			var n:String;
			
			for (n in module.TypeClass) _typeClass[n] = module.TypeClass[n];
			for (n in module.TypeRead) _typeRead[n] = module.TypeRead[n];					
		}
		
		/**
		 * Return true if this module exists
		 */
		public function containsModule(module:ModuleBase):Boolean
		{
			return _modules && _modules.indexOf(module) > -1;
		}				
	}
}

class StreamSequence
{
	public var position:int = 0;
	public var callback:Array = [];
	
	public function addCallback(func:Function):void
	{
		callback.push(func);
	}
	
	public function get completed():Boolean
	{
		return position == callback.length;
	}
	
	public function run():void
	{		
		while (position < callback.length && callback[position]())
		{
			position++;
		}
	}
}