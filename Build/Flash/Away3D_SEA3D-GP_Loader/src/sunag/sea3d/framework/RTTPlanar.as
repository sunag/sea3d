package sunag.sea3d.framework
{
	import away3d.textures.PlanarReflectionTextureTarget;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAPlanarRender;

	use namespace sea3dgp;
	
	public class RTTPlanar extends RTT
	{	
		sea3dgp var planar:PlanarReflectionTextureTarget;
		
		public function RTTPlanar()
		{
			rtt = planar = new PlanarReflectionTextureTarget();
		}
		
		override sea3dgp function setScene(scene:Scene3D):void
		{
			if (_scene)
			{
				SEA3DGP.rtt.splice(SEA3DGP.rtt.indexOf(planar), 1);
			}
			
			super.setScene(scene);
			
			if (_scene)
			{
				SEA3DGP.rtt.push(planar);
			}
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	REFERENCE
			//
			
			var planarRender:SEAPlanarRender = sea as SEAPlanarRender;
			
			planar.applyTransform(planarRender.transform);			
		}
	}
}