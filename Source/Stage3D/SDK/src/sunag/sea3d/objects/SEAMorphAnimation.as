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
	import sunag.utils.DataTable;
	
	public class SEAMorphAnimation extends SEAAnimationBase
	{
		public static const TYPE:String = "mpha";
		
		public var morph:Array;
		
		public function SEAMorphAnimation(name:String, sea:SEA)
		{
			super(name, TYPE, sea);	
		}	
		
		protected override function readBody(data:ByteArray):void
		{	
			morph = [];
			morph.length = data.readUnsignedByte();
			
			for(var i:int=0;i<morph.length;i++)
			{	
				var vec:Vector.<Number>;
				
				morph[i] =
					{
						kind:ByteArrayUtils.readUTFTiny(data),
						data:vec = new Vector.<Number>(numFrames)
					}
				
				DataTable.readVector(DataTable.FLOAT, data, morph[i].data, numFrames);
			}
		}
	}
}