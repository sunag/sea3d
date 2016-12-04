package awayphysics.dynamics.constraintsolver {
	import AWPC_Run.CModule;
	import AWPC_Run.createP2PConstraint1InC;
	import AWPC_Run.createP2PConstraint2InC;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.math.AWPVector3;

	import flash.geom.Vector3D;

	public class AWPPoint2PointConstraint extends AWPTypedConstraint {
		
		private var _pivotInA:Vector3D;
		private var _pivotInB:Vector3D;
		
		public function AWPPoint2PointConstraint(rbA : AWPRigidBody, pivotInA : Vector3D, rbB : AWPRigidBody = null, pivotInB : Vector3D = null) {
			super(0);
			m_rbA = rbA;
			m_rbB = rbB;
			
			_pivotInA = pivotInA;
			_pivotInB = pivotInB;

			if (rbB) {
				var vec1:AWPVector3 = new AWPVector3();
				vec1.sv3d = _pivotInA;
				var vec2:AWPVector3 = new AWPVector3();
				vec2.sv3d = _pivotInB;
				pointer = createP2PConstraint2InC(rbA.pointer, rbB.pointer, vec1.pointer, vec2.pointer);
				CModule.free(vec1.pointer);
				CModule.free(vec2.pointer);
			} else {
				vec1 = new AWPVector3();
				vec1.sv3d = _pivotInA;
				pointer = createP2PConstraint1InC(rbA.pointer, vec1.pointer);
				CModule.free(vec1.pointer);
			}
		}
		
		public function get pivotInA():Vector3D {
			return _pivotInA;
		}
		
		public function get pivotInB():Vector3D {
			return _pivotInB;
		}
	}
}