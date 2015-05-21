package sunag.sea3d.utils
{
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class ExternalInterface
	{
		sea3dgp static var methods:Object = {};
		
		sea3dgp static function addMethod(name:String, method:Function):void
		{
			methods[name] = method;
		}
		
		public static function contains(name:String):Boolean
		{
			return methods[name] != null;
		}
		
		public static function call(name:String, args:Array=null):*
		{
			return methods[name].apply(null, args);
		}
	}
}