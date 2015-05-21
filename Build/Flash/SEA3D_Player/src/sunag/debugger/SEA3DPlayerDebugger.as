package sunag.debugger
{
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.LocalConnection;
	import flash.utils.ByteArray;
	
	import sunag.sunag;
	import sunag.progressbar.ProgressCircle;
	
	use namespace sunag;
	
	public class SEA3DPlayerDebugger
	{
		private static const STUDIO:String = "SEA3D-STUDIO";
		
		private static const PACK_LIMIT:int = 3;
		
		private static var circle:ProgressCircle;
		private static var lc:LocalConnection = new LocalConnection();
		private static var sender:LocalConnection = new LocalConnection();
		private static var buffer:ByteArray;
		private static var loaderInfo:LoaderInfo;
		private static var packCount:int = 0;
		
		sunag static var stage:Stage;
		
		sunag static var onInit:Function;
		sunag static var onLoad:Function;
		
		public static function init(stage:Stage, onInit:Function, onLoad:Function):void
		{	
			sunag::stage = stage;
			
			sunag::onInit = onInit;
			sunag::onLoad = onLoad;
						
			addCircle('SEA3D Player Debugger\n<font color="#999999">Waiting Studio</font>');						
			
			lc.allowDomain('*');
			lc.connect("SEA3D-DEBUGGER");
			lc.client = {
					init:onInitStudio,
					appendbuffer:appendBuffer,
					loadbuffer:loadBuffer
				};		
			
			sender.addEventListener(StatusEvent.STATUS, onStatus);
		}				
		
		private static function onGlobalError(e:UncaughtErrorEvent):void
		{
			var msg:String;
			
			if (e.error is Error) msg = Error(e.error).message;
			else msg = String(e.error) || 'Unknown error';
				
			lc.send(STUDIO, 'error', msg);
			
			e.preventDefault();
		}
				
		private static function onInitStudio(message:String):void
		{
			addCircle("Waiting");
			
			sunag::onInit(message);
			
			send(message, 0x666666, true);								
		}
		
		private static function onStatus(e:StatusEvent):void
		{
			switch(e.level)
			{
				case 'status':					
					break;
				
				default:					
					trace('[DEBUGGER] Data pack not sended!');					
					break;								
			}
			
			--packCount;
		}
		
		private static function send(text:String, color:Number=0xEEEEEE, bold:Boolean=false, italic:Boolean=false):void
		{
			sender.send(STUDIO, 'print', text, color, bold, italic);
		}
		
		private static function appendBuffer(data:ByteArray):void
		{
			if (!buffer)
			{
				buffer = new ByteArray();
				
				send("[DEBUGGER] LOADING", 0x666666);
			}	
			
			buffer.writeBytes(data);			
		}
		
		private static function loadBuffer():void
		{
			buffer.position = 0;
						
			loadBytes( buffer );
			
			buffer = null;						
		}
		
		//
		//	PUBLIC
		//
		
		private static function reset():void
		{
			removeCircle();
		}
		
		public static function loadBytes(data:ByteArray):void
		{			
			reset();
			
			sunag::onLoad(data);					
			
			send("[DEBUGGER] SEA3D LOADED - " + (data.length / 1024).toFixed(3) + 'kB', 0x666666);
		}
		
		//
		//	TOP LEVEL
		//
		
		public static function warn(...args):void
		{
			if (packCount > PACK_LIMIT) 
				return;	
			
			++packCount;
			
			send(args.join(' '), 0xFF8800);
		}
		
		public static function error(msg:String):void
		{
			lc.send(STUDIO, 'error', msg);
		}
		
		public static function print(message:String, color:int, bold:Boolean=false):void
		{
			if (packCount > PACK_LIMIT) 
				return;
						
			++packCount;
			
			send(message, color, bold);
		}
		
		//
		//	CIRCLE
		//
		
		public static function addCircle(message:String):void
		{
			circle ||= new ProgressCircle();
			circle.x = circle.y = 100;
			circle.progress = Infinity;
			
			if (!circle.stage)
			{				
				stage.addChild( circle );
				stage.addEventListener(Event.RESIZE, onCircleResize);											
			}
			
			circle.htmlText = message;
			
			onCircleResize();
		}
		
		public static function removeCircle():void
		{
			if (stage.contains( circle ))
			{
				stage.removeChild( circle );				
				stage.removeEventListener(Event.RESIZE, onCircleResize);
			}
		}
		
		private static function onCircleResize(e:Event=null):void
		{
			circle.x = int(stage.stageWidth / 2);
			circle.y = int(stage.stageHeight / 2);
		}
	}
}