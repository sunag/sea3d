package sunag.sea3d.config
{
	public interface IConfigWriter
	{
		function set timeLimit(value:int):void;
		function get timeLimit():int;
		
		function set version(value:int):void;
		function get version():int;
		
		function set compressMethod(value:String):void;
		function get compressMethod():String;
	}
}