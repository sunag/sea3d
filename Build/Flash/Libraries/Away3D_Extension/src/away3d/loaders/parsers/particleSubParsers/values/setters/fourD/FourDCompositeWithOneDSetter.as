package away3d.loaders.parsers.particleSubParsers.values.setters.fourD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	public class FourDCompositeWithOneDSetter extends SetterBase
	{
		private var _setterX:SetterBase;
		private var _setterY:SetterBase;
		private var _setterZ:SetterBase;
		private var _setterW:SetterBase;
		
		public function FourDCompositeWithOneDSetter(propName:String, setterX:SetterBase = null, setterY:SetterBase = null, setterZ:SetterBase = null, setterW:SetterBase = null)
		{
			super(propName);
			_setterX = setterX;
			_setterY = setterY;
			_setterZ = setterZ;
			_setterW = setterW;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var x:Number = _setterX ? _setterX.generateOneValue(index, total) : 0;
			var y:Number = _setterY ? _setterY.generateOneValue(index, total) : 0;
			var z:Number = _setterZ ? _setterZ.generateOneValue(index, total) : 0;
			var w:Number = _setterW ? _setterW.generateOneValue(index, total) : 0;
			return new Vector3D(x, y, z, w);
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			if (_setterX)
				_setterX.startPropsGenerating(prop);
			if (_setterY)
				_setterY.startPropsGenerating(prop);
			if (_setterZ)
				_setterZ.startPropsGenerating(prop);
			if (_setterW)
				_setterW.startPropsGenerating(prop);
		}
		
		override public function finishPropsGenerating(prop:ParticleProperties):void
		{
			if (_setterX)
				_setterX.finishPropsGenerating(prop);
			if (_setterY)
				_setterY.finishPropsGenerating(prop);
			if (_setterZ)
				_setterZ.finishPropsGenerating(prop);
			if (_setterW)
				_setterW.finishPropsGenerating(prop);
		}
	}
}
