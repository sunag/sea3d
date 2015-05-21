package sunag.sea3d.gui
{
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import sunag.sea3d.loader.Loader;
	import sunag.sea3d.loader.LoaderEvent;

	public class LoaderDisplay extends Sprite
	{
		[Embed(source="font/Comfortaa-Regular.ttf", fontName="SEA3D FONT", embedAsCFF=false)]
		public var MyFontClass:Class;
		
		private var _progress:ProgressCircle;
		private var _bg:Shape;
		private var _field:TextField;
		private var _loader:Loader;
		
		protected static const TEXT_FORMAT:TextFormat = new TextFormat('SEA3D FONT',18,0xEEEEEE,null,null,null,null,null,TextFieldAutoSize.LEFT);
		
		public function LoaderDisplay(loader:Loader)
		{
			_loader = loader;
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
			
			addChild( _bg = new Shape() );
			_bg.graphics.beginFill(0, .5);
			_bg.graphics.drawRect(0, 0, 60, 60);
			
			addChild( _progress = new ProgressCircle() );			
			_progress.x = 30;
			_progress.y = 30;
			_progress.infinity = true;		
			
			addChild(_field = new TextField());			
			
			_field.defaultTextFormat = TEXT_FORMAT;
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.antiAliasType = AntiAliasType.ADVANCED; 
			_field.width = _field.height = 0;	
			_field.type = TextFieldType.DYNAMIC;			
			_field.x = _bg.width; 
			_field.embedFonts = true;
			
			_field.text = _loader.description;
			
			_field.y = int(_bg.height/2) - Math.round(_field.textHeight / 2) - 1;
			
			mouseChildren = mouseEnabled = false; 
		}
		
		protected function onAdded(e:Event):void			
		{
			_loader.addEventListener(LoaderEvent.PROGRESS, onProgress);
		}
		
		protected function onRemoved(e:Event):void
		{
			_loader.removeEventListener(LoaderEvent.PROGRESS, onProgress);
		}
		
		protected function onProgress(e:LoaderEvent):void
		{
			_progress.color = e.loader.streaming ? ProgressCircle.BLUE : ProgressCircle.GREEN;
			_progress.progress = e.loader.bytesLoaded / e.loader.bytesTotal;
		}
		
		override public function set width(value:Number):void
		{
			_bg.width = value;
		}
		
		override public function get height():Number
		{
			return _bg.height;
		}
	}
}