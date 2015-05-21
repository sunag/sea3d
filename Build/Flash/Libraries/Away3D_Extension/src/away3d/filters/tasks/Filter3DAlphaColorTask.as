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
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;

	public class Filter3DAlphaColorTask extends Filter3DTaskBase
	{
		private var _offset:Vector.<Number>;
		
		public function Filter3DAlphaColorTask()
		{
			super();
			
			_offset = new Vector.<Number>(4, true);
			_offset[0] = 0.00001;
		}
	
		override protected function getFragmentCode() : String
		{
			return "tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
				"sge ft0.x, ft0.xyz, fc0.x      		\n" +				
				"mov oc, ft0.x							\n";
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{				
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _offset, 1);
		}
	}
}
