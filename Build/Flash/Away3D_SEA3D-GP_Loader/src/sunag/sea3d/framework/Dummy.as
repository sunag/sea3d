package sunag.sea3d.framework
{
	import away3d.primitives.WireframeCube;
	import away3d.sea3d.animation.DummyAnimation;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEADummy;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class Dummy extends Object3D
	{
		sea3dgp var dummy:WireframeCube;
		
		public function Dummy()
		{
			super(dummy = new WireframeCube(100, 100, 100, 0x9AB9E5), DummyAnimation);
		}
		
		public function set width(val:Number):void
		{			
			dummy.width = val;
		}
		
		public function get width():Number
		{
			return dummy.width;
		}
		
		public function set height(val:Number):void
		{			
			dummy.height = val;
		}
		
		public function get height():Number
		{
			return dummy.height;
		}
		
		public function set depth(val:Number):void
		{			
			dummy.depth = val;
		}
		
		public function get depth():Number
		{
			return dummy.depth;
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	POINT LIGHT
			//
			
			var dmy:SEADummy = sea as SEADummy;
			
			dummy.transform = dmy.transform;
			
			dummy.width = dmy.width;
			dummy.height = dmy.height;
			dummy.depth = dmy.depth;					
		}
	}
}