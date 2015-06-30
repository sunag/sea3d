package sunag.sea3d.framework
{
	import flash.geom.Vector3D;
	
	import awayphysics.collision.shapes.AWPBoxShape;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEABox;
	import sunag.sea3d.objects.SEAObject;
	
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
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	BOX
			//
			
			var box:SEABox = sea as SEABox;				
			
			setDimensions(box.width, box.height, box.depth);
		}
		
		public function get width():Number
		{
			return box.localDimensions.x;
		}
		
		public function get height():Number
		{
			return box.localDimensions.y;
		}
		
		public function get depth():Number
		{
			return box.localDimensions.z;
		}
		
		public function setDimensions(width:Number, height:Number, depth:Number):void
		{
			scope = box = new AWPBoxShape(width, height, depth);
			scope.extra = this;
		}
	}
}