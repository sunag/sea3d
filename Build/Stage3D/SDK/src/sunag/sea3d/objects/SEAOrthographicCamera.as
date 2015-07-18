package sunag.sea3d.objects
{
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	public class SEAOrthographicCamera extends SEACamera
	{
		public static const TYPE:String = "camo";
		
		public var height:Number;
		
		public function SEAOrthographicCamera(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		protected override function read(data:ByteArray):void
		{
			super.read(data);
			
			transform = ByteArrayUtils.readMatrix3D(data);	
			height = data.readFloat();
		}
	}
}