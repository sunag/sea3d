package away3d.loaders.parsers.particleSubParsers.values.property
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.oneD.OneDConstValueSubParser;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.property.InstancePropertySubSetter;
	import away3d.loaders.parsers.particleSubParsers.values.threeD.ThreeDConstValueSubParser;
	
	public class InstancePropertySubParser extends ValueSubParserBase
	{
		private var _positionValue:ThreeDConstValueSubParser;
		private var _rotationValue:ThreeDConstValueSubParser;
		private var _scaleValue:ThreeDConstValueSubParser;
		private var _timeOffsetValue:OneDConstValueSubParser;
		private var _playSpeedValue:OneDConstValueSubParser;
		
		public function InstancePropertySubParser(propName:String)
		{
			super(propName, CONST_VALUE);
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				if (_data.position)
				{
					_positionValue = new ThreeDConstValueSubParser(null);
					addSubParser(_positionValue);
					_positionValue.parseAsync(_data.position.data);
				}
				if (_data.rotation)
				{
					_rotationValue = new ThreeDConstValueSubParser(null);
					addSubParser(_rotationValue);
					_rotationValue.parseAsync(_data.rotation.data);
				}
				if (_data.scale)
				{
					_scaleValue = new ThreeDConstValueSubParser(null);
					addSubParser(_scaleValue);
					_scaleValue.parseAsync(_data.scale.data);
				}
				if (_data.timeOffset)
				{
					_timeOffsetValue = new OneDConstValueSubParser(null);
					addSubParser(_timeOffsetValue);
					_timeOffsetValue.parseAsync(_data.timeOffset.data);
				}
				if (_data.playSpeed)
				{
					_playSpeedValue = new OneDConstValueSubParser(null);
					addSubParser(_playSpeedValue);
					_playSpeedValue.parseAsync(_data.playSpeed.data);
				}
				
			}
			
			if (super.proceedParsing() == PARSING_DONE)
			{
				initSetter();
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		}
		
		private function initSetter():void
		{
			var positionSetter:SetterBase = _positionValue ? _positionValue.setter : null;
			var rotationSetter:SetterBase = _rotationValue ? _rotationValue.setter : null;
			var scaleSetter:SetterBase = _scaleValue ? _scaleValue.setter : null;
			var timeOffsetSetter:SetterBase = _timeOffsetValue ? _timeOffsetValue.setter : null;
			var playSpeedSetter:SetterBase = _playSpeedValue ? _playSpeedValue.setter : null;
			_setter = new InstancePropertySubSetter(_propName, positionSetter, rotationSetter, scaleSetter, timeOffsetSetter, playSpeedSetter);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.InstancePropertySubParser;
		}
	}
}
