package sunag.sea3d.framework
{
	import away3d.animators.data.Skeleton;
	import away3d.animators.data.SkeletonJoint;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEASkeleton;

	use namespace sea3dgp;
	
	public class Skeleton extends Asset
	{
		sea3dgp static const TYPE:String = 'Skeleton/';
						
		sea3dgp var scope:away3d.animators.data.Skeleton;		
		
		public function Skeleton()
		{
			super(TYPE);						
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	SKELETON
			//
			
			var skl:SEASkeleton = sea as SEASkeleton;
			
			scope = new away3d.animators.data.Skeleton();
			
			var joints:Array = skl.joint;
			
			for(var i:int=0;i<joints.length;i++)
			{
				var jointData:Object = joints[i];	
				
				var sklJoint:SkeletonJoint = scope.joints[i] = new SkeletonJoint();
				sklJoint.name = jointData.name;
				sklJoint.parentIndex = jointData.parentIndex;
				sklJoint.inverseBindPose = jointData.inverseBindMatrix;
			}
		}
	}
}