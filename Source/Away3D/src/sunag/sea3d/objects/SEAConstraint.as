package sunag.sea3d.objects
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	public class SEAConstraint extends SEAObject
	{
		public static const TYPE:String = "ctnt";
		
		public var attrib:int;
		
		public var disableCollisionsBetweenBodies:Boolean;
		
		public var targetA:SEAObject;//SEAPhysics
		public var pointA:Vector3D;
		
		public var targetB:SEAObject;//SEAPhysics
		public var pointB:Vector3D;
		
		public function SEAConstraint(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}
		
		override public function load():void
		{
			attrib = data.readUnsignedShort();
			
			targetA = sea.getSEAObject( data.readUnsignedInt() ) ;
			pointA = ByteArrayUtils.readVector3D( data );
			
			if (attrib & 1)			
			{	
				targetB = sea.getSEAObject( data.readUnsignedInt() );
				pointB = ByteArrayUtils.readVector3D( data );
			}
			
			disableCollisionsBetweenBodies = (attrib & 2) != 0;
			
			read(data);
		}
		
		protected function read(data:ByteArray):void
		{			
		}
	}
}