package sunag.sea3d.math
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import away3d.core.math.Matrix3DUtils;
	import away3d.core.math.Vector3DUtils;
	
	public class MathHelper
	{
		public static const RADIANS:Number = Math.PI/180;
		public static const DEGREES:Number = 180/Math.PI;
		
		public static function centerBounds(min:flash.geom.Vector3D, max:flash.geom.Vector3D):flash.geom.Vector3D
		{
			return new flash.geom.Vector3D
			(			
				min.x + (max.x - min.x) * .5,
				min.y + (max.y - min.y) * .5,
				min.z + (max.z - min.z) * .5
			);
		}
		
		public static function normalRotation(normal:flash.geom.Vector3D, up:flash.geom.Vector3D=null):flash.geom.Vector3D
		{
			var m:Matrix3D = new Matrix3D(Matrix3DUtils.RAW_DATA_CONTAINER);
			m.identity();
			
			Matrix3DUtils.lookAt(m, new flash.geom.Vector3D(), normal, up || flash.geom.Vector3D.Y_AXIS);
			
			var r:flash.geom.Vector3D = m.decompose()[1];
			r.scaleBy(DEGREES);
			
			return r;
		}
		
		public static function rotateBounds(bounds:flash.geom.Vector3D, rotation:flash.geom.Vector3D, scale:flash.geom.Vector3D=null):flash.geom.Vector3D
		{
			var out:flash.geom.Vector3D = bounds.clone();
			
			if (scale)
			{
				out.x *= scale.x;
				out.y *= scale.y;
				out.z *= scale.z;
			}
			
			Vector3DUtils.rotatePoint(out, rotation);			
			
			return out;
		}
		
		public static function rotatePoint(point:flash.geom.Vector3D, rotation:flash.geom.Vector3D):flash.geom.Vector3D
		{
			return Vector3DUtils.rotatePoint(point, rotation);
		}
		
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
		
		public static function zero(val:Number, precision:Number):Number
		{
			precision = Math.pow(10, precision);
			var pValue:Number = val < 0 ? -val : val;			
			if (pValue - precision < 0) val = 0;			
			return val;			
		}
		
		public static function round(val:Number, precision:Number):Number
		{			
			precision = Math.pow(10, precision);
			return Math.round(val * precision) / precision;
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
			
			num--;
			num |= num >> 1;
			num |= num >> 2;
			num |= num >> 4;
			num |= num >> 8;
			num |= num >> 16;
			
			return num++;
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
		
		public static function lerp(val:Number, tar:Number, t:Number):Number
		{
			return val + ((tar - val) * t);
		}
						
		public static function lerpColor(val:Number, tar:Number, t:Number):Number
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
		
		public static function physicLerp(val:Number, to:Number, delta:Number, speed:Number):Number			
		{
			return val + ( (to - val) * (speed * delta) );
		}
		
		public static function physicLerpAngle(val:Number, to:Number, delta:Number, speed:Number):Number			
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
			
			return angle( val + ( (to - val) * (speed * delta) ) );			
		}
		
		public static function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x1-x2;
			var dy:Number = y1-y2;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		public static function direction(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			return Math.atan2(y2 - y1, x2 - x1);
		}
		
		public static function hitTestBox(objA:flash.geom.Vector3D, aMax:flash.geom.Vector3D, objB:flash.geom.Vector3D, bMax:flash.geom.Vector3D):Boolean
		{
			if(objA.x + aMax.x < objB.x - bMax.x
				|| objA.x - aMax.x > objB.x + bMax.x) {
				return false;
			} else if(objA.y + aMax.y < objB.y - bMax.y
				|| objA.y - aMax.y > objB.y + bMax.y) {
				return false;
			} else if(objA.z + aMax.z < objB.z - bMax.z
				|| objA.z - aMax.z > objB.z + bMax.z) {
				return false;
			}
			
			return true;
		}
	}
}