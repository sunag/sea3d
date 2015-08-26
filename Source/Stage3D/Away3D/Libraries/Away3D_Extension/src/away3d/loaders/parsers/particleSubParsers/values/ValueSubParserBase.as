package away3d.loaders.parsers.particleSubParsers.values
{
	import away3d.loaders.parsers.CompositeParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	public class ValueSubParserBase extends CompositeParserBase
	{
		public static const CONST_VALUE:int = 0;
		public static const VARIABLE_VALUE:int = 1;
		
		protected var _propName:String;
		
		protected var _valueType:int;
		
		protected var _setter:SetterBase;
		
		public function ValueSubParserBase(propName:String, type:int)
		{
			_propName = propName;
			_valueType = type;
			super();
		}
		
		public function get valueType():int
		{
			return _valueType;
		}
		
		public function get setter():SetterBase
		{
			return _setter;
		}
	}

}
