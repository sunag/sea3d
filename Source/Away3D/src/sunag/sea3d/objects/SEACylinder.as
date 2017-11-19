package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;

	public class SEACylinder extends SEAShape
	{
		public static const TYPE:String = "cyl";			
		
		public var radius:Number;
		public var height:Number;
		
		public function SEACylinder(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}	
		
		public override function load():void
		{
			radius = data.readFloat();
			height = data.readFloat();
		}	
	}
}