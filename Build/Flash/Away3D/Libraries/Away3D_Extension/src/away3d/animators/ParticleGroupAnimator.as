package away3d.animators
{
	import away3d.animators.data.ParticleGroupEventProperty;
	import away3d.animators.data.ParticleInstanceProperty;
	import away3d.entities.Mesh;
	import away3d.events.ParticleGroupEvent;
	
	/**
	 * ...
	 * @author
	 */
	public class ParticleGroupAnimator extends AnimatorBase
	{
		private var animators:Vector.<ParticleAnimator> = new Vector.<ParticleAnimator>;
		private var animatorTimeOffset:Vector.<int>;
		private var numAnimator:int;
		private var eventList:Vector.<ParticleGroupEventProperty>;
		
		public function ParticleGroupAnimator(particleAnimationMeshes:Vector.<Mesh>, instanceProperties:Vector.<ParticleInstanceProperty>, eventList:Vector.<ParticleGroupEventProperty>)
		{
			super(null);
			numAnimator = particleAnimationMeshes.length;
			animatorTimeOffset = new Vector.<int>(particleAnimationMeshes.length, true);
			for (var index:int; index < numAnimator; index++)
			{
				var mesh:Mesh = particleAnimationMeshes[index];
				var animator:ParticleAnimator = mesh.animator as ParticleAnimator;
				animators.push(animator);
				animator.autoUpdate = false;
				if (instanceProperties[index])
					animatorTimeOffset[index] = instanceProperties[index].timeOffset * 1000;
			}
			
			this.eventList = eventList;
		}
		
		override public function start():void
		{
			super.start();
			_absoluteTime = 0;
			for (var index:int; index < numAnimator; index++)
			{
				var animator:ParticleAnimator = animators[index];
				//cause the animator.absoluteTime to be 0
				animator.update( -animator.absoluteTime / animator.playbackSpeed + animator.time);
				
				animator.resetTime(_absoluteTime + animatorTimeOffset[index]);
			}
		}
		
		override protected function updateDeltaTime(dt:Number):void
		{
			_absoluteTime += dt;
			for each (var animator:ParticleAnimator in animators)
			{
				animator.time = _absoluteTime;
			}
			if (eventList)
			{
				for each (var eventProperty:ParticleGroupEventProperty in eventList)
				{
					if (dt != 0 && (eventProperty.occurTime * 1000 - _absoluteTime) * (eventProperty.occurTime * 1000 - (_absoluteTime - dt)) <= 0)
					{
						if (hasEventListener(ParticleGroupEvent.OCCUR))
							dispatchEvent(new ParticleGroupEvent(ParticleGroupEvent.OCCUR, eventProperty));
					}
				}
			}
		}
		
		public function resetTime(offset:int = 0):void
		{
			for (var index:int; index < numAnimator; index++)
			{
				var animator:ParticleAnimator = animators[index];
				animator.resetTime(offset + animatorTimeOffset[index]);
			}
		}
	
	}

}
