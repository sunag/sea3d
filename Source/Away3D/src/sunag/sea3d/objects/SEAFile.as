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
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	public class SEAFile extends SEAObject
	{
		public static const TYPE:String = "file";
		
		public var attrib:uint;
		
		public var parent:SEAObject;
		
		public var format:String;
		public var bytes:ByteArray;
		
		public function SEAFile(name:String, sea:SEA)
		{
			super(name, TYPE, sea);	
		}
		
		override public function load():void
		{
			attrib = data.readUnsignedByte();
			
			if (attrib & 1)
			{
				format = ByteArrayUtils.readUTFTiny( data );
				bytes = ByteArrayUtils.readDataObject( data );
			}
			
			parent = attrib & 2 ? sea.getSEAObject( data.readUnsignedInt() ) : null;
		}
		
		public function get isFolder():Boolean
		{
			return !bytes;
		}
		
		override public function get fullname():String
		{
			return name + '.' + format;
		}
	}
}