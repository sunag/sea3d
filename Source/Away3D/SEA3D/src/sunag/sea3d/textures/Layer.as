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

package sunag.sea3d.textures
{
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;

	public class Layer
	{
		public var sea:SEA;
		
		public var name:String;
		
		public var blendMode:String = "normal";
		public var opacity:Number = 1;
		
		public var color:uint;
		public var texture:LayerBitmap;
		public var mask:LayerBitmap;
		
		public function Layer(data:ByteArray, sea:SEA)
		{					
			this.sea = sea;
			
			var attrib:int = data.readUnsignedShort();
			
			if (attrib & 1) texture = new LayerBitmap(data, sea);
			else color = ByteArrayUtils.readUnsignedInt24(data); 
			
			if (attrib & 2)
				mask = new LayerBitmap(data, sea);			
			
			if (attrib & 4)
				name = ByteArrayUtils.readUTFTiny(data);
			
			if (attrib & 8)
				blendMode = ByteArrayUtils.readBlendMode(data);
			
			if (attrib & 16)
				opacity = data.readFloat();	
		}				
	}
}