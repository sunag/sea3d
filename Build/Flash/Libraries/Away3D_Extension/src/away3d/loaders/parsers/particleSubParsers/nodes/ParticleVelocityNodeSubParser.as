package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;

	public class ParticleVelocityNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _velocityValue:ValueSubParserBase;

		public function ParticleVelocityNodeSubParser()
		{
		}


		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				var object:Object = _data.velocity;
				var Id:Object = object.id;
				var subData:Object = object.data;

				var valueCls:Class = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_THREED_VALUES);
				if (!valueCls)
				{
					dieWithError("Unknown value");
				}
				_velocityValue = new valueCls(ParticleVelocityNode.VELOCITY_VECTOR3D);
				addSubParser(_velocityValue);
				_velocityValue.parseAsync(subData);
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
			if (_velocityValue.valueType == ValueSubParserBase.CONST_VALUE)
			{
				_particleAnimationNode = new ParticleVelocityNode(ParticlePropertiesMode.GLOBAL, _velocityValue.setter.generateOneValue());
			}
			else
			{
				_particleAnimationNode = new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC);
				_setters.push(_velocityValue.setter);
			}
		}

		public static function get identifier():*
		{
			return AllIdentifiers.ParticleVelocityNodeSubParser;
		}

	}

}
