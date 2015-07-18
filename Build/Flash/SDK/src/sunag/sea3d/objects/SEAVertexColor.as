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
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;
	
	public class SEAVertexColor extends SEAModifier 
	{
		public static const TYPE:String = "vtc";				
											
		public var attrib:uint;		
		public var numVertex:uint;
		
		public var isBig:Boolean = false;
		
		public var vertexColor:Vector.<Number>;
		
		protected var readUint:Function;	
		
		public function SEAVertexColor(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}			
		
		public override function load():void
		{
			attrib = data.readUnsignedShort();
			
			// Standard or Big Geometry
			readUint = (isBig = (attrib & 1) != 0) ? data.readUnsignedInt : data.readUnsignedShort;
			
			numVertex = readUint();
			
			var i:int = 0, len:uint = numVertex * 3, color:uint;
			
			vertexColor = new Vector.<Number>(len);
			
			if (attrib & 2)
			{
				while(i < len)	
				{
					vertexColor[i++] = data.readFloat();
					vertexColor[i++] = data.readFloat();
					vertexColor[i++] = data.readFloat();
				}
			}
			else
			{
				while(i < len)	
				{
					color = ByteArrayUtils.readUnsignedInt24(data);
					
					vertexColor[i++] = ((color >> 16) & 0xFF) / 0xFF;
					vertexColor[i++] = ((color >> 8) & 0xFF) / 0xFF;
					vertexColor[i++] = (color & 0xFF) / 0xFF;
				}
			}
		}	
	}
}
