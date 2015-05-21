package away3d.animators.states
{
	import flash.events.EventDispatcher;
	
	import away3d.animators.IAnimator;
	import away3d.animators.nodes.AnimationNodeBase;
	
	/**
	 *
	 */
	public class AnimationStateBase extends EventDispatcher implements IAnimationState
	{
		protected var _animationNode:AnimationNodeBase;
		
		protected var _time:int;
		protected var _startTime:int;
		protected var _animator:IAnimator;
		
		function AnimationStateBase(animator:IAnimator, animationNode:AnimationNodeBase)
		{
			_animator = animator;
			_animationNode = animationNode;
		}
		
		/**
		 * Resets the start time of the node to a  new value.
		 * 
		 * @param startTime The absolute start time (in milliseconds) of the node's starting time.
		 */
		public function offset(startTime:int):void
		{
			_startTime = startTime;
		}
		
		public function get startTime():int
		{
			return _startTime;
		}
		
		/**
		 * Updates the configuration of the node to its current state.
		 * 
		 * @param time The absolute time (in milliseconds) of the animator's play head position.
		 * 
		 * @see away3d.animators.AnimatorBase#update()
		 */		
		public function update(time:int):void
		{
			if (_time == time - _startTime)
				return;
			
			updateTime(time);
		}
		
		/**
		 * Sets the animation phase of the node.
		 * 
		 * @param value The phase value to use. 0 represents the beginning of an animation clip, 1 represents the end.
		 */
		public function phase(value:Number):void
		{
		}
		
		/**
		 * Updates the node's internal playhead position.
		 * 
		 * @param time The local time (in milliseconds) of the node's playhead position.
		 */
		protected function updateTime(time:int):void
		{
			_time = time - _startTime;
		}
		
		public function get time():int
		{
			return _time;
		}		
	}
}
