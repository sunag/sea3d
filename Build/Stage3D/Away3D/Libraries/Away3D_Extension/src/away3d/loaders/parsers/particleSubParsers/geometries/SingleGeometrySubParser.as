package away3d.loaders.parsers.particleSubParsers.geometries
{
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.core.base.ParticleGeometry;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.AllSubParsers;
	import away3d.loaders.parsers.particleSubParsers.geometries.shapes.ShapeSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.utils.MatchingTool;
	import away3d.loaders.parsers.particleSubParsers.values.ValueSubParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.matrix.Matrix2DUVCompositeValueSubParser;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import away3d.tools.helpers.data.ParticleGeometryTransform;
	
	use namespace arcane;
	
	public class SingleGeometrySubParser extends GeometrySubParserBase
	{
		
		private var _shape:ShapeSubParserBase;
		private var _vertexTransformValue:ValueSubParserBase;
		private var _uvTransformValue:ValueSubParserBase;
		private var _particleGeometry:ParticleGeometry;
		
		public function SingleGeometrySubParser():void
		{
		
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				var object:Object;
				var Id:Object;
				var subData:Object;
				var valueCls:Class;
				var cls:Class;
				
				object = _data.vertexTransform;
				if (object)
				{
					Id = object.id;
					subData = object.data;
					valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_MATRIX3DS);
					if (!valueCls)
					{
						dieWithError("Unknown value");
					}
					_vertexTransformValue = new valueCls(null);
					addSubParser(_vertexTransformValue);
					_vertexTransformValue.parseAsync(subData);
				}
				
				object = _data.uvTransformValue;
				if (object)
				{
					Id = object.id;
					subData = object.data;
					_uvTransformValue = new Matrix2DUVCompositeValueSubParser(null);
					addSubParser(_uvTransformValue);
					_uvTransformValue.parseAsync(subData);
				}
				
				
				object = _data.shape;
				Id = object.id;
				subData = object.data;
				valueCls = MatchingTool.getMatchedClass(Id, AllSubParsers.ALL_SHAPES);
				_shape = new valueCls();
				addSubParser(_shape);
				_shape.parseAsync(subData);
			}
			if (super.proceedParsing() == PARSING_DONE)
			{
				generateParticleGeometry();
				finalizeAsset(_particleGeometry);
				return PARSING_DONE;
			}
			else
				return MORE_TO_PARSE;
		}
		
		private function generateParticleGeometry():void
		{
			var geometry:Geometry = _shape.getGeometry();
			var vector:Vector.<Geometry> = new Vector.<Geometry>(_numParticles, true);
			var i:int;
			for (; i < _numParticles; i++)
			{
				vector[i] = geometry;
			}
			var transforms:Vector.<ParticleGeometryTransform>;
			if (_vertexTransformValue || _uvTransformValue)
			{
				var vertexSetter:SetterBase = _vertexTransformValue ? _vertexTransformValue.setter : null;
				var uvSetter:SetterBase = _uvTransformValue ? _uvTransformValue.setter : null;
				
				transforms = new Vector.<ParticleGeometryTransform>(_numParticles, true);
				var _geometryTransform:ParticleGeometryTransform;
				for (i = 0; i < _numParticles; i++)
				{
					_geometryTransform = new ParticleGeometryTransform();
					if (vertexSetter)
						_geometryTransform.vertexTransform = vertexSetter.generateOneValue(i, _numParticles);
					if (uvSetter)
						_geometryTransform.UVTransform = uvSetter.generateOneValue(i, _numParticles);
					transforms[i] = _geometryTransform;
				}
			}
			_particleGeometry = ParticleGeometryHelper.generateGeometry(vector, transforms);
		}
		
		override public function get particleGeometry():ParticleGeometry
		{
			return _particleGeometry;
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.SingleGeometrySubParser;
		}
	
	}

}
