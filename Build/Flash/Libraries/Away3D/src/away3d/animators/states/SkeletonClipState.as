package away3d.animators.states
{
	import away3d.animators.*;
	import away3d.animators.data.*;
	import away3d.animators.nodes.*;
	
	import flash.geom.*;
	
	/**
	 *
	 */
	public class SkeletonClipState extends AnimationClipState implements ISkeletonAnimationState
	{
		private var _rootPos:Vector3D = new Vector3D();
		private var _frames:Vector.<SkeletonPose>;
		private var _skeletonClipNode:SkeletonClipNode;
		private var _skeletonPose:SkeletonPose = new SkeletonPose();
		private var _skeletonPoseDirty:Boolean = true;
		private var _currentPose:SkeletonPose;
		private var _nextPose:SkeletonPose;
		
		/**
		 * Returns the current skeleton pose frame of animation in the clip based on the internal playhead position.
		 */
		public function get currentPose():SkeletonPose
		{
			if (_framesDirty)
				updateFrames();
			
			return _currentPose;
		}
		
		/**
		 * Returns the next skeleton pose frame of animation in the clip based on the internal playhead position.
		 */
		public function get nextPose():SkeletonPose
		{
			if (_framesDirty)
				updateFrames();
			
			return _nextPose;
		}
		
		function SkeletonClipState(animator:IAnimator, skeletonClipNode:SkeletonClipNode)
		{
			super(animator, skeletonClipNode);
			
			_skeletonClipNode = skeletonClipNode;
			_frames = _skeletonClipNode.frames;
		}
		
		/**
		 * Returns the current skeleton pose of the animation in the clip based on the internal playhead position.
		 */
		public function getSkeletonPose(skeleton:Skeleton):SkeletonPose
		{
			if (_skeletonPoseDirty)
				updateSkeletonPose(skeleton);
			
			return _skeletonPose;
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateTime(time:int):void
		{
			_skeletonPoseDirty = true;
			
			super.updateTime(time);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function updateFrames():void
		{
			super.updateFrames();
			
			_currentPose = _frames[_currentFrame];
			
			if (_skeletonClipNode.looping && _nextFrame >= _skeletonClipNode.lastFrame) {
				_nextPose = _frames[0];
				SkeletonAnimator(_animator).dispatchCycleEvent();
			} else
				_nextPose = _frames[_nextFrame];
		}
		
		/**
		 * Updates the output skeleton pose of the node based on the internal playhead position.
		 *
		 * @param skeleton The skeleton used by the animator requesting the ouput pose.
		 */
		private function updateSkeletonPose(skeleton:Skeleton):void
		{
			_skeletonPoseDirty = false;
			
			if (!_skeletonClipNode.totalDuration)
				return;
			
			if (_framesDirty)
				updateFrames();
			
			var currentPose:Vector.<JointPose> = _currentPose.jointPoses;
			var nextPose:Vector.<JointPose> = _nextPose.jointPoses;
			var numJoints:uint = skeleton.numJoints;
			var p1:Vector3D, p2:Vector3D;
			var pose1:JointPose, pose2:JointPose;
			var endPoses:Vector.<JointPose> = _skeletonPose.jointPoses;
			var endPose:JointPose;
			var tr:Vector3D;
			
			// :s
			if (endPoses.length != numJoints)
				endPoses.length = numJoints;
			
			if ((numJoints != currentPose.length) || (numJoints != nextPose.length))
				throw new Error("joint counts don't match!");
			
			for (var i:uint = 0; i < numJoints; ++i) {
				endPose = endPoses[i] ||= new JointPose();
				pose1 = currentPose[i];
				pose2 = nextPose[i];
				p1 = pose1.translation;
				p2 = pose2.translation;
				
				if (_skeletonClipNode.highQuality)
					endPose.orientation.slerp(pose1.orientation, pose2.orientation, _blendWeight);
				else
					endPose.orientation.lerp(pose1.orientation, pose2.orientation, _blendWeight);
								
				tr = endPose.translation;
				tr.x = p1.x + _blendWeight*(p2.x - p1.x);
				tr.y = p1.y + _blendWeight*(p2.y - p1.y);
				tr.z = p1.z + _blendWeight*(p2.z - p1.z);				
			}
		}
	}
}
