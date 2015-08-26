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
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;

	public class SEALine extends SEAObject3D 
	{		
		public static const TYPE:String = "line";
		
		public var transform:Matrix3D;
		public var vertex:Vector.<Number>;
		public var closed:Boolean;
		
		public function SEALine(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}	
		
		protected override function read(data:ByteArray):void
		{			
			super.read(data);
			
			var count:uint = (attrib & 64 ? data.readUnsignedInt() : data.readUnsignedShort()) * 3;
			
			closed = (attrib & 128) != 0;
			
			transform = ByteArrayUtils.readMatrix3D(data);				
			
			vertex = new Vector.<Number>(count);
			
			var i:uint = 0;
			while ( i < count )
				vertex[i++] = data.readFloat();
		}
		
		public function toVector3D():Vector.<Vector3D>
		{			
			var data:Vector.<Vector3D> = new Vector.<Vector3D>(vertex.length / 3);
			
			for (var i:int=0;i<data.length;i++)
			{
				var pos:int = i * 3;
				data[i] = new Vector3D(vertex[pos], vertex[pos+1], vertex[pos+2]);
			}
			
			if (closed)
				data.push(new Vector3D(vertex[0], vertex[1], vertex[2]));
			
			return data;
		}
	}
}
