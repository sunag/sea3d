package away3d.loaders.parsers.particleSubParsers.values.color
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.color.CompositeColorSetter;
	
	public class CompositeColorValueSubParser extends ValueSubParserBase
	{
		private var _redMultiplierValue:ValueSubParserBase;
		private var _greenMultiplierValue:ValueSubParserBase;
		private var _blueMultiplierValue:ValueSubParserBase;
		private var _alphaMultiplierValue:ValueSubParserBase;
		
		private var _redOffsetValue:ValueSubParserBase;
		private var _greenOffsetValue:ValueSubParserBase;
		private var _blueOffsetValue:ValueSubParserBase;
		private var _alphaOffsetValue:ValueSubParserBase;
		
		public var usesMultiplier:Boolean;
		public var usesOffset:Boolean;
		
		public function CompositeColorValueSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				var Id:Object;
				var subData:Object
				var valueCls:Class;
				//for Multiplier
				var object:Object = _data.redMultiplierValue;
				if (object)
				{
					usesMultiplier = true;
					//red
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_redMultiplierValue = new valueCls(null);
					addSubParser(_redMultiplierValue);
					_redMultiplierValue.parseAsync(subData);
					
					//green
					object = _data.greenMultiplierValue;
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_greenMultiplierValue = new valueCls(null);
					addSubParser(_greenMultiplierValue);
					_greenMultiplierValue.parseAsync(subData);
					
					//blue
					object = _data.blueMultiplierValue;
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_blueMultiplierValue = new valueCls(null);
					addSubParser(_blueMultiplierValue);
					_blueMultiplierValue.parseAsync(subData);
					
					//alpha
					object = _data.alphaMultiplierValue;
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_alphaMultiplierValue = new valueCls(null);
					addSubParser(_alphaMultiplierValue);
					_alphaMultiplierValue.parseAsync(subData);
					
				}
				
				
				object = _data.redOffsetValue;
				if (object)
				{
					usesOffset = true;
					//red
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_redOffsetValue = new valueCls(null);
					addSubParser(_redOffsetValue);
					_redOffsetValue.parseAsync(subData);
					
					//green
					object = _data.greenOffsetValue;
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_greenOffsetValue = new valueCls(null);
					addSubParser(_greenOffsetValue);
					_greenOffsetValue.parseAsync(subData);
					
					//blue
					object = _data.blueOffsetValue;
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_blueOffsetValue = new valueCls(null);
					addSubParser(_blueOffsetValue);
					_blueOffsetValue.parseAsync(subData);
					
					//alpha
					object = _data.alphaOffsetValue;
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_alphaOffsetValue = new valueCls(null);
					addSubParser(_alphaOffsetValue);
					_alphaOffsetValue.parseAsync(subData);
					
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
			var _redMultiplierSetter:SetterBase;
			var _greenMultiplierSetter:SetterBase;
			var _blueMultiplierSetter:SetterBase;
			var _alphaMultiplierSetter:SetterBase;
			
			var _redOffsetSetter:SetterBase;
			var _greenOffsetSetter:SetterBase;
			var _blueOffsetSetter:SetterBase;
			var _alphaOffsetSetter:SetterBase;
			
			if (usesMultiplier)
			{
				_redMultiplierSetter = _redMultiplierValue.setter;
				_greenMultiplierSetter = _greenMultiplierValue.setter;
				_blueMultiplierSetter = _blueMultiplierValue.setter;
				_alphaMultiplierSetter = _alphaMultiplierValue.setter;
			}
			
			if (usesOffset)
			{
				_redOffsetSetter = _redOffsetValue.setter;
				_greenOffsetSetter = _greenOffsetValue.setter;
				_blueOffsetSetter = _blueOffsetValue.setter;
				_alphaOffsetSetter = _alphaOffsetValue.setter;
			}
			
			if ((!usesMultiplier || (_redMultiplierValue.valueType == CONST_VALUE && _greenMultiplierValue.valueType == CONST_VALUE && _blueMultiplierValue.valueType == CONST_VALUE && _alphaMultiplierValue.valueType == CONST_VALUE)) && (!usesOffset || (_redOffsetValue.valueType == CONST_VALUE && _greenOffsetValue.valueType == CONST_VALUE && _blueOffsetValue.valueType == CONST_VALUE && _alphaOffsetValue.valueType == CONST_VALUE)))
			{
				_valueType = CONST_VALUE;
			}
			else
				_valueType = VARIABLE_VALUE;
			_setter = new CompositeColorSetter(_propName, _redMultiplierSetter, _greenMultiplierSetter, _blueMultiplierSetter, _alphaMultiplierSetter, _redOffsetSetter, _greenOffsetSetter, _blueOffsetSetter, _alphaOffsetSetter);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.CompositeColorValueSubParser;
		}
	}
}
