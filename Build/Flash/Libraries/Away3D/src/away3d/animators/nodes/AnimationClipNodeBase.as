package away3d.animators.nodes
{
	import away3d.arcane;
	import away3d.animators.nodes.*;
	
	import flash.geom.*;
	
	use namespace arcane;
	
	/**
	 * Provides an abstract base class for nodes with time-based animation data in an animation blend tree.
	 */
	public class AnimationClipNodeBase extends AnimationNodeBase
	{
		arcane var _looping:Boolean = true;
		arcane var _totalDuration : Number = 0;
		arcane var _lastFrame : uint;
		arcane var _numFrames : uint = 0;
		arcane var _frameRate : uint = 30;
		
		/**
		 * Determines whether the contents of the animation node have looping characteristics enabled.
		 */
		public function get looping():Boolean
		{
			return _looping;
		}
		
		public function set looping(value:Boolean):void
		{
			if (_looping == value)
				return;
			
			_looping = value;
		}
		
		public function get frameRate():uint
		{	
			return _frameRate;
		}
		
		public function set frameRate(value:uint):void
		{
			if (_frameRate == value)
				return;
			
			_frameRate = value;
			
			updateTotaltime(_numFrames);
		}	
		
		protected function updateTotaltime(numFrames:uint):void
		{
			_numFrames = numFrames;
			_lastFrame = numFrames - 1;
			_totalDuration = (1000 / _frameRate) * _numFrames;
		}
		
		public function get totalDuration():uint
		{
			return _totalDuration;
		}
		
		public function get lastFrame():uint
		{
			return _lastFrame;
		}
		
		/**
		 * Creates a new <code>AnimationClipNodeBase</code> object.
		 */
		public function AnimationClipNodeBase()
		{
			super();
		}
	}
}
