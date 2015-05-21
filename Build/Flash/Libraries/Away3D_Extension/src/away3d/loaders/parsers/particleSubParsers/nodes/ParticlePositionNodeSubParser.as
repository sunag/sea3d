package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	
	public class ParticlePositionNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _positionValue:ValueSubParserBase;
		
		public function ParticlePositionNodeSubParser()
		{
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				var object:Object = _data.position;
				var Id:Object = object.id;
				var subData:Object = object.data;
				
				var valueCls:Class = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_THREED_VALUES);
				if (!valueCls)
				{
					dieWithError("Unknown value");
				}
				_positionValue = new valueCls(ParticlePositionNode.POSITION_VECTOR3D);
				addSubParser(_positionValue);
				_positionValue.parseAsync(subData);
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
			if (_positionValue.valueType == ValueSubParserBase.CONST_VALUE)
			{
				_particleAnimationNode = new ParticlePositionNode(ParticlePropertiesMode.GLOBAL, _positionValue.setter.generateOneValue());
			}
			else
			{
				_particleAnimationNode = new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC);
				_setters.push(_positionValue.setter);
			}
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticlePositionNodeSubParser;
		}
	}
}
