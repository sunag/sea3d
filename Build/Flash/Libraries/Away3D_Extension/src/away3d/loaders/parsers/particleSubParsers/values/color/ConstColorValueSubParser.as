package away3d.loaders.parsers.particleSubParsers.values.color
{
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.color.ConstColorSetter;
	
	import flash.geom.ColorTransform;
	
	public class ConstColorValueSubParser extends ValueSubParserBase
	{
		public function ConstColorValueSubParser(propName:String)
		{
			super(propName, CONST_VALUE);
		}
		
		override public function parseAsync(data:*, frameLimit:Number = 30):void
		{
			super.parseAsync(data, frameLimit);
			_setter = new ConstColorSetter(_propName, extractColor(data));
		}
		
		private function extractColor(data:Object):ColorTransform
		{
			var color:ColorTransform = new ColorTransform();
			if (data.hasOwnProperty("mr"))
				color.redMultiplier = data.mr;
			if (data.hasOwnProperty("mg"))
				color.greenMultiplier = data.mg;
			if (data.hasOwnProperty("mb"))
				color.blueMultiplier = data.mb;
			if (data.hasOwnProperty("ma"))
				color.alphaMultiplier = data.ma;
			if (data.hasOwnProperty("or"))
				color.redOffset = data.or;
			if (data.hasOwnProperty("og"))
				color.greenOffset = data.og;
			if (data.hasOwnProperty("ob"))
				color.blueOffset = data.ob;
			if (data.hasOwnProperty("oa"))
				color.alphaOffset = data.oa;
			return color;
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ConstColorValueSubParser;
		}
	}
}
