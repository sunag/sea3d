package away3d.sea3d.animation
{
	import sunag.sunag;
	import sunag.animation.Animation;
	import sunag.animation.AnimationSet;
	
	use namespace sunag;
	
	public class HemisphereLightAnimation extends Animation
	{
		protected var _hemisphereLight:HemisphereLightAnimation;
		
		public function HemisphereLightAnimation(animationSet:AnimationSet, hemisphereLight:HemisphereLightAnimation, intrplFuncs:Object=null)
		{
			_hemisphereLight = hemisphereLight;
			super(animationSet, intrplFuncs);						
		}
		
		public function get hemisphereLight():HemisphereLightAnimation
		{
			return _hemisphereLight;
		}
	}
}