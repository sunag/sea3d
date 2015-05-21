package sunag.sea3d.framework
{
	import sunag.sea3dgp;
	import sunag.animation.AnimationNode;
	import sunag.animation.AnimationSet;
	import sunag.animation.data.AnimationData;
	import sunag.sea3d.objects.SEAAnimation;
	import sunag.sea3d.objects.SEAObject;

	use namespace sea3dgp;
	
	public class AnimationStandard extends Animation
	{
		public static function getAsset(name:String):AnimationStandard
		{
			return Animation.getAsset(name) as AnimationStandard;
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
			//	ANIMATION
			//
			
			var anm:SEAAnimation = sea as SEAAnimation;
			
			scope = new AnimationSet();
			
			var node:AnimationNode,
				anmData:Object,
				anmList:Array = anm.dataList;
			
			for each(var seq:Object in anm.sequence)
			{
				node = new AnimationNode(seq.name, anm.frameRate, seq.count, seq.repeat, seq.intrpl);
				
				for each(anmData in anmList)
				{						
					node.addData( new AnimationData(anmData.kind, anmData.type, anmData.data, seq.start * anmData.blockSize) );
				}
				
				scope.addAnimation( node );
			}
		}
	}
}