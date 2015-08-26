package awayphysics.dynamics.constraintsolver {
	import AWPC_Run.CModule;
	import awayphysics.AWPBase;

	public class AWPRotationalLimitMotor extends AWPBase {
		public function AWPRotationalLimitMotor(ptr : uint) {
			pointer = ptr;
		}

		public function isLimited() : Boolean {
			if (loLimit > hiLimit) return false;

			return true;
		}

		public function get loLimit() : Number {
			return CModule.readFloat(pointer + 0);
		}

		public function set loLimit(v : Number) : void {
			CModule.writeFloat(pointer + 0, v);
		}

		public function get hiLimit() : Number {
			return CModule.readFloat(pointer + 4);
		}

		public function set hiLimit(v : Number) : void {
			CModule.writeFloat(pointer + 4, v);
		}

		public function get targetVelocity() : Number {
			return CModule.readFloat(pointer + 8);
		}

		public function set targetVelocity(v : Number) : void {
			CModule.writeFloat(pointer + 8, v);
		}

		public function get maxMotorForce() : Number {
			return CModule.readFloat(pointer + 12);
		}

		public function set maxMotorForce(v : Number) : void {
			CModule.writeFloat(pointer + 12, v);
		}

		public function get maxLimitForce() : Number {
			return CModule.readFloat(pointer + 16);
		}

		public function set maxLimitForce(v : Number) : void {
			CModule.writeFloat(pointer + 16, v);
		}

		public function get damping() : Number {
			return CModule.readFloat(pointer + 20);
		}

		public function set damping(v : Number) : void {
			CModule.writeFloat(pointer + 20, v);
		}

		public function get limitSoftness() : Number {
			return CModule.readFloat(pointer + 24);
		}

		public function set limitSoftness(v : Number) : void {
			CModule.writeFloat(pointer + 24, v);
		}

		public function get normalCFM() : Number {
			return CModule.readFloat(pointer + 28);
		}

		public function set normalCFM(v : Number) : void {
			CModule.writeFloat(pointer + 28, v);
		}

		public function get stopERP() : Number {
			return CModule.readFloat(pointer + 32);
		}

		public function set stopERP(v : Number) : void {
			CModule.writeFloat(pointer + 32, v);
		}

		public function get stopCFM() : Number {
			return CModule.readFloat(pointer + 36);
		}

		public function set stopCFM(v : Number) : void {
			CModule.writeFloat(pointer + 36, v);
		}

		public function get bounce() : Number {
			return CModule.readFloat(pointer + 40);
		}

		public function set bounce(v : Number) : void {
			CModule.writeFloat(pointer + 40, v);
		}

		public function get enableMotor() : Boolean {
			return CModule.read8(pointer + 44) == 1;
		}

		public function set enableMotor(v : Boolean) : void {
			CModule.write8(pointer + 44, v ? 1 : 0);
		}

		public function get currentLimitError() : Number {
			return CModule.readFloat(pointer + 48);
		}

		public function set currentLimitError(v : Number) : void {
			CModule.writeFloat(pointer + 48, v);
		}

		public function get currentPosition() : Number {
			return CModule.readFloat(pointer + 52);
		}

		public function set currentPosition(v : Number) : void {
			CModule.writeFloat(pointer + 52, v);
		}

		public function get currentLimit() : int {
			return CModule.read32(pointer + 56);
		}

		public function set currentLimit(v : int) : void {
			CModule.write32(pointer + 56, v);
		}

		public function get accumulatedImpulse() : Number {
			return CModule.readFloat(pointer + 60);
		}

		public function set accumulatedImpulse(v : Number) : void {
			CModule.writeFloat(pointer + 60, v);
		}
	}
}