package sunag.sea3d.objects
{
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	public class SEAPerspectiveCamera extends SEACamera
	{
		public static const TYPE:String = "cam";
		
		public var fov:Number;
		public var dof:Object;
		
		public function SEAPerspectiveCamera(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		protected override function read(data:ByteArray):void
		{
			super.read(data);
			
			if (attrib & 512)
			{
				dof = 
					{
						distance:data.readFloat(), 
						range:data.readFloat()
					};
			}
			
			transform = ByteArrayUtils.readMatrix3D(data);
			
			fov = data.readFloat();				
		}
	}
}