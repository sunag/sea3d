package sunag.sea3d.objects
{
	import flash.geom.Matrix3D;
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	public class SEAParticleContainer extends SEAObject3D
	{
		public static const TYPE:String = 'p3d';
		
		public var autoPlay:Boolean;
		
		public var particle:SEAParticle;
		public var transform:Matrix3D;
		
		public function SEAParticleContainer(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		protected override function read(data:ByteArray):void
		{
			super.read(data);
			
			autoPlay = (attrib & 64) != 0;
			
			particle = sea.getSEAObject(data.readUnsignedInt()) as SEAParticle;
			transform = ByteArrayUtils.readMatrix3D( data );
		}
	}
}