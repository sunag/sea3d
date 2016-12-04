package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.textures.Texture2DBase;
	
	use namespace arcane;
	
	public class DetailMapMethod extends EffectMethodBase
	{
		private var _texture : Texture2DBase;
		private var _scale:Number;
				
		public function DetailMapMethod(texture : Texture2DBase, scale:Number=10)
		{
			super();
			_texture = texture;
			_scale = scale;
		}
		
		override arcane function initVO(vo : MethodVO) : void
		{
			vo.needsUV = true;
		}
		
		public function set scale(val:Number):void
		{
			_scale = val;
		}
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set texture(value : Texture2DBase) : void
		{
			if (_texture && (value.hasMipMaps != _texture.hasMipMaps || value.format != _texture.format))
				invalidateShaderProgram();
			_texture = value;
		}
		
		public function get texture():Texture2DBase
		{
			return _texture;
		}
		
		arcane override function activate(vo : MethodVO, stage3DProxy : Stage3DProxy) : void
		{
			var data : Vector.<Number> = vo.fragmentData;
			var index : int = vo.fragmentConstantsIndex;
			
			data[index] = data[index+1] = _scale;
			
			stage3DProxy._context3D.setTextureAt(vo.texturesIndex, _texture.getTextureForStage3D(stage3DProxy));
		}
		
		arcane override function deactivate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			stage3DProxy._context3D.setTextureAt(vo.texturesIndex, null);
		}
		
		arcane override function getFragmentCode(vo : MethodVO, regCache : ShaderRegisterCache, targetReg : ShaderRegisterElement) : String
		{
			var code : String = "";
			var detailMapReg : ShaderRegisterElement = regCache.getFreeTextureReg();
			var temp : ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			vo.texturesIndex = detailMapReg.index;
			
			var scaleReg : ShaderRegisterElement = regCache.getFreeFragmentConstant();
						
			code += "mov " + temp + " , " + _sharedRegisters.uvVarying + "\n";
			
			code +=	"mul " + temp + ".x , " + temp + ".x , " + scaleReg + ".x\n" +
					"mul " + temp + ".y , " + temp + ".y , " + scaleReg + ".y\n";
			
			code += getTex2DSampleCode(vo, temp, detailMapReg, _texture, temp, "wrap");			
			
			code += "mul " + targetReg + ", " + targetReg + ", " + temp + "\n";
			
			vo.fragmentConstantsIndex = scaleReg.index*4;
			
			return code;
		}
	}
}
