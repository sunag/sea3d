package awayphysics.dynamics.vehicle {
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import AWPC_Run.CModule;
	
	import away3d.containers.ObjectContainer3D;
	
	import awayphysics.AWPBase;
	import awayphysics.math.AWPMath;
	import awayphysics.math.AWPTransform;
	import awayphysics.math.AWPVector3;

	/**
	 * defining suspension and wheel parameters
	 * refer to https://docs.google.com/document/edit?id=18edpOwtGgCwNyvakS78jxMajCuezotCU_0iezcwiFQc
	 */
	public class AWPWheelInfo extends AWPBase {
		private var m_skin : ObjectContainer3D;
		private var m_raycastInfo : AWPRaycastInfo;
		private var m_worldTransform : AWPTransform;
		private var m_chassisConnectionPointCS : AWPVector3;
		private var m_wheelDirectionCS : AWPVector3;
		private var m_wheelAxleCS : AWPVector3;

		public function AWPWheelInfo(ptr : uint, _skin : ObjectContainer3D = null) {
			pointer = ptr;
			m_skin = _skin;

			m_raycastInfo = new AWPRaycastInfo(ptr);
			m_worldTransform = new AWPTransform(ptr + 92);
			m_chassisConnectionPointCS = new AWPVector3(ptr + 156);
			m_wheelDirectionCS = new AWPVector3(ptr + 172);
			m_wheelAxleCS = new AWPVector3(ptr + 188);
			
		}

		public function get skin() : ObjectContainer3D {
			return m_skin;
		}
		
		public function set skin(value:ObjectContainer3D):void {
			m_skin = value;
		}

		public function get raycastInfo() : AWPRaycastInfo {
			return m_raycastInfo;
		}

		public function set worldPosition(pos : Vector3D) : void {
			m_worldTransform.position = pos;
			updateTransform();
		}

		public function get worldPosition() : Vector3D {
			return m_worldTransform.position;
		}

		public function set worldRotation(rot : Vector3D) : void {
			m_worldTransform.rotation = AWPMath.degrees2radiansV3D(rot);
			updateTransform();
		}

		public function get worldRotation() : Vector3D {
			return AWPMath.radians2degreesV3D(m_worldTransform.rotation);
		}

		public function updateTransform() : void {
			if (!m_skin) return;
			
			m_skin.scaleX = m_skin.scaleX;
			m_skin.scaleY = m_skin.scaleY;
			m_skin.scaleZ = m_skin.scaleZ;
			var rot:Vector3D = AWPMath.radians2degreesV3D(m_worldTransform.rotation);
			m_skin.rotateTo(rot.x,rot.y,rot.z);
			m_skin.position = m_worldTransform.position;
		}

		public function get chassisConnectionPointCS() : Vector3D {
			return m_chassisConnectionPointCS.sv3d;
		}

		public function set chassisConnectionPointCS(v : Vector3D) : void {
			m_chassisConnectionPointCS.sv3d = v;
		}

		public function get wheelDirectionCS() : Vector3D {
			return m_wheelDirectionCS.v3d;
		}

		public function set wheelDirectionCS(v : Vector3D) : void {
			m_wheelDirectionCS.v3d = v;
		}

		public function get wheelAxleCS() : Vector3D {
			return m_wheelAxleCS.v3d;
		}

		public function set wheelAxleCS(v : Vector3D) : void {
			m_wheelAxleCS.v3d = v;
		}

		public function get suspensionRestLength1() : Number {
			return CModule.readFloat(pointer + 204) * _scaling;
		}

		public function set suspensionRestLength1(v : Number) : void {
			CModule.writeFloat(pointer + 204, v / _scaling);
		}

		public function get maxSuspensionTravelCm() : Number {
			return CModule.readFloat(pointer + 208);
		}

		public function set maxSuspensionTravelCm(v : Number) : void {
			CModule.writeFloat(pointer + 208, v);
		}

		public function get wheelsRadius() : Number {
			return CModule.readFloat(pointer + 212) * _scaling;
		}

		public function set wheelsRadius(v : Number) : void {
			CModule.writeFloat(pointer + 212, v / _scaling);
		}

		public function get suspensionStiffness() : Number {
			return CModule.readFloat(pointer + 216);
		}

		public function set suspensionStiffness(v : Number) : void {
			CModule.writeFloat(pointer + 216, v);
		}

		public function get wheelsDampingCompression() : Number {
			return CModule.readFloat(pointer + 220);
		}

		public function set wheelsDampingCompression(v : Number) : void {
			CModule.writeFloat(pointer + 220, v);
		}

		public function get wheelsDampingRelaxation() : Number {
			return CModule.readFloat(pointer + 224);
		}

		public function set wheelsDampingRelaxation(v : Number) : void {
			CModule.writeFloat(pointer + 224, v);
		}

		public function get frictionSlip() : Number {
			return CModule.readFloat(pointer + 228);
		}

		public function set frictionSlip(v : Number) : void {
			CModule.writeFloat(pointer + 228, v);
		}

		public function get steering() : Number {
			return CModule.readFloat(pointer + 232);
		}

		public function set steering(v : Number) : void {
			CModule.writeFloat(pointer + 232, v);
		}

		public function get rotation() : Number {
			return CModule.readFloat(pointer + 236);
		}

		public function set rotation(v : Number) : void {
			CModule.writeFloat(pointer + 236, v);
		}

		public function get deltaRotation() : Number {
			return CModule.readFloat(pointer + 240);
		}

		public function set deltaRotation(v : Number) : void {
			CModule.writeFloat(pointer + 240, v);
		}

		public function get rollInfluence() : Number {
			return CModule.readFloat(pointer + 244);
		}

		public function set rollInfluence(v : Number) : void {
			CModule.writeFloat(pointer + 244, v);
		}

		public function get maxSuspensionForce() : Number {
			return CModule.readFloat(pointer + 248);
		}

		public function set maxSuspensionForce(v : Number) : void {
			CModule.writeFloat(pointer + 248, v);
		}

		public function get engineForce() : Number {
			return CModule.readFloat(pointer + 252);
		}

		public function set engineForce(v : Number) : void {
			CModule.writeFloat(pointer + 252, v);
		}

		public function get brake() : Number {
			return CModule.readFloat(pointer + 256);
		}

		public function set brake(v : Number) : void {
			CModule.writeFloat(pointer + 256, v);
		}

		public function get bIsFrontWheel() : Boolean {
			return CModule.read8(pointer + 260) == 1;
		}

		public function set bIsFrontWheel(v : Boolean) : void {
			CModule.write8(pointer + 260, v ? 1 : 0);
		}

		public function get suspensionRelativeVelocity() : Number {
			return CModule.readFloat(pointer + 272);
		}

		public function get wheelsSuspensionForce() : Number {
			return CModule.readFloat(pointer + 276);
		}

		public function get skidInfo() : Number {
			return CModule.readFloat(pointer + 280);
		}
	}
}