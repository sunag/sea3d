package sunag.animation
{
	import sunag.sunag;

	use namespace sunag;
	
	public class AnimationGroup extends Animation
	{
		protected var _animationSetList:Vector.<AnimationSet>;
		protected var _animationSetIndex:uint = 0;
		
		public function AnimationGroup(animationSetList:Vector.<AnimationSet>, intrplFuncs:Object=null)
		{
			super(animationSetList[0], intrplFuncs);
			
			_animationSetList = animationSetList;
		}
		
		public function get animationSetList():Vector.<AnimationSet>
		{
			return _animationSetList;
		}
		
		override public function updateAnimation():void
		{			
			for ( _animationSetIndex = 0 ; _animationSetIndex < _animationSetList.length; _animationSetIndex++ )
			{								
				_animationSet = _animationSetList[ _animationSetIndex ];
				
				super.updateAnimation();
			}				
			
			_animationSet = _animationSetList[0];
		}
	}
}