package sunag.sea3d.framework
{
	import away3d.primitives.PlaneGeometry;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAPlaneGeometry;

	use namespace sea3dgp;
	
	public class PlaneGeometry extends GeometryBase
	{
		sea3dgp var plane:away3d.primitives.PlaneGeometry;
		
		public function PlaneGeometry(width:Number=100, height:Number=100)
		{
			super(plane = new away3d.primitives.PlaneGeometry(width, height));
		}
		
		public function set width(val:Number):void
		{
			plane.width = val;
		}
		
		public function get width():Number
		{
			return plane.width;
		}
		
		public function set height(val:Number):void
		{
			plane.height = val;
		}
		
		public function get height():Number
		{
			return plane.height;
		}
						
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	GEOMETRY
			//
			
			var geo:SEAPlaneGeometry = sea as SEAPlaneGeometry;
			
			plane.width = geo.width;
			plane.height = geo.height;
		}
	}
}