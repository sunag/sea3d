package sunag.sea3d.loader
{
	import flash.display.Sprite;
	
	import sunag.sea3dgp;
	import sunag.sea3d.gui.LoaderDisplay;

	use namespace sea3dgp;
	
	public class LoaderManager extends Sprite
	{
		public static const LIMIT:uint = 2;
		
		private var _loaders:Vector.<Loader> = new Vector.<Loader>();
		private var _loading:Vector.<LoaderDisplay> = new Vector.<LoaderDisplay>();
		
		private var _width:int = 100;
		private var _height:int = 100;
		
		sea3dgp function addLoader(loader:Loader):void
		{
			if (_loaders.indexOf(loader) == -1)
			{
				_loaders.push( loader );
				onLoad();
			}
		}
		
		private function onLoad():void
		{
			if (_loaders.length > 0 && _loading.length < LIMIT)
			{
				var loader:Loader = _loaders.shift();				
				
				var loaderDisplay:LoaderDisplay = loader.tag = new LoaderDisplay( loader );				
				
				_loading.push( loaderDisplay );		
				addChild(loaderDisplay);			
				
				loader.addEventListener(LoaderEvent.COMPLETE, onComplete);
				loader.onLoad();
			}
			
			update();
		}
		
		public function getLoaderFromURL(url:String):Loader
		{
			for each(var loader:Loader in _loaders)
			{
				if (loader.request.url == url)
					return loader;
			}
			
			return null;
		}
		
		override public function set width(value:Number):void
		{
			_width = value;
			update();
		}
		
		override public function get width():Number
		{
			return _width;
		}
		
		override public function set height(value:Number):void
		{
			_height = value;
			update();
		}
		
		override public function get height():Number
		{
			return _height;
		}
		
		protected function onComplete(e:LoaderEvent):void
		{						
			e.loader.removeEventListener(LoaderEvent.COMPLETE, onComplete);
			
			var loader:LoaderDisplay = e.loader.tag;
			
			removeChild(loader);
			
			_loading.splice( _loading.indexOf( loader ), 1 );						
			
			onLoad();
		}
		
		protected function update():void
		{
			var y:int = 0;
			
			for each(var loader:LoaderDisplay in _loading)
			{
				loader.y = y;
				loader.width = _width;
				
				y += loader.height + 1;
			}
		}
		
		public function get loaders():Vector.<Loader>
		{
			return _loaders;
		}
	}
}