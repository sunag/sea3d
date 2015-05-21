package sunag.sea3d.engine
{
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import sunag.sea3dgp;
	import sunag.sea3d.framework.Scene3D;
	import sunag.sea3d.gui.ProgressCircle;

	use namespace sea3dgp;
	
	public class SEA3DGPDebugger
	{
		private static const VERSION:String = "1.1.0";
		private static const STUDIO:String = "SEA3D-STUDIO";
		
		private static const PACK_LIMIT:int = 3;
		
		private static var circle:ProgressCircle;
		private static var lc:LocalConnection = new LocalConnection();
		private static var sender:LocalConnection = new LocalConnection();
		private static var buffer:ByteArray;
		private static var loaderInfo:LoaderInfo;
		private static var packCount:int = 0;
		private static var game:Scene3D;
		
		public static function init(loaderInfo:LoaderInfo):void
		{
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onGlobalError);
				
			TopLevel.print = print;			
			TopLevel.watch = watch;
			TopLevel.warn = warn;
			
			SEA3DGPDebugger.loaderInfo = loaderInfo;
			
			SEA3DGPDebugger.addCircle('SEA3D-GP Debugger\n<font color="#999999">Waiting Studio</font>');						
			
			lc.allowDomain('*');
			lc.connect("SEA3D-DEBUGGER");
			lc.client = {
					init:onInit,
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
				
			error(msg);
			
			e.preventDefault();
		}
				
		private static function onInit(message:String):void
		{
			unload();
			
			SEA3DGPDebugger.addCircle("Waiting");
			
			trace(message);
			
			send(message, 0x666666, true);	
			
			if (!Capabilities.isDebugger) 	
			{
				send('[WARN] Flash Player is not a debugger', 0xFF8800);
			}
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
			game = new Scene3D();
			
			SEA3DGPDebugger.removeCircle();
		}
		
		public static function unload():void
		{
			if (game)
			{
				game.dispose();
				game = null;
			}
		}
		
		public static function load(url:URLRequest):void
		{
			reset();
			
			game.loadScene( url );
			
			send("[DEBUGGER] SEA3D LOADED - " + url.url, 0x666666);
		}
		
		public static function loadBytes(data:ByteArray):void
		{			
			reset();
			
			game.loadScene( data );
			
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
		
		public static function print(...args):void
		{
			if (packCount > PACK_LIMIT) 
				return;
						
			++packCount;
			
			send(args.join(' '));
		}
		
		public static function watch(name:String, value:*=null):void
		{
			if (packCount > PACK_LIMIT) 
				return;	
			
			++packCount;
			
			var output:Array;
			
			if (value)
			{		
				output = [];
				
				var description:XML = describeType(value);				
				
				for each (var prop:XML in description.variable)
				{
					var property:Object = {};
					property.name = String(prop.@name);
					property.type = String(prop.@type);
					property.access = String(prop.@access);					
					
					try
					{
						property.value = value[property.name];
					}
					catch (e : Error)
					{
						property.value = "";
					}
					
					output.push( property );
				}
				
				output.sortOn("name");
				
				output.value = String(value);
				output.type = getQualifiedClassName(value);
			}
			
			sender.send(STUDIO, 'watch', name, output);
		}
		
		//
		//	CIRCLE
		//
		
		public static function addCircle(message:String):void
		{
			if (!circle)
			{
				circle = new ProgressCircle();
				circle.x = circle.y = 100;
				circle.infinity = true;				
				
				SEA3DGP.stage.addChild( circle );
				
				SEA3DGP.stage.addEventListener(Event.RESIZE, onCircleResize);
				
				onCircleResize();
			}
			
			circle.htmlText = message;
		}
		
		public static function removeCircle():void
		{
			if (SEA3DGP.stage.contains( circle ))
			{
				SEA3DGP.stage.removeChild( circle );
			}
		}
		
		private static function onCircleResize(e:Event=null):void
		{
			circle.x = int(SEA3DGP.stage.stageWidth / 2);
			circle.y = int(SEA3DGP.stage.stageHeight / 2);
		}
	}
}