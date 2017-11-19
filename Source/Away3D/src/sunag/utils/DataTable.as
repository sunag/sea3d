/*
*
* Copyright (c) 2013 Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

package sunag.utils
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import sunag.sea3d.SEA;	
	
	public class DataTable
	{		
		public static const NONE:int = 0;		
		
		// 1D = 1 at 31
		public static const BOOLEAN:int = 1;
		
		public static const BYTE:int = 2;
		public static const UBYTE:int = 3;
		
		public static const SHORT:int = 4;
		public static const USHORT:int = 5;
		
		//public static const INT24:int = 6;
		public static const UINT24:int = 7;
		
		public static const INT:int = 8;
		public static const UINT:int = 9;
		
		public static const FLOAT:int = 10;
		public static const DOUBLE:int = 11;
		//public static const DECIMAL:int = 12;
		
		public static const COLOR:int = 22;				
		
		// 2D = 32 at 63
		
		// 3D = 64 at 95
		public static const VECTOR3D:int = 74;		
		
		// 4D = 96 at 127
		public static const VECTOR4D:int = 106;
		
		public static const COLOR_FLOAT:int = 112;	
		
		// Variable Size = 128 at 255
		public static const STRING_TINY:int = 128;
		public static const STRING_SHORT:int = 129;
		public static const STRING_LONG:int = 130;
		
		public static const ASSET:int = 200;
		public static const GROUP:int = 255;
		
		public static const MAX_SIZE:uint = 4;
		
		public static const QUALITY_MODE:Vector.<String> = Vector.<String>
			([
				"high","normal","low","verylow"
			]);
		
		public static const BLEND_MODE:Vector.<String> = Vector.<String>
			([
				"normal","add","subtract","multiply","dividing","mix","alpha","screen","darken",
				"overlay","colorburn","linearburn","lighten","colordodge","lineardodge",
				"softlight","hardlight","pinlight","spotlight","spotlightblend","hardmix",
				"average","difference","exclusion","hue","saturation","color","value",
				"linearlight","grainextract","reflect","glow","darkercolor","lightercolor","phoenix","negation"
			]);
		
		public static const INTERPOLATION_TABLE:Vector.<String> = Vector.<String>
			([
				"normal","linear",
				"sine.in","sine.out","sine.inout",
				"cubic.in","cubic.out","cubic.inout",
				"quint.in","quint.out","quint.inout",
				"circ.in","circ.out","circ.inout",
				"back.in","back.out","back.inout",
				"quad.in","quad.out","quad.inout",
				"quart.in","quart.out","quart.inout",
				"expo.in","expo.out","expo.inout",
				"elastic.in","elastic.out","elastic.inout",
				"bounce.in","bounce.out","bounce.inout"
			]);
		
		public static function readObject(data:IDataInput, sea:SEA=null):*
		{			
			return readToken(data.readUnsignedByte(), data, sea);
		}
		
		public static function readToken(type:int, data:IDataInput, sea:SEA=null):*
		{						
			switch(type)
			{
				// 1D
				case BOOLEAN:
					return data.readBoolean();
					break;
				
				case BYTE:
					return data.readByte();
					break;
				case UBYTE:
					return data.readUnsignedByte();
					break;
				
				case SHORT:
					return data.readShort();
					break;
				case USHORT:
					return data.readUnsignedShort();
					break;
				
				case UINT24:
					return ByteArrayUtils.readUnsignedInt24(data);
					break;	
				
				case INT:
					return data.readInt();
					break;
				case UINT:
					return data.readUnsignedInt();
					break;
				
				case FLOAT:
					return data.readFloat();
					break;
				case DOUBLE:
					return data.readDouble();
					break;	
				
				// 3D
				case VECTOR3D:
					return ByteArrayUtils.readVector3D(data);						
					break;	
				
				// 4D
				case VECTOR4D:
					return ByteArrayUtils.readVector4D(data);						
					break;
				
				// Variable Size
				case STRING_TINY:
					return ByteArrayUtils.readUTFTiny(data);						
					break;
				case STRING_SHORT:
					return data.readUTF();
					break;
				case STRING_LONG:
					return ByteArrayUtils.readUTFLong(data);						
					break;
				
				case ASSET:
					var asset:uint = data.readUnsignedInt();
					return asset > 0 ? sea.getSEAObject( asset - 1 ).tag : null;		
					break;
			}
			
			return null;
		}
		
		public static function writeObject(type:int, data:IDataOutput, value:*):void
		{
			data.writeByte(type);
			writeToken(type, data, value);
		}
		
		public static function writeToken(type:int, data:IDataOutput, val:*):void
		{
			switch(type)
			{
				// 1D
				case BOOLEAN:
					data.writeBoolean(val);
					break;
				
				case BYTE:
					data.writeByte(val);
					break;
				
				case SHORT:
				case USHORT:
					data.writeShort(val);
					break;
				
				case UINT24:
					ByteArrayUtils.writeUnsignedInt24(data, val);
					break;	
				
				case INT:
					data.writeInt(val);
					break;
				case UINT:
					data.writeUnsignedInt(val);
					break;
				
				case FLOAT:
					data.writeFloat(val);
					break;
				case DOUBLE:
					data.writeDouble(val);
					break;	
				
				// 3D
				case VECTOR3D:
					ByteArrayUtils.writeVector3D(data, val);						
					break;	
				
				// 4D
				case VECTOR4D:
					ByteArrayUtils.writeVector4D(data, val);						
					break;
				
				// Variable Size
				case STRING_TINY:
					ByteArrayUtils.writeUTFTiny(data, val);						
					break;
				case STRING_SHORT:
					data.writeUTF(val);
					break;
				case STRING_LONG:
					ByteArrayUtils.writeUTFLong(data, val);						
					break;
				
				case ASSET:
					data.writeUnsignedInt(val);
					break;
			}
		}
		
		public static function writeVector(type:int, data:IDataOutput, value:Vector.<Number>, length:uint, offset:uint=0):void
		{
			var i:uint = offset;
			
			switch(type)
			{
				// 1D
				case BOOLEAN:
					while (i < length) data.writeBoolean( value[i++] != 0 );						
					break;
				
				case BYTE:
				case UBYTE:
					while (i < length) data.writeByte( value[i++] );
					break;
				
				case SHORT:
				case USHORT:
					while (i < length) data.writeShort( value[i++] );			
					break;
				
				case UINT24:
					while (i < length) ByteArrayUtils.writeUnsignedInt24(data, value[i++]);						
					break;	
				
				case INT:
					while (i < length) data.writeInt( value[i++] );					
					break;
				case UINT:
				case COLOR:
					while (i < length) data.writeUnsignedInt( value[i++] );			
					break;
				
				case FLOAT:
				case VECTOR3D:
				case VECTOR4D:
				case COLOR_FLOAT:
					while (i < length) data.writeFloat( value[i++] );					
					break;
				case DOUBLE:
					while (i < length) data.writeDouble( value[i++] );									
					break;
			}
		}
		
		public static function readVector(type:int, data:IDataInput, out:Vector.<Number>, length:uint, offset:uint=0):void
		{			
			var size:int = sizeOf(type), 
				i:uint = offset * size, 
				count:uint = i + (length * size);
			
			switch(type)
			{
				// 1D
				case BOOLEAN:
					while (i < count) out[i++] = data.readBoolean() ? 1 : 0;						
					break;
				
				case BYTE:
					while (i < count) out[i++] = data.readByte();
					break;
				case UBYTE:
					while (i < count) out[i++] = data.readUnsignedByte();						
					break;
				
				case SHORT:
					while (i < count) out[i++] = data.readShort();						
					break;
				case USHORT:
					while (i < count) out[i++] = data.readUnsignedShort();							
					break;
				
				case UINT24:
					while (i < count) out[i++] = ByteArrayUtils.readUnsignedInt24(data);						
					break;	
				
				case INT:
					while (i < count) out[i++] = data.readInt();						
					break;
				case UINT:
				case COLOR:
					while (i < count) out[i++] = data.readUnsignedInt();						
					break;
				
				case FLOAT:
					while (i < count) out[i++] = data.readFloat();						
					break;
				case DOUBLE:
					while (i < count) out[i++] = data.readDouble();						
					break;
				
				// 3D
				case VECTOR3D:
					while (i < count) 		
					{
						out[i++] = data.readFloat();
						out[i++] = data.readFloat();
						out[i++] = data.readFloat();							
					}
					break;	
				
				// 4D
				case VECTOR4D:
				case COLOR_FLOAT:
					while (i < count) 	
					{
						out[i++] = data.readFloat();
						out[i++] = data.readFloat();
						out[i++] = data.readFloat();
						out[i++] = data.readFloat();
					}
					break;
			}
		}				
		
		public static function sizeOf(kind:int):int
		{
			if (kind == 0) return 0;
			else if (kind >= 1 && kind <= 31) return 1;
			else if (kind >= 32 && kind <= 63) return 2;
			else if (kind >= 64 && kind <= 95) return 3;
			else if (kind >= 96 && kind <= 125) return 4;			
			return -1;
		}
	}
}