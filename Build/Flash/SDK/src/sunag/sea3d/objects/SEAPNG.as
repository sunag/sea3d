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
	
	public class SEAPNG extends SEATexture
	{
		public static const TYPE:String = "png";
		
		public function SEAPNG(name:String, sea:SEA)
		{
			super(name, TYPE, sea);	
		}		
		
		public override function load():void
		{
			/*
			references: http://www.bit-101.com/blog/?p=2581 | http://www.kaourantin.net/2005/10/png-encoder-in-as3.html
			if (bytes.readUnsignedInt() == 0x89504E47 && 
				bytes.readUnsignedInt() == 0x0D0A1A0A && 
				// length chunk and IHDR ID
				bytes.readUnsignedInt() == 13 && bytes.readUnsignedInt() == 0x49484452)
			{	
				// jump width, height and bit depth
				bytes.position += 9;				
				transparent = bytes.readUnsignedByte() == 0x06;
				
				//trace("width",bytes.readInt());
				//trace("height", bytes.readInt());				
				//trace("bit depth per channel",bytes.readUnsignedByte());
				//trace("color type RGBA", bytes.readUnsignedByte());
			}
			*/
						
			transparent = data[25] == 0x06;
		}		
	}
}