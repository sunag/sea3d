package sunag.sea3d.events
{
	import sunag.sea3d.framework.Animation;

	public class AnimationEvent extends Event
	{
		public static const COMPLETE:String = "animationComplete";		
		
		public var animation:Animation;
		public var name:String;
		
		public function AnimationEvent(type:String, animation:Animation, name:String)
		{
			super(type);
			
			this.animation = animation;
			this.name = name;
		}
	}
}