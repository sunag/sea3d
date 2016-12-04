package sunag.sea3d.events
{	
	import flash.events.EventDispatcher;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class EventDispatcher
	{
		sea3dgp static const PROXY:Class = flash.events.EventDispatcher;
		
		sea3dgp var eDict:Object = {};
		
		public function addEventListener(type:String, listener:Function):void
		{
			if (!eDict[type]) eDict[type] = [];
			
			if (eDict[type].indexOf( listener) == -1)
			{				
				eDict[type].push( listener );
			}
		}
		
		public function removeEventListener(type:String, listener:Function):void
		{
			var list:Array = eDict[type];
			
			delete list.splice( list.indexOf( listener, 1 ) );
		}
		
		public function hasEvent(type:String):Boolean
		{
			return eDict[type];
		}
		
		public function dispatchEvent(e:Event):Boolean
		{
			e.preventDefault = false;
			e.target = this; 
			
			var list:Array = eDict[e.type];												
			
			if (list) 
			{							
				for each(var listener:Function in list.concat())
				{
					listener(e);
					
					if (e.preventDefault) return false;
				}				
			}
			
			return true;
		}
	}
}