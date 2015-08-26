package awayphysics.collision.shapes {
	import AWPC_Run.CModule;
	import AWPC_Run.setShapeScalingInC;
	import AWPC_Run.disposeCollisionShapeInC;
	
	import awayphysics.AWPBase;
	import awayphysics.math.AWPVector3;
	
	import flash.geom.Vector3D;
	
	public class AWPCollisionShape extends AWPBase {
		
		protected var m_shapeType:int;
		protected var m_localScaling:Vector3D;
		
		protected var m_counter:int = 0;
		
		public function AWPCollisionShape(ptr:uint, type:int) {
			pointer = ptr;
			m_shapeType = type;
			
			m_localScaling = new Vector3D(1, 1, 1);
		}
		
		/**
		 * the values defined by AWPCollisionShapeType
		 */
		public function get shapeType():int {
			return m_shapeType;
		}
		
		public function get localScaling():Vector3D {
			return m_localScaling;
		}
		
		public function set localScaling(scale:Vector3D):void {
			m_localScaling.setTo(scale.x, scale.y, scale.z);
			if(scale.w == 0){
				var vec:AWPVector3 = new AWPVector3();
				vec.v3d = scale;
				setShapeScalingInC(pointer, vec.pointer);
				CModule.free(vec.pointer);
			}
		}
		
		/**
		 * this function just called by internal
		 */
		public function retain():void {
			m_counter++;
		}
		
		/**
		 * this function just called by internal
		 */
		public function dispose():void {
			m_counter--;
			if (m_counter > 0) {
				return;
			}else {
				m_counter = 0;
			}
			if (!_cleanup) {
				_cleanup  = true;
				disposeCollisionShapeInC(pointer);
			}
		}
	}
}