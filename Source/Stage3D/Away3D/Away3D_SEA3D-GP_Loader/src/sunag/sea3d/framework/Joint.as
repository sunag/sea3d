package sunag.sea3d.framework
{
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.JointPose;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class Joint
	{
		sea3dgp var skl:SkeletonAnimator;
		sea3dgp var jnt:JointPose;
		sea3dgp var index:int;
		
		public var forceUpdate:Boolean = false;
		
		public function Joint(skeletonAnm:SkeletonAnimator, jointName:String)
		{
			skl = skeletonAnm;
			index = skl.skeleton.jointIndexFromName(jointName)
		}
		
		sea3dgp function get jointPose():JointPose
		{			
			if (forceUpdate) skl.invalidateSkeletonPose();
			return skl.updatePose().jointPoses[ index ];
		}
		
		public function update():void
		{
			skl.updateGlobalPose();
		}
	}
}