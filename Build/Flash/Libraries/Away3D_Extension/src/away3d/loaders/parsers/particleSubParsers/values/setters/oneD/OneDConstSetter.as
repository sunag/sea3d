package away3d.loaders.parsers.particleSubParsers.values.setters.oneD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;

	
	public class OneDConstSetter extends SetterBase
	{
		private var _value:Number;
		
		public function OneDConstSetter(propName:String,value:Number)
		{
			super(propName);
			_value = value;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = _value;
		}
		
		override public function generateOneValue(index:int=0, total:int=1):*
		{
			return _value;
		}
		
	}

}