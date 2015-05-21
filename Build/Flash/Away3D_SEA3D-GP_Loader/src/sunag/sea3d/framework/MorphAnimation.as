package sunag.sea3d.framework
{
	import sunag.sea3dgp;
	import sunag.animation.AnimationNode;
	import sunag.animation.AnimationSet;
	import sunag.animation.data.AnimationData;
	import sunag.sea3d.objects.SEAMorphAnimation;
	import sunag.sea3d.objects.SEAObject;
	import sunag.utils.DataTable;
	
	use namespace sea3dgp;
	
	public class MorphAnimation extends Animation
	{
		public static function getAsset(name:String):MorphAnimation
		{
			return Animation.getAsset(name) as MorphAnimation;
		}
		
		sea3dgp var scope:AnimationSet;
		
		override public function get names():Array
		{
			var names:Array = [];
			
			for each(var anm:AnimationNode in scope.animations)			
				names.push( anm.name );			
			
			return names;
		}		
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	MORPH ANIMATION
			//
			
			var anm:SEAMorphAnimation = sea as SEAMorphAnimation;
			
			scope = new AnimationSet();
			
			var node:AnimationNode, 
				anmData:Object,
				anmList:Array = anm.morph;
			
			for each(var seq:Object in anm.sequence)
			{
				node = new AnimationNode(seq.name, anm.frameRate, seq.count, seq.repeat, seq.intrpl);
				
				for each(anmData in anmList)
				{						
					node.addData( new AnimationData(anmData.kind, DataTable.FLOAT, anmData.data, seq.start) );						
				}
				
				scope.addAnimation( node );
			}
		}
	}
}