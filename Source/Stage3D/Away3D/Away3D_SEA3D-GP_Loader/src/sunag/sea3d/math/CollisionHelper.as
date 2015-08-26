package sunag.sea3d.math
{
	import flash.geom.Vector3D;
	
	import sunag.sea3d.framework.Object3D;

	public class CollisionHelper
	{
		public static function hitTestBox(objA:Object3D, objB:Object3D):Boolean
		{
			var c1:flash.geom.Vector3D = MathHelper.centerBounds(objA.min, objA.max);
			var c2:flash.geom.Vector3D = MathHelper.centerBounds(objB.min, objB.max);
			
			c1 = MathHelper.rotateBounds(c1, objA.rotation, objA.scale);
			c2 = MathHelper.rotateBounds(c2, objB.rotation, objB.scale);
			
			c1.x = c1.x < 0 ? -c1.x : c1.x;
			c1.y = c1.y < 0 ? -c1.y : c1.y;
			c1.z = c1.z < 0 ? -c1.z : c1.z;
			
			c2.x = c2.x < 0 ? -c2.x : c2.x;
			c2.y = c2.y < 0 ? -c2.y : c2.y;
			c2.z = c2.z < 0 ? -c2.z : c2.z;
			
			return MathHelper.hitTestBox(objA.globalPosition, c1, objB.globalPosition, c2);
		}
	}
}