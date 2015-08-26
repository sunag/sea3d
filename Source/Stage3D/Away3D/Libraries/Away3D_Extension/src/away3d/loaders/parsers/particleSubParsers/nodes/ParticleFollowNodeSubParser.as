package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	
	public class ParticleFollowNodeSubParser extends ParticleNodeSubParserBase
	{
		public function ParticleFollowNodeSubParser()
		{
			super();
		
		}
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_particleAnimationNode = new ParticleFollowNode(_data.usesPosition, _data.usesRotation);
			}
			return super.proceedParsing()
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ParticleFollowNodeSubParser;
		}
	}
}
