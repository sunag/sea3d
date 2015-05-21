package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleScaleNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	
	import flash.geom.Vector3D;
	
	public class ParticleScaleNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _scaleValue:ValueSubParserBase;
		private var _usesCycle:Boolean;
		private var _usesPhase:Boolean;
		
		
		public function ParticleScaleNodeSubParser()
		{
			super();
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_usesCycle = _data.usesCycle;
				_usesPhase = _data.usesPhase;
				var object:Object = _data.scale;
				var Id:Object = object.id;
				var subData:Object = object.data;
				var valueCls:Class = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_FOURD_VALUES);
				if (!valueCls)
				{
					dieWithError("Unknown value");
				}
				_scaleValue = new valueCls(ParticleScaleNode.SCALE_VECTOR3D);
				addSubParser(_scaleValue);
				_scaleValue.parseAsync(subData);
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
			if (_scaleValue.valueType == ValueSubParserBase.CONST_VALUE)
			{
				var scale:Vector3D = _scaleValue.setter.generateOneValue();
				_particleAnimationNode = new ParticleScaleNode(ParticlePropertiesMode.GLOBAL, _usesCycle, _usesPhase, scale.x, scale.y, scale.z, scale.w);
			}
			else
			{
				_particleAnimationNode = new ParticleScaleNode(ParticlePropertiesMode.LOCAL_STATIC, _usesCycle, _usesPhase);
				_setters.push(_scaleValue.setter);
			}
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleScaleNodeSubParser;
		}
	
	}
}
