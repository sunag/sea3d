package awayphysics.collision.shapes {
	import flash.geom.Vector3D;
	
	import AWPC_Run.createBoxShapeInC;
	import AWPC_Run.CModule;
	
	import awayphysics.math.AWPVector3;
	
	public class AWPBoxShape extends AWPCollisionShape {
		
		private var _dimensions:Vector3D;
		
		public function AWPBoxShape(width : Number = 100, height : Number = 100, depth : Number = 100) {
			_dimensions = new Vector3D(width, height, depth);
			var vec:AWPVector3 = new AWPVector3();
			vec.sv3d = new Vector3D(width, height, depth);
			pointer = createBoxShapeInC(vec.pointer);
			CModule.free(vec.pointer);
			super(pointer, 0);
		}
		
		public function get dimensions():Vector3D {
			return new Vector3D(_dimensions.x * m_localScaling.x, _dimensions.y * m_localScaling.y, _dimensions.z * m_localScaling.z);
		}
	}
}