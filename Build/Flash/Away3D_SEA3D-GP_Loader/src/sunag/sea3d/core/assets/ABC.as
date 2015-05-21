package sunag.sea3d.core.assets
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import sunag.sea3dgp;
	import sunag.sea3d.core.script.Scripter;
	import sunag.sea3d.core.script.ScripterABC;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.engine.TopLevel;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class ABC extends Script
	{
		public static const RUN:uint = 0;
		public static const EVENT:uint = 1;
		public static const SINGLE_EVENT:uint = 2;
			
		sea3dgp var loader:Loader;		
		sea3dgp var script:Object;
		sea3dgp var waiting:Vector.<ScripterABC>;
		
		public function loadBytes(bytes:ByteArray):void
		{
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(flash.events.Event.COMPLETE, onLoaderComplete);
			loader.loadBytes(bytes, new LoaderContext(false, new ApplicationDomain()));				
		}
		
		protected function onLoaderComplete(e:flash.events.Event):void
		{
			script = Object(loader.content).GET_SCRIPTS(TopLevel)
			
			for each(var scripter:ScripterABC in waiting)
			{
				run( scripter );
			}
			
			waiting = null;
			
			dispatchEvent(new ScriptEvent(ScriptEvent.COMPLETE));
		}
				
		override public function run(scripter:Scripter):void
		{
			var abc:ScripterABC = scripter as ScripterABC;
			
			if (script)
			{
				script[abc.method](SEA3DGP.REFERENCE, SEA3DGP.GLOBAL, LOCAL, abc.scope, abc.params);				
			}
			else
			{
				waiting ||= new Vector.<ScripterABC>();
				waiting.push( abc );
			}
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	ABC
			//
			
			loadBytes(sea.data);
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (loader)
			{
				loader.contentLoaderInfo.removeEventListener(flash.events.Event.COMPLETE, onLoaderComplete);
				loader.unloadAndStop(false);
				loader = null;
			}		
		}
	}
}