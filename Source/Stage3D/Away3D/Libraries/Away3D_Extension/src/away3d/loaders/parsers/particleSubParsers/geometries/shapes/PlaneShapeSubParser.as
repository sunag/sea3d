package away3d.loaders.parsers.particleSubParsers.geometries.shapes
{
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.primitives.PlaneGeometry;
	use namespace arcane;
	
	public class PlaneShapeSubParser extends ShapeSubParserBase
	{
		private var _geometry:PlaneGeometry;
		
		public function PlaneShapeSubParser()
		{
			_geometry = new PlaneGeometry(10, 10, 1, 1, false);
		}
		
		override public function getGeometry():Geometry
		{
			return _geometry;
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_geometry.width = _data.width;
				_geometry.height = _data.height;
			}
			return super.proceedParsing();
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.PlaneShapeSubParser;
		}
	}

}
