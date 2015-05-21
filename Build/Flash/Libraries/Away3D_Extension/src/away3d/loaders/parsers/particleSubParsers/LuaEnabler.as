package away3d.loaders.parsers.particleSubParsers
{
	import away3d.loaders.parsers.particleSubParsers.values.global.LuaGeneratorSubParser;
	import away3d.loaders.parsers.particleSubParsers.values.oneD.LuaExtractSubParser;
	
	public class LuaEnabler
	{
		private static var enable:Boolean = false;
		
		public static function enableLua():void
		{
			if (!enable)
			{
				AllSubParsers.ALL_GLOBAL_VALUES.push(LuaGeneratorSubParser);
				AllSubParsers.ALL_ONED_VALUES.push(LuaExtractSubParser);
				enable = true;
			}
		}
	}
}
