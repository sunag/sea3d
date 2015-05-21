/*
*
* Copyright (c) 2013 Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

package away3d.tools
{
	import flash.geom.Matrix3D;
	
	import away3d.animators.data.JointPose;
	import away3d.animators.data.Skeleton;
	import away3d.animators.data.SkeletonJoint;
	import away3d.animators.data.SkeletonPose;
	import away3d.core.math.Quaternion;

	public class SkeletonTools
	{
		public static function poseFromSkeleton(skeletonPose:SkeletonPose, skeleton:Skeleton):void
		{			
			var jointPoses:Vector.<JointPose> = skeletonPose.jointPoses;
			
			jointPoses.length = skeleton.joints.length;
			
			for(var i:int=0;i<jointPoses.length;i++)
			{
				var pose:JointPose = jointPoses[i] ||= new JointPose();
				var joint:SkeletonJoint = skeleton.joints[i];
				
				var mtx:Matrix3D = new Matrix3D(joint.inverseBindPose).clone();					
				
				mtx.invert();
								
				pose.translation = mtx.position;
				
				pose.orientation ||= new Quaternion();
				pose.orientation.fromMatrix(mtx);
			}
		}
	}
}