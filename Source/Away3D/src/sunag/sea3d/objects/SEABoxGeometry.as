package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;

	public class SEABoxGeometry extends SEAPrimitive
	{
		public static const TYPE:String = "Gbox";			
		
		public var width:Number;
		public var height:Number;
		public var depth:Number;
		
		public function SEABoxGeometry(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}	
		
		public override function load():void
		{
			width = data.readFloat();
			height = data.readFloat();
			depth = data.readFloat();
		}	
	}
}