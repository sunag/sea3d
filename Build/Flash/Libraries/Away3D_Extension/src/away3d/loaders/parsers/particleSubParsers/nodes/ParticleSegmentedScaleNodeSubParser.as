package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.nodes.ParticleSegmentedScaleNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.loaders.parsers.particleSubParsers.values.threeD.ThreeDConstValueSubParser;
	
	import flash.geom.Vector3D;
	
	public class ParticleSegmentedScaleNodeSubParser extends ParticleNodeSubParserBase
	{
		private var _startScaleValue:ThreeDConstValueSubParser;
		private var _endScaleValue:ThreeDConstValueSubParser;
		private var _segmentPoints:Array;
		
		
		public function ParticleSegmentedScaleNodeSubParser()
		{
			super();
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				
				var object:Object;
				var Id:Object;
				var subData:Object;
				
				object = _data.startScale;
				//Id = object.id;
				subData = object.data;
				_startScaleValue = new ThreeDConstValueSubParser(null);
				addSubParser(_startScaleValue);
				_startScaleValue.parseAsync(subData);
				
				object = _data.endScale;
				//Id = object.id;
				subData = object.data;
				_endScaleValue = new ThreeDConstValueSubParser(null);
				addSubParser(_endScaleValue);
				_endScaleValue.parseAsync(subData);
				
				_segmentPoints = new Array;
				var pointsData:Array = _data.segmentPoints;
				for (var i:int; i < pointsData.length; i++)
				{
					var scaleValue:ThreeDConstValueSubParser = new ThreeDConstValueSubParser(null);
					addSubParser(scaleValue);
					_segmentPoints.push({life: pointsData[i].life, scale: scaleValue});
					scaleValue.parseAsync(pointsData[i].scale.data);
				}
				_segmentPoints.sortOn("life", Array.NUMERIC | Array.CASEINSENSITIVE);
				//make sure all life values are different
				for (i = 0; i < pointsData.length - 1; i++)
				{
					if (_segmentPoints[i].life == _segmentPoints[i + 1].life)
						_segmentPoints[i].life -= 0.00001 * (pointsData.length - i);
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
			var segmentPoints:Vector.<Vector3D> = new Vector.<Vector3D>;
			var len:int = _segmentPoints.length;
			var i:int;
			for (; i < len; i++)
			{
				var scale:Vector3D = _segmentPoints[i].scale.setter.generateOneValue();
				scale.w = _segmentPoints[i].life;
				segmentPoints.push(scale);
			}
			_particleAnimationNode = new ParticleSegmentedScaleNode(len, _startScaleValue.setter.generateOneValue(), _endScaleValue.setter.generateOneValue(), segmentPoints);
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleSegmentedScaleNodeSubParser;
		}
	}
}
