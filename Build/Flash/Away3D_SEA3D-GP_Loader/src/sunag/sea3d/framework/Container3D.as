package sunag.sea3d.framework
{
	import away3d.containers.ObjectContainer3D;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAContainer3D;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class Container3D extends Object3D
	{
		public function Container3D()
		{
			super(new ObjectContainer3D(), Animation);
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	CONTAINER
			//
			
			var c3d:SEAContainer3D = sea as SEAContainer3D;
			
			scope.transform = c3d.transform;
		}
	}
}