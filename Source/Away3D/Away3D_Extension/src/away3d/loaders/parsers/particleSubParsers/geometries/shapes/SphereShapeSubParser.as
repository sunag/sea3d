package away3d.loaders.parsers.particleSubParsers.geometries.shapes
{
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.primitives.SphereGeometry;
	
	use namespace arcane;
	
	public class SphereShapeSubParser extends ShapeSubParserBase
	{
		private var _geometry:SphereGeometry;
		
		public function SphereShapeSubParser()
		{
			_geometry = new SphereGeometry(10, 8, 8);
		}
		
		override public function getGeometry():Geometry
		{
			return _geometry;
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_geometry.radius = _data.radius;
				_geometry.segmentsW = _data.segmentsW;
				_geometry.segmentsH = _data.segmentsH;
			}
			return super.proceedParsing();
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.SphereShapeSubParser;
		}
	}

}
