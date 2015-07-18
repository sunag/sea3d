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
	
	public class SEAGeometry extends SEAGeometryData 
	{
		public static const TYPE:String = "geo";				
								
		protected var readUint:Function;
		
		public function SEAGeometry(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}			
		
		override public function load():void
		{
			attrib = data.readUnsignedShort();
			
			// Standard or Big Geometry
			readUint = (isBig = (attrib & 1) != 0) ? data.readUnsignedInt : data.readUnsignedShort;
			
			numVertex = readUint();
			
			var i:int, j:int, len:uint = numVertex*3, vec:Vector.<Number>;												
			
			// NORMAL
			if (attrib & 4)
			{
				normal = new Vector.<Number>(len);
				
				i = 0;
				while (i < len) 			
					normal[i++] = data.readFloat();	
			}
			
			// TANGENT
			if (attrib & 8)
			{
				tangent = new Vector.<Number>(len);
				
				i = 0;
				while (i < len) 			
					tangent[i++] = data.readFloat();
			}
			
			// UVS
			if (attrib & 32)
			{				
				uv = [];
				uv.length = data.readUnsignedByte();
				
				i = 0;
				while ( i < uv.length )
				{
					// UV_VERTEX
					uv[i++] = vec = new Vector.<Number>(numVertex * 2);									
					j = 0; 
					while(j < vec.length) 
						vec[j++] = data.readFloat();		
				}
			}						
			
			// JOINT_INDEXES | WEIGHTS
			if (attrib & 64)
			{
				jointPerVertex = data.readUnsignedByte();
				
				var jntLen:uint = numVertex * jointPerVertex;
				
				joint = new Vector.<Number>(jntLen);
				weight = new Vector.<Number>(jntLen);
				
				i = 0;
				while (i < jntLen) 		
					joint[i++] = data.readUnsignedShort() * SEAGeometryBase.JOINT_STRIDE;
				
				i = 0;
				while (i < jntLen) 		
					weight[i++] = data.readFloat(); 
			}						
			
			// VERTEX_COLOR
			if (attrib & 128)
			{
				var colorAttrib:int = data.readUnsignedByte(),
					numColor:int = (((colorAttrib & 64) >> 6) | ((colorAttrib & 128) >> 6)) + 1,
					colorCount:int = numVertex * 4;					
				
				color = [];
				color.length = colorAttrib & 15;
				
				for(i = 0; i < color.length; i++)
				{								
					var vColor:Vector.<Number> = new Vector.<Number>(colorCount);
					
					switch(numColor)
					{
						case 1:
							j = 0;					
							while (j < colorCount)
							{
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = 0;
								vColor[j++] = 0;
								vColor[j++] = 1;
							}
							break;
						
						case 2:
							j = 0;					
							while (j < colorCount)
							{
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = 0;
								vColor[j++] = 1;
							}
							break;
						
						case 3:
							j = 0;					
							while (j < colorCount)
							{
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = 1;
							}
							break;
						
						case 4:
							j = 0;					
							while (j < colorCount)
							{
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = data.readUnsignedByte() / 0xFF;
								vColor[j++] = data.readUnsignedByte() / 0xFF;
							}
							break;
					}										
					
					color[i] = vColor;
				}
			}			
			
			// VERTEX
			vertex = new Vector.<Number>(len);	
			i = 0; 
			while(i < vertex.length) 
				vertex[i++] = data.readFloat();
			
			indexes = [];
			indexes.length = data.readUnsignedByte();			
			
			// INDEXES
			for (i=0;i<indexes.length;i++)
			{
				var vecUint:Vector.<uint>;				
				
				indexes[i] = vecUint = new Vector.<uint>(readUint() * 3);	
				j = 0; 
				while(j < vecUint.length) 
					vecUint[j++] = readUint();			
			}			
		}			
	}
}
