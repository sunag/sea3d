package away3d.loaders.parsers.particleSubParsers.values.setters.fourD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	public class FourDCompositeWithThreeDSetter extends SetterBase
	{
		private var _setter3D:SetterBase;
		private var _setterW:SetterBase;
		
		public function FourDCompositeWithThreeDSetter(propName:String, setter3D:SetterBase, setterW:SetterBase)
		{
			super(propName);
			_setter3D = setter3D;
			_setterW = setterW;
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			_setter3D.startPropsGenerating(prop);
			_setterW.startPropsGenerating(prop);
		}
		
		override public function finishPropsGenerating(prop:ParticleProperties):void
		{
			_setter3D.finishPropsGenerating(prop);
			_setterW.finishPropsGenerating(prop);
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var vector3D:Vector3D = _setter3D.generateOneValue(index, total);
			vector3D.w = _setterW.generateOneValue(index, total);
			return vector3D;
		}
	}
}
