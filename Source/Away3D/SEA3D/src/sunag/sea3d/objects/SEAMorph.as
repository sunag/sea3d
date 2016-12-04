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
	import sunag.sea3d.mesh.MeshData;
	import sunag.utils.ByteArrayUtils;
	
	public class SEAMorph extends SEAModifier
	{
		public static const TYPE:String = "mph";
		
		public var numVertex:uint;
		public var jointPerVertex:uint;
		
		public var isBig:Boolean = false;
		
		public var node:Vector.<MeshData>;
		
		public function SEAMorph(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}	
		
		public override function load():void
		{
			var attrib:uint = data.readUnsignedShort();
			
			// Standard or Big Geometry			
			numVertex = (attrib & 1) != 0 ? data.readUnsignedInt() : data.readUnsignedShort();
						
			var i:int, j:int, len:uint = numVertex * 3;			
						
			var useVertex:Boolean = (attrib & 2) != 0;
			var useNormal:Boolean = (attrib & 4) != 0;
			
			node = new Vector.<MeshData>(data.readUnsignedShort());
			
			for(i=0;i<node.length;i++)	
			{
				var name:String = ByteArrayUtils.readUTFTiny(data);
				
				if (useVertex)
				{				
					var verts:Vector.<Number> = new Vector.<Number>(len);
					
					j = 0;
					while(j < len)
						verts[j++] = data.readFloat();
				}
				
				if (useNormal)
				{
					var norms:Vector.<Number> = new Vector.<Number>(len);
					
					j = 0;
					while(j < len)
						norms[j++] = data.readFloat();
				}
				
				node[i] = new MeshData(verts, norms, name);
			}
		}
	}
}