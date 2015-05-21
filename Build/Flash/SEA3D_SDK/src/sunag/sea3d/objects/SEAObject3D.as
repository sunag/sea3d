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
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	
	use namespace sunag;
	
	public class SEAObject3D extends SEAObject implements IAnimation
	{
		public static const TYPE:String = "o3d";
		
		public static const TAG_STARTUP:uint = 1;
		public static const TAG_CHILDRENS:uint = 2;
		
		public var tags:Array;
		
		
		public var attrib:uint;	
		
		public var parent:SEAObject3D;
		public var properties:SEAProperties;
		
		public var animations:Array;	
		public var scripts:Array;
		
		public var isStatic:Boolean = false;
		public var clazz:SEAClassBase;
		
		public function SEAObject3D(name:String, type:String, sea:SEA)
		{						
			super(name, type, sea);
		}
		
		override public function load():void
		{
			attrib = data.readUnsignedShort();
			
			read(data);
			
			var numTag:int = data.readUnsignedByte();
			
			for (var i:int=0;i<numTag;++i)
			{
				var kind:uint = data.readUnsignedShort();
				var size:uint = data.readUnsignedInt();				
				var pos:uint = data.position;
				
				if (!readTag(kind, data, size))				
					trace("Tag 0x" + kind.toString(16) + " was not found in the object \"" + filename + "\".");				
				
				data.position = pos += size;
			}
		}
		
		protected function read(data:ByteArray):void
		{
			// 0 at 32
			if (attrib & 1)
				parent = sea.getSEAObject(data.readUnsignedInt()) as SEAObject3D;
			
			if (attrib & 2)
				animations = SEAAnimationBase.readAnimationList(data, sea);			
			
			if (attrib & 4)			
				scripts = SEAScript.readScriptList(data, sea);			
						
			if (attrib & 8)
				clazz = sea.getSEAObject(data.readUnsignedInt()) as SEAClassBase;
			
			if (attrib & 16)
				properties = sea.getSEAObject(data.readUnsignedInt()) as SEAProperties;
			
			if (attrib & 32)
			{
				var objectType:int = data.readUnsignedByte();				
				isStatic = (objectType & 1) != 0;
			}						
		}
		
		protected function readTag(kind:uint, data:ByteArray, size:uint):Boolean
		{
			tags ||= [];
			
			switch(kind)
			{
				case TAG_STARTUP:
					tags.push({
						kind : kind,
						startup : data.readBoolean()
					});		
					return true;
					
				case TAG_CHILDRENS:
					var i:int;
					var childrens:Vector.<SEAObject3D> = new Vector.<SEAObject3D>( data.readUnsignedInt() );										
					
					for(i = 0; i < childrens.length; i++)					
						childrens[i] = sea.getSEAObject(data.readUnsignedInt()) as SEAObject3D;					
					
					tags.push({
						kind : kind,
						childrens : childrens
					});	
					return true;
			}
			
			return false;		
		}
	}
}