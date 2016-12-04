package away3d.loaders.parsers.particleSubParsers.values.setters.color
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.ColorTransform;
	
	public class CompositeColorSetter extends SetterBase
	{
		private var _redMultiplierSetter:SetterBase;
		private var _greenMultiplierSetter:SetterBase;
		private var _blueMultiplierSetter:SetterBase;
		private var _alphaMultiplierSetter:SetterBase;
		
		private var _redOffsetSetter:SetterBase;
		private var _greenOffsetSetter:SetterBase;
		private var _blueOffsetSetter:SetterBase;
		private var _alphaOffsetSetter:SetterBase;
		
		public function CompositeColorSetter(propName:String, redMultiplierSetter:SetterBase, greenMultiplierSetter:SetterBase, blueMultiplierSetter:SetterBase, alphaMultiplierSetter:SetterBase, redOffsetSetter:SetterBase, greenOffsetSetter:SetterBase, blueOffsetSetter:SetterBase, alphaOffsetSetter:SetterBase)
		{
			super(propName);
			_redMultiplierSetter = redMultiplierSetter;
			_greenMultiplierSetter = greenMultiplierSetter;
			_blueMultiplierSetter = blueMultiplierSetter;
			_alphaMultiplierSetter = alphaMultiplierSetter;
			
			_redOffsetSetter = redOffsetSetter;
			_greenOffsetSetter = greenOffsetSetter;
			_blueOffsetSetter = blueOffsetSetter;
			_alphaOffsetSetter = alphaOffsetSetter;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var rm:Number = _redMultiplierSetter ? _redMultiplierSetter.generateOneValue(index, total) : 0;
			var gm:Number = _greenMultiplierSetter ? _greenMultiplierSetter.generateOneValue(index, total) : 0;
			var bm:Number = _blueMultiplierSetter ? _blueMultiplierSetter.generateOneValue(index, total) : 0;
			var am:Number = _alphaMultiplierSetter ? _alphaMultiplierSetter.generateOneValue(index, total) : 0;
			
			var ro:Number = _redOffsetSetter ? _redOffsetSetter.generateOneValue(index, total) : 0;
			var go:Number = _greenOffsetSetter ? _greenOffsetSetter.generateOneValue(index, total) : 0;
			var bo:Number = _blueOffsetSetter ? _blueOffsetSetter.generateOneValue(index, total) : 0;
			var ao:Number = _alphaOffsetSetter ? _alphaOffsetSetter.generateOneValue(index, total) : 0;
			return new ColorTransform(rm, gm, bm, am, ro, go, bo, ao);
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			if (_redMultiplierSetter)
				_redMultiplierSetter.startPropsGenerating(prop);
			if (_greenMultiplierSetter)
				_greenMultiplierSetter.startPropsGenerating(prop);
			if (_blueMultiplierSetter)
				_blueMultiplierSetter.startPropsGenerating(prop);
			if (_alphaMultiplierSetter)
				_alphaMultiplierSetter.startPropsGenerating(prop);
			
			if (_redOffsetSetter)
				_redOffsetSetter.startPropsGenerating(prop);
			if (_greenOffsetSetter)
				_greenOffsetSetter.startPropsGenerating(prop);
			if (_blueOffsetSetter)
				_blueOffsetSetter.startPropsGenerating(prop);
			if (_alphaOffsetSetter)
				_alphaOffsetSetter.startPropsGenerating(prop);
		}
		
		override public function finishPropsGenerating(prop:ParticleProperties):void
		{
			if (_redMultiplierSetter)
				_redMultiplierSetter.finishPropsGenerating(prop);
			if (_greenMultiplierSetter)
				_greenMultiplierSetter.finishPropsGenerating(prop);
			if (_blueMultiplierSetter)
				_blueMultiplierSetter.finishPropsGenerating(prop);
			if (_alphaMultiplierSetter)
				_alphaMultiplierSetter.finishPropsGenerating(prop);
			
			if (_redOffsetSetter)
				_redOffsetSetter.finishPropsGenerating(prop);
			if (_greenOffsetSetter)
				_greenOffsetSetter.finishPropsGenerating(prop);
			if (_blueOffsetSetter)
				_blueOffsetSetter.finishPropsGenerating(prop);
			if (_alphaOffsetSetter)
				_alphaOffsetSetter.finishPropsGenerating(prop);
		}
	}
}
