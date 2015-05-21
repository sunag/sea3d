package away3d.lights.shadowmaps
{
	import away3d.arcane;
	import away3d.lights.DirectionalLight;

	use namespace arcane;
	
	public class DynamicShadowMapper extends ShadowMapperBase
	{
		arcane var _method : IDynamicShadow;
		
		public function DynamicShadowMapper(method:IDynamicShadow)
		{
			super();
			
			_method = method;
		}
		
		public function get method():IDynamicShadow
		{
			return _method;
		}
	}
}