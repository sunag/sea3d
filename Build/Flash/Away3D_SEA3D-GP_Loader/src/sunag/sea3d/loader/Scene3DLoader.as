package sunag.sea3d.loader
{
	import flash.utils.Dictionary;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import sunag.sea3dgp;
	import sunag.events.SEAEvent;
	import sunag.sea3d.SEA;
	import sunag.sea3d.config.ConfigBase;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.framework.Asset;
	import sunag.sea3d.modules.ActionModuleBase;
	import sunag.sea3d.modules.ByteCodeModuleBase;
	import sunag.sea3d.modules.ParticleModuleBase;
	import sunag.sea3d.modules.SoundModuleBase;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class Scene3DLoader extends Loader
	{
		public static const IDLE:int = 0;
		public static const LOADING:int = 1;		
		public static const COMPLETE:int = 2;
		
		static private var DICT:Dictionary = new Dictionary(true);
		
		static public function get(name:*):Scene3DLoader
		{
			return DICT[name];
		}
		
		static public function create(name:*, description:String, config:ConfigBase):Scene3DLoader
		{
			var loader:Scene3DLoader = new Scene3DLoader(description, config)
			loader.name = name;
				
			return DICT[name] = loader;
		}
		
		private var _status:int = 0;
		private var _sea3d:SEA;
		private var _config:ConfigBase;
		private var _objects:Object = {};
		private var _load:Array = [];
		private var _progress:Array = [];
		private var _complete:Array = [];		
		
		public var name:String;
		
		public function Scene3DLoader(description:String, config:ConfigBase)
		{
			super(description, onLoad);
			
			_config = config;
		}
		
		public function get status():int
		{
			return _status;
		}
		
		public function get config():ConfigBase
		{
			return _config;
		}
		
		public function close():void
		{
			if (name) delete DICT[name];			
			
			if (_sea3d)
			{
				_sea3d.removeEventListener(SEAEvent.STREAMING_PROGRESS, onProgress);
				_sea3d.removeEventListener(SEAEvent.PROGRESS, onProgress);
				_sea3d.removeEventListener(SEAEvent.COMPLETE, onComplete);
				_sea3d.removeEventListener(SEAEvent.COMPLETE_OBJECT, onCompleteObject);
				
				_sea3d.close();
			}
			
			if (_status != COMPLETE)
			{
				dispatchComplete();
			}
		}
		
		public function get deps():int
		{
			return _complete ? _complete.length : 0;
		}
		
		public function removeCallback(onAssetComplete:Function, onAssetLoad:Function=null, onProgress=null):void
		{
			var i:int;
			
			i = _complete.indexOf(onAssetComplete);
			if (i > -1) _complete.splice(i, 1);
			
			i = _load.indexOf(onAssetLoad);
			if (i > -1) _load.splice(i, 1);
			
			i = _progress.indexOf(onProgress);
			if (i > -1) _progress.splice(i, 1);
		}
		
		public function addCallback(onAssetComplete:Function, onAssetLoad:Function=null, onProgress=null):void
		{
			var asset:Asset;
			
			if (_status == COMPLETE)
			{
				if (onAssetLoad) 
				{
					for each(asset in _objects)				
						onAssetLoad(asset);				
				}
				
				if (onProgress)
				{
					onProgress(_bytesLoaded, _bytesTotal);
				}
				
				onAssetComplete( _objects );
			}
			else
			{
				if (onAssetLoad) 
				{
					if (_status == LOADING)
					{
						for each(asset in _objects)				
							onAssetLoad(asset);	
					}
					
					_load.push( onAssetLoad );
				}
				
				if (onProgress)
				{
					_progress.push( onProgress );
				}
				
				if (onAssetComplete) _complete.push( onAssetComplete );
			}
		}
		
		private function onLoad():void
		{
			_status = 1;
			
			_sea3d = new SEA(_config);
			_sea3d.addModule(new ByteCodeModuleBase());
			_sea3d.addModule(new ActionModuleBase());
			_sea3d.addModule(new SoundModuleBase());
			_sea3d.addModule(new ParticleModuleBase());
			_sea3d.addEventListener(SEAEvent.STREAMING_PROGRESS, onProgress);
			_sea3d.addEventListener(SEAEvent.PROGRESS, onProgress);
			_sea3d.addEventListener(SEAEvent.COMPLETE, onComplete);
			_sea3d.addEventListener(SEAEvent.COMPLETE_OBJECT, onCompleteObject);
			
			//if (data) setTimeout(_sea3d.loadBytes, 5000, data);
			//else setTimeout(_sea3d.load, 5000, request);
			
			if (data) _sea3d.loadBytes( data );
			else _sea3d.load( request );
		}
		
		private function onComplete(e:SEAEvent):void
		{
			_status = 2;
			
			for each(var callback:Function in _complete)
			{
				callback(_objects);
			}				
			
			dispatchComplete();
			
			_load = null;
			_complete = null;
			_progress = null;
		}
		
		private function onProgress(e:SEAEvent):void
		{
			_bytesLoaded = _sea3d.bytesLoaded;
			_bytesTotal = _sea3d.bytesTotal;
			
			for each(var callback:Function in _progress)
			{
				callback(_bytesLoaded, _bytesTotal);
			}
			
			dispatchProgress();
		}
				
		private function onCompleteObject(e:SEAEvent):void
		{
			var sea:SEAObject = e.object;
			
			if (SEA3DGP.TYPE_CLASS[sea.type])
			{								
				var asset:Asset = new SEA3DGP.TYPE_CLASS[sea.type]();
				asset.load( sea );		
							
				if (_status == LOADING)
				{
					_objects[ sea.filename ] = asset;
					
					for each(var callback:Function in _load)
					{
						callback( asset );
					}
				}
			}
			else
			{
				trace("asset", sea.type, "not mapped");
			}
		}
		
		public function getAsset(ns:String):Asset
		{			
			return _objects[ ns ] ? _objects[ ns ] : _sea3d.getObject(ns);
		}				
	}
}