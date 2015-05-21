/*
*
* Copyright (c) 2014 Sunag Entertainment
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
	
	public class SEAReference extends SEAObject
	{
		public static const TYPE:String = "refs";
		
		public var refs:Object = [];		
							
		public function SEAReference(name:String, sea:SEA)
		{
			super(name, TYPE, sea);
		}
						
		public override function load():void
		{
			var count:int = data.readUnsignedShort();
			
			refs = [];
			
			for(var i:int = 0; i < count; i++)
			{
				var flags:int = data.readUnsignedByte();
				var ref:Object = {};
				 		
				ref.flags = flags;
				
				ref.name = ByteArrayUtils.readUTFTiny( data );
				
				if (flags & 1)
				{
					ref.data = ByteArrayUtils.readDataObject( data );
				}
					
				refs.push( ref );
			}			
		}
	}
}