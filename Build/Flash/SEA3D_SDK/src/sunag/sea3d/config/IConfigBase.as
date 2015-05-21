package sunag.sea3d.config
{
	public interface IConfigBase
	{		
		function set timeLimit(value:int):void;
		function get timeLimit():int;
		
		function set streaming(value:Boolean):void;
		function get streaming():Boolean;
		
		function set forceStreaming(value:Boolean):void;
		function get forceStreaming():Boolean;
	}
}