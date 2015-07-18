package away3d.events
{
	import flash.events.Event;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	
	public class Scene3DEvent extends Event
	{
		public static const ADDED_TO_SCENE:String = "addedToScene";
		public static const REMOVED_FROM_SCENE:String = "removedFromScene";
		public static const PARTITION_CHANGED:String = "partitionChanged";
		public static const ADDED_TO_VIEW3D : String = "addedToView3D";
		public static const REMOVED_FROM_VIEW3D : String = "removedFromView3D";
		public static const CHANGE_VIEW3D:String = "changeView3D";
		
		public var objectContainer3D:ObjectContainer3D;
		public var view3D : View3D;
		
		override public function get target():Object
		{
			return objectContainer3D;
		}
		
		public function Scene3DEvent(type:String, objectContainer:ObjectContainer3D = null, view : View3D = null)
		{
			objectContainer3D = objectContainer;
			view3D = view;
			super(type);
		}
		
		public override function clone():Event
		{
			return new Scene3DEvent(type, objectContainer3D);
		}
	}
}
