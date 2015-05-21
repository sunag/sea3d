package away3d.loaders.parsers.particleSubParsers.values.fourD
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.fourD.FourDCompositeWithOneDSetter;
	
	
	public class FourDCompositeWithOneDValueSubParser extends ValueSubParserBase
	{
		
		private var _valueX:ValueSubParserBase;
		private var _valueY:ValueSubParserBase;
		private var _valueZ:ValueSubParserBase;
		private var _valueW:ValueSubParserBase;
		
		public function FourDCompositeWithOneDValueSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				//for x
				var object:Object = _data.x;
				if (object)
				{
					var Id:Object = object.id;
					var subData:Object = object.data;
					
					var valueCls:Class;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_valueX = new valueCls(null);
					addSubParser(_valueX);
					_valueX.parseAsync(subData);
				}
				
				//for y
				object = _data.y;
				if (object)
				{
					Id = object.id;
					subData = object.data;
					
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_valueY = new valueCls(null);
					addSubParser(_valueY);
					_valueY.parseAsync(subData);
				}
				//for z
				object = _data.z;
				if (object)
				{
					Id = object.id;
					subData = object.data;
					
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_valueZ = new valueCls(null);
					addSubParser(_valueZ);
					_valueZ.parseAsync(subData);
				}
				
				//for w
				object = _data.w;
				if (object)
				{
					Id = object.id;
					subData = object.data;
					
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_valueW = new valueCls(null);
					addSubParser(_valueW);
					_valueW.parseAsync(subData);
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
			var setterX:SetterBase = _valueX ? _valueX.setter : null;
			var setterY:SetterBase = _valueY ? _valueY.setter : null;
			var setterZ:SetterBase = _valueZ ? _valueZ.setter : null;
			var setterW:SetterBase = _valueW ? _valueW.setter : null;
			if ((!_valueX || _valueX.valueType == CONST_VALUE) && (!_valueY || _valueY.valueType == CONST_VALUE) && (!_valueZ || _valueZ.valueType == CONST_VALUE) && (!_valueW || _valueW.valueType == CONST_VALUE))
				_valueType = CONST_VALUE;
			else
				_valueType = VARIABLE_VALUE;
			_setter = new FourDCompositeWithOneDSetter(_propName, setterX, setterY, setterZ, setterW);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.FourDCompositeWithOneDValueSubParser;
		}
	
	}

}
