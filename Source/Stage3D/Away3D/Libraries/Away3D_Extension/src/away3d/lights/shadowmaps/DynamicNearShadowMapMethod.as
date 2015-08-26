package away3d.lights.shadowmaps
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.lights.DirectionalLight;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.lightpickers.DynamicLightPicker;
	import away3d.materials.methods.MethodVO;
	import away3d.materials.methods.NearShadowMapMethod;
	import away3d.materials.methods.SimpleShadowMapMethodBase;
	import away3d.materials.methods.SoftShadowMapMethod;
	
	use namespace arcane;
	
	public class DynamicNearShadowMapMethod extends NearShadowMapMethod implements IDynamicShadow
	{
		public static const instance : DynamicNearShadowMapMethod = new DynamicNearShadowMapMethod(DynamicLightPicker.directionalLightInstance);
		
		private var _enabled : Boolean = false;		
		private var _filter : SimpleShadowMapMethodBase;
		private var _mapper : NearDirectionalShadowMapper = new NearDirectionalShadowMapper();
		private var _light : DirectionalLight;
		
		public function DynamicNearShadowMapMethod(light:DirectionalLight)
		{
			_light = light;
			
			apply();
			
			super(_filter = new SoftShadowMapMethod(_light));
		}								
		
		public function get coverageRatio() : Number
		{
			return _mapper.coverageRatio;
		}
		
		public function set coverageRatio(value : Number) : void
		{
			_mapper.coverageRatio = value;
		}
		
		private function apply():void
		{						
			if ( !(_light.shadowMapper is NearDirectionalShadowMapper) )
			{
				_light.shadowMapper = _mapper;				
			}
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
		
		arcane override function setRenderState(vo : MethodVO, renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{
			if (_enabled) super.setRenderState(vo, renderable, stage3DProxy, camera);			
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