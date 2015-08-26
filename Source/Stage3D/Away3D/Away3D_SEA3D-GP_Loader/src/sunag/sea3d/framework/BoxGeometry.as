package sunag.sea3d.framework
{
	import away3d.primitives.CubeGeometry;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEABoxGeometry;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class BoxGeometry extends GeometryBase
	{
		sea3dgp var cube:CubeGeometry;
		
		public function BoxGeometry(width:Number=100, height:Number=100, depth:Number=100)
		{
			super(cube = new CubeGeometry(width, height, depth, 1, 1, 1, false));
		}
		
		public function set width(val:Number):void
		{
			cube.width = val;
		}
		
		public function get width():Number
		{
			return cube.width;
		}
		
		public function set height(val:Number):void
		{
			cube.height = val;
		}
		
		public function get height():Number
		{
			return cube.height;
		}
		
		public function set depth(val:Number):void
		{
			cube.depth = val;
		}
		
		public function get depth():Number
		{
			return cube.depth;
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	GEOMETRY
			//
			
			var geo:SEABoxGeometry = sea as SEABoxGeometry;
			
			cube.width = geo.width;
			cube.height = geo.height;
			cube.depth = geo.height;
		}
	}
}