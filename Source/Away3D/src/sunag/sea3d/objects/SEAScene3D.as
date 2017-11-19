package sunag.sea3d.objects
{
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	
	public class SEAScene3D extends SEAObject
	{
		public static const TYPE:String = "s3d";

		public static const NONE:uint = 0;
		
		public var attrib:uint;
		
		public var partition:uint = NONE;
		public var object:Vector.<SEAObject>;//SEAObject3D
		
		public function SEAScene3D(name:String, type:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
		
		override public function load():void
		{
			attrib = data.readUnsignedShort();
			
			read(data);
			
			var numTag:int = data.readUnsignedByte();
			
			for (var i:int=0;i<numTag;++i)
			{
				var kind:uint = data.readUnsignedShort();
				var size:uint = data.readUnsignedInt();				
				var pos:uint = data.position;
				
				if (!readTag(kind, data, size))				
					trace("Tag 0x" + kind.toString(16) + " was not found in the object \"" + filename + "\".");				
				
				data.position = pos += size;
			}
		}
		
		protected function read(data:ByteArray):void
		{
			var length:uint;
			
			if (partition == NONE)
			{
				length = data.readUnsignedInt();
				
				for(var i:int = 0;i < length; i++)
					object[i] = sea.getSEAObject( data.readUnsignedInt() );
			}
		}
		
		protected function readTag(kind:uint, data:ByteArray, size:uint):Boolean
		{
			return false;		
		}
	}
}