package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	
	public class ParticleTimeNodeSubParser extends ParticleNodeSubParserBase
	{
		public var usesDuration:Boolean;
		public var usesLooping:Boolean;
		public var usesDelay:Boolean;
		private var _startTimeValue:ValueSubParserBase;
		private var _durationValue:ValueSubParserBase;
		private var _delayValue:ValueSubParserBase;
		
		public function ParticleTimeNodeSubParser()
		{
		}
		
		private function initSetters():void
		{
			_setters.push(_startTimeValue.setter);
			if (usesDuration)
				_setters.push(_durationValue.setter);
			if (usesDelay)
				_setters.push(_delayValue.setter);
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				usesLooping = _data.usesLooping;
				usesDuration = _data.usesDuration;
				usesDelay = _data.usesDelay;
				
				var object:Object = _data.startTime;
				var Id:Object = object.id;
				var subData:Object = object.data;
				
				var valueCls:Class;
				
				valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
				if (!valueCls)
				{
					dieWithError("Unknown value");
				}
				_startTimeValue = new valueCls("startTime");
				addSubParser(_startTimeValue);
				_startTimeValue.parseAsync(subData);
				
				
				if (usesDuration)
				{
					object = _data.duration;
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_durationValue = new valueCls("duration");
					addSubParser(_durationValue);
					_durationValue.parseAsync(subData);
				}
				
				
				if (usesDelay)
				{
					object = _data.delay;
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_delayValue = new valueCls("delay");
					addSubParser(_delayValue);
					_delayValue.parseAsync(subData);
				}
			}
			if (super.proceedParsing() == PARSING_DONE)
			{
				initSetters();
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleTimeNodeSubParser;
		}
	
	}

}
