package sunag.sea3d.framework
{
	import away3d.primitives.CylinderGeometry;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEACylinderGeometry;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class CylinderGeometry extends GeometryBase
	{
		sea3dgp var cube:away3d.primitives.CylinderGeometry;
		
		public function CylinderGeometry(radiusTop:Number=50, radiusBottom:Number=50, height:Number=100)
		{
			super(cube = new away3d.primitives.CylinderGeometry(radiusTop, radiusBottom, height, 16, 1, true, true, true, true));
		}
		
		public function set radiusTop(val:Number):void
		{
			cube.topRadius = val;
		}
		
		public function get radiusTop():Number
		{
			return cube.topRadius;
		}
		
		public function set radiusBottom(val:Number):void
		{
			cube.bottomRadius = val;
		}
		
		public function get radiusBottom():Number
		{
			return cube.bottomRadius;
		}
		
		public function set height(val:Number):void
		{
			cube.height = val;
		}
		
		public function get height():Number
		{
			return cube.height;
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	GEOMETRY
			//
			
			var geo:SEACylinderGeometry = sea as SEACylinderGeometry;
			
			cube.topRadius = geo.radiusTop;
			cube.bottomRadius = geo.radiusBottom;
			cube.height = geo.height;
		}
	}
}