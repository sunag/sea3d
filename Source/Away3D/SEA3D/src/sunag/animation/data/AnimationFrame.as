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

package sunag.animation.data
{
	import flash.geom.Vector3D;
	
	import sunag.sunag;
	import sunag.utils.MathHelper;

	use namespace sunag;
	
	public class AnimationFrame
	{
		public var data:Vector.<Number>;
		
		private static const _v:Vector3D = new Vector3D();
		
		public function AnimationFrame()
		{
			data = new Vector.<Number>(4,true);
		}
		
		public function toVector3D():Vector3D
		{
			_v.x = data[0];
			_v.y = data[1];
			_v.z = data[2];		
			return _v;
		}
		
		public function toEuler():Vector3D
		{
			var x:Number = data[0], 
				y:Number = data[1], 
				z:Number = data[2], 
				w:Number = data[3],
				d:Number = MathHelper.DEGREES;
			
			var a:Number = 2 * (w * y - z * x);
			
			if (a < -1) a = -1;
			else if (a > 1) a = 1; 
			
			_v.x = Math.atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y)) * d;
			_v.y = Math.asin(a) * d;
			_v.z = Math.atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z)) * d;
			
			return _v;
		}
		
		public function toRadians():Vector3D
		{
			var x:Number = data[0], 
				y:Number = data[1], 
				z:Number = data[2], 
				w:Number = data[3];
			
			var a:Number = 2 * (w * y - z * x);
			
			if (a < -1) a = -1;
			else if (a > 1) a = 1; 
			
			_v.x = Math.atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y));
			_v.y = Math.asin(a);
			_v.z = Math.atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z));
			
			return _v;
		}
		
		public function toVector4D():Vector3D
		{
			_v.x = data[0];
			_v.y = data[1];
			_v.z = data[2];
			_v.w = data[3];
			return _v;
		}
		
		public function set x(value:Number):void { data[0] = value; }
		public function get x():Number { return data[0] }
		
		public function set y(value:Number):void { data[1] = value; }
		public function get y():Number { return data[1] }
		
		public function set z(value:Number):void { data[2] = value; }
		public function get z():Number { return data[2] }
		
		public function set w(value:Number):void { data[3] = value; }
		public function get w():Number { return data[3] }
		
		public function toString():String
		{
			var list:Array = [];
			
			for each (var v:Number in data)			
				list.push(v.toString());					
				
			return "AnimationFrame(" + list.join(", ") + ")";
		}
	}
}