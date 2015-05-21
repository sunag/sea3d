package away3d.loaders.parsers.particleSubParsers.values.matrix
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.matrix.Matrix2DUVCompositeSetter;
	
	public class Matrix2DUVCompositeValueSubParser extends ValueSubParserBase
	{
		private var _numColumns:int;
		private var _numRows:int;
		private var _selectedValue:ValueSubParserBase;
		
		public function Matrix2DUVCompositeValueSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_numColumns = _data.numColumns;
				_numRows = _data.numRows;
				
				var object:Object = _data.selectedValue;
				var Id:Object = object.id;
				var subData:Object = object.data;
				
				var valueCls:Class = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
				if (!valueCls)
				{
					dieWithError("Unknown value");
				}
				_selectedValue = new valueCls(null);
				addSubParser(_selectedValue);
				_selectedValue.parseAsync(subData);
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
			_setter = new Matrix2DUVCompositeSetter(_propName, _numColumns, _numRows, _selectedValue.setter);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.Matrix2DUVCompositeValueSubParser;
		}
	}
}
