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

package away3d.filters.tasks
{
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	import flash.geom.Vector3D;

	public class Filter3DColorBalanceTask extends Filter3DTaskBase
	{
		private var _data : Vector.<Number>;
		
		private var _preserveLuminance:Boolean;
		
		public function Filter3DColorBalanceTask(preserveLuminance:Boolean=false)
		{
			super();
			
			_data = new Vector.<Number>(24,true);
			
			// fc3
			_data[12] = amount;			// x
			_data[13] = Math.PI / 180;	// y
			_data[14] = 180; 			// z
			
			// fc4
			_data[16] = 1;// x			
			_data[17] = 2;// y
			_data[18] = 3;// z
			_data[19] = 4;// w
			
			// fc5
			_data[20] = 5;// x
			
			this.shadows = new Vector3D();// fc0
			this.midtones = new Vector3D(); // fc1
			this.highlights = new Vector3D(); // fc2			
			
			_preserveLuminance = preserveLuminance;	
		}
		
		public function set shadows(value:Vector3D):void
		{
			setVector3D(0, value);
		}
		
		public function get shadows():Vector3D
		{
			return getVector3D(0);
		}
		
		public function set midtones(value:Vector3D):void
		{
			setVector3D(4, value);
		}
		
		public function get midtones():Vector3D
		{
			return getVector3D(4);
		}
		
		public function set highlights(value:Vector3D):void
		{
			setVector3D(8, value);
		}
		
		public function get highlights():Vector3D
		{
			return getVector3D(8);
		}
		
		public function set amount(value:Number):void
		{
			_data[12] = value;
		}				
		
		public function get amount():Number
		{
			return _data[12];
		}
		
		public function get preserveLuminance():Boolean
		{
			return _preserveLuminance;
		}
		
		private function setVector3D(index:int, value:Vector3D):void
		{
			_data[index++] = value.x;
			_data[index++] = value.y;
			_data[index] = value.z;
		}
		
		private function getVector3D(index:int):Vector3D
		{
			var x:Number = _data[index++];
			var y:Number = _data[index++];
			var z:Number = _data[index];
			
			return new Vector3D(x,y,z);
		}
		
		override protected function getFragmentCode() : String
		{
			// ft1.w = intensity
			// ft1.x = shadowsBleed
			// ft1.y = midtonesBleed
			// ft1.z = highlightsBleed
			
			var code:Array = 
				[
					// get source_colors
					"tex ft0, v0, fs0 <2d,linear,clamp>",
					
					// get intensity
					"add ft1.w, ft0.x, ft0.y",// ft1.w = ft0.r + ft0.g
					"add ft1.w, ft1.w, ft0.z",// ft1.w = ft1.w + ft0.b
					"div ft1.w, ft1.w, fc4.z",// ft1.w = ft1.w / 3.0
					
					// get shadowsBleed
					"sub ft2.x, ft1.w, fc4.x",// ft2.x = intensity-1.0
					"mul ft2.y, ft2.x, ft2.x",// ft2.y = ft2.x * ft2.x
					"div ft1.x, ft2.y, fc4.y",// ft1.x = ft2.y * 2.0
					
					// get midtonesBleed
					"mul ft2.x, ft1.w, fc3.z",// ft2.x = intensity*180.0
					"mul ft2.y, fc3.y, ft2.x",// ft2.y = (PI/180) * ft2.x
					"sin ft2.y, ft2.y",		  // ft2.y = sin(ft2.y)
					"div ft1.y, ft2.y, fc4.w",// ft1.y = ft2.y / 4.0
					
					// get highlightsBleed
					"mul ft2.x, ft1.w, ft1.w",// ft2.x = intensity * intensity
					"div ft1.z, ft2.x, fc4.y",// ft1.z = ft2.x / 2.0
					
					// get colorization = ft2
					"mul ft2, fc0, ft1.x",// shadows*shadowsBleed
					"mul ft3, fc1, ft1.y",// midtones*midtonesBleed
					"mul ft4, fc2, ft1.z",// highlights*highlightsBleed
					"add ft5, ft2, ft3",  //  = shadows+midtones
					"add ft5, ft5, ft4",  // += highlights
					"add ft2, ft5, ft0",  // += source_colors
					
					// move cost to variable
					"mov ft6.x, fc3.x" // ft6.x = amount
				];
						
			if (_preserveLuminance)
			{
				code.push
					(
						"mul ft6.x, ft6.x, fc5.x",//  = amount*5.0
						"mul ft6.x, ft6.x, ft1.w" // += intensity*intensity
					);
			}
						
			code.push
				(
					// mix(source_colors, colorization, amount)
					// mix(ft0, ft2, ft6.x)
					"mul ft7, ft2, ft6.x",    // dt7 = colorization * amount
					"sub ft6.y, fc4.x, ft6.x",// ft6.y = 1.0 - amount					
					"mul ft0, ft0, ft6.y",	  // ft0 = source_colors * ft6.y
					"add ft0, ft0, ft7",	  // ft0 = ft0 * dt7
					
					// move result to output
					"mov oc, ft0"
				);
			
			return code.join("\n");
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{				
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, 6);
		}
	}
}
