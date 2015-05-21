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
	import flash.geom.Vector3D;
	
	import sunag.sea3d.SEA;
	import sunag.sunag;
	import sunag.utils.ByteArrayUtils;
	
	use namespace sunag;
	
	public class SEACubeRender extends SEACubeBase implements ISEARTT
	{
		public static const TYPE:String = "rttc";				
				
		public static const FREE:uint = 0;
		public static const TARGET:uint = 1;
		
		public var attrib:uint;
		
		public var quality:uint;
		public var position:Vector3D;
		
		public function SEACubeRender(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}		
		
		override public function load():void
		{
			// Render to Texture
			attrib = data.readUnsignedByte();
			
			// 0 HIGH
			// 1 NORMAL
			// 2 LOW
			// 3 VERY_LOW
			quality = (attrib & 1) | (attrib & 2);	
			
			position = ByteArrayUtils.readVector3D( data );
		}
	}
}
