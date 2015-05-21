package sunag.sea3d.framework
{
	import awayphysics.collision.shapes.AWPCollisionShape;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class Shape extends Asset
	{
		sea3dgp static const TYPE:String = 'Shape/';				
		
		sea3dgp var scope:AWPCollisionShape;	
		
		public function Shape()
		{
			super(TYPE);	
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			scope.dispose();
		}
	}
}