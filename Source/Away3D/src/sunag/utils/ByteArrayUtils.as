package sunag.utils
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	

	public class ByteArrayUtils
	{
		//
		//	READER
		//
		
		public static function readUInteger(data:IDataInput):uint
		{
			var v:int = data.readUnsignedByte(),
				r:int = v & 0x7F;
			
			if ((v & 0x80) != 0)
			{
				v = data.readUnsignedByte();
				r |= (v & 0x7F) << 7;
				
				if ((v & 0x80) != 0)
				{
					v = data.readUnsignedByte();
					r |= (v & 0x7F) << 13;
				}
			}
			
			return r;
		}
		
		public static function readUnsignedInt24(data:IDataInput):uint
		{
			return data.readUnsignedShort() | data.readUnsignedByte() << 16;
		}
		
		public static function readUTFTiny(data:IDataInput):String
		{
			return data.readUTFBytes(data.readUnsignedByte());
		}
		
		public static function readUTFLong(data:IDataInput):String
		{
			return data.readUTFBytes(data.readUnsignedInt());
		}
		
		public static function readVector3D(data:IDataInput):Vector3D
		{
			return new Vector3D
			(
				data.readFloat(),
				data.readFloat(),
				data.readFloat()
			);
		}
		
		public static function readVector4D(data:IDataInput):Vector3D
		{
			return new Vector3D
			(
				data.readFloat(),
				data.readFloat(),
				data.readFloat(),
				data.readFloat()
			);
		}
		
		public static function readMatrix3DVector(data:IDataInput):Vector.<Number>
		{
			var v:Vector.<Number> = new Vector.<Number>(16, true);
			
			v[0] = data.readFloat();
			v[1] = data.readFloat();
			v[2] = data.readFloat();
			v[3] = 0;
			v[4] = data.readFloat();
			v[5] = data.readFloat();
			v[6] = data.readFloat();
			v[7] = 0;
			v[8] = data.readFloat();
			v[9] = data.readFloat();
			v[10] = data.readFloat();
			v[11] = 0;
			v[12] = data.readFloat();
			v[13] = data.readFloat();
			v[14] = data.readFloat();
			v[15] = 1;
			
			return v;
		}
		
		public static function readMatrix3D(data:IDataInput):Matrix3D
		{
			return new Matrix3D(readMatrix3DVector(data));
		}
		
		public static function readBlendMode(data:IDataInput):String
		{
			return DataTable.BLEND_MODE[data.readUnsignedByte()];
		}
		
		public static function getTypeInt(type:String):uint
		{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeUnsignedInt(0x00000000);
			bytes.position = 0;
			bytes.writeUTFBytes(type);
			bytes.position = 0;
			return bytes.readUnsignedInt();
		}
		
		public static function readDataObject(data:ByteArray):ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			
			var len:uint = data.readUnsignedInt();
			
			bytes.writeBytes(data, data.position, len);
			data.position += len;
			
			return bytes;
		}
		
		//
		//	WRITER
		//
		
		public static function writeUInteger(data:IDataOutput, value:int):void
		{
			var abs:uint = Math.abs(value);
			
			if (abs > 0x3F)
			{
				data.writeByte((value & 0x7F) | 0x80);
				
				if (abs > 0x1FFF)
				{
					data.writeByte(((value >> 7) & 0x7F) | 0x80);
					
					data.writeByte((value >> 13) & 0x7F);
				}
				else
				{
					data.writeByte((value >> 7) & 0x7F);
				}
			}
			else
			{
				data.writeByte(value & 0x7F);
			}
		}
		
		public static function writeVector3D(data:IDataOutput, val:Vector3D):void
		{
			data.writeFloat( val.x );
			data.writeFloat( val.y );
			data.writeFloat( val.z );
		}
		
		public static function writeVector4D(data:IDataOutput, val:Vector3D):void
		{
			data.writeFloat( val.x );
			data.writeFloat( val.y );
			data.writeFloat( val.z );
			data.writeFloat( val.w );
		}
		
		public static function writeMatrix3D(data:IDataOutput, matrix:Matrix3D):void
		{
			return writeMatrix3DVector(data, matrix.rawData);
		}
		
		public static function writeMatrix3DVector(data:IDataOutput, v:Vector.<Number>):void
		{
			data.writeFloat( v[0] );
			data.writeFloat( v[1] );
			data.writeFloat( v[2] );
			
			data.writeFloat( v[4] );
			data.writeFloat( v[5] );
			data.writeFloat( v[6] );
			
			data.writeFloat( v[8] );
			data.writeFloat( v[9] );
			data.writeFloat( v[10] );
			
			data.writeFloat( v[12] );
			data.writeFloat( v[13] );
			data.writeFloat( v[14] );
		}
		
		public static function writeBlendMode(data:IDataOutput, blendMode:String):void
		{
			data.writeByte( DataTable.BLEND_MODE.indexOf(blendMode) );
		}
		
		public static function writeUnsignedInt24(data:IDataOutput, val:uint):void
		{
			data.writeShort(val & 0xFFFF)
			data.writeByte(0xFF & (val >> 16));		
		}
		
		public static function writeDataObject(data:IDataOutput, bytes:ByteArray):void
		{
			data.writeUnsignedInt(bytes.length);
			data.writeBytes(bytes);
		}
		
		public static function writeUTFTiny(data:IDataOutput, val:String):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(val);
			
			data.writeByte(bytes.length);
			data.writeBytes(bytes);	
		}
		
		public static function writeUTFLong(data:IDataOutput, val:String):void
		{
			var bytes:ByteArray = new ByteArray();
			bytes.writeUTFBytes(val);
			
			data.writeUnsignedInt(bytes.length);
			data.writeBytes(bytes);	
		}
	}
}