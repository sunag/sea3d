package sunag.sea3d.framework
{
	import away3d.animator.MorphAnimationSet;
	import away3d.morph.MorphNode;
	
	import sunag.sea3dgp;
	import sunag.sea3d.mesh.MeshData;
	import sunag.sea3d.objects.SEAMorph;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class Morph extends Asset
	{
		sea3dgp static const TYPE:String = 'Morph/';				
		
		sea3dgp var scope:MorphAnimationSet;
		
		sea3dgp var numVertex:int = 0;
		
		public function Morph()
		{
			super(TYPE);						
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	MORPH
			//
			
			var morph:SEAMorph = sea as SEAMorph;
			
			var morphs:Vector.<MorphNode> = new Vector.<MorphNode>(morph.node.length);
			
			for(var i:int=0;i<morphs.length;i++)
			{
				var md:MeshData = morph.node[i];				 					
				morphs[i] = new MorphNode(md.name, md.vertex, md.normal);
			}
			
			scope = new MorphAnimationSet(morphs, false);
			
			numVertex = morph.numVertex;
		}
	}
}