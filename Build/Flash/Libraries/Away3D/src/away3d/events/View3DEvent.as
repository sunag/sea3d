package away3d.events
{
	import away3d.containers.View3D;
	
	import flash.events.Event;
	
	public class View3DEvent extends Event
	{
		public static const CHANGE_CAMERA : String = "changeCamera";
		public static const CHANGE_SCENE : String = "changeCamera";
		
		public var view3d : View3D;
		
		public function View3DEvent(type : String, view3d : View3D)
		{
			this.view3d = view3d;
			super(type);
		}
	}
}
