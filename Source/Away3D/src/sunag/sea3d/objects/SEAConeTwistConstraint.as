package sunag.sea3d.objects
{
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	public class SEAConeTwistConstraint extends SEAConstraint
	{
		public static const TYPE:String = "ctwc";
		
		public var axisA:Vector3D;
		public var axisB:Vector3D;
		
		public var limit:Object;
		
		public function SEAConeTwistConstraint(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		override protected function read(data:ByteArray):void
		{
			axisA = ByteArrayUtils.readVector3D( data );
			
			if (attrib & 1)			
			{	
				axisB = ByteArrayUtils.readVector3D( data );
			}
			
			if (attrib & 4)
			{
				limit = 
					{
						swingSpanA : data.readFloat(),
						swingSpanB : data.readFloat(),
						twistSpan : data.readFloat(),
						softness : data.readFloat(), // 1
						biasFactor : data.readFloat(), // 0.3
						relaxationFactor : data.readFloat() // 1.0
					};
			}
		}
	}
}