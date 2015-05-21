package away3d.loaders.parsers
{
	import away3d.animators.data.ParticleGroupEventProperty;
	import away3d.animators.data.ParticleInstanceProperty;
	import away3d.arcane;
	import away3d.entities.Mesh;
	import away3d.entities.ParticleGroup;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.particleSubParsers.values.property.InstancePropertySubParser;
	
	import flash.net.URLRequest;
	
	use namespace arcane;
	
	public class ParticleGroupParser extends CompositeParserBase
	{
		
		private var _particleGroup:ParticleGroup;
		private var _animationParsers:Vector.<ParticleAnimationParser>;
		private var _instancePropertyParsers:Vector.<InstancePropertySubParser>;
		private var _customParameters:Object;
		private var _particleEvents:Vector.<ParticleGroupEventProperty>;
		
		public function ParticleGroupParser()
		{
			super();
		}
		
		public static function supportsType(extension:String):Boolean
		{
			extension = extension.toLowerCase();
			return extension == "awp";
		}
		
		public static function supportsData(data:*):Boolean
		{
			var serializedData:Object;
			
			try
			{
				serializedData = JSON.parse(data);
			}
			catch (e:Error)
			{
				return false;
			}
			
			return serializedData.hasOwnProperty('animationDatas');
		}
		
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_customParameters = _data.customParameters;
				var animationDatas:Array = _data.animationDatas;
				_animationParsers = new Vector.<ParticleAnimationParser>(animationDatas.length, true);
				_instancePropertyParsers = new Vector.<InstancePropertySubParser>(animationDatas.length, true);
				
				var particleEventsData:Array = _data.particleEvents as Array;
				if (particleEventsData)
				{
					_particleEvents = new Vector.<ParticleGroupEventProperty>;
					for each (var event:Object in particleEventsData)
					{
						_particleEvents.push(new ParticleGroupEventProperty(event.occurTime, event.name));
					}
				}
				
				for (var index:int = 0; index < animationDatas.length; index++)
				{
					var animationData:Object = animationDatas[index];
					var propertyData:Object = animationData.property;
					if (propertyData)
					{
						var instancePropertyParser:InstancePropertySubParser = new InstancePropertySubParser(null);
						addSubParser(instancePropertyParser);
						instancePropertyParser.parseAsync(propertyData.data);
						_instancePropertyParsers[index] = instancePropertyParser;
					}
					if (animationData.embed)
					{
						var animationParser:ParticleAnimationParser = new ParticleAnimationParser();
						addSubParser(animationParser);
						animationParser.parseAsync(animationData.data);
						_animationParsers[index] = animationParser;
					}
					else
					{
						addDependency(index.toString(), new URLRequest(animationData.url), true);
					}
				}
			}
			
			if (super.proceedParsing() == PARSING_DONE)
			{
				generateGroup();
				finalizeAsset(_particleGroup);
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		
		}
		
		override arcane function resolveDependency(resourceDependency:ResourceDependency):void
		{
			var index:int = int(resourceDependency.id);
			var animationParser:ParticleAnimationParser = new ParticleAnimationParser();
			addSubParser(animationParser);
			animationParser.parseAsync(resourceDependency.data);
			_animationParsers[index] = animationParser;
		
		}
		
		override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void
		{
			dieWithError("resolveDependencyFailure");
		}
		
		private function generateGroup():void
		{
			var len:int = _animationParsers.length;
			var particleMeshes:Vector.<Mesh> = new Vector.<Mesh>;
			var instanceProperties:Vector.<ParticleInstanceProperty> = new Vector.<ParticleInstanceProperty>(len, true);
			
			for (var index:int; index < _animationParsers.length; index++)
			{
				var animationParser:ParticleAnimationParser = _animationParsers[index];
				if (_instancePropertyParsers[index])
				{
					instanceProperties[index] = ParticleInstanceProperty(_instancePropertyParsers[index].setter.generateOneValue());
				}
				particleMeshes.push(animationParser.particleMesh);
			}
			_particleGroup = new ParticleGroup(particleMeshes, instanceProperties, _customParameters, _particleEvents);
		}
		
		public function get particleGroup():ParticleGroup
		{
			return _particleGroup;
		}
	
	}
}
