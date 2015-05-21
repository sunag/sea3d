package sunag.sea3d.core.assets
{
	import sunag.sea3dgp;
	import sunag.sea3d.framework.Asset;
	import sunag.sea3d.framework.Scene3D;
	import sunag.sea3d.objects.SEAAction;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class Actions extends Asset
	{
		sea3dgp static const TYPE:String = 'Actions/'; 
		
		sea3dgp var action:Array = [];
		
		public function Actions()
		{
			super(TYPE);
		}
		
		sea3dgp function update():void
		{
			for each(var act:Object in action)
			{
				switch (act.kind)
				{					
					case SEAAction.LOOK_AT:
						//act.source.tag.controller = new LookAtController(act.target.tag);		
						break;
					
					case SEAAction.RTT_TARGET:				
						//act.source.tag.target = act.target.tag;						
						break;
					
					case SEAAction.FOG:
						scene.fog = true;
						scene.fogColor = act.color;
						scene.fogMin = act.min;
						scene.fogMax = act.max; 				
						break;
					
					case SEAAction.ENVIRONMENT:
						scene.environment = act.texture.tag;									
						break;
					
					case SEAAction.ENVIRONMENT_COLOR:
						scene.environmentColor = act.color;						
						break;
					
					case SEAAction.CAMERA:
						scene.camera = act.camera.tag;						
						break;
				}
			}
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			super.setScene( scene );
			
			if (scene) update();
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			action = SEAAction(sea).action;
		}
	}
}