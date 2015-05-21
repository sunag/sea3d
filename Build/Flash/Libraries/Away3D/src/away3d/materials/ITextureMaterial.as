package away3d.materials
{
	import away3d.textures.Texture2DBase;

	public interface ITextureMaterial extends IPassMaterial
	{		
		 function get animateUVs() : Boolean
		 
		 function set animateUVs(value : Boolean) : void
		 
		 function get texture() : Texture2DBase
		 
		 function set texture(value : Texture2DBase) : void
		 
		 function get ambientTexture() : Texture2DBase
		 
		 function set ambientTexture(value : Texture2DBase) : void
	}
}