package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleSpriteSheetNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	
	import flash.geom.Vector3D;
	
	public class ParticleSpriteSheetNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _durationValue:ValueSubParserBase;
		
		private var _numColumns:int;
		private var _numRows:int;
		private var _total:int;
		
		private var _usesCycle:Boolean;
		private var _usesPhase:Boolean;
		
		
		public function ParticleSpriteSheetNodeSubParser()
		{
			super();
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_numColumns = _data.numColumns;
				_numRows = _data.numRows;
				_total = _data.total;
				
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
				_durationValue = new valueCls(ParticleSpriteSheetNode.UV_VECTOR3D);
				addSubParser(_durationValue);
				_durationValue.parseAsync(subData);
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
			if (_total == 0)
				_total = int.MAX_VALUE;
			if (_durationValue.valueType == ValueSubParserBase.CONST_VALUE)
			{
				var value:Vector3D = _durationValue.setter.generateOneValue();
				_particleAnimationNode = new ParticleSpriteSheetNode(ParticlePropertiesMode.GLOBAL, _usesCycle, _usesPhase, _numColumns, _numRows, value.x, value.y, _total);
			}
			else
			{
				_particleAnimationNode = new ParticleSpriteSheetNode(ParticlePropertiesMode.LOCAL_STATIC, _usesCycle, _usesPhase, _numColumns, _numRows, 1, 0, _total);
				_setters.push(_durationValue.setter);
			}
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleSpriteSheetNodeSubParser;
		}
	}
}
