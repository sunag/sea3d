package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleAccelerationNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	
	public class ParticleAccelerationNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _acceleration:ValueSubParserBase;
		
		public function ParticleAccelerationNodeSubParser()
		{
		}
		
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				var object:Object = _data.acceleration;
				var Id:Object = object.id;
				var subData:Object = object.data;
				
				var valueCls:Class = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_THREED_VALUES);
				if (!valueCls)
				{
					dieWithError("Unknown value");
				}
				_acceleration = new valueCls(ParticleAccelerationNode.ACCELERATION_VECTOR3D);
				addSubParser(_acceleration);
				_acceleration.parseAsync(subData);
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
			if (_acceleration.valueType == ValueSubParserBase.CONST_VALUE)
			{
				_particleAnimationNode = new ParticleAccelerationNode(ParticlePropertiesMode.GLOBAL, _acceleration.setter.generateOneValue());
			}
			else
			{
				_particleAnimationNode = new ParticleAccelerationNode(ParticlePropertiesMode.LOCAL_STATIC);
				_setters.push(_acceleration.setter);
			}
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleAccelerationNodeSubParser;
		}
	
	}

}
