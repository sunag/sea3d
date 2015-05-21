package away3d.animators.nodes
{
	import away3d.animators.states.*;
	import away3d.core.base.*;
	
	import flash.geom.*;
	
	/**
	 * A vertex animation node containing time-based animation data as individual geometry obejcts.
	 */
	public class VertexClipNode extends AnimationClipNodeBase
	{
		private var _frames:Vector.<Geometry> = new Vector.<Geometry>();
		private var _translations:Vector.<Vector3D> = new Vector.<Vector3D>();
		
		/**
		 * Returns a vector of geometry frames representing the vertex values of each animation frame in the clip.
		 */
		public function get frames():Vector.<Geometry>
		{
			return _frames;
		}
		
		/**
		 * Creates a new <code>VertexClipNode</code> object.
		 */
		public function VertexClipNode()
		{
			_stateClass = VertexClipState;
		}
		
		/**
		 * Adds a geometry object to the internal timeline of the animation node.
		 *
		 * @param geometry The geometry object to add to the timeline of the node.
		 * @param duration The specified duration of the frame in milliseconds.
		 * @param translation The absolute translation of the frame, used in root delta calculations for mesh movement.
		 */
		public function addFrame(geometry:Geometry):void
		{
			_frames.push(geometry);
			updateTotaltime(_frames.length);
		}
	}
}
