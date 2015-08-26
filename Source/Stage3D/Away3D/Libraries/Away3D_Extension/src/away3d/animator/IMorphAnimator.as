package away3d.animator
{
	public interface IMorphAnimator
	{
		function containsMorph(name:String):Boolean;
		
		function setWeightByIndex(index:uint, value:Number):void;				
		
		function getWeightByIndex(index:uint):Number;
		
		function setWeight(name:String, value:Number):void;
		
		function getWeight(name:String):Number;
			
		function numMorph():uint;
	}
}