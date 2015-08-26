package away3d.loaders.parsers.particleSubParsers.values.setters.threeD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	public class ThreeDCompositeSetter extends SetterBase
	{
		private var _setterX:SetterBase;
		private var _setterY:SetterBase;
		private var _setterZ:SetterBase;
		private var _isometric:Boolean;
		
		public function ThreeDCompositeSetter(propName:String, setterX:SetterBase, setterY:SetterBase, setterZ:SetterBase, isometric:Boolean = false)
		{
			super(propName);
			_setterX = setterX;
			_setterY = setterY;
			_setterZ = setterZ;
			_isometric = isometric;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var x:Number = _setterX.generateOneValue(index, total);
			var y:Number = _isometric ? x : _setterY.generateOneValue(index, total);
			var z:Number = _isometric ? x : _setterZ.generateOneValue(index, total);
			return new Vector3D(x, y, z);
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			if (_setterX)
				_setterX.startPropsGenerating(prop);
			if (_setterY)
				_setterY.startPropsGenerating(prop);
			if (_setterZ)
				_setterZ.startPropsGenerating(prop);
		}
		
		override public function finishPropsGenerating(prop:ParticleProperties):void
		{
			if (_setterX)
				_setterX.finishPropsGenerating(prop);
			if (_setterY)
				_setterY.finishPropsGenerating(prop);
			if (_setterZ)
				_setterZ.finishPropsGenerating(prop);
		}
	}

}
