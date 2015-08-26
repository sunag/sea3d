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
	import sunag.events.AnimationEvent;
	import sunag.utils.MathHelper;

	use namespace sunag;
		
	public class Animation extends AnimationBroadcaster
	{				
		sunag var _animationSet:AnimationSet;		
		sunag var _animationState:Vector.<AnimationState>;
		sunag var _animationStateDict:Object = {};
		
		sunag var _blendMethod:uint = AnimationBlendMethod.LINEAR;
		sunag var _updateAllStates:Boolean = false;
				
		sunag var _defaultIntrpl:Function;
		sunag var _intrplFuncs:Object;
		
		sunag var _relative:Boolean = false;
		
		sunag var _currentState:AnimationState;
		sunag var _animations:Vector.<AnimationNode>;								
		
		// Dict Leprs Functions
		public static const DefaultLerpFuncs:Array = 
			[
				MathHelper.lerp3x, // position
				MathHelper.lerpQuat4x, // rotation
				MathHelper.lerp3x, // scale
				MathHelper.lerpColor1x, // color
				MathHelper.lerp1x, // multiplier
				MathHelper.lerp1x, // attenuation-start
				MathHelper.lerp1x, // attenuation-end
				MathHelper.lerp1x, // fov
				MathHelper.lerp1x, // offset-u
				MathHelper.lerp1x, // offset-v
				MathHelper.lerp1x, // scale-u
				MathHelper.lerp1x, // scale-v
				MathHelper.lerpAng1x, // angle
				MathHelper.lerp1x, // alpha
				MathHelper.lerp1x // volume
			];
		
		public static const POSITION:uint = 0x0000;
		public static const ROTATION:uint = 0x0001;
		public static const SCALE:uint = 0x0002;
		public static const COLOR:uint = 0x0003;
		public static const MULTIPLIER:uint = 0x0004;
		public static const ATTENUATION_START:uint = 0x0005;
		public static const ATTENUATION_END:uint = 0x0006;
		public static const FOV:uint = 0x0007;
		public static const OFFSET_U:uint = 0x0008;
		public static const OFFSET_V:uint = 0x0009;
		public static const SCALE_U:uint = 0x000A;
		public static const SCALE_V:uint = 0x000B;
		public static const ANGLE:uint = 0x000C;
		public static const ALPHA:uint = 0x000D;
		public static const VOLUME:uint = 0x000E;
		
		public function Animation(animationSet:AnimationSet=null, intrplFuncs:Object=null)
		{
			_animationSet = animationSet;
			_intrplFuncs = intrplFuncs || DefaultLerpFuncs; 
			
			if (_animationSet)
			{
				_animations = _animationSet.animations;			
				initStateList();
			}
		}
				
		public function set relative(value:Boolean):void
		{
			_relative = value;
		}
		
		public function get relative():Boolean
		{
			return _relative;
		}
		
		public function get animationSet():AnimationSet
		{
			return _animationSet;
		}
		
		public function set enableIntrpl(value:Boolean):void
		{
			_defaultIntrpl = value ? null : MathHelper.empyNx;
		}
		
		public function get enableIntrpl():Boolean
		{
			return _defaultIntrpl !== MathHelper.empyNx;
		}
		
		public function set defaultIntrpl(value:Function):void
		{
			_defaultIntrpl = value;
		}
		
		public function get defaultIntrpl():Function
		{
			return _defaultIntrpl;
		}
		
		public function set intrplFuncs(value:Object):void
		{
			_intrplFuncs = value;
		}
		
		public function get intrplFuncs():Object
		{
			return _intrplFuncs;
		}
		
		public function set blendMethod(value:uint):void
		{
			_blendMethod = value;
		}
		
		public function get blendMethod():uint
		{
			return _blendMethod;
		}
		
		public function get currentDuration():Number
		{
			return _currentState._node._duration;
		}
		
		public function set updateAllStates(value:Boolean):void
		{
			_updateAllStates = value;
		}
		
		public function get updateAllStates():Boolean
		{
			return _updateAllStates;
		}
		
		public function get animations():Vector.<AnimationNode>
		{
			return _animations;
		}
		
		public function get states():Vector.<AnimationState>
		{
			return _animationState;
		}

		private function initStateList():void
		{
			_animationState = new Vector.<AnimationState>();
			
			for each(var node:AnimationNode in _animationSet._anmList)			
			{
				var state:AnimationState = new AnimationState(node);
				
				_animationStateDict[node.name] = state; 
				_animationState.push(state);
			}						
		}
		
		override public function reset(name:String, offset:Number=0):void
		{
			getStateByName(name)._offset = _time + offset;
		}
		
		public function getState(node:AnimationNode):AnimationState
		{
			return _animationStateDict[node.name];
		}
		
		public function getStateByName(name:String="root"):AnimationState
		{
			return _animationStateDict[name];
		}
		
		public function getNodeByName(name:String="root"):AnimationNode
		{
			return _animationSet.getAnimationByName(name);
		}

		public function isRepeat(name:String="root"):Boolean
		{
			return _animationSet.getAnimationByName(name).repeat;
		}
		
		protected function updateAnimationFrame(frame:AnimationFrame, kind:Object):void
		{
			
		}
					
		override protected function setAnimation(name:String, blendSpeed:Number):void
		{
			if (_currentAnimation)
			{
				var prevState:AnimationState = getStateByName(_currentAnimation);
				prevState.oldWeight = prevState._weight;			
			}
			
			_currentState = getStateByName(name);
			
			if (_currentState)
			{
				_currentState.positiveTime = _currentState._time > 0;
			}
			
			super.setAnimation(name, blendSpeed);
		}
		
		protected function getReference(name:String):uint
		{
			return 0; // InterpolationMethod.LINEAR
		}
		
		override public function update(time:Number):void
		{
			super.update(time);
			
			updateState();
			updateAnimation();
		}
		
		protected function updateCurrentOffset(time:Number):void
		{
			_currentState._offset = 0;
		}
		
		override public function updateAbsolute(time:Number, delta:Number):void
		{
			super.updateAbsolute(time, delta);
			
			updateCurrentOffset(0);
			
			updateState();
			updateAnimation();
		}
		
		/**
		 * Updates animation state.
		 * */
		public function updateState():void
		{
			var state:AnimationState;
			
			_currentState.time = _time - _currentState._offset;
			
			if (_currentState._weight < 1 && _blendSpeed > 0)
			{
				var delta:Number = Math.abs(_delta) / (1000.0 * _blendSpeed);				
				var weight:Number = 1;
				
				if (_blendMethod === AnimationBlendMethod.EASING)
					delta *= _easeSpeed;
				
				for each(state in _animationState)
				{
					if (state !== _currentState)
					{
						if (_blendMethod === AnimationBlendMethod.LINEAR)
							state._weight -= delta;
						else if (_blendMethod === AnimationBlendMethod.EASING)
							state._weight -= state._weight * delta;
												
						if (state._weight < 0) 
							state._weight = 0;
						
						weight -= state._weight;
						
						if (_updateAllStates)
						{
							state._node.time = _time - state._offset;
						}
					}
				}
				
				if (weight < 0)				
					weight = 0;
				
				_currentState._weight = weight;
			}
			else
			{
				for each(state in _animationState)
				{
					if (state === _currentState)
						state._weight = 1;
					else
					{
						state._weight = 0;
						
						if (_updateAllStates)
						{
							state._node.time = _time;
						}
					}
				}
			}
		}
		
		/**
		 * Updates state of the animations in objects.
		 * */
		public function updateAnimation():void
		{
			var dataCount:int = _animationSet._dataCount;
			var anmList:Vector.<AnimationNode> = _animationSet._anmList;
			
			var frame:AnimationFrame, 
				node:AnimationNode, 
				state:AnimationState, 
				data:AnimationData, 
				iFunc:Function;
				
			var currentNode:AnimationNode = _currentState._node;			
			var defaultIntrpl:Function = currentNode.intrpl ? _defaultIntrpl : MathHelper.empyNx;
			
			if (notifyTransitionCompleted && _currentState._weight == 1 && !calledTransitionCompleted)
			{
				dispatchEvent(new AnimationEvent(AnimationEvent.TRANSITION_COMPLETE));
				calledTransitionCompleted = true;
			}
			
			for(var i:int=0;i<dataCount;i++)			
			{
				for(var n:int=0;n<anmList.length;n++)
				{
					node = anmList[n];
					state = _animationState[n];
					data = node._dataList[i];
					iFunc = defaultIntrpl || _intrplFuncs[data._kind];
					
					if (n == 0) 
					{		
						frame = currentNode._getInterpolationFrame(currentNode._dataList[i], iFunc);
						
						if (!currentNode._repeat)
						{
							if (_timeScale > 0 && currentNode.position == 1)
							{
								state._offset = _time - currentNode._duration;
								
								if (_currentState.notifyCompleted)
									_currentState.dispatchComplete();
							}
							else if (_timeScale < 0 && currentNode.position == 0)
							{
								state._offset = state.positiveTime ? _time : _time + currentNode._duration;								
								
								if (_currentState.notifyCompleted)
									_currentState.dispatchComplete();								
							}
						}
					}
					
					if (node != currentNode)
					{
						if (state._weight > 0)
						{													
							iFunc
								(
									frame.data, 
									node._getInterpolationFrame(data,iFunc).data, 
									state._weight
								);	
						}
					}
				}
				
				updateAnimationFrame(frame, data._kind);
			}				
		}				
	}
}