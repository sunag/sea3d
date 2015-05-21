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
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	
	import sunag.sunag;
	import sunag.animation.Animation;
	import sunag.animation.AnimationSet;
	import sunag.animation.data.AnimationFrame;
	
	use namespace sunag;
	
	public class PointLightAnimation extends LightAnimationBase
	{
		protected var _pointLight:PointLight;
		
		public function PointLightAnimation(light:PointLight, animationSet:AnimationSet)
		{
			super(_pointLight = light, animationSet);	
		}
				
		public override function set light(value:LightBase):void
		{
			super.light = _pointLight = value as PointLight;
		}
		
		override protected function updateAnimationFrame(frame:AnimationFrame, kind:Object):void	
		{
			switch(kind)					
			{
				case Animation.POSITION:						
					if (_relative) 
					{
						_light.animateTransform.position = frame.toVector3D();
						_light.animateTransform = _light.animateTransform;
					}
					else _light.position = frame.toVector3D();
					break;						
				
				case Animation.COLOR:									
					_light.color = frame.x;				
					break;
				case Animation.MULTIPLIER:		
					_light.diffuse = frame.x;
					break;
					
				case Animation.ATTENUATION_START:
					_pointLight.radius = frame.x;
					break;
				case Animation.ATTENUATION_END:
					_pointLight.fallOff = frame.x;
					break;	
			}
		}			
	}
}