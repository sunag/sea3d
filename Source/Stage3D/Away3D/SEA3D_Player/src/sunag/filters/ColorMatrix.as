/* Copyright (c) 2013 Sunag Entertainment
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE. */

package sunag.filters
{
	import flash.display.DisplayObject;
	import flash.filters.ColorMatrixFilter;
	
	public class ColorMatrix 
	{
		private var matrix : Array;
		
		public function ColorMatrix(saturation:Number=1,hue:Number=0) {
			identity();			
			if (saturation!==1) this.saturation = saturation;
			if (hue!==0) this.hue = hue;
		}
		
		private function identity() : void {
			matrix = [1, 0, 0, 0, 0,
				0, 1, 0, 0, 0,
				0, 0, 1, 0, 0,
				0, 0, 0, 1, 0];
		}
		
		public function reset() : void {
			identity();
		}
		
		public function set saturation(saturation : Number) : void {						
			var M1 : Array = [0.213, 0.715, 0.072,
				0.213, 0.715, 0.072,
				0.213, 0.715, 0.072];
			var M2 : Array = [0.787, -0.715, -0.072,
				-0.212, 0.285, -0.072,
				-0.213, -0.715, 0.928];
			var M3 : Array = add(M1, multiply(saturation, M2));
			
			concat([M3[0], M3[1], M3[2], 0, 0,
				M3[3], M3[4], M3[5], 0, 0,
				M3[6], M3[7], M3[8], 0, 0,
				0, 0, 0, 1, 0]);
		}
		
		private var _h : Number = 0;
		
		public function set hue(hue : Number) : void {
			_h = hue;
			hue = _h * 0.0174532925;
			
			var M1 : Array = [0.213, 0.715, 0.072,
				0.213, 0.715, 0.072,
				0.213, 0.715, 0.072];
			
			var M2 : Array = [0.787, -0.715, -0.072,
				-0.212, 0.285, -0.072,
				-0.213, -0.715, 0.928];
			
			var M3 : Array = [-0.213, -0.715, 0.928,
				0.143, 0.140, -0.283,
				-0.787, 0.715, 0.072];
			var M4 : Array = add(M1, add(multiply(Math.cos(hue), M2), multiply(Math.sin(hue), M3)));
			
			concat([M4[0], M4[1], M4[2], 0, 0,
				M4[3], M4[4], M4[5], 0, 0,
				M4[6], M4[7], M4[8], 0, 0,
				0, 0, 0, 1, 0]);
		}
		
		public function get hue() : Number {
			return _h;
		}
		
		private function add(A : Array, B : Array) : Array {
			var C : Array = [];
			for(var i : uint = 0;i < A.length;i++) {
				C.push(A[i] + B[i]);
			}
			return C;
		}
		
		private function multiply(x : Number, B : Array) : Array {
			var A : Array = [];
			for each(var n:Number in B) {
				if(n == 0)
					A.push(0);
				else
					A.push(x * n);
			}
			return A;
		}
		
		private function concat(B : Array) : void {
			var nM : Array = [];
			var A : Array = matrix;
			
			nM[0] = (A[0] * B[0]) + (A[1] * B[5]) + (A[2] * B[10]);
			nM[1] = (A[0] * B[1]) + (A[1] * B[6]) + (A[2] * B[11]);
			nM[2] = (A[0] * B[2]) + (A[1] * B[7]) + (A[2] * B[12]);
			nM[3] = 0;
			nM[4] = 0;
			
			nM[5] = (A[5] * B[0]) + (A[6] * B[5]) + (A[7] * B[10]);
			nM[6] = (A[5] * B[1]) + (A[6] * B[6]) + (A[7] * B[11]);
			nM[7] = (A[5] * B[2]) + (A[6] * B[7]) + (A[7] * B[12]);
			nM[8] = 0;
			nM[9] = 0;
			
			nM[10] = (A[10] * B[0]) + (A[11] * B[5]) + (A[12] * B[10]);
			nM[11] = (A[10] * B[1]) + (A[11] * B[6]) + (A[12] * B[11]);
			nM[12] = (A[10] * B[2]) + (A[11] * B[7]) + (A[12] * B[12]);
			nM[13] = 0;
			nM[14] = 0;
			
			nM[15] = 0;
			nM[16] = 0;
			nM[17] = 0;
			nM[18] = 1;
			nM[19] = 0;
			
			matrix = nM;
		}
		
		public function get filter() : ColorMatrixFilter {
			return new ColorMatrixFilter(matrix);
		}
		
		public static function setSaturation(obj:DisplayObject, value:Number=1):void
		{
			obj.filters = value===1?[]:[new ColorMatrix(value).filter];
		}
	}
}