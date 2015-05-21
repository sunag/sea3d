package awayphysics.dynamics.constraintsolver {
	import AWPC_Run.createConeTwistConstraint1;
	import AWPC_Run.createConeTwistConstraint2;
	import AWPC_Run.CModule;
	
	import awayphysics.dynamics.AWPRigidBody;
	import awayphysics.math.AWPMath;
	import awayphysics.math.AWPMatrix3x3;
	import awayphysics.math.AWPTransform;
	import awayphysics.math.AWPVector3;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class AWPConeTwistConstraint extends AWPTypedConstraint {
		
		private var m_rbAFrame:AWPTransform;
		private var m_rbBFrame:AWPTransform;
		
		public function AWPConeTwistConstraint(rbA : AWPRigidBody, pivotInA : Vector3D, rotationInA : Vector3D, rbB : AWPRigidBody = null, pivotInB : Vector3D = null, rotationInB : Vector3D = null) {
			super(2);
			m_rbA = rbA;
			m_rbB = rbB;
			
			m_rbAFrame = new AWPTransform();
			m_rbAFrame.position = pivotInA;
			m_rbAFrame.rotation = AWPMath.degrees2radiansV3D(rotationInA);

			var posInA : Vector3D = pivotInA.clone();
			var rotA:Matrix3D = AWPMath.euler2matrix(m_rbAFrame.rotation);
			if (rbB) {
				m_rbBFrame = new AWPTransform();
				m_rbBFrame.position = pivotInB;
				m_rbBFrame.rotation = AWPMath.degrees2radiansV3D(rotationInB);
				
				var posInB : Vector3D = pivotInB.clone();
				var rotB:Matrix3D = AWPMath.euler2matrix(m_rbBFrame.rotation);
				
				var vec1:AWPVector3 = new AWPVector3();
				vec1.sv3d = posInA;
				var vec2:AWPVector3 = new AWPVector3();
				vec2.sv3d = posInB;
				var mat1:AWPMatrix3x3 = new AWPMatrix3x3();
				mat1.m3d = rotA;
				var mat2:AWPMatrix3x3 = new AWPMatrix3x3();
				mat2.m3d = rotB;
				pointer = createConeTwistConstraint2(rbA.pointer, vec1.pointer, mat1.pointer, rbB.pointer, vec2.pointer, mat2.pointer);
				CModule.free(vec1.pointer);
				CModule.free(vec2.pointer);
				CModule.free(mat1.pointer);
				CModule.free(mat2.pointer);
			} else {
				m_rbBFrame = null;
				vec1 = new AWPVector3();
				vec1.v3d = posInA;
				mat1 = new AWPMatrix3x3();
				mat1.m3d = rotA;
				pointer = createConeTwistConstraint1(rbA.pointer, vec1.pointer, mat1.pointer);
				CModule.free(vec1.pointer);
				CModule.free(mat1.pointer);
			}
		}
		
		public function get rbAFrame():AWPTransform {
			return m_rbAFrame;
		}
		
		public function get rbBFrame():AWPTransform {
			return m_rbBFrame;
		}

		public function setLimit(_swingSpan1 : Number, _swingSpan2 : Number, _twistSpan : Number, _softness : Number = 1, _biasFactor : Number = 0.3, _relaxationFactor : Number = 1) : void {
			swingSpan1 = _swingSpan1;
			swingSpan2 = _swingSpan2;
			twistSpan = _twistSpan;

			limitSoftness = _softness;
			biasFactor = _biasFactor;
			relaxationFactor = _relaxationFactor;
		}

		/*
		public function setMaxMotorImpulse(_maxMotorImpulse:Number):void {
		maxMotorImpulse = _maxMotorImpulse;
		bNormalizedMotorStrength = false;
		}
		
		public function setMaxMotorImpulseNormalized(_maxMotorImpulse:Number):void {
		maxMotorImpulse = _maxMotorImpulse;
		bNormalizedMotorStrength = true;
		}
		 */
		public function get limitSoftness() : Number {
			return CModule.readFloat(pointer + 428);
		}

		public function set limitSoftness(v : Number) : void {
			CModule.writeFloat(pointer + 428, v);
		}

		public function get biasFactor() : Number {
			return CModule.readFloat(pointer + 432);
		}

		public function set biasFactor(v : Number) : void {
			CModule.writeFloat(pointer + 432, v);
		}

		public function get relaxationFactor() : Number {
			return CModule.readFloat(pointer + 436);
		}

		public function set relaxationFactor(v : Number) : void {
			CModule.writeFloat(pointer + 436, v);
		}

		public function get damping() : Number {
			return CModule.readFloat(pointer + 440);
		}

		public function set damping(v : Number) : void {
			CModule.writeFloat(pointer + 440, v);
		}

		public function get swingSpan1() : Number {
			return CModule.readFloat(pointer + 444);
		}

		public function set swingSpan1(v : Number) : void {
			CModule.writeFloat(pointer + 444, v);
		}

		public function get swingSpan2() : Number {
			return CModule.readFloat(pointer + 448);
		}

		public function set swingSpan2(v : Number) : void {
			CModule.writeFloat(pointer + 448, v);
		}

		public function get twistSpan() : Number {
			return CModule.readFloat(pointer + 452);
		}

		public function set twistSpan(v : Number) : void {
			CModule.writeFloat(pointer + 452, v);
		}

		public function get fixThresh() : Number {
			return CModule.readFloat(pointer + 456);
		}

		public function set fixThresh(v : Number) : void {
			CModule.writeFloat(pointer + 456, v);
		}

		public function get twistAngle() : Number {
			return CModule.readFloat(pointer + 512);
		}

		public function get angularOnly() : Boolean {
			return CModule.read8(pointer + 524) == 1;
		}

		public function set angularOnly(v : Boolean) : void {
			CModule.write8(pointer + 524, v ? 1 : 0);
		}
		/*public function get enableMotor():Boolean { return memUser._mru8(pointer + 540) == 1; }
		public function set enableMotor(v:Boolean):void { memUser._mw8(pointer + 540, v ? 1 : 0); }
		public function get bNormalizedMotorStrength():Boolean { return memUser._mru8(pointer + 541) == 1; }
		public function set bNormalizedMotorStrength(v:Boolean):void { memUser._mw8(pointer + 541, v ? 1 : 0); }
		public function get maxMotorImpulse():Number { return memUser._mrf(pointer + 560); }
		public function set maxMotorImpulse(v:Number):void { memUser._mwf(pointer + 560, v); }*/
	}
}