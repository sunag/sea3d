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
	import flash.utils.IDataInput;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.utils.ByteArrayUtils;

	use namespace sunag;
	
	public class SEAAnimationBase extends SEAObject implements IAnimator
	{
		public static const TYPE:String = "anim";
		
		public var attrib:int;
		public var frameRate:int;
		public var numFrames:int;
		public var sequence:Array;			
		
		public function SEAAnimationBase(name:String, type:String, sea:SEA)
		{
			super(name, type, sea);
		}
		
		public function get duration():uint
		{
			return numFrames * frameRate;
		}
		
		public function get useSequence():Boolean
		{
			return sequence && (sequence.length > 1 || sequence[0].name != "root")
		}
		
		public override function load():void
		{
			attrib = data.readUnsignedByte();			
			
			sequence = [];
			
			if (attrib & 1)
			{
				sequence.length = data.readUnsignedShort();
				
				for(var i:int=0;i<sequence.length;i++)
				{
					var seqAttrib:uint = data.readUnsignedByte();
					
					sequence[i] = 
						{
							name:ByteArrayUtils.readUTFTiny(data), // name
							start:data.readUnsignedInt(), // start
							count:data.readUnsignedInt(), // count
							repeat:(seqAttrib & 1) != 0, // repeat animation
							intrpl:(seqAttrib & 2) == 0 // interpolation
						};
				}
			}
			
			frameRate = data.readUnsignedByte();
			numFrames = data.readUnsignedInt();		
			
			// no contains sequence
			if (sequence.length == 0)
				sequence[0] = {name:"root",start:0,count:numFrames,repeat:true,intrpl:true};
			
			readBody(data);
		}
		
		protected function readBody(data:ByteArray):void{};
		
		/*
		public function get intTimeScale():Number
		{	
			return int(1000 / frameRate) / (1000 / frameRate);
		}
		*/
		
		public static function readAnimationList(data:IDataInput, sea:SEA):Array
		{
			var list:Array = [],					
				count:int = data.readUnsignedByte();				
			
			var i:int = 0;
			while ( i < count )
			{				
				var attrib:int = data.readUnsignedByte(),				
					anm:Object = {};
				
				anm.relative = (attrib & 1) != 0;
				
				if (attrib & 2)
					anm.timeScale = data.readFloat();
				
				anm.tag = sea.getSEAObject(data.readUnsignedInt());
				
				list[i++] = anm;
			}
			
			return list;
		}
	}
}