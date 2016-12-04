package sunag.sea3d.engine
{
	import flash.display3D.Context3DProfile;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class Config
	{
		sea3dgp var autoPlay:Boolean; 		
		sea3dgp var antiAlias:int;
		sea3dgp var profile:String;
		sea3dgp var shaderPicker:Boolean;
		sea3dgp var cacheableScene:Boolean;
		sea3dgp var cacheableTexture:Boolean;
		sea3dgp var cacheableMaterial:Boolean;
		sea3dgp var skinGPU:Boolean;
		sea3dgp var morphGPU:Boolean;
		sea3dgp var drawPhysics:Boolean;	
		sea3dgp var showProgress:Boolean;
		sea3dgp var shadowFadeRatio:Number = .2;
		sea3dgp var shadowMaxSize:int = 2048;
		sea3dgp var near:Number = 1;
		sea3dgp var far:Number = 12000;
		sea3dgp var alphaThreshold:Number = .3;
		
		public function Config(autoPlay:Boolean=true, antiAlias:int=4, profile:String=Context3DProfile.BASELINE, shaderPicker:Boolean=false, cacheable:Boolean=false)
		{
			sea3dgp::autoPlay = autoPlay;
			sea3dgp::antiAlias = antiAlias;
			sea3dgp::profile = profile; 
			sea3dgp::shaderPicker = shaderPicker;			
			sea3dgp::cacheableScene = cacheable;
			sea3dgp::cacheableTexture = cacheable;
			sea3dgp::cacheableMaterial = cacheable;
			sea3dgp::drawPhysics = true;
			sea3dgp::showProgress = true;
			sea3dgp::skinGPU = true;
			sea3dgp::morphGPU = false;
		}
	}
}