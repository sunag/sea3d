package away3d.lights.shadowmaps
{
	public interface IDynamicShadow
	{
		function set enabled(val:Boolean):void;
		function get enabled():Boolean;
		
		function set alpha(val:Number):void;
		function get alpha():Number;
	}
}