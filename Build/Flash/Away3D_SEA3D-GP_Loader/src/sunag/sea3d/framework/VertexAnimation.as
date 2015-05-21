package sunag.sea3d.framework
{
	import away3d.animators.VertexAnimationSet;
	import away3d.animators.nodes.AnimationNodeBase;
	import away3d.animators.nodes.VertexClipNode;
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;
	
	import sunag.sea3dgp;
	import sunag.sea3d.mesh.MeshData;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAVertexAnimation;
	
	use namespace sea3dgp;

	public class VertexAnimation extends Animation
	{
		public static function getAsset(name:String):VertexAnimation
		{
			return Animation.getAsset(name) as VertexAnimation;
		}
		
		sea3dgp var scope:VertexAnimationSet;
		sea3dgp var seaTmp:SEAVertexAnimation;
		
		sea3dgp var numVertex:int = 0;
		
		sea3dgp function creatAnimationSet(ref:away3d.core.base.Geometry):VertexAnimationSet
		{
			if (!scope)
			{
				scope = new VertexAnimationSet();
				
				var i:int = 0, 
					frames:Vector.<away3d.core.base.Geometry> = new Vector.<away3d.core.base.Geometry>(seaTmp.frame.length);					
				
				while (i < frames.length)
				{
					var frame:MeshData = seaTmp.frame[i];				
					var geo:away3d.core.base.Geometry = new away3d.core.base.Geometry();
					
					for each(var refSG:SubGeometry in ref.subGeometries)
					{
						var frameSG:SubGeometry = new SubGeometry();
						
						frameSG.updateIndexData(refSG.indexData);
						
						frameSG.fromVectors
							(
								frame.vertex,
								refSG.UVData,
								frame.normal ? frame.normal : null,
								refSG.vertexTangentData,
								refSG.secondaryUVData
							);
						
						geo.addSubGeometry(frameSG);
					}	
					
					frames[i++] = geo;
				}
				
				for each(var seq:Object in seaTmp.sequence)		
				{
					var clip:VertexClipNode = new VertexClipNode();
					
					clip.name = seq.name;
					clip.looping = seq.repeat;
					clip.frameRate = seaTmp.frameRate;
					
					var start:int = seq.start;
					var end:int = seq.start + seq.count;
					
					for (var j:int=start;j<end;j++)			
						clip.addFrame(frames[j]);
					
					scope.addAnimation(clip);				
				}
			}
			
			return scope;
		}
		
		override public function get names():Array
		{
			var names:Array = [];
			
			for each(var anm:AnimationNodeBase in scope.animations)			
				names.push( anm.name );			
			
			return names;
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	VERTEX ANIMATION
			//
			
			seaTmp = sea as SEAVertexAnimation;						
		}
	}
}