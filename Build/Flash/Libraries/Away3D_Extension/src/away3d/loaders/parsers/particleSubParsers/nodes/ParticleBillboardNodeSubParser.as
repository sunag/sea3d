package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.nodes.ParticleBillboardNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	
	import flash.geom.Vector3D;
	
	public class ParticleBillboardNodeSubParser extends ParticleNodeSubParserBase
	{
		public function ParticleBillboardNodeSubParser()
		{
			super();
			_particleAnimationNode = new ParticleBillboardNode();
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				if (_data && _data.usesAxis)
				{
					_particleAnimationNode = new ParticleBillboardNode(new Vector3D(_data.axisX, _data.axisY, _data.axisZ));
				}
				else
					_particleAnimationNode = new ParticleBillboardNode();
			}
			return super.proceedParsing()
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleBillboardNodeSubParser;
		}
	}
}
