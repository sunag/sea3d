package away3d.loaders.parsers.particleSubParsers.values.threeD
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.threeD.ThreeDSphereSetter;
	
	
	public class ThreeDSphereValueSubParser extends ValueSubParserBase
	{
		public function ThreeDSphereValueSubParser(propName:String)
		{
			super(propName, VARIABLE_VALUE);
		}
		
		override public function parseAsync(data:*, frameLimit:Number = 30):void
		{
			super.parseAsync(data, frameLimit);
			_setter = new ThreeDSphereSetter(_propName, _data.innerRadius, _data.outerRadius, _data.centerX, _data.centerY, _data.centerZ);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ThreeDSphereValueSubParser;
		}
	
	}

}
