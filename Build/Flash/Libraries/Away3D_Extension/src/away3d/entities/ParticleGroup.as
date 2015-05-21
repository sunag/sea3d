package away3d.entities
{
	import flash.geom.Vector3D;
	
	import away3d.animators.ParticleAnimator;
	import away3d.animators.ParticleGroupAnimator;
	import away3d.animators.data.ParticleGroupEventProperty;
	import away3d.animators.data.ParticleInstanceProperty;
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.bounds.BoundingSphere;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Object3D;
	
	
	public class ParticleGroup extends ObjectContainer3D
	{
		protected var _animator:ParticleGroupAnimator;
		protected var _particleMeshes:Vector.<Mesh>;
		protected var _instanceProperties:Vector.<ParticleInstanceProperty>;
		
		protected var _followParticleContainer:FollowParticleContainer;
		
		protected var _showBounds:Boolean;
		
		protected var _customParamters:Object;
		protected var _eventList:Vector.<ParticleGroupEventProperty>;
		
		public function ParticleGroup(particleMeshes:Vector.<Mesh>, instanceProperties:Vector.<ParticleInstanceProperty>, customParameters:Object = null, eventList:Vector.<ParticleGroupEventProperty> = null)
		{
			_followParticleContainer = new FollowParticleContainer();
			addChild(_followParticleContainer);
			
			if (customParameters)
			{
				//clone the customParameters
				//TODO: find a better way
				_customParamters = JSON.parse(JSON.stringify(customParameters));
			}
			else
			{
				_customParamters = {};
			}
			
			_particleMeshes = particleMeshes;
			_instanceProperties = instanceProperties;
			_eventList = eventList;
			
			_animator = new ParticleGroupAnimator(particleMeshes, instanceProperties, _eventList);
			
			for (var index:int; index < particleMeshes.length; index++)
			{
				var mesh:Mesh = particleMeshes[index];
				var instanceProperty:ParticleInstanceProperty = instanceProperties[index];
				if (instanceProperty)
					instanceProperty.apply(mesh);
				if (isFollowParticle(mesh))
				{
					_followParticleContainer.addFollowParticle(mesh);
				}
				else
				{
					addChild(mesh);
				}
			}
		}
		
		override public function get zOffset():int 
		{
			return super.zOffset;
		}
		
		override public function set zOffset(value:int):void 
		{
			super.zOffset = value;
			
			for (var i:int = 0; i < particleMeshes.length; i++)
			{
				particleMeshes[i].zOffset = value;
			}
		}
		
		public function get customParamters():Object
		{
			return _customParamters;
		}
		
		public function get particleMeshes():Vector.<Mesh>
		{
			return _particleMeshes;
		}
		
		public function get showBounds():Boolean
		{
			return _showBounds;
		}
		
		public function set showBounds(value:Boolean):void
		{
			_showBounds = value;
			for each (var mesh:Mesh in _particleMeshes)
			{
				mesh.showBounds = _showBounds;
			}
		}
		
		public function get animator():ParticleGroupAnimator
		{
			return _animator;
		}
		
		private function isFollowParticle(mesh:Mesh):Boolean
		{
			var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
			if (animator)
			{
				var followNode:ParticleFollowNode = animator.animationSet.getAnimation("ParticleFollowLocalDynamic") as ParticleFollowNode;
				if (followNode)
				{
					return true;
				}
			}
			return false;
		}
		
		override public function clone():Object3D
		{
			var len:uint = _particleMeshes.length;
			var newMeshes:Vector.<Mesh> = new Vector.<Mesh>(len, true);
			var i:int;
			for (i = 0; i < len; i++)
			{
				newMeshes[i] = _particleMeshes[i].clone() as Mesh;
				//TODO: the Away3D doesn't allow to disable the bounds' update, need to change it in next cycle
				var bounds:BoundingSphere = _particleMeshes[i].bounds as BoundingSphere;
				newMeshes[i].bounds = new BoundingSphere();
				newMeshes[i].bounds.fromSphere(new Vector3D, bounds.radius);
			}
			var clone:ParticleGroup = new ParticleGroup(newMeshes, _instanceProperties, customParamters, _eventList);
			clone.pivotPoint = pivotPoint;
			clone.transform = transform;
			clone.partition = partition;
			clone.name = name;
			clone.showBounds = showBounds;
			
			len = numChildren;
			for (i = 0; i < len; i++)
			{
				var child:ObjectContainer3D = getChildAt(i);
				if (_followParticleContainer != child && _particleMeshes.indexOf(child as Mesh) == -1)
				{
					clone.addChild(ObjectContainer3D(child.clone()));
				}
			}
			
			return clone;
		}
		
		override public function dispose():void
		{
			super.dispose();
			_animator.stop();
			for each (var mesh:Mesh in _particleMeshes)
			{
				mesh.dispose();
			}
		}
	
	}

}
