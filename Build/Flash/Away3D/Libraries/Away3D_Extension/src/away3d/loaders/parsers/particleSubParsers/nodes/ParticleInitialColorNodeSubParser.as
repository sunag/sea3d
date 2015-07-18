package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleInitialColorNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.color.CompositeColorValueSubParser;
	
	public class ParticleInitialColorNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _colorValue:CompositeColorValueSubParser;
		
		
		public function ParticleInitialColorNodeSubParser()
		{
			super();
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				
				var object:Object;
				var Id:Object;
				var subData:Object;
				
				object = _data.color;
				Id = object.id;
				subData = object.data;
				_colorValue = new CompositeColorValueSubParser(ParticleInitialColorNode.COLOR_INITIAL_COLORTRANSFORM);
				addSubParser(_colorValue);
				_colorValue.parseAsync(subData);
				
			}
			
			if (super.proceedParsing() == PARSING_DONE)
			{
				initProps();
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		}
		
		private function initProps():void
		{
			
			if (_colorValue.valueType == ValueSubParserBase.CONST_VALUE)
			{
				_particleAnimationNode = new ParticleInitialColorNode(ParticlePropertiesMode.GLOBAL, _colorValue.usesMultiplier, _colorValue.usesOffset, _colorValue.setter.generateOneValue());
			}
			else
			{
				_particleAnimationNode = new ParticleInitialColorNode(ParticlePropertiesMode.LOCAL_STATIC, _colorValue.usesMultiplier, _colorValue.usesOffset);
				_setters.push(_colorValue.setter);
			}
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleInitialColorNodeSubParser;
		}
	}
}
