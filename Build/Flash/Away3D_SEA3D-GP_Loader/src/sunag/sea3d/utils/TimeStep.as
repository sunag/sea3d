package sunag.sea3d.utils
{
	import flash.display.Stage;
	import flash.utils.getTimer;
	
	import sunag.sea3dgp;	

	use namespace sea3dgp;
	
	public class TimeStep
	{	
		private static const FRAME_RATE:int = 60;
		
		private static var _time:Number = 0;
		private static var _oldTime:int = 0;
		private static var _step:int = 0;
		private static var _timeScale:Number = 1;
		private static var _deltaTime:Number = 0;
		private static var _delta:Number = 0;
				
		sea3dgp static function init(stage:Stage):void
		{
		}
		
		sea3dgp static function update():void
		{
			var t:int = getTimer();		
			
			_step = t - _oldTime;
			_deltaTime =  _step / 1000;			
			
			if (_deltaTime > .25) 
				_deltaTime = .25;			
			
			_delta = _deltaTime * FRAME_RATE;
		}
		
		sea3dgp static function updateTime():void
		{									
			_time += step * _timeScale;
			
			_oldTime = getTimer();	
		}
		
		/**
		 * Value of frame rate of the application for calculating the delta value.
		 * 
		 * @see #getDelta
		 * */
		public static function get fixedFrameRate():Number
		{
			return FRAME_RATE;
		}
		
		/**
		 * Return delta time.
		 * */
		public static function get delta():Number
		{
			update();			
			return _delta * _timeScale;
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
		 * Return actual frame rate
		 * */
		public static function get frameRate():Number
		{
			return 1000 / _step;
		}
		
		/**
		 * Calculates the coefficient of delta with the same <b>frame rate</b> of the application.
		 * 
		 * @param friction
		 * @see #getDelta
		 * */
		public static function deltaCoff(friction:Number):Number
		{
			return Math.pow(friction, delta);
		}
	}
}