package sunag.sea3d.core.assets
{
	import sunag.sea3dgp;
	import sunag.sea3d.core.script.Scripter;
	import sunag.sea3d.framework.Asset;
	import sunag.sea3d.framework.Scene3D;

	use namespace sea3dgp;
	
	public class Script extends Asset		
	{
		sea3dgp static const TYPE:String = 'Script/'; 
		
		sea3dgp var LOCAL:Object = {};
		
		public function Script()
		{
			super(TYPE);
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			if (_scene)
				_scene.scripts.splice( _scene.scripts.indexOf(this), 1 );
			
			super.setScene( scene );
			
			if (scene)
				scene.scripts.push( this );
		}
		
		public function get local():Object
		{
			return LOCAL;
		}
		
		public function run(scripter:Scripter):void
		{			
		}
	}
}