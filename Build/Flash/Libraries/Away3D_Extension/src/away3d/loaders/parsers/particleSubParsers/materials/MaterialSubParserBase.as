package away3d.loaders.parsers.particleSubParsers.materials
{
	import away3d.arcane;
	import away3d.errors.AbstractMethodError;
	import away3d.loaders.parsers.CompositeParserBase;
	import away3d.materials.MaterialBase;
	
	import flash.display.BlendMode;
	
	use namespace arcane;
	
	public class MaterialSubParserBase extends CompositeParserBase
	{
		protected var _bothSide:Boolean;
		protected var _blendMode:String = BlendMode.NORMAL;
		
		public function MaterialSubParserBase()
		{
			super();
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_bothSide = _data.bothSide;
				if (_data.blendMode)
				{
					_blendMode = _data.blendMode;
				}
			}
			return super.proceedParsing();
		}
		
		public function get material():MaterialBase
		{
			throw(new AbstractMethodError());
		}
	}

}
