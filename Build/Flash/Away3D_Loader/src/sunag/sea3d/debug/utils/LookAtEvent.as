package sunag.sea3d.debug.utils
{
	import away3d.containers.ObjectContainer3D;
	import away3d.entities.SegmentSet;
	import away3d.events.Object3DEvent;
	import away3d.primitives.LineSegment;
	
	import flash.geom.Vector3D;
	import sunag.sea3d.debug.IEventDebug;

	public class LookAtEvent implements IEventDebug
	{
		public var target:ObjectContainer3D;
		public var object3d:ObjectContainer3D;
		
		public var lookAtLine:SegmentSet;
		public var line:LineSegment;
		
		public function LookAtEvent(object3d:ObjectContainer3D, target:ObjectContainer3D, colorA:int, colorB:int)
		{
			this.target = target;
			this.object3d = object3d;
			
			target.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onUpdateLookAtLine, false, 0, true);
			object3d.addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onUpdateLookAtLine, false, 0, true);
			
			lookAtLine = new SegmentSet();		
			lookAtLine.addSegment(line = new LineSegment(new Vector3D(), new Vector3D(), colorA,  colorB, 1));
			
			onUpdateLookAtLine();
		}
		
		private function onUpdateLookAtLine(e:Object3DEvent=null):void
		{
			line.start = object3d.scenePosition;
			line.end = target.scenePosition;
		}
		
		public function dispose():void
		{
			target.removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onUpdateLookAtLine);
			object3d.removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, onUpdateLookAtLine);
		}
	}
}