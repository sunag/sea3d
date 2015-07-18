package sunag.sea3d.loader
{
	import flash.utils.Dictionary;
	
	import away3d.textures.AsynBitmapCubeTexture;

	public class CubeMapLoader
	{
		static private var DICT:Dictionary = new Dictionary(true);
		
		static public function get(key:*):AsynBitmapCubeTexture
		{
			return DICT[key];
		}
		
		static public function create(key:*, negX:*, posX:*, negY:*, posY:*, negZ:*, posZ:*):AsynBitmapCubeTexture
		{
			return DICT[key] = new AsynBitmapCubeTexture(posX, negX, posY, negY, posZ, negZ);
		}
	}
}