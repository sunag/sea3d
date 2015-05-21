package away3d.animators.nodes
{
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.states.*;
	
	import flash.geom.*;
	
	/**
	 * A skeleton animation node containing time-based animation data as individual skeleton poses.
	 */
	public class SkeletonClipNode extends AnimationClipNodeBase
	{
		private var _frames:Vector.<SkeletonPose> = new Vector.<SkeletonPose>();
		
		/**
		 * Determines whether to use SLERP equations (true) or LERP equations (false) in the calculation
		 * of the output skeleton pose. Defaults to false.
		 */
		public var highQuality:Boolean = false;
		
		/**
		 * Returns a vector of skeleton poses representing the pose of each animation frame in the clip.
		 */
		public function get frames():Vector.<SkeletonPose>
		{
			return _frames;
		}
		
		/**
		 * Creates a new <code>SkeletonClipNode</code> object.
		 */
		public function SkeletonClipNode()
		{
			_stateClass = SkeletonClipState;
		}
		
		/**
		 * Adds a skeleton pose frame to the internal timeline of the animation node.
		 *
		 * @param skeletonPose The skeleton pose object to add to the timeline of the node.
		 * @param duration The specified duration of the frame in milliseconds.
		 */
		public function addFrame(skeletonPose:SkeletonPose):void
		{
			_frames.push(skeletonPose);
			updateTotaltime(_frames.length);
		}
		
		/**
		 * @inheritDoc
		 */
		public function getAnimationState(animator:IAnimator):SkeletonClipState
		{
			return animator.getAnimationState(this) as SkeletonClipState;
		}
	}
}
