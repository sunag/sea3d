package sunag.sea3d.framework
{
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.data.JointPose;
	import away3d.animators.data.SkeletonPose;
	import away3d.animators.nodes.AnimationNodeBase;
	import away3d.animators.nodes.SkeletonClipNode;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEASkeletonAnimation;

	use namespace sea3dgp;
	
	public class SkeletonAnimation extends Animation
	{
		public static function getAsset(name:String):SkeletonAnimation
		{
			return Animation.getAsset(name) as SkeletonAnimation;
		}
		
		sea3dgp var clipNodes:Vector.<SkeletonClipNode>;
		sea3dgp var scope:SkeletonAnimationSet;		
		
		sea3dgp function creatAnimationSet(jointPerVertex:int=4):SkeletonAnimationSet
		{
			if (!scope)
			{
				scope = new SkeletonAnimationSet(jointPerVertex);
				
				for each(var node:SkeletonClipNode in clipNodes)
					scope.addAnimation(node);
			}
			
			return scope;
		}
		
		override public function get names():Array
		{
			var names:Array = [];
			
			for each(var anm:AnimationNodeBase in scope.animations)			
				names.push( anm.name );			
			
			return names;
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	SKELETON ANIMATION
			//
			
			var anm:SEASkeletonAnimation = sea as SEASkeletonAnimation;
			
			clipNodes = new Vector.<SkeletonClipNode>();
			
			for each(var seq:Object in anm.sequence)		
			{
				var clip:SkeletonClipNode = new SkeletonClipNode();
				
				clip.name = seq.name;
				clip.looping = seq.repeat;
				clip.frameRate = anm.frameRate;
				
				var start:int = seq.start;
				var end:int = start + seq.count;
				
				for (var i:int=start;i<end;i++)
				{
					var pose:Array = anm.pose[i];
					var len:uint = pose.length;
					
					var sklPose:SkeletonPose = new SkeletonPose();			
					sklPose.jointPoses.length = len;
					
					for (var j:int=0;j<len;j++)
					{				
						var jointPose:JointPose = sklPose.jointPoses[j] = new JointPose();
						var jointData:Object = pose[j];
						
						jointPose.translation.x = jointData.x;
						jointPose.translation.y = jointData.y;
						jointPose.translation.z = jointData.z;
						
						jointPose.orientation.x = jointData.qx;
						jointPose.orientation.y = jointData.qy;
						jointPose.orientation.z = jointData.qz;
						jointPose.orientation.w = jointData.qw;
					}
					
					clip.addFrame(sklPose);				
				}
				
				clipNodes[clipNodes.length] = clip;
			}
		}
	}
}