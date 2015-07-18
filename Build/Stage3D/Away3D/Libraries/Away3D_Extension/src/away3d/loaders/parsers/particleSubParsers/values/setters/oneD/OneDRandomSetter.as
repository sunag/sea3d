package away3d.loaders.parsers.particleSubParsers.values.setters.oneD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;

	
	public class OneDRandomSetter extends SetterBase
	{
		private var _min:Number;
		private var _max:Number;
		private var _delta:Number;
		
		public function OneDRandomSetter(propName:String,min:Number,max:Number)
		{
			super(propName);
			_min = min;
			_max = max;
			_delta = _max - _min;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = Math.random() * _delta + _min;
		}
		
		override public function generateOneValue(index:int=0, total:int=1):*
		{
			return Math.random() * _delta + _min;
		}
		
	}

}