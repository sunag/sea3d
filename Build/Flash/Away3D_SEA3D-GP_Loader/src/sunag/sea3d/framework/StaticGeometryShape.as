package sunag.sea3d.framework
{
	import awayphysics.collision.shapes.AWPBvhTriangleMeshShape;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAStaticGeometryShape;
	
	use namespace sea3dgp;
	
	public class StaticGeometryShape extends Shape
	{
		sea3dgp var tri:AWPBvhTriangleMeshShape;
		sea3dgp var geo:Geometry;
		
		public function Box(geometry:Geometry=null)
		{
			this.geometry = geometry;
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	GEOMETRY SHAPE
			//
			
			var geoShape:SEAStaticGeometryShape = sea as SEAStaticGeometryShape;				
			
			geometry = geoShape.geometry.tag;
		}
		
		public function set geometry(val:Geometry):void
		{
			geo = val;
			
			if (geo)
			{
				scope = tri = new AWPBvhTriangleMeshShape(geo.scope, 0, true);
			}
		}
		
		public function get geometry():Geometry
		{
			return geo; 
		}
	}
}