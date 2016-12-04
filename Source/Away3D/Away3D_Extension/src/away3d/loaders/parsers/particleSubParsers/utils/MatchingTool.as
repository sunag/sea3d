package away3d.loaders.parsers.particleSubParsers.utils
{
	
	public class MatchingTool
	{
		
		public static function getMatchedClass(identifier:*, classes:Array):Class
		{
			var result:Class;
			for each(var cls:Class in classes)
			{
				if (cls["identifier"] == identifier)
				{
					result = cls;
					break;
				}
			}
			return result;
		}
		
	}

}