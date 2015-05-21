package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.engine.SEA3DGPDebugger;
	
	[SWF(width="1024", height="632", backgroundColor="0x333333", frameRate="60")]
	public class SEA3DDebugger extends Sprite
	{
		public function SEA3DDebugger()
		{		
			addEventListener(Event.ADDED_TO_STAGE, onAdded);		
		}
		
		private function onAdded(e:Event):void
		{
			SEA3DGP.init(this);
			
			SEA3DGPDebugger.init(loaderInfo);
		}
	}
}