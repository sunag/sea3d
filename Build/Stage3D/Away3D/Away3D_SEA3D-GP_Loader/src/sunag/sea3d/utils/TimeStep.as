package sunag.sea3d.utils
{
	import flash.display.Stage;
	import flash.utils.getTimer;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;

	use namespace sea3dgp;
	
	public class TimeStep
	{	
		sea3dgp static var FRAME_RATE:int = 60;
		sea3dgp static const FIXED_FRAME_RATE:int = 60;
		
		private static var _time:Number = 0;
		private static var _global:Number = 0;
		private static var _oldTime:int = 0;
		private static var _step:int = 0;
		private static var _timeScale:Number = 1;
		private static var _deltaTime:Number = 0;
		private static var _delta:Number = 0;
		private static var _stepFrame:int = 0;
				
		sea3dgp static function init(stage:Stage):void
		{
		}
		
		sea3dgp static function update():void
		{
			_step = getTimer() - _oldTime;
			
			_global += _step;
			
			if (SEA3DGP.playing)
			{												
				_deltaTime = _step / 1000;
				
				if (_deltaTime > .25) 
					_deltaTime = .25;
				
				_delta = _deltaTime * FRAME_RATE;
			}
		}
		
		sea3dgp static function updateTime():void
		{							
			var t:int = getTimer();
			
			if (SEA3DGP.playing)
			{
				_stepFrame = t - _oldTime;			
				_time += _stepFrame * _timeScale;
			}
			
			_oldTime = t;	
		}
		
		/**
		 * Value of frame rate of the application for calculating the delta value.
		 * 
		 * @see #delta
		 * */
		public static function get fixedFrameRate():Number
		{
			return FIXED_FRAME_RATE;
		}
		
		public static function get fixedDelta():Number
		{
			return (FIXED_FRAME_RATE / FRAME_RATE) * _timeScale;
		}
		
		public static function get fixedStep():Number
		{
			return 1000 / FRAME_RATE;
		}
		
		/**
		 * Time Scale
		 * */		
		public static function set timeScale(val:Number):void
		{
			_timeScale = isNaN(val) ? 1 : val;
		}
		
		public static function get timeScale():Number
		{
			return _timeScale;
		}
		
		/**
		 * Return delta.
		 * */
		public static function get delta():Number
		{
			update();			
			return _delta * _timeScale;
		}
		
		/**
		 * Return delta time.
		 * */
		public static function get deltaTime():Number
		{
			update();			
			return _deltaTime * _timeScale;
		}
		
		/**
		 * Return time in milliseconds of an update to another.
		 * */
		public static function get step():Number
		{
			update();
			return _step * _timeScale;
		}
		
		/**
		 * Return total time
		 * */
		public static function get time():Number
		{
			return _time;
		}
		
		/**
		 * Return global time
		 * */
		public static function set global(val:Number):void
		{
			_global = val;
		}		
		
		public static function get global():Number
		{
			return _global;
		}
		
		public static function get clock():Number
		{
			return getTimer();
		}
		
		/**
		 * Return current frame rate
		 * */
		public static function get frameRate():Number
		{			
			return 1000 / _stepFrame;
		}
		
		/**
		 * Calculates the coefficient of delta with the same <b>frame rate</b> of the application.
		 * 
		 * @param friction
		 * @see #delta
		 * */
		public static function deltaCoff(friction:Number):Number
		{
			return Math.pow(friction, delta);
		}
	}
}