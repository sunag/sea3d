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

package away3d.tools
{
	import away3d.core.base.Geometry;
	import away3d.core.base.SubGeometry;

	public class GeometryHelper
	{
		public static function unifyFaces(geometry:Geometry):Geometry 
		{
			var i:int,
				vertexOffset:uint = 0,				
				sub:SubGeometry;
			
			var vertex:Vector.<Number> = new Vector.<Number>();
			var indexes:Vector.<uint> = new Vector.<uint>();
						
			for each(sub in geometry.subGeometries)
			{
				var vertexData:Vector.<Number> = sub.vertexData;				
				var indexData:Vector.<uint> = sub.indexData;
				
				for (i = 0; i < vertexData.length; i++)
					vertex.push(vertexData[i]);
				
				for (i = 0; i < indexData.length; i++)
					indexes.push(indexData[i]+vertexOffset);
												
				vertexOffset += vertexData.length/3;
			}
			
			var geo:Geometry = new Geometry();
			
			sub = new SubGeometry();
			sub.updateVertexData(vertex);
			sub.updateIndexData(indexes);
			
			geo.addSubGeometry(sub);
			
			return geo;
		}
	}
}