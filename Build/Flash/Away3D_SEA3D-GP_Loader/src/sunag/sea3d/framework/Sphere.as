package sunag.sea3d.framework
{
	import awayphysics.collision.shapes.AWPSphereShape;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEASphere;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class Sphere extends Shape
	{
		sea3dgp var sph:AWPSphereShape;
		
		public function Sphere(radius:Number=NaN)
		{
			if (radius > 0)
			{
				setDimensions(radius);
			}
		}
		
		public function get radius():Number
		{
			return sph.radius;
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	SPHERE
			//
			
			var cap:SEASphere = sea as SEASphere;				
			
			setDimensions(cap.radius);
		}
		
		public function setDimensions(radius:Number):void
		{
			scope = sph = new AWPSphereShape(radius);
			scope.extra = this;
		}
	}
}