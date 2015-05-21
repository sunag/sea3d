package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;

	public class SEACylinderGeometry extends SEAPrimitive
	{
		public static const TYPE:String = "Gcyl";			
		
		public var radiusTop:Number;
		public var radiusBottom:Number;
		public var height:Number;
		
		public function SEACylinderGeometry(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}	
		
		public override function load():void
		{
			radiusTop = data.readFloat();
			radiusBottom = data.readFloat();
			height = data.readFloat();
		}	
	}
}