package away3d.loaders.parsers.particleSubParsers.materials
{
	import away3d.arcane;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.materials.ColorMaterial;
	import away3d.materials.MaterialBase;
	
	use namespace arcane;
	
	public class ColorMaterialSubParser extends MaterialSubParserBase
	{
		
		private var _colorMaterial:ColorMaterial = new ColorMaterial;
		
		
		public function ColorMaterialSubParser()
		{
		
		}
		
		override public function parseAsync(data:*, frameLimit:Number = 30):void
		{
			super.parseAsync(data, frameLimit);
		
		}
		
		override protected function proceedParsing():Boolean
		{
			
			if (super.proceedParsing() == PARSING_DONE)
			{
				_colorMaterial.color = _data.color;
				_colorMaterial.alpha = _data.alpha;
				_colorMaterial.bothSides = _bothSide;
				_colorMaterial.blendMode = _blendMode;
				_colorMaterial.alphaPremultiplied = false;
				return PARSING_DONE;
			}
			else
			{
				return MORE_TO_PARSE;
			}
		}
		
		
		
		override public function get material():MaterialBase
		{
			return _colorMaterial;
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ColorMaterialSubParser;
		}
	
	}

}
