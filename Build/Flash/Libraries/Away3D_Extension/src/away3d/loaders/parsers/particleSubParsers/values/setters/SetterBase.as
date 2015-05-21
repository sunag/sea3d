package away3d.loaders.parsers.particleSubParsers.values.setters
{
	import away3d.animators.data.ParticleProperties;
	import away3d.errors.AbstractMethodError;
	
	public class SetterBase
	{
		protected var _propName:String;
		
		public function SetterBase(propName:String)
		{
			_propName = propName;
		}
		
		public function get propName():String
		{
			return _propName;
		}
		
		public function startPropsGenerating(prop:ParticleProperties):void
		{
		
		}
		
		public function setProps(prop:ParticleProperties):void
		{
			throw(new AbstractMethodError());
		}
		
		public function generateOneValue(index:int = 0, total:int = 1):*
		{
			throw(new AbstractMethodError());
		}
		
		public function finishPropsGenerating(prop:ParticleProperties):void
		{
		
		}
	
	}

}
