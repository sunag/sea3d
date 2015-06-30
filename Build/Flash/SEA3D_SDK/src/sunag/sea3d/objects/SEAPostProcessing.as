/*
*
* Copyright (c) 2015 Sunag Entertainment
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
	import sunag.utils.ByteArrayUtils;
	
	use namespace sunag;
	
	public class SEAPostProcessing extends SEAObject implements IAnimation
	{
		public static const TYPE:String = "post";	
		
		public static const GAMMA:uint = 0;
		public static const LEVELS:uint = 1;
		public static const COLOR_BALANCE:uint = 2;
		public static const VIBRANCE:uint = 4;
		public static const MOTION_BLUR:uint = 5;
		public static const VIGNETTE:uint = 6;
		public static const BLOOM:uint = 7;
		public static const DEPTH_OF_FIELD:uint = 8;
		public static const RADIAL_BLUR:uint = 9;
		public static const HUE:uint = 10;
		
		public var animations:Array;				
		public var processings:Array = [];	
		
		public function SEAPostProcessing(name:String, sea:SEA)
		{
			super(name, TYPE, sea);										
		}	
		
		override public function load():void
		{
			var attrib:uint = data.readUnsignedShort();
			
			if (attrib & 1)
				animations = SEAAnimationBase.readAnimationList(data, sea);
			
			var count:int = data.readUnsignedByte();
			
			for (var i:int=0;i<count;++i)
			{
				var kind:uint = data.readUnsignedShort();
				var size:uint = data.readUnsignedShort();				
				var pos:uint = data.position;
				var method:Object;	
					
				switch(kind)
				{
					case GAMMA:
						method =
							{
								ambientColor:ByteArrayUtils.readUnsignedInt24(data),
								diffuseColor:ByteArrayUtils.readUnsignedInt24(data),
								specularColor:ByteArrayUtils.readUnsignedInt24(data),
								
								specular:data.readFloat(),
								gloss:data.readFloat()
							}
						break;
					case LEVELS:						
						method = 
							{
								composite:sea.getSEAObject(data.readUnsignedInt())							
							}
						break;					
					default:						
						trace("Post-Processing Method not found:", kind.toString(16));
						data.position = pos += size;
						continue;
						break;
				}
				
				method.kind = kind;
				
				processings.push(method);								
				
				data.position = pos += size;
			}	
		}
	}
}