package awayphysics.dynamics {
	import away3d.Away3D;
	import AWPC_Run.addBodyInC;
	import AWPC_Run.addBodyWithGroupInC;
	import AWPC_Run.addCharacterInC;
	import AWPC_Run.addConstraintInC;
	import AWPC_Run.addVehicleInC;
	import AWPC_Run.createDiscreteDynamicsWorldWithAxisSweep3InC;
	import AWPC_Run.createDiscreteDynamicsWorldWithDbvtInC;
	import AWPC_Run.physicsStepInC;
	import AWPC_Run.removeBodyInC;
	import AWPC_Run.removeCharacterInC;
	import AWPC_Run.removeConstraintInC;
	import AWPC_Run.removeVehicleInC;
	import AWPC_Run.removeCollisionObjectInC;
	import AWPC_Run.disposeDynamicsWorldInC;
	import AWPC_Run.CModule;
	
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.collision.dispatch.AWPCollisionWorld;
	import awayphysics.data.AWPCollisionFlags;
	import awayphysics.dynamics.character.AWPKinematicCharacterController;
	import awayphysics.dynamics.constraintsolver.AWPTypedConstraint;
	import awayphysics.dynamics.vehicle.AWPRaycastVehicle;
	import awayphysics.math.AWPVector3;
	
	import com.adobe.flascc.Console;
	
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;

	public class AWPDynamicsWorld extends AWPCollisionWorld {
		private static var currentDynamicsWorld : AWPDynamicsWorld;
		private var m_gravity : AWPVector3;
		private var m_rigidBodies : Vector.<AWPRigidBody>;
		private var m_nonStaticRigidBodies : Vector.<AWPRigidBody>;
		private var m_vehicles : Vector.<AWPRaycastVehicle>;
		private var m_characters : Vector.<AWPKinematicCharacterController>;
		private var m_constraints:Vector.<AWPTypedConstraint>;

		public static function getInstance() : AWPDynamicsWorld {
			if (!currentDynamicsWorld) {
				if (Away3D.MAJOR_VERSION ==4 && Away3D.MINOR_VERSION < 1)
					throw new Error("Incorrect AWAY3D version "+Away3D.MAJOR_VERSION+"."+Away3D.MINOR_VERSION+ ". Use Away3D 4.1 or higher");
				trace("version: AwayPhysics v1.0 alpha (4-9-2013)");
				currentDynamicsWorld = new AWPDynamicsWorld();
			}
			return currentDynamicsWorld;
		}

		public function AWPDynamicsWorld() {
			CModule.startAsync(this);
			new Console(this);
			m_rigidBodies = new Vector.<AWPRigidBody>();
			m_nonStaticRigidBodies = new Vector.<AWPRigidBody>();
			m_vehicles = new Vector.<AWPRaycastVehicle>();
			m_characters = new Vector.<AWPKinematicCharacterController>();
			m_constraints = new Vector.<AWPTypedConstraint>();
		}

		/**
		 * init the physics world with btDbvtBroadphase
		 * refer to http://bulletphysics.org/mediawiki-1.5.8/index.php/Broadphase
		 */
		public function initWithDbvtBroadphase() : void {
			pointer = createDiscreteDynamicsWorldWithDbvtInC();
			m_gravity = new AWPVector3(pointer + 256);
			this.gravity = new Vector3D(0, -10, 0);
		}

		/**
		 * init the physics world with btAxisSweep3
		 * refer to http://bulletphysics.org/mediawiki-1.5.8/index.php/Broadphase
		 */
		public function initWithAxisSweep3(worldAabbMin : Vector3D, worldAabbMax : Vector3D) : void {
			var vec1:AWPVector3 = new AWPVector3();
			vec1.sv3d = worldAabbMin;
			var vec2:AWPVector3 = new AWPVector3();
			vec2.sv3d = worldAabbMax;
			pointer = createDiscreteDynamicsWorldWithAxisSweep3InC(vec1.pointer, vec2.pointer);
			CModule.free(vec1.pointer);
			CModule.free(vec2.pointer);
			m_gravity = new AWPVector3(pointer + 256);
			this.gravity = new Vector3D(0, -10, 0);
		}
		
		/**
		 * dispose the physics world
		 */
		public function dispose():void {
			disposeDynamicsWorldInC();
		}

		/**
		 * add a rigidbody to physics world
		 */
		public function addRigidBody(body : AWPRigidBody) : void {
			if (body.collisionFlags != AWPCollisionFlags.CF_STATIC_OBJECT) {
				if (m_nonStaticRigidBodies.indexOf(body) < 0) {
					m_nonStaticRigidBodies.push(body);
				}
			}
			if (m_rigidBodies.indexOf(body) < 0) {
				m_rigidBodies.push(body);
				addBodyInC(body.pointer);
			}
			if(!m_collisionObjects.hasOwnProperty(body.pointer.toString())){
				m_collisionObjects[body.pointer.toString()] = body;
			}
		}

		/**
		 * add a rigidbody to physics world with group and mask
		 * refer to: http://bulletphysics.org/mediawiki-1.5.8/index.php/Collision_Filtering
		 */
		public function addRigidBodyWithGroup(body : AWPRigidBody, group : int, mask : int) : void {
			if (body.collisionFlags != AWPCollisionFlags.CF_STATIC_OBJECT) {
				if (m_nonStaticRigidBodies.indexOf(body) < 0) {
					m_nonStaticRigidBodies.push(body);
				}
			}
			if (m_rigidBodies.indexOf(body) < 0) {
				m_rigidBodies.push(body);
				addBodyWithGroupInC(body.pointer, group, mask);
			}
			if(!m_collisionObjects.hasOwnProperty(body.pointer.toString())){
				m_collisionObjects[body.pointer.toString()] = body;
			}
		}

		/**
		 * remove a rigidbody from physics world, if cleanup is true, release pointer in memory.
		 */
		public function removeRigidBody(body : AWPRigidBody, cleanup:Boolean = false) : void {
			if (m_nonStaticRigidBodies.indexOf(body) >= 0) {
				m_nonStaticRigidBodies.splice(m_nonStaticRigidBodies.indexOf(body), 1);
			}
			if (m_rigidBodies.indexOf(body) >= 0) {
				m_rigidBodies.splice(m_rigidBodies.indexOf(body), 1);
				removeBodyInC(body.pointer);
				
				if (cleanup) {
					body.dispose();
				}
			}
			if(m_collisionObjects.hasOwnProperty(body.pointer.toString())){
				delete m_collisionObjects[body.pointer.toString()];
			}
		}
		
		/**
		 * add a constraint to physics world
		 */
		public function addConstraint(constraint : AWPTypedConstraint, disableCollisionsBetweenLinkedBodies : Boolean = false) : void {
			if (m_constraints.indexOf(constraint) < 0) {
				m_constraints.push(constraint);
				addConstraintInC(constraint.pointer, disableCollisionsBetweenLinkedBodies ? 1 : 0);
			}
		}
		
		/**
		 * remove a constraint from physics world, if cleanup is true, release pointer in memory.
		 */
		public function removeConstraint(constraint : AWPTypedConstraint, cleanup:Boolean = false) : void {
			if (m_constraints.indexOf(constraint) >= 0) {
				m_constraints.splice(m_constraints.indexOf(constraint), 1);
				removeConstraintInC(constraint.pointer);
				
				if (cleanup) {
					constraint.dispose();
				}
			}
		}
		
		/**
		 * add a vehicle to physics world
		 */
		public function addVehicle(vehicle : AWPRaycastVehicle) : void {
			if (m_vehicles.indexOf(vehicle) < 0) {
				m_vehicles.push(vehicle);
				addVehicleInC(vehicle.pointer);
			}
		}
		
		/**
		 * remove a vehicle from physics world, if cleanup is true, release pointer in memory.
		 */
		public function removeVehicle(vehicle : AWPRaycastVehicle, cleanup:Boolean = false) : void {
			if (m_vehicles.indexOf(vehicle) >= 0) {
				m_vehicles.splice(m_vehicles.indexOf(vehicle), 1);
				removeVehicleInC(vehicle.pointer);
				
				if (cleanup) {
					removeRigidBody(vehicle.getRigidBody(),cleanup);
					vehicle.dispose();
				}
			}
		}
		
		/**
		 * add a character to physics world
		 */
		public function addCharacter(character : AWPKinematicCharacterController, group : int = 32, mask : int = -1) : void {
			if (m_characters.indexOf(character) < 0) {
				m_characters.push(character);
				addCharacterInC(character.pointer, group, mask);
			}
			
			if(!m_collisionObjects.hasOwnProperty(character.ghostObject.pointer.toString())){
				m_collisionObjects[character.ghostObject.pointer.toString()] = character.ghostObject;
			}
		}
		
		/**
		 * remove a character from physics world, if cleanup is true, release pointer in memory.
		 */
		public function removeCharacter(character : AWPKinematicCharacterController, cleanup:Boolean = false) : void {
			if (m_characters.indexOf(character) >= 0) {
				m_characters.splice(m_characters.indexOf(character), 1);
				removeCharacterInC(character.pointer);
				
				if (cleanup) {
					character.dispose();
				}
			}
			if(m_collisionObjects.hasOwnProperty(character.ghostObject.pointer.toString())){
				delete m_collisionObjects[character.ghostObject.pointer.toString()];
			}
		}
		
		/**
		 * clear all objects from physics world, if cleanup is true, release pointer in memory.
		 */
		public function cleanWorld(cleanup:Boolean = false):void{
			while (m_constraints.length > 0){
				removeConstraint(m_constraints[0],cleanup);
			}
			m_constraints.length = 0;
			
			while (m_vehicles.length > 0){
				removeVehicle(m_vehicles[0],cleanup);
			}
			m_vehicles.length = 0;
			
			while (m_characters.length > 0){
				removeCharacter(m_characters[0],cleanup);
			}
			m_characters.length = 0;
			
			while (m_rigidBodies.length > 0){
				removeRigidBody(m_rigidBodies[0],cleanup);
			}
			m_nonStaticRigidBodies.length = 0;
			m_rigidBodies.length = 0;
			
			for each (var obj:AWPCollisionObject in m_collisionObjects) {
				removeCollisionObjectInC(obj.pointer);
			}
			m_collisionObjects =  new Dictionary(true);
		}

		/**
		 * get the gravity of physics world
		 */
		public function get gravity() : Vector3D {
			return m_gravity.v3d;
		}

		/**
		 * set the gravity of physics world
		 */
		public function set gravity(g : Vector3D) : void {
			m_gravity.v3d = g;
			for each (var body:AWPRigidBody in m_nonStaticRigidBodies) {
				body.gravity = g;
			}
		}

		/**
		 * get all rigidbodies
		 */
		public function get rigidBodies() : Vector.<AWPRigidBody> {
			return m_rigidBodies;
		}

		/**
		 * get all non static rigidbodies
		 */
		public function get nonStaticRigidBodies() : Vector.<AWPRigidBody> {
			return m_nonStaticRigidBodies;
		}
		
		public function get constraints() : Vector.<AWPTypedConstraint> {
			return m_constraints;
		}

		public function get vehicles() : Vector.<AWPRaycastVehicle> {
			return m_vehicles;
		}

		public function get characters() : Vector.<AWPKinematicCharacterController> {
			return m_characters;
		}

		/**
		 * set physics world scaling
		 * refer to http://www.bulletphysics.org/mediawiki-1.5.8/index.php?title=Scaling_The_World
		 */
		public function set scaling(v : Number) : void {
			_scaling = v;
		}

		/**
		 * get physics world scaling
		 */
		public function get scaling() : Number {
			return _scaling;
		}

		/**
		 * get if implement object collision callback
		 */
		public function get collisionCallbackOn() : Boolean {
			return CModule.read8(pointer + 280) == 1;
		}

		/**
		 * set this to true if need add a collision event to object, default is false
		 */
		public function set collisionCallbackOn(v : Boolean) : void {
			CModule.write8(pointer + 280, v ? 1 : 0);
		}

		/**
		 * set time step and simulate the physics world
		 * refer to: http://bulletphysics.org/mediawiki-1.5.8/index.php/Stepping_the_World
		 */
		public function step(timeStep : Number, maxSubSteps : int = 1, fixedTimeStep : Number = 1.0 / 60) : void {
			physicsStepInC(timeStep, maxSubSteps, fixedTimeStep);

			for each (var body:AWPRigidBody in m_nonStaticRigidBodies) {
				body.updateTransform();
			}

			for each (var vehicle:AWPRaycastVehicle in m_vehicles) {
				vehicle.updateWheelsTransform();
			}

			for each (var character:AWPKinematicCharacterController in m_characters) {
				character.updateTransform();
			}
		}
	}
}
