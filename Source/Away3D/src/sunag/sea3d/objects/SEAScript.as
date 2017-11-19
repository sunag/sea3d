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
	import flash.utils.IDataInput;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.field.FieldData;
	import sunag.utils.ByteArrayUtils;
	import sunag.utils.DataTable;
	
	use namespace sunag;
	
	public class SEAScript extends SEAObject
	{
		public static const TYPE:String = "code";
		
		public static var DETAILED:Boolean = false;
		
		public var source:String;
		
		public function SEAScript(name:String, sea:SEA, type:String=TYPE)
		{
			super(name, type, sea);
		}	
		
		public override function load():void
		{
			source = data.readUTFBytes(data.length);
		}
		
		public static function readScriptList(data:IDataInput, sea:SEA):Array
		{
			var list:Array = [],					
				count:int = data.readUnsignedByte();
			
			var i:int = 0;
			while ( i < count )
			{				
				var attrib:int = data.readUnsignedByte(),		
					numParams:int,
					script:Object = {};
				
				script.priority = (attrib & 1) | (attrib & 2);
				
				if (attrib & 4)
				{
					var j:int, name:String;
					
					numParams = data.readUnsignedByte();
					
					if (DETAILED)
					{
						script.params = [];
						
						for(j = 0; j < numParams; j++)
						{
							name = ByteArrayUtils.readUTFTiny(data);
							var type:int = data.readUnsignedByte();
							
							script.params[j] = new FieldData(name, type, DataTable.readToken(type, data, sea));
						}
					}
					else
					{
						script.params = {};
						
						for ( j = 0; j < numParams; j++ )
						{
							name = ByteArrayUtils.readUTFTiny(data);		
							script.params[name] = DataTable.readObject(data, sea);
						}
					}					
				}
				
				if (attrib & 8)
				{
					script.method = ByteArrayUtils.readUTFTiny(data);
				}
				
				script.tag = sea.getSEAObject(data.readUnsignedInt());
				
				list[i++] = script;
			}
			
			return list;
		}
	}
}