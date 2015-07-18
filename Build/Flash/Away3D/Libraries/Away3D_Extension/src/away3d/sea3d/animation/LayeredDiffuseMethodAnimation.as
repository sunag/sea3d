/*
*
* Copyright (c) 2012 Sunag Entertainment
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

package away3d.sea3d.animation
{
	import away3d.materials.methods.LayeredTexture;
	
	import sunag.animation.Animation;
	import sunag.animation.AnimationGroup;
	import sunag.animation.AnimationSet;
	import sunag.animation.data.AnimationFrame;
	import sunag.sunag;
	
	use namespace sunag;
	
	public class LayeredDiffuseMethodAnimation extends AnimationGroup
	{
		protected var _layers:Vector.<LayeredTexture>;
		
		public function LayeredDiffuseMethodAnimation(animationSetList:Vector.<AnimationSet>, layers:Vector.<LayeredTexture>)
		{
			super(animationSetList);			
			_layers = layers;
		}
		
		public function set layers(value:Vector.<LayeredTexture>):void
		{
			_layers = value;
		}
		
		public function get layers():Vector.<LayeredTexture>
		{
			return _layers;
		}
		
		override protected function updateAnimationFrame(frame:AnimationFrame, kind:Object):void			
		{
			var tex:LayeredTexture = _layers[_animationSetIndex];
			
			switch(kind)					
			{
				case Animation.OFFSET_U:						
					tex.offsetU = frame.x;					
					break;							
				case Animation.OFFSET_V:
					tex.offsetV = frame.x;
					break;					
				case Animation.SCALE_U:						
					tex.scaleU = frame.x;		
					break;
				case Animation.SCALE_V:						
					tex.scaleV = frame.x;
					break;
				case Animation.ALPHA:						
					tex.alpha = frame.x;
					break;
			}
		}				
	}
}