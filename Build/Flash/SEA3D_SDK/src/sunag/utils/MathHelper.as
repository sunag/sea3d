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

package sunag.utils
{
	import flash.geom.Vector3D;

	public class MathHelper
	{
		public static const DEGREES : Number = 180 / Math.PI;
		public static const RADIANS : Number = Math.PI / 180;
		
		public static function angleDifferenceRad(x:Number, y:Number):Number
		{
			return Math.atan2(Math.sin(x-y), Math.cos(x-y));
		}
		
		public static function angleDifference(x:Number, y:Number):Number
		{
			x = x * RADIANS;
			y = y * RADIANS;
			return Math.atan2(Math.sin(x-y), Math.cos(x-y)) * DEGREES;
		}
		
		public static function angleArea(angle:Number, target:Number, area:Number):Boolean
		{
			return Math.abs( angleDifference(angle,target) ) <= area;
		}
				
		public static function zero(val:Number, lim:Number=1.0E-3):Number
		{
			var pValue:Number = val < 0 ? -val : val;			
			if (pValue - lim < 0) val = 0;			
			return val;			
		}
		
		public static function round(val:Number, lim:Number=1E-6):Number
		{			
			return Math.round(val * lim) / lim;
		}	
		
		public static function isPowerOfTwo(num:uint):Boolean
		{			
			return num ? ((num & -num) == num) : false;
		}
		
		public static function nearestPowerOfTwo(num:uint):uint
		{
			return Math.pow( 2, Math.round( Math.log( num ) / Math.LN2 ) );
		}
		
		public static function lowerPowerOfTwo(num:uint):uint
		{
			return upperPowerOfTwo(num) >> 1;
		}
		
		public static function upperPowerOfTwo(num:uint):uint
		{
			if (num == 1) return 2;
			
			--num;
			num |= num >> 1;
			num |= num >> 2;
			num |= num >> 4;
			num |= num >> 8;
			num |= num >> 16;
						
			return ++num;
		}
		
		public static function angleLimit(val:Number, lim:Number):Number			
		{
			if (val > lim) val = lim;
			else if (val < -lim) val = -lim;
			return val;
		}
		
		public static function angle(val:Number):Number			
		{
			const ang:Number = 180;
			var inv:Boolean = val < 0;
			
			val = (inv ? -val : val) % 360;
			
			if (val > ang)			
			{
				val = -ang + (val - ang);
			}
			
			return (inv ? -val : val);			
		}
		
		public static function invertAngle(val:Number):Number
		{
			return angle(val + 180);
		}
		
		public static function absAngle(val:Number):Number
		{
			if (val < 0) return 180 + (180 + val);										
			return val;
		}
		
		public static function angleBetweenVector3D(vec0:Vector3D, vec1:Vector3D, axis:Vector3D=null):Number
		{			
			axis = axis || Vector3D.Y_AXIS;
			if (axis == Vector3D.Y_AXIS) return Math.atan2(vec0.x - vec1.x, vec0.z - vec1.z);
			else if (axis == Vector3D.X_AXIS) return Math.atan2(vec0.y - vec1.y, vec0.z - vec1.z);
			return Math.atan2(vec0.x - vec1.x, vec0.y - vec1.y);
		}
		
		public static function lerp(val:Number, tar:Number, t:Number):Number
		{
			return val + ((tar - val) * t);
		}
		
		public static function lerpVector3D(val:Vector3D, tar:Vector3D, t:Number):Vector3D
		{
			return new Vector3D(
				val.x + ((tar.x - val.x) * t),
				val.y + ((tar.y - val.y) * t),
				val.z + ((tar.z - val.z) * t));
		}
		
		public static function lerpColor(val:uint, tar:uint, t:Number):uint
		{
			var a0:Number = val >> 24 & 0xff;
			var r0:Number = val >> 16 & 0xff;
			var g0:Number = val >> 8 & 0xff;
			var b0:Number = val & 0xff;
			
			var a1:Number = tar >> 24 & 0xff;
			var r1:Number = tar >> 16 & 0xff;
			var g1:Number = tar >> 8 & 0xff;
			var b1:Number = tar & 0xff;
			
			a0 += (a1 - a0) * t;
			r0 += (r1 - r0) * t;
			g0 += (g1 - g0) * t;
			b0 += (b1 - b0) * t;
			
			return a0 << 24 | r0 << 16 | g0 << 8 | b0;
		}
		
		public static function lerpAngle(val:Number, tar:Number, t:Number):Number			
		{				
			if (Math.abs(val - tar) > 180)
			{
				if (val > tar) 
				{		
					tar += 360;				
				}
				else 
				{
					tar -= 360;				
				}
			}
			
			val += (tar - val) * t;
			
			return angle(val);
		}			
		
		public static function colorToVector3D(val:uint):Vector3D
		{
			return new Vector3D
			(
				val >> 16 & 0xff,
				val >> 8 & 0xff,
				val & 0xff,
				val >> 24 & 0xff
			);
		}
		
		public static function vector3DToColor(val:Vector3D):uint
		{
			return val.w << 24 | val.x << 16 | val.y << 8 | val.z;
		}				
		
		public static function empyNx(val:Vector.<Number>, tar:Vector.<Number>, t:Number):void {};
		
		public static function lerp1x(val:Vector.<Number>, tar:Vector.<Number>, t:Number):void
		{
			val[0] += (tar[0] - val[0]) * t;
		}
		
		public static function lerp3x(val:Vector.<Number>, tar:Vector.<Number>, t:Number):void 
		{
			val[0] += (tar[0] - val[0]) * t;			
			val[1] += (tar[1] - val[1]) * t;
			val[2] += (tar[2] - val[2]) * t;
		}
		
		public static function lerpAng1x(val:Vector.<Number>, tar:Vector.<Number>, t:Number):void
		{
			val[0] = lerpAngle(val[0], tar[0], t);
		}		
						
		public static function lerpColor1x(val:Vector.<Number>, tar:Vector.<Number>, t:Number):void
		{
			val[0] = lerpColor(val[0], tar[0], t);
		}
		
		public static function lerpQuat4x(val:Vector.<Number>, tar:Vector.<Number>, t:Number):void
		{				
			var x1 : Number = val[0], 
				y1 : Number = val[1], 
				z1 : Number = val[2],
				w1 : Number = val[3];
			
			var x2 : Number = tar[0], 
				y2 : Number = tar[1], 
				z2 : Number = tar[2],
				w2 : Number = tar[3];
			
			var x : Number, y : Number, z : Number, w : Number, l : Number;
			
			// shortest direction
			if (x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2 < 0) {				
				x2 = -x2;
				y2 = -y2;
				z2 = -z2;
				w2 = -w2;
			}
						
			x = x1 + t * (x2 - x1);
			y = y1 + t * (y2 - y1);
			z = z1 + t * (z2 - z1);
			w = w1 + t * (w2 - w1);
			
			l = 1.0 / Math.sqrt(w * w + x * x + y * y + z * z);			
			val[0] = x * l;
			val[1] = y * l;
			val[2] = z * l;
			val[3] = w * l;
		}
		
		public static function toBinary(val:uint, len:Number=8):Vector.<int> 
		{
			var result:Vector.<int> = new Vector.<int>(length);
			
			for (var i:int=length-1; i >= 0; i--) 
			{
				if ((val - Math.pow(2,i)) >= 0) 
				{
					result[i] = 1;
					len -= Math.pow(2,i);
				}
			}
			
			return result;
		}
		
		public static function ease(val:Number, to:Number, smothness:Number):Number	
		{
			return val + (to - val) / smothness;
		}
		
		public static function physicLerp(val:Number, to:Number, deltaTime:Number, duration:Number):Number			
		{
			var t:Number = deltaTime/duration;			
			if (t > 1) t = 1;
				
			return val + ((to - val) * t);
		}	
		
		public static function physicLerpAngle(val:Number, to:Number, deltaTime:Number, duration:Number):Number			
		{				
			if (Math.abs(val - to) > 180)
			{
				if (val > to) 
				{		
					to += 360;				
				}
				else 
				{
					to -= 360;				
				}
			}
			
			var t:Number = deltaTime/duration;			
			if (t > 1) t = 1;
			
			return angle( val + ((to - val) * t) );			
		}
		
		// http://away3d.com/forum/viewthread/797/
		public static function scaleByFOV(FOV:Number, distance:Number, viewHeight:Number):Number
		{
			// focal length is the position where objects are seen at their 
			// natural size on the screen
			// fLength = viewHeight / 2 arctan(radianFOV)
			var fl:Number = viewHeight / (2 * Math.tan(FOV * (180 / Math.PI)));
			// scale = fLength / (fLength + distanceFromViewer);
			return 1 / (fl / (fl + distance));
		} 
	}
}