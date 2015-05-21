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

package sunag.sea3d.objects
{
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	use namespace sunag;
	
	public class SEAObject
	{				
		public static const TYPE:String = "obj";
		
		public var index:uint;
		public var name:String;
		public var type:String;
		public var filename:String;
		public var sea:SEA;		
		public var data:ByteArray;
		public var crc32:uint;
		
		//	ATTRIBUTES
		public var compressed:Boolean = true;
		public var streaming:Boolean = true;
		
		public var tag:*;
				
		sunag var complete:Boolean = false;
		
		public function SEAObject(name:String, type:String, sea:SEA):void
		{
			this.name = name;
			this.type = type;
			this.filename = name + '.' + type;
			this.sea = sea;			
		}
				
		public function get typeInt():uint
		{
			return ByteArrayUtils.getTypeInt(type);
		}
		
		public function load():void
		{
		}
		
		public function write():ByteArray
		{
			var bytes:ByteArray = new ByteArray();
			bytes.endian = Endian.LITTLE_ENDIAN;
			bytes.writeBytes(data);
			bytes.position = 0;
			return bytes;
		}
		
		public function dispose():void
		{
			tag = null;
			complete = false;
		}
	}
}