package sunag.sea3d.framework
{
	import away3d.lights.LightBase;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;

	use namespace sea3dgp;
	
	public class Light extends Object3D
	{
		sea3dgp var light:LightBase;
		sea3dgp var shd:Boolean = false;
		
		public function Light(scope:LightBase, animatorClass:Class=null)
		{
			super(light = scope, animatorClass);
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			if (_scene == scene) return;
			
			super.setScene( scene );
			
			updateLight();
		}
		
		override public function set visible(val:Boolean):void
		{			
			if (visible == val) return;
			super.visible = val;
			updateLight();
		}
		
		protected function updateLight():void
		{
			var lights:Array = SEA3DGP.lightPicker.lights;
			
			if ((scene && visible) && lights.indexOf(light) == -1)
			{
				lights.push( light );				
				SEA3DGP.lightPicker.lights = lights;
			}
			else if ((!scene || !visible) && lights.indexOf(light) != -1)
			{
				lights.splice( lights.indexOf(light), 1 );					
				SEA3DGP.lightPicker.lights = lights;
			}
			
			if (shd)
			{
				updateShadow();
			}
		}
		
		public function set shadow(val:Boolean):void
		{			
			shd = val;
		}
		
		public function get shadow():Boolean
		{
			return shd;
		}
		
		protected function updateShadow():void
		{			
		}
		
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var light:Light = asset as Light;
			
			shadow = light.shadow;
		}
	}
}