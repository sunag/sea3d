package sunag.sea3d.framework
{
	import away3d.textures.ATFTexture;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class ATFTexture extends Texture
	{
		sea3dgp var tex:away3d.textures.ATFTexture;		
		
		public function ATFTexture()
		{					
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	TEXTURE FILE
			//
			
			this.scope = tex = new away3d.textures.ATFTexture( sea.data );
		}
	}
}