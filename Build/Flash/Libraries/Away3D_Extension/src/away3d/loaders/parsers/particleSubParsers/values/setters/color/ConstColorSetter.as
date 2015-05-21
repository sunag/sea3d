package away3d.loaders.parsers.particleSubParsers.values.setters.color
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.ColorTransform;
	
	public class ConstColorSetter extends SetterBase
	{
		private var _color:ColorTransform;
		
		public function ConstColorSetter(propName:String, color:ColorTransform)
		{
			super(propName);
			_color = color;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = _color;
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			return _color;
		}
	}
}
