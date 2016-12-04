package awayphysics.collision.dispatch {
	import AWPC_Run.createGhostObjectInC;
	import away3d.containers.ObjectContainer3D;
	import awayphysics.collision.shapes.AWPCollisionShape;

	/**
	 *used for create the character controller
	 */
	public class AWPGhostObject extends AWPCollisionObject {
		public function AWPGhostObject(shape : AWPCollisionShape, skin : ObjectContainer3D = null) {
			pointer = createGhostObjectInC(shape.pointer);
			super(shape, skin, pointer);
		}
	}
}