package awayphysics.dynamics {
	import AWPC_Run.createBodyInC;
	import AWPC_Run.setBodyMassInC;
	import AWPC_Run.CModule;
	import away3d.containers.ObjectContainer3D;

	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.shapes.AWPCollisionShape;
	import awayphysics.math.AWPMatrix3x3;
	import awayphysics.math.AWPVector3;
	import awayphysics.math.AWPMath;

	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	public class AWPRigidBody extends AWPCollisionObject {
		private var m_invInertiaTensorWorld : AWPMatrix3x3;
		private var m_linearVelocity : AWPVector3;
		private var m_angularVelocity : AWPVector3;
		private var m_linearFactor : AWPVector3;
		private var m_angularFactor : AWPVector3;
		private var m_gravity : AWPVector3;
		private var m_gravity_acceleration : AWPVector3;
		private var m_invInertiaLocal : AWPVector3;
		private var m_totalForce : AWPVector3;
		private var m_totalTorque : AWPVector3;
		private var m_invMass : AWPVector3;

		/**
		 * rigidbody is static if mass is zero, otherwise is dynamic
		 */
		public function AWPRigidBody(shape : AWPCollisionShape, skin : ObjectContainer3D = null, mass : Number = 0) {
			pointer = createBodyInC(shape.pointer, mass);
			super(shape, skin, pointer);

			m_invInertiaTensorWorld = new AWPMatrix3x3(pointer + 260);
			m_linearVelocity = new AWPVector3(pointer + 308);
			m_angularVelocity = new AWPVector3(pointer + 324);
			m_linearFactor = new AWPVector3(pointer + 344);
			m_angularFactor = new AWPVector3(pointer + 508);
			m_gravity = new AWPVector3(pointer + 360);
			m_gravity_acceleration = new AWPVector3(pointer + 376);
			m_invInertiaLocal = new AWPVector3(pointer + 392);
			m_totalForce = new AWPVector3(pointer + 408);
			m_totalTorque = new AWPVector3(pointer + 424);
			m_invMass = new AWPVector3(pointer + 524);
		}
		
		/**
		 * add force to the rigidbody's mass center
		 */
		public function applyCentralForce(force : Vector3D) : void {
			var vec : Vector3D = AWPMath.vectorMultiply(force, m_linearFactor.v3d);
			m_totalForce.v3d = vec.add(m_totalForce.v3d);
			activate();
		}

		/**
		 * add torque to the rigidbody
		 */
		public function applyTorque(torque : Vector3D) : void {
			var vec : Vector3D = AWPMath.vectorMultiply(torque, m_angularFactor.v3d);
			m_totalTorque.v3d = vec.add(m_totalTorque.v3d);
			activate();
		}

		/**
		 * add force to the rigidbody, rel_pos is the position in body's local coordinates
		 */
		public function applyForce(force : Vector3D, rel_pos : Vector3D) : void {
			applyCentralForce(force);
			rel_pos.scaleBy(1 / _scaling);
			var vec : Vector3D = AWPMath.vectorMultiply(force, m_linearFactor.v3d);
			applyTorque(rel_pos.crossProduct(vec));
		}

		/**
		 * add impulse to the rigidbody's mass center
		 */
		public function applyCentralImpulse(impulse : Vector3D) : void {
			var vec : Vector3D = AWPMath.vectorMultiply(impulse, m_linearFactor.v3d);
			vec.scaleBy(inverseMass);
			m_linearVelocity.v3d = vec.add(m_linearVelocity.v3d);
			activate();
		}

		/**
		 * add a torque impulse to the rigidbody
		 */
		public function applyTorqueImpulse(torque : Vector3D) : void {
			var tor : Vector3D = torque.clone();
			var vec : Vector3D = AWPMath.vectorMultiply(new Vector3D(m_invInertiaTensorWorld.row1.dotProduct(tor), m_invInertiaTensorWorld.row2.dotProduct(tor), m_invInertiaTensorWorld.row3.dotProduct(tor)), m_angularFactor.v3d);
			m_angularVelocity.v3d = vec.add(m_angularVelocity.v3d);
			activate();
		}

		/**
		 * add a impulse to the rigidbody, rel_pos is the position in body's local coordinates
		 */
		public function applyImpulse(impulse : Vector3D, rel_pos : Vector3D) : void {
			if (inverseMass != 0) {
				applyCentralImpulse(impulse);
				rel_pos.scaleBy(1 / _scaling);
				var vec : Vector3D = AWPMath.vectorMultiply(impulse, m_linearFactor.v3d);
				applyTorqueImpulse(rel_pos.crossProduct(vec));
			}
		}

		/**
		 * clear all force and torque to zero
		 */
		public function clearForces() : void {
			m_totalForce.v3d = new Vector3D();
			m_totalTorque.v3d = new Vector3D();
		}

		/**
		 * set the gravity of this rigidbody
		 */
		public function set gravity(acceleration : Vector3D) : void {
			if (inverseMass != 0) {
				var vec : Vector3D = acceleration.clone();
				vec.scaleBy(1 / inverseMass);
				m_gravity.v3d = vec;
				activate();
			}
			m_gravity_acceleration.v3d = acceleration;
		}
		
		override public function set scale(sc:Vector3D):void {
			super.scale = sc;
			setBodyMassInC(pointer, mass);
		}
		override public function set transform(tr:Matrix3D) : void {
			super.transform = tr;
			setBodyMassInC(pointer, mass);
		}

		public function get invInertiaTensorWorld() : Matrix3D {
			return m_invInertiaTensorWorld.m3d;
		}

		public function get linearVelocity() : Vector3D {
			return m_linearVelocity.v3d;
		}

		public function set linearVelocity(v : Vector3D) : void {
			m_linearVelocity.v3d = v;
		}

		public function get angularVelocity() : Vector3D {
			return m_angularVelocity.v3d;
		}

		public function set angularVelocity(v : Vector3D) : void {
			m_angularVelocity.v3d = v;
		}

		public function get linearFactor() : Vector3D {
			return m_linearFactor.v3d;
		}

		public function set linearFactor(v : Vector3D) : void {
			m_linearFactor.v3d = v;

			var vec : Vector3D = v.clone();
			vec.scaleBy(inverseMass);
			m_invMass.v3d = vec;
		}

		public function get angularFactor() : Vector3D {
			return m_angularFactor.v3d;
		}

		public function set angularFactor(v : Vector3D) : void {
			m_angularFactor.v3d = v;
		}

		public function get gravity() : Vector3D {
			return m_gravity.v3d;
		}

		public function get gravityAcceleration() : Vector3D {
			return m_gravity_acceleration.v3d;
		}

		public function get invInertiaLocal() : Vector3D {
			return m_invInertiaLocal.v3d;
		}

		public function set invInertiaLocal(v : Vector3D) : void {
			m_invInertiaLocal.v3d = v;
		}

		public function get totalForce() : Vector3D {
			return m_totalForce.v3d;
		}

		public function get totalTorque() : Vector3D {
			return m_totalTorque.v3d;
		}

		public function get mass() : Number {
			return (inverseMass == 0)?0:1 / inverseMass;
		}

		public function set mass(v : Number) : void {
			setBodyMassInC(pointer, v);
			var physicsWorld:AWPDynamicsWorld = AWPDynamicsWorld.getInstance();
			if (v == 0) {
				if (physicsWorld.nonStaticRigidBodies.indexOf(this) >= 0) {
					physicsWorld.nonStaticRigidBodies.splice(physicsWorld.nonStaticRigidBodies.indexOf(this), 1);
				}
			} else {
				if (physicsWorld.nonStaticRigidBodies.indexOf(this) < 0) {
					physicsWorld.nonStaticRigidBodies.push(this);
				}
			}
			activate();
		}

		public function get inverseMass() : Number {
			return CModule.readFloat(pointer + 340);
		}

		public function set inverseMass(v : Number) : void {
			CModule.writeFloat(pointer + 340, v);
		}

		public function get linearDamping() : Number {
			return CModule.readFloat(pointer + 440);
		}

		public function set linearDamping(v : Number) : void {
			CModule.writeFloat(pointer + 440, v);
		}

		public function get angularDamping() : Number {
			return CModule.readFloat(pointer + 444);
		}

		public function set angularDamping(v : Number) : void {
			CModule.writeFloat(pointer + 444, v);
		}

		public function get linearSleepingThreshold() : Number {
			return CModule.readFloat(pointer + 468);
		}

		public function set linearSleepingThreshold(v : Number) : void {
			CModule.writeFloat(pointer + 468, v);
		}

		public function get angularSleepingThreshold() : Number {
			return CModule.readFloat(pointer + 472);
		}

		public function set angularSleepingThreshold(v : Number) : void {
			CModule.writeFloat(pointer + 472, v);
		}

		public function get rigidbodyFlags() : int {
			return CModule.read32(pointer + 500);
		}

		public function set rigidbodyFlags(v : int) : void {
			CModule.write32(pointer + 500, v);
		}
	}
}