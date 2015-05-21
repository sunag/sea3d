package away3d.materials
{
	import flash.display.BlendMode;
	
	import away3d.arcane;
	
	use namespace arcane;
	
	/**
	 * ColorMaterial is a single-pass material that uses a flat color as the surface's diffuse reflection value.
	 */
	public class ColorMaterial extends SinglePassMaterialBase implements IColorMaterial, ITranslucentMaterial
	{
		private var _diffuseAlpha:Number = 1;
		
		/**
		 * Creates a new ColorMaterial object.
		 * @param color The material's diffuse surface color.
		 * @param alpha The material's surface alpha.
		 */
		public function ColorMaterial(color:uint = 0xcccccc, alpha:Number = 1)
		{
			super();
			this.color = color;
			this.alpha = alpha;
		}
		
		/**
		 * The alpha of the surface.
		 */
		public function get alpha():Number
		{
			return _screenPass.diffuseMethod.diffuseAlpha;
		}
		
		public function set alpha(value:Number):void
		{
			if (value > 1)
				value = 1;
			else if (value < 0)
				value = 0;
			_screenPass.diffuseMethod.diffuseAlpha = _diffuseAlpha = value;
			_screenPass.preserveAlpha = false;//requiresBlending;
			_screenPass.setBlendMode(blendMode == BlendMode.NORMAL && requiresBlending? BlendMode.LAYER : blendMode);
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get requiresBlending():Boolean
		{
			return super.requiresBlending || _diffuseAlpha < 1;
		}
	}
}
