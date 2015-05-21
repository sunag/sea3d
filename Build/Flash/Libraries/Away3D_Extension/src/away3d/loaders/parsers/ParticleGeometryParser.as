package away3d.loaders.parsers
{
	import away3d.core.base.ParticleGeometry;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.geometries.GeometrySubParserBase;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	
	import away3d.arcane;
	use namespace arcane;
	
	public class ParticleGeometryParser extends CompositeParserBase
	{
		
		private var _assembler:GeometrySubParserBase;
		
		public function ParticleGeometryParser()
		{
			super();
		}
		
		public static function supportsType(extension:String):Boolean
		{
			extension = extension.toLowerCase();
			return extension == "pag";
		}
		
		public static function supportsData(data:*):Boolean
		{
			return false;
		}
		
		public function get particleGeometry():ParticleGeometry
		{
			return _assembler.particleGeometry;
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				var assemblerData:Object = _data.assembler.data;
				var assemblerId:* = _data.assembler.id;
				var parserCls:Class = MatchingTool.getMatchedClass(assemblerId, AllSubParsers.ALL_GEOMETRIES);
				
				if (!parserCls)
				{
					dieWithError("Unknown geometry assembler");
				}
				
				_assembler = new parserCls();
				addSubParser(_assembler);
				_assembler.parseAsync(assemblerData);
			}
			
			return super.proceedParsing();
		}
	}

}
