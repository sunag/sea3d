package away3d.loaders.parsers.particleSubParsers.values.setters.threeD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	
	public class ThreeDConstSetter extends SetterBase
	{
		private var _value:Vector3D;
		
		public function ThreeDConstSetter(propName:String, value:Vector3D)
		{
			super(propName);
			_value = value;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = _value;
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			return _value;
		}
	
	}

}
