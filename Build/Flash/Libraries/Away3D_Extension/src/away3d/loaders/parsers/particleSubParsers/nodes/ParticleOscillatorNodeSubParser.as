package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleOscillatorNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.fourD.FourDCompositeWithThreeDValueSubParser;
	
	public class ParticleOscillatorNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _oscillatorValue:FourDCompositeWithThreeDValueSubParser;
		
		public function ParticleOscillatorNodeSubParser()
		{
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				var object:Object = _data.oscillator;
				var Id:Object = object.id;
				var subData:Object = object.data;
				_oscillatorValue = new FourDCompositeWithThreeDValueSubParser(ParticleOscillatorNode.OSCILLATOR_VECTOR3D);
				addSubParser(_oscillatorValue);
				_oscillatorValue.parseAsync(subData);
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
			if (_oscillatorValue.valueType == ValueSubParserBase.CONST_VALUE)
			{
				_particleAnimationNode = new ParticleOscillatorNode(ParticlePropertiesMode.GLOBAL, _oscillatorValue.setter.generateOneValue());
			}
			else
			{
				_particleAnimationNode = new ParticleOscillatorNode(ParticlePropertiesMode.LOCAL_STATIC);
				_setters.push(_oscillatorValue.setter);
			}
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleOscillatorNodeSubParser;
		}
	}
}
