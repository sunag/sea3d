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
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.objects.IAnimation;
	import sunag.sea3d.objects.SEAAnimationBase;
	import sunag.sea3d.objects.SEATexture;

	use namespace sunag;
	
	public class LayerBitmap implements IAnimation
	{
		public var sea:SEA;
		
		public var map:SEATexture;
		public var animations:Array;		
		
		public var channel:int = 0;
		public var repeat:Boolean = true;
		
		public var offsetU:Number = 0;
		public var offsetV:Number = 0;		
		public var scaleU:Number = 1;
		public var scaleV:Number = 1;		
		public var rotation:Number = 0;		
		
		public var containsUV:Boolean;
		
		public function LayerBitmap(data:ByteArray, sea:SEA)
		{			
			this.sea = sea;
			
			map = sea.getSEAObject(data.readUnsignedInt()) as SEATexture;
			
			var attrib:int = data.readUnsignedShort();
			
			if (attrib > 0)
			{
				if (attrib & 1)							
					channel = data.readUnsignedByte();
				
				if (attrib & 2)							
					repeat = false;
				
				if (attrib & 4)							
					offsetU = data.readFloat();
				
				if (attrib & 8)							
					offsetV = data.readFloat();
				
				if (attrib & 16)							
					scaleU = data.readFloat();
				
				if (attrib & 32)							
					scaleV = data.readFloat();
				
				if (attrib & 64)							
					rotation = data.readFloat();
				
				if (attrib & 128)					
					animations = SEAAnimationBase.readAnimationList( data, sea );				
			}
			
			containsUV = offsetU != 0 || offsetV != 0 || scaleU != 1 || scaleV != 1 || rotation != 0;
		}						
	}
}