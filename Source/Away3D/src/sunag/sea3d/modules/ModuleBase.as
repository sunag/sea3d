package sunag.sea3d.modules
{
	import sunag.sea3d.SEA;
	import sunag.sunag;

	use namespace sunag;
	
	public class ModuleBase
	{	
		sunag var sea:SEA;
		sunag var TypeClass:Object = {};
		sunag var TypeRead:Object = {};
		
		sunag function init(sea:SEA):void
		{
			this.sea = sea;
		}
		
		sunag function reset():void
		{
			
		}
		
		public function dispose():void
		{
			
		}				
		
		protected function regClass(clazz:Class):void
		{
			TypeClass[clazz.TYPE] = clazz;
		}
		
		protected function regRead(type:String, func:Function):void
		{
			TypeRead[type] = func;
		}
	}
}