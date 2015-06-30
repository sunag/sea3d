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
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.field.FieldData;
	import sunag.utils.ByteArrayUtils;
	import sunag.utils.DataTable;
	
	use namespace sunag;
	
	public class SEAPropertiesBase extends SEAObject
	{
		public static var DETAILED:Boolean = false;
		
		public var attribs:*;
		
		public function SEAPropertiesBase(name:String, sea:SEA, type:String)
		{
			super(name, type, sea);						
		}
		
		public override function load():void
		{	
			var count:int, i:int, type:int, name:String,
				objects:Vector.<SEAObject> = sea.objects;
			
			if (DETAILED)
			{								
				count = data.readUnsignedByte();
				
				attribs = new Vector.<FieldData>(count);
				
				for(i = 0; i < count; i++)
				{
					name = ByteArrayUtils.readUTFTiny(data);
					type = data.readUnsignedByte();
					
					attribs[i] = new FieldData(name, type, DataTable.readToken(type, data, sea));
				}
			}
			else
			{								
				count = data.readUnsignedByte();
				
				attribs = {__name__:this.name};
				
				for(i = 0; i < count; i++)
				{
					name = ByteArrayUtils.readUTFTiny(data);		
					attribs[name] = DataTable.readObject(data, sea);
				}
			}
			
			tag = attribs;
		}		
	}
}