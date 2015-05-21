package away3d.entities
{
	import away3d.animators.ParticleAnimator;
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.animators.states.ParticleFollowState;
	import away3d.arcane;
	import away3d.bounds.BoundingSphere;
	import away3d.containers.ObjectContainer3D;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	use namespace arcane;
	
	public class FollowParticleContainer extends ObjectContainer3D
	{
		
		private var _identityTransform:Matrix3D = new Matrix3D;
		private var _followTarget:TargetObject3D;
		private var _updateBoundMeshes:Vector.<Mesh> = new Vector.<Mesh>;
		private var _updatePositionMeshes:Vector.<Mesh> = new Vector.<Mesh>;
		private var _tempCenter:Vector3D = new Vector3D;
		
		public function FollowParticleContainer()
		{
			_followTarget = new TargetObject3D(this);
			addChild(_followTarget);
		}
		
		
		public function addFollowParticle(mesh:Mesh):void
		{
			var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
			if (!animator)
				throw(new Error("not a particle mesh"));
			var followState:ParticleFollowState = animator.getAnimationStateByName("ParticleFollowLocalDynamic") as ParticleFollowState;
			if (!followState)
				throw(new Error("not a follow particle"));
			followState.followTarget = _followTarget;
			addChild(mesh);
			if ((animator.animationSet.getAnimation("ParticleFollowLocalDynamic") as ParticleFollowNode)._usesPosition)
			{
				_updateBoundMeshes.push(mesh);
			}
			else
			{
				_updatePositionMeshes.push(mesh);
			}
		}
		
		public function removeFollowParticle(mesh:Mesh):void
		{
			var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
			if (!animator)
				throw(new Error("not a particle mesh"));
			var followState:ParticleFollowState = animator.getAnimationStateByName("ParticleFollowLocalDynamic") as ParticleFollowState;
			if (!followState)
				throw(new Error("not a follow particle"));
			followState.followTarget = null;
			removeChild(mesh);
			var index:int = _updateBoundMeshes.indexOf(mesh);
			if (index != -1)
				_updateBoundMeshes.splice(index, 1);
			else
				_updatePositionMeshes.splice(_updatePositionMeshes.indexOf(mesh), 1);
		}
		
		public function get originalSceneTransform():Matrix3D
		{
			return super.sceneTransform;
		}
		
		override public function get sceneTransform():Matrix3D
		{
			if (_sceneTransformDirty)
			{
				var comps:Vector.<Vector3D> = super.sceneTransform.decompose();
				var rawData:Vector.<Number> = _identityTransform.rawData;
				rawData[0] = comps[2].x;
				rawData[5] = comps[2].y;
				rawData[10] = comps[2].z;
				_identityTransform.copyRawDataFrom(rawData);
			}
			if (_followTarget.sceneTransformDirty)
				updateBounds(_followTarget.position);
			return _identityTransform;
		}
		
		private function updateBounds(center:Vector3D):void
		{
			var mesh:Mesh;
			for each (mesh in _updateBoundMeshes)
			{
				_tempCenter.copyFrom(center);
				_tempCenter.x /= mesh.scaleX;
				_tempCenter.y /= mesh.scaleY;
				_tempCenter.z /= mesh.scaleZ;
				var bounds:BoundingSphere = mesh.bounds as BoundingSphere;
				bounds.fromSphere(_tempCenter, bounds.radius);
			}
			for each (mesh in _updatePositionMeshes)
			{
				mesh.position = _followTarget.specificPos;
			}
		
		}
	}
}
import away3d.containers.ObjectContainer3D;
import away3d.entities.FollowParticleContainer;

import flash.geom.Matrix3D;
import flash.geom.Vector3D;

class TargetObject3D extends ObjectContainer3D
{
	private var _container:FollowParticleContainer;
	private var _helpTransform:Matrix3D = new Matrix3D;
	
	public var specificPos:Vector3D = new Vector3D;
	private var specificEulers:Vector3D = new Vector3D;
	
	public function TargetObject3D(container:FollowParticleContainer)
	{
		_container = container;
	}
	
	public function get sceneTransformDirty():Boolean
	{
		return _sceneTransformDirty;
	}
	
	private function validateTransform():void
	{
		if (_sceneTransformDirty)
		{
			
			_helpTransform.copyFrom(_container.originalSceneTransform);
			var comps:Vector.<Vector3D> = _helpTransform.decompose();
			this.specificPos = comps[0];
			specificPos.x /= comps[2].x;
			specificPos.y /= comps[2].y;
			specificPos.z /= comps[2].z;
			//TODO: find a better way to implement it
			specificEulers.x = 0;
			specificEulers.y = 0;
			specificEulers.z = 0;
			var parent:ObjectContainer3D = _container;
			while (parent)
			{
				specificEulers.x += parent.rotationX;
				specificEulers.y += parent.rotationY;
				specificEulers.z += parent.rotationZ;
				parent = parent.parent;
			}
			_sceneTransformDirty = false;
		}
	}
	
	override public function get x():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificPos.x;
	}
	
	override public function get y():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificPos.y;
	}
	
	override public function get z():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificPos.z;
	}
	
	override public function get position():Vector3D
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificPos;
	}
	
	override public function get rotationX():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificEulers.x;
	}
	
	override public function get rotationY():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificEulers.y;
	}
	
	override public function get rotationZ():Number
	{
		if (_sceneTransformDirty)
			validateTransform();
		return specificEulers.z;
	}

}
