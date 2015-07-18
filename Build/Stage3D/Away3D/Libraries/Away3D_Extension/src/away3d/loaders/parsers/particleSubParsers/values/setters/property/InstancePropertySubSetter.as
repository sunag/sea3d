package away3d.loaders.parsers.particleSubParsers.values.setters.property
{
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.data.ParticleInstanceProperty;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	public class InstancePropertySubSetter extends SetterBase
	{
		private var _positionSetter:SetterBase;
		private var _rotationSetter:SetterBase;
		private var _scaleSetter:SetterBase;
		private var _timeOffsetSetter:SetterBase;
		private var _playSpeedSetter:SetterBase;
		
		public function InstancePropertySubSetter(propName:String, positionSetter:SetterBase, rotationSetter:SetterBase, scaleSetter:SetterBase, timeOffsetSetter:SetterBase, playSpeedSetter:SetterBase)
		{
			super(propName);
			_positionSetter = positionSetter;
			_rotationSetter = rotationSetter;
			_scaleSetter = scaleSetter;
			_timeOffsetSetter = timeOffsetSetter;
			_playSpeedSetter = playSpeedSetter;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var position:Vector3D = _positionSetter ? _positionSetter.generateOneValue(index, total) : null;
			var rotation:Vector3D = _rotationSetter ? _rotationSetter.generateOneValue(index, total) : null;
			var scale:Vector3D = _scaleSetter ? _scaleSetter.generateOneValue(index, total) : null;
			var timeOffset:Number = _timeOffsetSetter ? _timeOffsetSetter.generateOneValue(index, total) : 0;
			var playSpeed:Number = _playSpeedSetter ? _playSpeedSetter.generateOneValue(index, total) : 1;
			return new ParticleInstanceProperty(position, rotation, scale, timeOffset, playSpeed);
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			if (_positionSetter)
				_positionSetter.startPropsGenerating(prop);
			if (_rotationSetter)
				_rotationSetter.startPropsGenerating(prop);
			if (_scaleSetter)
				_scaleSetter.startPropsGenerating(prop);
			if (_timeOffsetSetter)
				_timeOffsetSetter.startPropsGenerating(prop);
			if (_playSpeedSetter)
				_playSpeedSetter.startPropsGenerating(prop);
		}
		
		override public function finishPropsGenerating(prop:ParticleProperties):void
		{
			if (_positionSetter)
				_positionSetter.finishPropsGenerating(prop);
			if (_rotationSetter)
				_rotationSetter.finishPropsGenerating(prop);
			if (_scaleSetter)
				_scaleSetter.finishPropsGenerating(prop);
			if (_timeOffsetSetter)
				_timeOffsetSetter.finishPropsGenerating(prop);
			if (_playSpeedSetter)
				_playSpeedSetter.finishPropsGenerating(prop);
		}
	}
}
