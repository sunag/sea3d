package away3d.loaders.parsers.particleSubParsers.values.threeD
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.threeD.ThreeDCompositeSetter;
	
	
	public class ThreeDCompositeValueSubParser extends ValueSubParserBase
	{
		
		private var _valueX:ValueSubParserBase;
		private var _valueY:ValueSubParserBase;
		private var _valueZ:ValueSubParserBase;
		private var _isometric:Boolean;
		
		public function ThreeDCompositeValueSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_isometric = _data.isometric;
				//for x
				var object:Object = _data.x;
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
				
				//for y
				object = _data.y;
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
				
				//for z
				object = _data.z;
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
			if (_valueX.valueType == CONST_VALUE && (_isometric || (_valueY.valueType == CONST_VALUE && _valueZ.valueType == CONST_VALUE)))
				_valueType = CONST_VALUE;
			_setter = new ThreeDCompositeSetter(_propName, _valueX.setter, _valueY.setter, _valueZ.setter, _isometric);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ThreeDCompositeValueSubParser;
		}
	
	}

}
