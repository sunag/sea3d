package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	
	import awayphysics.collision.shapes.AWPBoxShape;
	
	import sunag.sea3dgp;
	
	use namespace sea3dgp;
	
	public class Box extends Shape
	{
		sea3dgp var box:AWPBoxShape;
		
		public function Box(width:Number=NaN, height:Number=NaN, depth:Number=NaN)
		{
			if (width > 0 && height > 0 && depth > 0)
			{
				setDimensions(width, height, depth);
			}
		}
		
		public function setDimensions(width:Number, height:Number, depth:Number):void
		{
			scope = box = new AWPBoxShape(width, height, depth);
			scope.extra = this;
		}
			
		public function get localDimensions():Vector3D
		{
			return box.dimensions;
		}
	}
}