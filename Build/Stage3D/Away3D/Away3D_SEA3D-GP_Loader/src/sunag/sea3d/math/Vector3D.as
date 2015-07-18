package sunag.sea3d.math
{
	import flash.geom.Vector3D;
	
	import sunag.sea3dgp;
	
	use namespace sea3dgp;
	
	//
	//	TODO: Iterface Only
	//
	
	public class Vector3D
	{
		sea3dgp static const PROXY:Class = flash.geom.Vector3D;
		
		sea3dgp static const init:Boolean = (function():Boolean
		{
			PROXY.prototype.toColor = function():Number
			{
				return this.w << 24 | this.x << 16 | this.y << 8 | this.z;
			}
			
			PROXY.prototype.lerp = function(tar:Vector3D, t:Number):void
			{
				this.x = this.x + ((tar.x - this.x) * t);
				this.y = this.y + ((tar.y - this.y) * t);
				this.z = this.z + ((tar.z - this.z) * t);
			}
			
			PROXY.prototype.fromColor = function(color:Number):void
			{
				this.x = color >> 16 & 0xff;
				this.y = color >> 8 & 0xff;
				this.z = color & 0xff;
				this.w = color >> 24 & 0xff;
			}
			
			PROXY.prototype.angle = function(tar:Vector3D, axis:Vector3D=null):Number
			{
				axis = axis || Vector3D.Y_AXIS;
				if (axis == Vector3D.Y_AXIS) return Math.atan2(this.x - tar.x, this.z - tar.z);
				else if (axis == Vector3D.X_AXIS) return Math.atan2(this.y - tar.y, this.z - tar.z);
				return Math.atan2(this.x - tar.x, this.y - tar.y);
			}
		})();
		
		public static const X_AXIS:Vector3D = new Vector3D(1,0,0);
		public static const Y_AXIS:Vector3D = new Vector3D(0,1,0);
		public static const Z_AXIS:Vector3D = new Vector3D(0,0,1);			
		
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var w:Number;
		
		public function Vector3D(x:Number=0, y:Number=0, z:Number=0, w:Number=0)
		{
			this.x = x;
			this.y = y;
			this.z = z;
			this.w = w;
		}
		
		public function toColor():Number
		{
			return 0;
		}
		
		public function lerp(tar:Vector3D, t:Number):void
		{		
		}
		
		public function fromColor(color:Number):void
		{			
		}
		
		public function angle(tar:Vector3D, axis:Vector3D=null):Number
		{
			return 0;
		}
		
		public static function distance(v1:Vector3D, v2:Vector3D):Number
		{
			return 0;
		}				
	}
}