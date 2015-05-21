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
	import flash.geom.ColorTransform;

	public class Filter3DColorTransformTask extends Filter3DTaskBase
	{				
		private var _filter : ColorTransform;
		private var _data : Vector.<Number>;
		
		public function Filter3DColorTransformTask(filter : ColorTransform = null)
		{
			super();
			
			_filter = filter ? filter : new ColorTransform();
			
			_data = new Vector.<Number>(8, true);
		}
	
		public function get colorTransform():ColorTransform
		{
			return _filter;
		}
		
		public function set colorTransform(filter:ColorTransform):void
		{
			_filter = filter;
		}
		
		override protected function getFragmentCode() : String
		{
			return "tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
				"mul ft0, ft0, fc0						\n" +
				"add ft0, ft0, fc1						\n" +
				"mov oc, ft0							\n";
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{	
			var inv : Number = 1/0xff;
			_data[0] = _filter.redMultiplier;
			_data[1] = _filter.greenMultiplier;
			_data[2] = _filter.blueMultiplier;
			_data[3] = _filter.alphaMultiplier;
			_data[4] = _filter.redOffset*inv;
			_data[5] = _filter.greenOffset*inv;
			_data[6] = _filter.blueOffset*inv;
			_data[7] = _filter.alphaOffset*inv;
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, 2);
		}
	}
}
