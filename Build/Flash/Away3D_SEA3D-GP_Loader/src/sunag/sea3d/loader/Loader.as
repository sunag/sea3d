package sunag.sea3d.loader
{
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import sunag.sea3dgp;
	
	use namespace sea3dgp;
	
	public class Loader extends EventDispatcher
	{
		sea3dgp var des:String;
		sea3dgp var onLoad:Function;
		
		sea3dgp var _bytesLoaded:Number = 0;
		sea3dgp var _bytesTotal:Number = 0;
		
		sea3dgp var request:URLRequest;
		sea3dgp var data:ByteArray;
		
		public var tag:*;
		
		public function Loader(description:String, onLoad:Function)
		{
			sea3dgp::des = description;
			sea3dgp::onLoad = onLoad;
		}
		
		public function get streaming():Boolean
		{
			return _bytesLoaded < _bytesTotal;
		}
		
		public function get bytesLoaded():Number
		{
			return _bytesLoaded;
		}
		
		public function get bytesTotal():Number
		{
			return _bytesTotal;
		}
		
		public function set description(val:String):void
		{
			des = val;
		}
		
		public function get description():String
		{
			return des;
		}
						
		sea3dgp function dispatchProgress():void
		{
			dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS));
		}
		
		sea3dgp function dispatchComplete():void
		{
			dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE));
		}
		
		public function load(request:URLRequest):void
		{
			this.request = request;
		}
		
		public function loadBytes(data:ByteArray):void
		{
			this.data = data;
		}
	}
}