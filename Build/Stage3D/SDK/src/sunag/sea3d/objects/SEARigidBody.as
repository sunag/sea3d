package sunag.sea3d.objects
{
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	
	public class SEARigidBody extends SEAPhysics
	{
		public static const TYPE:String = "rb";
		
		public var linearDamping:Number = 0;
		public var angularDamping:Number = 0;
		
		public var mass:Number;
		public var friction:Number;
		public var restitution:Number;
		
		public function SEARigidBody(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		override protected function read(data:ByteArray):void
		{
			super.read(data);
			
			if (attrib & 32) 
			{				
				linearDamping = data.readFloat();
				angularDamping = data.readFloat();
			}
									
			mass = data.readFloat();
			friction = data.readFloat();
			restitution = data.readFloat();						
		}
	}
}