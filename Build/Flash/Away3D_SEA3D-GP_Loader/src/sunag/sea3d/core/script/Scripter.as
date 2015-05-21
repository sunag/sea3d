package sunag.sea3d.core.script
{
	import sunag.sea3dgp;
	import sunag.sea3d.core.IGameObject;
	import sunag.sea3d.core.assets.Script;

	use namespace sea3dgp;
	
	public class Scripter
	{
		sea3dgp var scope:IGameObject;	
		sea3dgp var script:Script;
				
		public function Scripter(script:Script, scope:IGameObject)
		{
			sea3dgp::script = script;
			sea3dgp::scope = scope;
		}
		
		public function run():void
		{
			script.run( this );
		}
		
		public function clone(scope:IGameObject):Scripter
		{
			return new Scripter(script, scope);
		}
	}
}