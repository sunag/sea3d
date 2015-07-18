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

package sunag.animation
{
	import sunag.sunag;
	import sunag.animation.data.AnimationData;
	import sunag.animation.data.AnimationFrame;
	import sunag.utils.DataTable;
	
	use namespace sunag;
	
	public class AnimationNode
	{
		sunag static const _anmFrameDataMul:Vector.<Number> = new Vector.<Number>(DataTable.MAX_SIZE, true);
		
		sunag var _name:String;		
		sunag var _anmFrame:AnimationFrame;				
		sunag var _anmFrameData:Vector.<Number>;
		
		sunag var _dataListId:Object = {};
		sunag var _dataList:Vector.<AnimationData> = new Vector.<AnimationData>();
		
		public var intrpl:Boolean;
		
		public var extra:Object;
		
		public function AnimationNode(name:String, frameRate:uint, numFrames:uint, repeat:Boolean=true, intrpl:Boolean=true)
		{					
			_name = name;						
			_frameRate = frameRate;	
			_frameMill = 1000 / _frameRate;
			_numFrames = numFrames;			
			_length = _numFrames - 1;
			_duration = _length * _frameMill;			
			_anmFrame = new AnimationFrame();
			_anmFrameData = _anmFrame.data;
			_repeat = repeat;
			
			this.intrpl = intrpl;
		}
		
		public function addData(val:AnimationData):void
		{			
			_dataListId[val._kind] = val;
			_dataList[_dataList.length] = val;			
		}
		
		public function removeData(val:AnimationData):void
		{			
			delete _dataListId[val._kind];
			_dataList.splice(_dataList.indexOf(val), 1);			
		}
		
		public function getDataByKind(kind:Object):AnimationData
		{
			return _dataListId[kind];
		}
		
		public function set name(value:String):void
		{
			_name = value;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function getFrameAt(frame:int, id:uint):AnimationFrame
		{
			_dataListId[id].getFrameData(frame, _anmFrame.data);			
			return _anmFrame;
		}
		
		public function getFrame(id:uint):AnimationFrame
		{
			_dataListId[id].getFrameData(int(frame), _anmFrame.data);		
			return _anmFrame;
		}
		
		sunag function _getInterpolationFrame(data:AnimationData, iFunc:Function):AnimationFrame
		{
			if (_numFrames === 0) 
				return _anmFrame;
			
			if (_invalidState)
			{
				_prevFrame = int(frame);								
				_nextFrame = validFrame(_prevFrame + 1);									
				_percent = frame - _prevFrame;				
				_invalidState = false;
			}
			
			data.getData(_prevFrame, _anmFrameData);
			
			if (_percent > 0)
			{
				data.getData(_nextFrame, _anmFrameDataMul);	
				
				// interpolation function
				iFunc(_anmFrameData, _anmFrameDataMul, _percent);
			}
			
			return _anmFrame;
		}
		
		/*
		public function getInterpolationFrameAt(index:int, type:uint=0):AnimationFrame
		{					
			return _getInterpolationFrame(_dataList[index], type);
		}	
		
		public function getInterpolationFrame(name:String, type:uint=0):AnimationFrame
		{					
			return _getInterpolationFrame(getDataByName(name), type);
		}									
			
		*/
		//
		//	Base
		//
				
		sunag var _percent:Number = 0;
		sunag var _prevFrame:int = 0;
		sunag var _nextFrame:int = 0;
		
		sunag var _time:Number = 0;
		sunag var _frame:Number = 0;
		sunag var _frameRate:int = 0;
		sunag var _frameMill:Number = 0;
		sunag var _length:uint;
		sunag var _duration:Number = 0;
		sunag var _numFrames:uint;
		sunag var _repeat:Boolean = true;
		sunag var _invalidState:Boolean = true;		
		
		public function set repeat(value:Boolean):void
		{
			_repeat = value;
			_invalidState = true;
		}
		
		public function get length():int
		{
			return _length;
		}
		
		public function get repeat():Boolean
		{
			return _repeat;
		}
		
		public function get frameRate():uint
		{
			return _frameRate;
		}
		
		public function get numFrames():uint
		{			
			return _numFrames;
		}
		
		public function get duration():Number
		{
			return _duration;
		}
		
		public function set time(value:Number):void
		{			
			_frame = validFrame( value / _frameMill );						
			_time = _frame * _frameRate;	
			_invalidState = true;
		}
		
		public function get time():Number
		{
			return _time;
		}
				
		public function get frame():Number
		{
			return _frame;
		}
		
		public function set frame(value:Number):void
		{
			time = value * _frameMill;
		}
		
		public function set position(value:Number):void
		{
			frame = value * _length;
		}
		
		public function get position():Number
		{
			return frame / _length;
		}				
		
		protected function validFrame(value:Number):Number
		{			
			var inverse:Boolean = value < 0;
			
			if (inverse) value = -value;			
			
			if (value > _length) 
				value = _repeat ? value % _length : _length;	
			
			if (inverse) value = _length - value;
			
			return value;
		}
		
		public function stateFrom(value:AnimationNode):void
		{			
			_numFrames = value._numFrames;
			_frameRate = value._frameRate;
			_duration = value._duration;
			_time = value._time;	
			_repeat = value._repeat;
			intrpl = value.intrpl;
			_invalidState = true;
		}					
	}
}