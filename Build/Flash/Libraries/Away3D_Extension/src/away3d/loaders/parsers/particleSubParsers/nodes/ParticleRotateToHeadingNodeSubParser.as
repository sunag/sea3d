package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.nodes.ParticleRotateToHeadingNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	
	public class ParticleRotateToHeadingNodeSubParser extends ParticleNodeSubParserBase
	{
		public function ParticleRotateToHeadingNodeSubParser()
		{
			super();
			_particleAnimationNode = new ParticleRotateToHeadingNode();
		}
		
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleRotateToHeadingNodeSubParser;
		}
	}
}
