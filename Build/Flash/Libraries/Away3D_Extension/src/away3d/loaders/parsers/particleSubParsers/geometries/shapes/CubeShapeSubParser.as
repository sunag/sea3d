package away3d.loaders.parsers.particleSubParsers.geometries.shapes
{
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.primitives.CubeGeometry;
	
	use namespace arcane;
	
	public class CubeShapeSubParser extends ShapeSubParserBase
	{
		private var _geometry:CubeGeometry;
		
		public function CubeShapeSubParser()
		{
			_geometry = new CubeGeometry(10, 10, 10);
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
				_geometry.depth = _data.depth;
			}
			return super.proceedParsing();
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.CubeShapeSubParser;
		}
	}

}
