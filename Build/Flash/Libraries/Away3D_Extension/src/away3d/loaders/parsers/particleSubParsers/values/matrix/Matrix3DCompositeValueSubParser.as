package away3d.loaders.parsers.particleSubParsers.values.matrix
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.matrix.Matrix3DCompositeSetter;
	
	
	public class Matrix3DCompositeValueSubParser extends ValueSubParserBase
	{
		private var _transforms:Vector.<ValueSubParserBase> = new Vector.<ValueSubParserBase>;
		
		public function Matrix3DCompositeValueSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				
				var object:Object;
				var Id:Object;
				var subData:Object;
				var valueCls:Class;
				var valueData:Object;
				
				var transformDatas:Array = _data.transforms;
				for each (var transformData:Object in transformDatas)
				{
					valueData = transformData.data;
					subData = valueData.data;
					Id = valueData.id;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_THREED_VALUES);
					
					if (!valueCls)
					{
						dieWithError("Unknown value parser");
					}
					//use name property as type
					var valueParser:ValueSubParserBase = new valueCls(transformData.type);
					addSubParser(valueParser);
					valueParser.parseAsync(subData);
					_transforms.push(valueParser);
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
			var transformSetters:Vector.<SetterBase> = new Vector.<SetterBase>();
			for (var i:int; i < _transforms.length; i++)
			{
				transformSetters.push(_transforms[i].setter);
			}
			_setter = new Matrix3DCompositeSetter(_propName, transformSetters);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.Matrix3DCompositeValueSubParser;
		}
	
	}

}
