package sunag.sea3d.loader
{
	import flash.utils.Dictionary;
	
	import away3d.textures.AsynBitmapTexture;

	public class TextureLoader
	{
		static private var DICT:Dictionary = new Dictionary(true);
		
		static public function get(key:*):AsynBitmapTexture
		{
			return DICT[key];
		}
		
		static public function create(key:*):AsynBitmapTexture
		{
			return DICT[key] = new AsynBitmapTexture(key);
		}
	}
}