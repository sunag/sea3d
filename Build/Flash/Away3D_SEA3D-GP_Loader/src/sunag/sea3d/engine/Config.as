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
		sea3dgp var cacheable:Boolean;
		sea3dgp var drawPhysics:Boolean;	
		sea3dgp var showProgress:Boolean;
		
		public function Config(autoPlay:Boolean=true, antiAlias:int=4, profile:String=Context3DProfile.BASELINE_EXTENDED, shaderPicker:Boolean=false, cacheable:Boolean=false)
		{
			sea3dgp::autoPlay = autoPlay;
			sea3dgp::antiAlias = antiAlias;
			sea3dgp::profile = profile; 
			sea3dgp::shaderPicker = shaderPicker;			
			sea3dgp::cacheable = cacheable;
			sea3dgp::drawPhysics = true;
			sea3dgp::showProgress = true;
		}
	}
}