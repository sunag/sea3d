package sunag.sea3d.framework
{
	import awayphysics.collision.shapes.AWPCapsuleShape;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEACapsule;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class Capsule extends Shape
	{
		sea3dgp var cap:AWPCapsuleShape;
		
		public function Capsule(radius:Number=NaN, height:Number=NaN)
		{
			if (radius > 0 && height > 0)
			{
				setDimensions(radius, height);
			}
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	CAPSULE
			//
			
			var cap:SEACapsule = sea as SEACapsule;				
			
			setDimensions(cap.radius, cap.height);
		}
		
		public function get radius():Number
		{
			return cap.radius;
		}
		
		public function get height():Number
		{
			return cap.height;
		}
		
		public function setDimensions(radius:Number, height:Number):void
		{
			scope = cap = new AWPCapsuleShape(radius, height);
			scope.extra = this;
		}
	}
}