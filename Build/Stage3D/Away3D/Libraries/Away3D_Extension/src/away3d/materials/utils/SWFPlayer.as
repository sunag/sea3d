package away3d.materials.utils
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	public class SWFPlayer implements IVideoPlayer
	{		
		private var _loader:Loader;
		private var _container:Sprite;
		private var _width:int;
		private var _height:int;
		private var _src:String;
		private var _playing:Boolean = true;
		
		public function SWFPlayer(width:int=256, height:int=256)
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onProgress);
			
			_width = width;
			_height = height;
			
			// container
			_container = new Sprite();
			_container.addChild(_loader);
		}
		
		//////////////////////////////////////////////////////
		// public methods
		//////////////////////////////////////////////////////
		
		protected function updateSize():void
		{
			_loader.width = _width; //(_width / _loader.contentLoaderInfo.width) * _width;
			_loader.height = _height; //(_height / _loader.contentLoaderInfo.height) * _height;
		}
		
		protected function onProgress(e:ProgressEvent):void
		{
			updateSize();
		}
		
		protected function onComplete(e:Event):void
		{
			updateSize();
		}
		
		public function play():void
		{			
		}
		
		public function pause():void
		{			
		}
		
		public function seek(val:Number):void
		{			
		}
		
		public function stop():void
		{			
		}
		
		public function dispose():void
		{
			_loader.unload();		
		}
		
		public function clone():IVideoPlayer
		{			
			return null;
		}
		
		public function get source():String
		{
			return _src;
		}
		
		public function set source(src:String):void
		{
			if (_src == src) return;
			
			_src = src;
			
			if (_src)
			{
				var context:LoaderContext = new LoaderContext();
				
				_loader.load(new URLRequest(_src), context);
			}
		}
		
		public function get loop():Boolean
		{
			return true;
		}
		
		public function set loop(val:Boolean):void
		{
		}
		
		public function get volume():Number
		{
			return 1;
		}
		
		public function set volume(val:Number):void
		{
		}
		
		public function get pan():Number
		{
			return 0;
		}
		
		public function set pan(val:Number):void
		{
		}
		
		public function get mute():Boolean
		{
			return false;
		}
		
		public function set mute(val:Boolean):void
		{
		}
		
		public function get soundTransform():SoundTransform
		{
			return new SoundTransform();
		}
		
		public function set soundTransform(val:SoundTransform):void
		{
		}
		
		public function get width():int
		{
			return _width;
		}
		
		public function set width(val:int):void
		{
			_width = val;
		}
		
		public function get height():int
		{
			return _height;
		}
		
		public function set height(val:int):void
		{
			_height = val;
		}
		
		//////////////////////////////////////////////////////
		// read-only vars
		//////////////////////////////////////////////////////
		
		public function get container():Sprite
		{
			
			
			return _container;
		}
		
		public function get time():Number
		{
			return 0;
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function get paused():Boolean
		{
			return !_playing;
		}	
	}
}
