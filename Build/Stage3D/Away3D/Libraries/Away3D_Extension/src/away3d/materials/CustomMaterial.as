package away3d.materials
{
	import away3d.materials.custom.ShaderData;
	import away3d.materials.pass.CustomMaterialPass;

	public class CustomMaterial extends MaterialBase
	{
		private var _pass:CustomMaterialPass
		
		public function CustomMaterial(shader:ShaderData)
		{
			addPass(_pass = new CustomMaterialPass(shader));			
		}
		
		public function get shader():ShaderData
		{
			return _pass.shader;
		}
	}
}