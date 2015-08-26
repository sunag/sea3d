package sunag.sea3d.modules
{
	import away3d.containers.View3D;
	import away3d.textures.Texture2DBase;
	
	import sunag.sunag;
	import sunag.sea3d.SEA3DDebug;
	import sunag.sea3d.objects.SEAAction;

	use namespace sunag;
	
	public class ActionModuleDebug extends ActionModule
	{
		protected var bg:Texture2DBase;
		
		public function ActionModuleDebug(view3d:View3D)
		{
			super(view3d);
			
			bg = view3d.background;
		}
		
		override protected function readAction(sea:SEAAction):void
		{
			super.readAction(sea);
			
			for each(var act:Object in sea.action)
			{
				switch (act.kind)
				{					
					case SEAAction.LOOK_AT:								
						(this.sea as SEA3DDebug).debug.creatLookAt(act.source.tag, act.target.tag);	
						break;
					
					case SEAAction.ENVIRONMENT_COLOR:								
						_view3d.background = null;
						break;
				}
			}						
		}
		
		override sunag function reset():void
		{
			super.reset();
			
			view3d.background = bg;
		}
	}
}