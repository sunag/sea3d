package awayphysics.collision.shapes {
	import flash.geom.Vector3D;
	import AWPC_Run.CModule;
	import AWPC_Run.createCylinderShapeInC;
	import awayphysics.math.AWPVector3;

	public class AWPCylinderShape extends AWPCollisionShape {
		
		private var _radius:Number;
		private var _height:Number;
		
		public function AWPCylinderShape(radius : Number = 50, height : Number = 100) {
			
			_radius = radius;
			_height = height;
			
			var vec:AWPVector3 = new AWPVector3();
			vec.v3d = new Vector3D(radius * 2 / _scaling, height / _scaling, radius * 2 / _scaling)
			pointer = createCylinderShapeInC(vec.pointer);
			CModule.free(vec.pointer);
			super(pointer, 2);
		}
		
		public function get radius():Number {
			return _radius * m_localScaling.x;
		}
		
		public function get height():Number {
			return _height * m_localScaling.y;
		}
	}
}