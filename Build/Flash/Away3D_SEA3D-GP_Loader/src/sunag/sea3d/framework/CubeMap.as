package sunag.sea3d.framework
{
	import away3d.textures.CubeTextureBase;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class CubeMap extends Asset
	{
		sea3dgp static const TYPE:String = 'CubeMap/';
				
		sea3dgp var scope:CubeTextureBase;
		sea3dgp var transparent:Boolean = false;
		
		function CubeMap(scope:CubeTextureBase=null)
		{
			super(TYPE);
			
			this.scope = scope;
		}
		
		override public function dispose():void
		{
			scope.dispose();
			
			super.dispose();			
		}
	}
}