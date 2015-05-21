package awayphysics.collision.shapes {
	import AWPC_Run.CModule;
	import AWPC_Run.createStaticPlaneShapeInC;
	
	import awayphysics.math.AWPVector3;
	
	import flash.geom.Vector3D;

	public class AWPStaticPlaneShape extends AWPCollisionShape {
		
		private var _normal:Vector3D;
		private var _constant:Number;
		
		public function AWPStaticPlaneShape(normal : Vector3D = null, constant : Number = 0) {
			if (!normal) {
				normal = new Vector3D(0, 1, 0);
			}
			_normal = normal;
			_constant = constant;
			
			var vec:AWPVector3 = new AWPVector3();
			vec.v3d = normal;
			pointer = createStaticPlaneShapeInC(vec.pointer, constant / _scaling);
			CModule.free(vec.pointer);
			super(pointer, 8);
		}
		
		public function get normal():Vector3D {
			return _normal;
		}
		
		public function get constant():Number {
			return _constant;
		}
	}
}