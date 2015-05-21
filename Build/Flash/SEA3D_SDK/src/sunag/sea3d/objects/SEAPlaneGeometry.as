package sunag.sea3d.objects
{
	import sunag.sea3d.SEA;

	public class SEAPlaneGeometry extends SEAPrimitive
	{
		public static const TYPE:String = "Gpln";			
		
		public var width:Number;
		public var height:Number;		
		
		public function SEAPlaneGeometry(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}	
		
		public override function load():void
		{
			width = data.readFloat();
			height = data.readFloat();			
		}	
	}
}