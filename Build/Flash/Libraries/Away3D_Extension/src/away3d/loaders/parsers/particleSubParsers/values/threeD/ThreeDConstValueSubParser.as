package away3d.loaders.parsers.particleSubParsers.values.threeD
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.threeD.ThreeDConstSetter;
	
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 */
	public class ThreeDConstValueSubParser extends ValueSubParserBase
	{
		
		public function ThreeDConstValueSubParser(propName:String)
		{
			super(propName, CONST_VALUE);
		}
		
		override public function parseAsync(data:*, frameLimit:Number = 30):void
		{
			super.parseAsync(data, frameLimit);
			_setter = new ThreeDConstSetter(_propName, new Vector3D(_data.x, _data.y, _data.z));
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ThreeDConstValueSubParser;
		}
	
	}

}
