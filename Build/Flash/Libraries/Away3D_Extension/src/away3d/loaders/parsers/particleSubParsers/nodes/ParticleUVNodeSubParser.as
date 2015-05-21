package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleUVNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	
	public class ParticleUVNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _cycleValue:ValueSubParserBase;
		private var _scaleValue:ValueSubParserBase;
		private var _axis:String;
		private var _formula:int;
		
		public function ParticleUVNodeSubParser()
		{
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				var object:Object = _data.cycle;
				var Id:Object = object.id;
				var subData:Object = object.data;
				var valueCls:Class = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
				if (!valueCls)
				{
					dieWithError("Unknown value");
				}
				_cycleValue = new valueCls(ParticleUVNode.UV_CYCLE);
				addSubParser(_cycleValue);
				_cycleValue.parseAsync(subData);
				
				object = _data.scale;
				if (object)
				{
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_ONED_VALUES);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_scaleValue = new valueCls(ParticleUVNode.UV_SCALE);
					addSubParser(_scaleValue);
					_scaleValue.parseAsync(subData);
				}
				_axis = _data.axis;
				_formula = _data.formula;
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
			if (_cycleValue.valueType == ValueSubParserBase.CONST_VALUE)
			{
				if (!_scaleValue)
					_particleAnimationNode = new ParticleUVNode(ParticlePropertiesMode.GLOBAL, _cycleValue.setter.generateOneValue(), 1, _axis, _formula);
				else if (_scaleValue.valueType == ValueSubParserBase.CONST_VALUE)
					_particleAnimationNode = new ParticleUVNode(ParticlePropertiesMode.GLOBAL, _cycleValue.setter.generateOneValue(), _scaleValue.setter.generateOneValue(), _axis, _formula);
				else
				{
					_particleAnimationNode = new ParticleUVNode(ParticlePropertiesMode.LOCAL_STATIC, _cycleValue.setter.generateOneValue(), 2, _axis, _formula);
					_setters.push(_cycleValue.setter);
					_setters.push(_scaleValue.setter);
				}
			}
			else
			{
				_setters.push(_cycleValue.setter);
				if (!_scaleValue)
					_particleAnimationNode = new ParticleUVNode(ParticlePropertiesMode.LOCAL_STATIC, _cycleValue.setter.generateOneValue(), 1, _axis, _formula);
				else if (_scaleValue.valueType == ValueSubParserBase.CONST_VALUE)
					_particleAnimationNode = new ParticleUVNode(ParticlePropertiesMode.LOCAL_STATIC, _cycleValue.setter.generateOneValue(), _scaleValue.setter.generateOneValue(), _axis, _formula);
				else
				{
					_particleAnimationNode = new ParticleUVNode(ParticlePropertiesMode.LOCAL_STATIC, _cycleValue.setter.generateOneValue(), 2, _axis, _formula);
					_setters.push(_scaleValue.setter);
				}
				
			}
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleUVNodeSubParser;
		}
	}
}
