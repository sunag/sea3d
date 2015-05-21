package away3d.events
{
	import away3d.animators.data.ParticleGroupEventProperty;
	
	import flash.events.Event;
	
	public class ParticleGroupEvent extends Event
	{
		public static const OCCUR:String = "occur";
		
		private var _eventProperty:ParticleGroupEventProperty;
		
		public function ParticleGroupEvent(type:String, eventProperty:ParticleGroupEventProperty, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_eventProperty = eventProperty;
		}
		
		public function get eventProperty():ParticleGroupEventProperty
		{
			return _eventProperty;
		}
	
	}
}
