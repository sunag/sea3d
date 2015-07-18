package sunag.sea3d.debug.utils
{
	import away3d.containers.ObjectContainer3D;
	import away3d.events.Object3DEvent;
	
	import sunag.sea3d.debug.IEventDebug;

	public class ConstraintTransform implements IEventDebug
	{
		public var target:ObjectContainer3D;
		public var source:ObjectContainer3D;
		
		public function ConstraintTransform(source:ObjectContainer3D, target:ObjectContainer3D)
		{
			this.target = target;
			this.source = source;
			
			source.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onTransform, false, 0, true);
			
			onTransform();
		}
		
		private function onTransform(e:Object3DEvent=null):void
		{
			target.transform = source.transform;
		}
		
		public function dispose():void
		{
			source.removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onTransform, false);
		}
	}
}