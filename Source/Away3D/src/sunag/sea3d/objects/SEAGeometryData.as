package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;

	public class SEAGeometryData extends SEAGeometryBase
	{
		public var attrib:uint;
		
		public var vertex:Vector.<Number>;
		public var indexes:Array;
		
		public var uv:Array;		
		public var normal:Vector.<Number>;
		public var tangent:Vector.<Number>;
		public var color:Array;
		
		public var joint:Vector.<Number>;
		public var weight:Vector.<Number>;
		
		public function SEAGeometryData(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}	
	}
}