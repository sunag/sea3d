package away3d.loaders.parsers.particleSubParsers.values.fourD
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.fourD.FourDCompositeWithThreeDSetter;
	
	
	public class FourDCompositeWithThreeDValueSubParser extends ValueSubParserBase
	{
		
		private var _value3D:ValueSubParserBase;
		private var _valueW:ValueSubParserBase;
		
		public function FourDCompositeWithThreeDValueSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				//for 3d
				var object:Object = _data.x;
				if (object)
				{
					var Id:Object = object.id;
					var subData:Object = object.data;
					
					var valueCls:Class;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_THREED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_value3D = new valueCls(null);
					addSubParser(_value3D);
					_value3D.parseAsync(subData);
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
			var setter3D:SetterBase = _value3D.setter;
			var setterW:SetterBase = _valueW.setter;
			if (_value3D.valueType == CONST_VALUE && _valueW.valueType == CONST_VALUE)
				_valueType = CONST_VALUE;
			else
				_valueType = VARIABLE_VALUE;
			_setter = new FourDCompositeWithThreeDSetter(_propName, setter3D, setterW);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.FourDCompositeWithThreeDValueSubParser;
		}
	
	}
}
