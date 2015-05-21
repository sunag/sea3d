package sunag.sea3d.framework
{
	import away3d.textures.Texture2DBase;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEATexture;
	
	use namespace sea3dgp;
	
	public class Texture extends Asset
	{
		sea3dgp static const TYPE:String = 'Texture/';
		
		sea3dgp var scope:Texture2DBase;
		sea3dgp var transparent:Boolean = false;
		
		function Texture(scope:Texture2DBase=null)
		{
			super(TYPE);
			
			this.scope = scope;
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	TEXTURE
			//
			
			transparent = SEATexture(sea).transparent;
		}
		
		override public function dispose():void		
		{
			super.dispose();
			
			scope.dispose();
		}
	}
}