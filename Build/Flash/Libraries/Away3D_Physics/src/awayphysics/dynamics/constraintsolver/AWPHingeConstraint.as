package awayphysics.dynamics.constraintsolver {
	import AWPC_Run.CModule;
	import AWPC_Run.createHingeConstraint1InC;
	import AWPC_Run.createHingeConstraint2InC;
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.math.AWPVector3;
	
	import flash.geom.Vector3D;

	public class AWPHingeConstraint extends AWPTypedConstraint {
		private var m_limit : AWPAngularLimit;
		
		private var _pivotInA:Vector3D;
		private var _pivotInB:Vector3D;
		private var _axisInA:Vector3D;
		private var _axisInB:Vector3D;

		public function AWPHingeConstraint(rbA : AWPRigidBody, pivotInA : Vector3D, axisInA : Vector3D, rbB : AWPRigidBody = null, pivotInB : Vector3D = null, axisInB : Vector3D = null, useReferenceFrameA : Boolean = false) {
			super(1);
			m_rbA = rbA;
			m_rbB = rbB;
			
			_pivotInA=pivotInA;
			_pivotInB=pivotInB;
			_axisInA=axisInA;
			_axisInB=axisInB;

			if (rbB) {
				var vec1:AWPVector3 = new AWPVector3();
				vec1.sv3d = _pivotInA;
				var vec2:AWPVector3 = new AWPVector3();
				vec2.sv3d = _pivotInB;
				var vec3:AWPVector3 = new AWPVector3();
				vec3.v3d = _axisInA;
				var vec4:AWPVector3 = new AWPVector3();
				vec4.v3d = _axisInB;
				pointer = createHingeConstraint2InC(rbA.pointer, rbB.pointer, vec1.pointer, vec2.pointer, vec3.pointer, vec4.pointer, useReferenceFrameA ? 1 : 0);
				CModule.free(vec1.pointer);
				CModule.free(vec2.pointer);
				CModule.free(vec3.pointer);
				CModule.free(vec4.pointer);
			} else {
				vec1 = new AWPVector3();
				vec1.sv3d = _pivotInA;
				vec2 = new AWPVector3();
				vec2.v3d = _axisInA;
				pointer = createHingeConstraint1InC(rbA.pointer, vec1.pointer, vec2.pointer, useReferenceFrameA ? 1 : 0);
				CModule.free(vec1.pointer);
				CModule.free(vec2.pointer);
			}
			m_limit = new AWPAngularLimit(pointer + 688);
		}
		
		public function get pivotInA():Vector3D{
			return _pivotInA;
		}
		public function get pivotInB():Vector3D{
			return _pivotInB;
		}
		public function get axisInA():Vector3D{
			return _axisInA;
		}
		public function get axisInB():Vector3D{
			return _axisInB;
		}
		
		public function get limit():AWPAngularLimit {
			return m_limit;
		}

		public function setLimit(low : Number, high : Number, _softness : Number = 0.9, _biasFactor : Number = 0.3, _relaxationFactor : Number = 1.0) : void {
			m_limit.setLimit(low, high, _softness, _biasFactor, _relaxationFactor);
		}

		public function setAngularMotor(_enableMotor : Boolean, _targetVelocity : Number, _maxMotorImpulse : Number) : void {
			enableAngularMotor = _enableMotor;
			motorTargetVelocity = _targetVelocity;
			maxMotorImpulse = _maxMotorImpulse;
		}

		public function get motorTargetVelocity() : Number {
			return CModule.readFloat(pointer + 680);
		}

		public function set motorTargetVelocity(v : Number) : void {
			CModule.writeFloat(pointer + 680, v);
		}

		public function get maxMotorImpulse() : Number {
			return CModule.readFloat(pointer + 684);
		}

		public function set maxMotorImpulse(v : Number) : void {
			CModule.writeFloat(pointer + 684, v);
		}

		public function get angularOnly() : Boolean {
			return CModule.read8(pointer + 736) == 1;
		}

		public function set angularOnly(v : Boolean) : void {
			CModule.write8(pointer + 736, v ? 1 : 0);
		}

		public function get enableAngularMotor() : Boolean {
			return CModule.read8(pointer + 737) == 1;
		}

		public function set enableAngularMotor(v : Boolean) : void {
			CModule.write8(pointer + 737, v ? 1 : 0);
		}

		public function get useOffsetForConstraintFrame() : Boolean {
			return CModule.read8(pointer + 739) == 1;
		}

		public function set useOffsetForConstraintFrame(v : Boolean) : void {
			CModule.write8(pointer + 739, v ? 1 : 0);
		}
	}
}