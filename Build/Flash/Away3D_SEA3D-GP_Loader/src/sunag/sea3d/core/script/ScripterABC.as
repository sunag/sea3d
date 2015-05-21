package sunag.sea3d.core.script
{
	import sunag.sea3dgp;
	import sunag.sea3d.core.IGameObject;
	import sunag.sea3d.core.assets.Script;

	use namespace sea3dgp;
	
	public class ScripterABC extends Scripter
	{
		sea3dgp var method:String;
		sea3dgp var params:Object;
		
		public function ScripterABC(script:Script, scope:IGameObject, method:String, params:Object=null)
		{
			super(script, scope);
			
			sea3dgp::method = method;
			sea3dgp::params = params;
		}				
		
		override public function clone(scope:IGameObject):Scripter
		{
			return new ScripterABC(script, scope, method, params);
		}
	}
}