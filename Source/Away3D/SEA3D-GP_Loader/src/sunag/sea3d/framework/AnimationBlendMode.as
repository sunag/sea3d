package sunag.sea3d.framework
{
	import sunag.sea3dgp;
	import sunag.animation.AnimationBlendMethod;

	use namespace sea3dgp;
	
	public class AnimationBlendMode
	{
		sea3dgp static const BLEND_MODE:Object = {
			0 : LINEAR,
			1 : EASING,
			LINEAR : AnimationBlendMethod.LINEAR,
			EASE : AnimationBlendMethod.EASING		
		}
		
		public static const LINEAR:String = 'linear';
		public static const EASING:String = 'easing';
	}
}