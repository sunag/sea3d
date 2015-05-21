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

package sunag.animation.data
{
	import sunag.sunag;
	import sunag.utils.DataTable;

	use namespace sunag;
	
	public class AnimationData
	{
		sunag var _kind:Object;
		sunag var _type:uint;						
		sunag var _blockLength:int;
		private var _data:Vector.<Number>;
		private var _offset:uint;
		
		sunag var getData:Function;
		
		public function AnimationData(kind:Object, dataType:uint, data:Vector.<Number>, offset:uint=0)
		{
			_kind = kind;
			_type = dataType;
			_blockLength = DataTable.sizeOf(dataType);
			_data = data;
			_offset = offset;
						
			switch(_blockLength)
			{
				case 1: getData = getData1x; break;
				case 2: getData = getData2x; break;
				case 3: getData = getData3x; break;
				case 4: getData = getData4x; break;
			}
		}
		
		public function get kind():Object
		{
			return _kind;			
		}
		
		public function get dataType():uint
		{
			return _type;			
		}
		
		public function get blockLength():int
		{
			return _blockLength;			
		}
		
		public function get data():Vector.<Number>
		{
			return _data;			
		}
		
		protected function getData1x(frame:uint, data:Vector.<Number>):void
		{				
			frame = _offset + frame * _blockLength;	
			
			data[0] = _data[frame];			
		}
		
		protected function getData2x(frame:uint, data:Vector.<Number>):void
		{				
			frame = _offset + frame * _blockLength;	
			
			data[0] = _data[frame];
			data[1] = _data[frame + 1];								
		}
		
		protected function getData3x(frame:uint, data:Vector.<Number>):void
		{						
			frame = _offset + frame * _blockLength;	
			
			data[0] = _data[frame];		
			data[1] = _data[frame + 1];			
			data[2] = _data[frame + 2];
		}
		
		protected function getData4x(frame:uint, data:Vector.<Number>):void
		{				
			frame = _offset + frame * _blockLength;	
			
			data[0] = _data[frame];		
			data[1] = _data[frame + 1];			
			data[2] = _data[frame + 2];
			data[3] = _data[frame + 3];
		}
	}
}