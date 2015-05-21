package away3d.loaders.parsers.particleSubParsers.values.global
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.global.LuaGeneratorSetter;
	
	
	public class LuaGeneratorSubParser extends ValueSubParserBase
	{
		public function LuaGeneratorSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		override public function parseAsync(data:*, frameLimit:Number = 30):void
		{
			super.parseAsync(data, frameLimit);
			_setter = new LuaGeneratorSetter(_propName, _data.code);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.LuaGeneratorSubParser;
		}
	}
}
