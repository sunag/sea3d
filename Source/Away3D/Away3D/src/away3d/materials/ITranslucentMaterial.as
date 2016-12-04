package away3d.materials
{
	public interface ITranslucentMaterial
	{
		function set alpha(value:Number):void;
		function get alpha():Number;
		
		function get requiresBlending():Boolean;
				
		function set alphaThreshold(value:Number):void;
		function get alphaThreshold():Number;
		
		function set alphaBlending(value:Boolean):void;
		function get alphaBlending():Boolean;
		
	}
}