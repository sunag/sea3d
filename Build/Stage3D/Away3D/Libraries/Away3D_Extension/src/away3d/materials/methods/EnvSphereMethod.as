package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.MethodVO;
	import away3d.textures.Texture2DBase;
	
	use namespace arcane;
	
	public class EnvSphereMethod extends EffectMethodBase
	{
		private var _color:uint;
		private var _alpha:Number;
		private var _envMap:Texture2DBase;
		
		public function EnvSphereMethod(envMap:Texture2DBase, alpha:Number = 1)
		{
			_envMap = envMap;
			_alpha = alpha
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function initConstants(vo:MethodVO):void
		{			
			// const .5
			vo.fragmentData[vo.fragmentConstantsIndex + 1] = .5;
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function initVO(vo:MethodVO):void
		{
			vo.needsNormals = true;
			vo.needsView = true;
		}
		
		public function get alpha():Number
		{
			return _alpha;
		}
		
		public function set alpha(val:Number):void
		{
			_alpha = val;
		}
		
		/**
		 * The texture to use as the alpha mask.
		 */
		public function get envMap():Texture2DBase
		{
			return _envMap;
		}
		
		public function set envMap(value:Texture2DBase):void
		{
			_envMap = value;
		}
		
		/**
		 * @inheritDoc
		 */
		arcane override function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			var index:int = vo.fragmentConstantsIndex;
			var data:Vector.<Number> = vo.fragmentData;
			
			data[index] = _alpha;					
			
			stage3DProxy._context3D.setTextureAt(vo.texturesIndex, _envMap.getTextureForStage3D(stage3DProxy));
		}
		
		/**
		 * @inheritDoc
		 */
		arcane override function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			var textureReg:ShaderRegisterElement = regCache.getFreeTextureReg();
			
			var reg1:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			
			var temp:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();						
			var temp2:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();
			
			regCache.addFragmentTempUsages(temp, 1);
			regCache.addFragmentTempUsages(temp2, 1);
			
			var code:String = "";
			
			vo.fragmentConstantsIndex = reg1.index*4;
			vo.texturesIndex = textureReg.index;
						
			code += "dp3 " + temp + ".w, " + _sharedRegisters.viewDirFragment + ".xyz, " + _sharedRegisters.normalFragment + ".xyz		\n" +
				"add " + temp + ".w, " + temp + ".w, " + temp + ".w											\n" +
				"mul " + temp + ".xyz, " + _sharedRegisters.normalFragment + ".xyz, " + temp + ".w						\n" +
				"sub " + temp + ".xyz, " + temp + ".xyz, " + _sharedRegisters.viewDirFragment + ".xyz					\n" ;
			
			code += "mul " + temp + ".xy, " + temp + ".xy, " + reg1 + ".y \n";
			code += "add " + temp + ".xy, " + temp + ".xy, " + reg1 + ".y \n";
			
			code += getTex2DSampleCode(vo, temp, textureReg, _envMap, temp);
			
			code += "sub " + temp2 + ".w, " + temp + ".w, fc0.x									\n" +               	// -.5
				"kil " + temp2 + ".w\n" +	// used for real time reflection mapping - if alpha is not 1 (mock texture) kil output
				"sub " + temp + ", " + temp + ", " + targetReg + "											\n";
			
			code += "mul " + temp + ", " + temp + ", " + reg1 + ".x										\n" +
				"add " + targetReg + ".xyz, " + targetReg + ".xyz, " + temp + ".xyz										\n";
			
			regCache.removeFragmentTempUsage(temp);
			regCache.removeFragmentTempUsage(temp2);
			
			return code;
		}
	}
}
