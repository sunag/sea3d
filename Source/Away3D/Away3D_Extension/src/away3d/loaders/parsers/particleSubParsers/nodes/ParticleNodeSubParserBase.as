package away3d.loaders.parsers.particleSubParsers.nodes
{
	import away3d.animators.nodes.ParticleNodeBase;
	import away3d.loaders.parsers.CompositeParserBase;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	
	public class ParticleNodeSubParserBase extends CompositeParserBase
	{
		protected var _setters:Vector.<SetterBase> = new Vector.<SetterBase>;
		protected var _particleAnimationNode:ParticleNodeBase;
		
		public function ParticleNodeSubParserBase()
		{
			super();
		}
		
		public function get setters():Vector.<SetterBase>
		{
			return _setters;
		}
		
		public function get particleAnimationNode():ParticleNodeBase
		{
			return _particleAnimationNode;
		}
	}

}
