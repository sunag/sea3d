package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	
	use namespace arcane;
	
	/**
	 * LightMapMethod provides a method that allows applying a light map texture to the calculated pixel colour.
	 * It is different from LightMapDiffuseMethod in that the latter only modulates the diffuse shading value rather
	 * than the whole pixel colour.
	 */
	public class VertexColorMethod extends EffectMethodBase
	{
		/**
		 * Indicates the light map should be multiplied with the calculated shading result.
		 */
		public static const MULTIPLY:String = "multiply";
		
		/**
		 * Indicates the light map should be added into the calculated shading result.
		 */
		public static const ADD:String = "add";
		
		private var _blendMode:String;
		
		/**
		 * Creates a new LightMapMethod object.
		 * @param texture The texture containing the light map.
		 * @param blendMode The blend mode with which the light map should be applied to the lighting result.
		 * @param useSecondaryUV Indicates whether the secondary UV set should be used to map the light map.
		 */
		public function VertexColorMethod(blendMode:String = VertexColorMethod.MULTIPLY)
		{
			super();
			this.blendMode = blendMode;
		}
		
		/**
		 * @inheritDoc
		 */
		override arcane function initVO(vo:MethodVO):void
		{			
			vo.needsVertexColor = true;
		}
		
		/**
		 * The blend mode with which the light map should be applied to the lighting result.
		 *
		 * @see LightMapMethod.ADD
		 * @see LightMapMethod.MULTIPLY
		 */
		public function get blendMode():String
		{
			return _blendMode;
		}
		
		public function set blendMode(value:String):void
		{
			if (_blendMode == value)
				return;
			
			if (value != ADD && value != MULTIPLY)
				throw new Error("Unknown blendmode!");
			
			_blendMode = value;
			
			invalidateShaderProgram();
		}
		
		/**
		 * @inheritDoc
		 */
		arcane override function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			var code:String;
				
			switch (_blendMode) {
				case MULTIPLY:
					code = "mul " + targetReg + ".xyz, " + targetReg + ".xyz, " + _sharedRegisters.vertexColorVarying + ".xyz\n";
					break;
				case ADD:
					code = "add " + targetReg + ".xyz, " + targetReg + ".xyz, " + _sharedRegisters.vertexColorVarying + ".xyz\n";
					break;
			}
			
			return code;
		}
	}
}

