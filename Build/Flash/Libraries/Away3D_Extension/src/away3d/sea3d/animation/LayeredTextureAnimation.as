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
	import sunag.animation.AnimationSet;
	import sunag.animation.data.AnimationFrame;
	import sunag.sunag;
	
	use namespace sunag;
	
	public class LayeredTextureAnimation extends Animation
	{
		protected var _texture:LayeredTexture;
		
		public function LayeredTextureAnimation(animationSet:AnimationSet, texture:LayeredTexture)
		{
			super(animationSet);			
			_texture = texture;
		}
		
		public function set layeredTexture(value:LayeredTexture):void
		{
			_texture = value;
		}
		
		public function get layeredTexture():LayeredTexture
		{
			return _texture;
		}
		
		override protected function updateAnimationFrame(frame:AnimationFrame, kind:Object):void			
		{
			switch(kind)					
			{
				case Animation.OFFSET_U:						
					_texture.offsetU = frame.x;					
					break;							
				case Animation.OFFSET_V:
					_texture.offsetV = frame.x;
					break;					
				case Animation.SCALE_U:						
					_texture.scaleU = frame.x;		
					break;
				case Animation.SCALE_V:						
					_texture.scaleV = frame.x;
					break;
				case Animation.ALPHA:						
					_texture.alpha = frame.x;
					break;
			}
		}				
	}
}