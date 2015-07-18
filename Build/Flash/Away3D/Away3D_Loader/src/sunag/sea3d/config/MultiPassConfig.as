package sunag.sea3d.config
{
	import away3d.materials.ITextureMaterial;
	import away3d.materials.TextureMultiPassMaterial;

	public class MultiPassConfig extends DefaultConfig
	{		
		override public function createMaterial():ITextureMaterial
		{
			return new TextureMultiPassMaterial();
		}
	}
}