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
	import flash.filters.ColorMatrixFilter;

	public class Filter3DColorMatrixTask extends Filter3DTaskBase
	{
		private var _colors:Vector.<Number>; 
		private var _offset:Vector.<Number>;
		
		private var _filter:ColorMatrixFilter;
		
		public function Filter3DColorMatrixTask(filter : ColorMatrixFilter = null)
		{
			super();
			
			_filter = filter ? filter : new ColorMatrixFilter();
			
			_colors = new Vector.<Number>(16, true);	
			_offset = new Vector.<Number>(4, true);
		}
	
		public function get colorMatrixFilter():ColorMatrixFilter
		{
			return _filter;
		}
		
		public function set colorMatrixFilter(filter:ColorMatrixFilter):void
		{
			_filter = filter;
		}
		
		override protected function getFragmentCode() : String
		{
			return "tex ft0, v0, fs0 <2d,linear,clamp>	\n" +
				"m44 ft0, ft0, fc1						\n" +
				"add ft0, ft0, fc0						\n" +
				"mov oc, ft0							\n";
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera3D : Camera3D, depthTexture : Texture) : void
		{	
			var matrix:Array = _filter.matrix;
			// r
			_colors[0] = matrix[0];
			_colors[1] = matrix[1];
			_colors[2] = matrix[2];
			_colors[3] = matrix[3];
			_offset[0] = matrix[4];
			// g
			_colors[4] = matrix[5];
			_colors[5] = matrix[6];
			_colors[6] = matrix[7];
			_colors[7] = matrix[8];
			_offset[1] = matrix[9];
			// b
			_colors[8] = matrix[10];
			_colors[9] = matrix[11];
			_colors[10] = matrix[12];
			_colors[11] = matrix[13];
			_offset[2] = matrix[14];
			// a
			_colors[12] = matrix[15];
			_colors[13] = matrix[16];
			_colors[14] = matrix[17];
			_colors[15] = matrix[18];
			_offset[3] = matrix[19];
			
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _offset, 1);
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _colors, 4);
		}
	}
}
