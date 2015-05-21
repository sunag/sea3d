package sunag.sea3d.framework
{
	import away3d.lights.LightBase;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;

	use namespace sea3dgp;
	
	public class Light extends Object3D
	{
		sea3dgp var light:LightBase;
		
		public function Light(scope:LightBase, animatorClass:Class=null)
		{
			super(light = scope, animatorClass);
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			if (_scene == scene) return;
			
			super.setScene( scene );
			
			var lights:Array = SEA3DGP.lightPicker.lights;
			
			if (scene)
			{
				lights.push( light );				
				SEA3DGP.lightPicker.lights = lights;
			}
			else
			{
				lights.splice( light, 1 );					
				SEA3DGP.lightPicker.lights = lights;
			}
		}
		
		public function set shadow(val:Boolean):void
		{			
			
		}
		
		public function get shadow():Boolean
		{
			return false;
		}
		
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var light:Light = asset as Light;
			
			shadow = light.shadow;
		}
	}
}