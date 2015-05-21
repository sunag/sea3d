package away3d.lights.shadowmaps
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.lights.DirectionalLight;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.lightpickers.DynamicLightPicker;
	import away3d.materials.methods.CascadeShadowMapMethod;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.methods.SimpleShadowMapMethodBase;
	import away3d.materials.methods.SoftShadowMapMethod;
	
	use namespace arcane;
	
	public class DynamicCascadeShadowMapMethod extends CascadeShadowMapMethod implements IDynamicShadow
	{
		public static const instance : DynamicCascadeShadowMapMethod = new DynamicCascadeShadowMapMethod(DynamicLightPicker.directionalLightInstance);
				
		private var _enabled : Boolean = false;		
		private var _filter : SimpleShadowMapMethodBase;
		private var _mapper : CascadeShadowMapper = new CascadeShadowMapper(3);
		private var _light : DirectionalLight;
		
		public function DynamicCascadeShadowMapMethod(light:DirectionalLight)
		{
			_light = light;
			
			apply();
			
			super(_filter = new SoftShadowMapMethod(_light));
		}
		
		private function apply():void
		{						
			if ( !(_light.shadowMapper is CascadeShadowMapper) )
			{
				_light.shadowMapper = _mapper;	
			}
		}
		
		public function get mapper():CascadeShadowMapper
		{
			return _mapper;
		}

		override arcane function initVO(vo : MethodVO) : void
		{
			if (_enabled) 
				return super.initVO(vo);
		}
		
		override arcane function initConstants(vo : MethodVO) : void
		{
			if (_enabled) 
				return super.initConstants(vo);
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			if (_enabled) 
				return super.activate(vo, stage3DProxy);
		}
		
		arcane override function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			if (_enabled) return super.getFragmentCode(vo, regCache, targetReg);
			else return '';
		}
		
		arcane override function getVertexCode(vo : MethodVO, regCache : ShaderRegisterCache) : String
		{
			if (_enabled) return super.getVertexCode(vo, regCache);
			else return '';
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value) return;
			_enabled = value;
			if (value) apply();
			invalidateShaderProgram();
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
	}
}