package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleOrbitNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.threeD.ThreeDConstValueSubParser;
	
	import flash.geom.Vector3D;
	
	public class ParticleOrbitNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _orbitValue:ValueSubParserBase;
		private var _usesCycle:Boolean;
		private var _usesPhase:Boolean;
		private var _usesEulers:Boolean;
		private var _eulersValue:ThreeDConstValueSubParser;
		
		
		public function ParticleOrbitNodeSubParser()
		{
			super();
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_usesCycle = _data.usesCycle;
				_usesPhase = _data.usesPhase;
				var object:Object = _data.orbit;
				var Id:Object = object.id;
				var subData:Object = object.data;
				var valueCls:Class = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_FOURD_VALUES);
				if (!valueCls)
				{
					dieWithError("Unknown value");
				}
				_orbitValue = new valueCls(ParticleOrbitNode.ORBIT_VECTOR3D);
				addSubParser(_orbitValue);
				_orbitValue.parseAsync(subData);
				
				object = _data.eulers;
				if (object)
				{
					_usesEulers = true;
					Id = object.id;
					subData = object.data;
					_eulersValue = new ThreeDConstValueSubParser(null);
					addSubParser(_eulersValue);
					_eulersValue.parseAsync(subData);
				}
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
			var eulers:Vector3D = _usesEulers ? _eulersValue.setter.generateOneValue() : null;
			if (_orbitValue.valueType == ValueSubParserBase.CONST_VALUE)
			{
				var orbit:Vector3D = _orbitValue.setter.generateOneValue();
				_particleAnimationNode = new ParticleOrbitNode(ParticlePropertiesMode.GLOBAL, _usesEulers, _usesCycle, _usesPhase, orbit.x, orbit.y, orbit.z, eulers);
			}
			else
			{
				_particleAnimationNode = new ParticleOrbitNode(ParticlePropertiesMode.LOCAL_STATIC, _usesEulers, _usesCycle, _usesPhase, 100, 1, 0, eulers);
				_setters.push(_orbitValue.setter);
			}
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleOrbitNodeSubParser;
		}
	
	}
}
