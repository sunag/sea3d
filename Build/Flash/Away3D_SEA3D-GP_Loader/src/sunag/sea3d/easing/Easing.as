package sunag.sea3d.easing
{
	import sunag.sea3dgp;

	//
	//	REFERENCE: http://www.libspark.org/wiki/BetweenAS3/en
	//
	
	use namespace sea3dgp;
	
	public class Easing
	{
		public static const Linear:String = 'linear';
		
		public static const CubicIn:String = 'cubicIn';
		public static const CubicOut:String = 'cubicOut';
		public static const CubicInOut:String = 'cubicInOut';
		public static const CubicOutIn:String = 'cubicOutIn';
		
		public static const ElasticIn:String = 'elasticIn';
		public static const ElasticOut:String = 'elasticOut';
		public static const ElasticInOut:String = 'elasticInOut';
		public static const ElasticOutIn:String = 'elasticOutIn';
		
		public static function linear(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * t / d + b
		}
		
		//==============================================================================
		// Cubic
		//==============================================================================
		
		sea3dgp static function cubicIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * (t /= d) * t * t + b;
		}
		
		sea3dgp static function cubicOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			return c * ((t = t / d - 1) * t * t + 1) + b;
		}
		
		sea3dgp static function cubicInOut(t:Number, b:Number, c:Number, d:Number):Number
		{
			if ((t /= d / 2) < 1) {
				return -c / 2 * (Math.sqrt(1 - t * t) - 1) + b;
			}
			return c / 2 * (Math.sqrt(1 - (t -= 2) * t) + 1) + b;
		}
		
		sea3dgp static function cubicOutIn(t:Number, b:Number, c:Number, d:Number):Number
		{
			return t < d / 2 ? c / 2 * ((t = t * 2 / d - 1) * t * t + 1) + b : c / 2 * (t = (t * 2 - d) / d) * t * t + b + c / 2;
		}
		
		//==============================================================================
		// Elastic
		//==============================================================================
		
		sea3dgp static function elasticOut(t:Number, b:Number, c:Number, d:Number, p:Number, a:Number):Number
		{
			if (t == 0) {
				return b;
			}
			if ((t /= d) == 1) {
				return b + c;
			}
			if (!p) {
				p = d * 0.3;
			}
			var s:Number;
			if (!a || a < Math.abs(c)) {
				a = c;
				s = p / 4;
			}
			else {
				s = p / (2 * Math.PI) * Math.asin(c / a);
			}
			return a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
		}
		
		sea3dgp static function elasticIn(t:Number, b:Number, c:Number, d:Number, p:Number, a:Number):Number
		{
			if (t == 0) {
				return b;
			}
			if ((t /= d) == 1) {
				return b + c;
			}
			if (!p) {
				p = d * 0.3;
			}
			var s:Number;
			if (!a || a < Math.abs(c)) {
				a = c;
				s = p / 4;
			}
			else {
				s = p / (2 * Math.PI) * Math.asin(c / a);
			}
			return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
		}
		
		sea3dgp static function elasticInOut(t:Number, b:Number, c:Number, d:Number, p:Number, a:Number):Number
		{
			if (t == 0) {
				return b;
			}
			if ((t /= d / 2) == 2) {
				return b + c;
			}
			if (!p) {
				p = d * (0.3 * 1.5);
			}
			var s:Number;
			if (!a || a < Math.abs(c)) {
				a = c;
				s = p / 4;
			}
			else {
				s = p / (2 * Math.PI) * Math.asin(c / a);
			}
			if (t < 1) {
				return -0.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + b;
			}
			return a * Math.pow(2, -10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p) * 0.5 + c + b;
		}
		
		sea3dgp static function elasticOutIn(t:Number, b:Number, c:Number, d:Number, p:Number, a:Number):Number
		{
			var s:Number;
			
			c /= 2;
			
			if (t < d / 2) {
				if ((t *= 2) == 0) {
					return b;
				}
				if ((t /= d) == 1) {
					return b + c;
				}
				if (!p) {
					p = d * 0.3;
				}
				if (!a || a < Math.abs(c)) {
					a = c;
					s = p / 4;
				}
				else {
					s = p / (2 * Math.PI) * Math.asin(c / a);
				}
				return a * Math.pow(2, -10 * t) * Math.sin((t * d - s) * (2 * Math.PI) / p) + c + b;
			}
			else {
				if ((t = t * 2 - d) == 0) {
					return (b + c);
				}
				if ((t /= d) == 1) {
					return (b + c) + c;
				}
				if (!p) {
					p = d * 0.3;
				}
				if (!a || a < Math.abs(c)) {
					a = c;
					s = p / 4;
				}
				else {
					s = p / (2 * Math.PI) * Math.asin(c / a);
				}
				return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin((t * d - s) * (2 * Math.PI) / p)) + (b + c);
			}
		}
	}
}