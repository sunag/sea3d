package away3d.animators
{
	import flash.display3D.Context3DProgramType;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.base.SkinnedSubGeometry;
	import away3d.core.base.SubMesh;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;
	
	use namespace arcane;
	
	/**
	 * Provides an interface for assigning skeleton-based animation data sets to mesh-based entity objects
	 * and controlling the various available states of animation through an interative playhead that can be
	 * automatically updated or manually triggered.
	 */
	public class SkeletonAnimatorProxy extends AnimatorBase implements IAnimator
	{
		arcane var _skeletonAnimator:SkeletonAnimator;
							
		public function get skeletonAnimator():SkeletonAnimator
		{
			return _skeletonAnimator;
		}			
		
		/**
		 * Creates a new <code>SkeletonAnimator</code> object.
		 *
		 * @param skeletonAnimationSet The animation data set containing the skeleton animations used by the animator.
		 * @param skeleton The skeleton object used for calculating the resulting global matrices for transforming skinned mesh data.
		 * @param forceCPU Optional value that only allows the animator to perform calculation on the CPU. Defaults to false.
		 */
		public function SkeletonAnimatorProxy(skeletonAnimator:SkeletonAnimator)
		{
			super((_skeletonAnimator = skeletonAnimator).animationSet);
			
			if (_skeletonAnimator._useCondensedIndices || _animationSet.usesCPU)
			{
				throwCPU();
			}
			
			autoUpdate = false;
		}
		
		/**
		 * @inheritDoc
		 */
		public function clone():IAnimator
		{
			return new SkeletonAnimatorProxy(_skeletonAnimator);
		}
						
		/**
		 * @inheritDoc
		 */
		public function setRenderState(stage3DProxy:Stage3DProxy, renderable:IRenderable, vertexConstantOffset:int, vertexStreamOffset:int, camera:Camera3D):void
		{			
			var skinnedGeom:SkinnedSubGeometry = SubMesh(renderable).subGeometry as SkinnedSubGeometry;
					
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, vertexConstantOffset, _skeletonAnimator.globalMatrices, _skeletonAnimator._numJoints*3);
			
			skinnedGeom.activateJointIndexBuffer(vertexStreamOffset, stage3DProxy);
			skinnedGeom.activateJointWeightsBuffer(vertexStreamOffset + 1, stage3DProxy);
		}
		
		/**
		 * @inheritDoc
		 */
		public function testGPUCompatibility(pass:MaterialPassBase):void
		{
			if (!_skeletonAnimator._useCondensedIndices && (_skeletonAnimator._forceCPU || _skeletonAnimator._jointsPerVertex > 4 || pass.numUsedVertexConstants + _skeletonAnimator._numJoints*3 > 128))
			{				
				//throwCPU();
			}
		}
		
		private function throwCPU():void
		{
			throw new Error("CPU mode not compatible.");
		}
	}
}
