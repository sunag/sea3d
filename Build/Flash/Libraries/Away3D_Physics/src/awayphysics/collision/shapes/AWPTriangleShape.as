package awayphysics.collision.shapes 
{
	import AWPC_Run.CModule;
	import AWPC_Run.createTriangleShapeInC;
	import awayphysics.math.AWPVector3;
	import flash.geom.Vector3D;
	
	public class AWPTriangleShape extends AWPCollisionShape 
	{
		private var _point0:Vector3D;
		private var _point1:Vector3D;
		private var _point2:Vector3D;
		
		public function AWPTriangleShape(p0:Vector3D, p1:Vector3D, p2:Vector3D)
		{
			_point0 = p0.clone();
			_point1 = p1.clone();
			_point2 = p2.clone();
			var vec1:AWPVector3 = new AWPVector3();
			vec1.sv3d = p0;
			var vec2:AWPVector3 = new AWPVector3();
			vec2.sv3d = p1;
			var vec3:AWPVector3 = new AWPVector3();
			vec3.sv3d = p2;
			pointer = createTriangleShapeInC(vec1.pointer, vec2.pointer, vec3.pointer);
			CModule.free(vec1.pointer);
			CModule.free(vec2.pointer);
			CModule.free(vec3.pointer);
			super(pointer, 6);
		}
		
		public function get point0():Vector3D{
			return _point0;
		}
		
		public function get point1():Vector3D{
			return _point1;
		}
		
		public function get point2():Vector3D{
			return _point2;
		}
	}
}