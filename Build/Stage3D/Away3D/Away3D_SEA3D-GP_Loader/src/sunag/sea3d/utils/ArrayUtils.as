package sunag.sea3d.utils
{
	public class ArrayUtils
	{
		public static function getItem(array:Array, index:int):*
		{
			return array[ index % array.length ];
		}
		
		public static function randItem(array:Array):*
		{
			return array[ Math.round( Math.random() * (array.length-1) ) ];
		}
	}
}