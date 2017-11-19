/**
 * 	SEA3D - Rigid Body
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

//
//	Sphere
//

SEA3D.Sphere = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.radius = data.readFloat();

};

SEA3D.Sphere.prototype.type = "sph";

//
//	Box
//

SEA3D.Box = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.width = data.readFloat();
	this.height = data.readFloat();
	this.depth = data.readFloat();

};

SEA3D.Box.prototype.type = "box";

//
//	Cone
//

SEA3D.Cone = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.radius = data.readFloat();
	this.height = data.readFloat();

};

SEA3D.Cone.prototype.type = "cone";

//
//	Capsule
//

SEA3D.Capsule = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.radius = data.readFloat();
	this.height = data.readFloat();

};

SEA3D.Capsule.prototype.type = "cap";

//
//	Cylinder
//

SEA3D.Cylinder = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.radius = data.readFloat();
	this.height = data.readFloat();

};

SEA3D.Cylinder.prototype.type = "cyl";

//
//	Convex Geometry
//

SEA3D.ConvexGeometry = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.geometry = sea3d.getObject( data.readUInt() );
	this.subGeometryIndex = data.readUByte();

};

SEA3D.ConvexGeometry.prototype.type = "gs";

//
//	Triangle Geometry
//

SEA3D.TriangleGeometry = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.geometry = sea3d.getObject( data.readUInt() );
	this.subGeometryIndex = data.readUByte();

};

SEA3D.TriangleGeometry.prototype.type = "sgs";

//
//	Compound
//

SEA3D.Compound = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.compounds = [];

	var count = data.readUByte();

	for ( var i = 0; i < count; i ++ ) {

		this.compounds.push( {
			shape: sea3d.getObject( data.readUInt() ),
			transform: data.readMatrix()
		} );

	}

};

SEA3D.Compound.prototype.type = "cmps";

//
//	Physics
//

SEA3D.Physics = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.attrib = data.readUShort();

	this.shape = sea3d.getObject( data.readUInt() );

	if ( this.attrib & 1 ) this.target = sea3d.getObject( data.readUInt() );
	else this.transform = data.readMatrix();

	if ( this.attrib & 2 ) this.offset = data.readMatrix();

	if ( this.attrib & 4 ) this.scripts = data.readScriptList( sea3d );

	if ( this.attrib & 16 ) this.attributes = sea3d.getObject( data.readUInt() );

};

SEA3D.Physics.prototype.readTag = function ( kind, data, size ) {

};

//
//	Rigidy Body Base
//

SEA3D.RigidBodyBase = function ( name, data, sea3d ) {

	SEA3D.Physics.call( this, name, data, sea3d );

	if ( this.attrib & 32 ) {

		this.linearDamping = data.readFloat();
		this.angularDamping = data.readFloat();

	} else {

		this.linearDamping = 0;
		this.angularDamping = 0;

	}

	this.mass = data.readFloat();
	this.friction = data.readFloat();
	this.restitution = data.readFloat();

};

SEA3D.RigidBodyBase.prototype = Object.create( SEA3D.Physics.prototype );
SEA3D.RigidBodyBase.prototype.constructor = SEA3D.RigidBodyBase;

//
//	Rigidy Body
//

SEA3D.RigidBody = function ( name, data, sea3d ) {

	SEA3D.RigidBodyBase.call( this, name, data, sea3d );

	data.readTags( this.readTag.bind( this ) );

};

SEA3D.RigidBody.prototype = Object.create( SEA3D.RigidBodyBase.prototype );
SEA3D.RigidBody.prototype.constructor = SEA3D.RigidBody;

SEA3D.RigidBody.prototype.type = "rb";

//
//	Car Controller
//

SEA3D.CarController = function ( name, data, sea3d ) {

	SEA3D.RigidBodyBase.call( this, name, data, sea3d );

	this.suspensionStiffness = data.readFloat();
	this.suspensionCompression = data.readFloat();
	this.suspensionDamping = data.readFloat();
	this.maxSuspensionTravelCm = data.readFloat();
	this.frictionSlip = data.readFloat();
	this.maxSuspensionForce = data.readFloat();

	this.dampingCompression = data.readFloat();
	this.dampingRelaxation = data.readFloat();

	var count = data.readUByte();

	this.wheel = [];

	for ( var i = 0; i < count; i ++ ) {

		this.wheel[ i ] = new SEA3D.CarController.Wheel( data, sea3d );

	}

	data.readTags( this.readTag.bind( this ) );

};

SEA3D.CarController.Wheel = function ( data, sea3d ) {

	this.data = data;
	this.sea3d = sea3d;

	this.attrib = data.readUShort();

	this.isFront = ( this.attrib & 1 ) != 0;

	if ( this.attrib & 2 ) {

		this.target = sea3d.getObject( data.readUInt() );

	}

	if ( this.attrib & 4 ) {

		this.offset = data.readMatrix();

	}

	this.pos = data.readVector3();
	this.dir = data.readVector3();
	this.axle = data.readVector3();

	this.radius = data.readFloat();
	this.suspensionRestLength = data.readFloat();

};

SEA3D.CarController.prototype = Object.create( SEA3D.RigidBodyBase.prototype );
SEA3D.CarController.prototype.constructor = SEA3D.CarController;

SEA3D.CarController.prototype.type = "carc";

//
//	Constraints
//

SEA3D.Constraints = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	this.attrib = data.readUShort();

	this.disableCollisionsBetweenBodies = this.attrib & 1 != 0;

	this.targetA = sea3d.getObject( data.readUInt() );
	this.pointA = data.readVector3();

	if ( this.attrib & 2 ) {

		this.targetB = sea3d.getObject( data.readUInt() );
		this.pointB = data.readVector3();

	}

};

//
//	P2P Constraint
//

SEA3D.P2PConstraint = function ( name, data, sea3d ) {

	this.name = name;
	this.data = data;
	this.sea3d = sea3d;

	SEA3D.Constraints.call( this, name, data, sea3d );

};

SEA3D.P2PConstraint.prototype = Object.create( SEA3D.Constraints.prototype );
SEA3D.P2PConstraint.prototype.constructor = SEA3D.P2PConstraint;

SEA3D.P2PConstraint.prototype.type = "p2pc";

//
//	Hinge Constraint
//

SEA3D.HingeConstraint = function ( name, data, sea3d ) {

	SEA3D.Constraints.call( this, name, data, sea3d );

	this.axisA = data.readVector3();

	if ( this.attrib & 1 ) {

		this.axisB = data.readVector3();

	}

	if ( this.attrib & 4 ) {

		this.limit = {
			low: data.readFloat(),
			high: data.readFloat(),
			softness: data.readFloat(),
			biasFactor: data.readFloat(),
			relaxationFactor: data.readFloat()
		};

	}

	if ( this.attrib & 8 ) {

		this.angularMotor = {
			velocity: data.readFloat(),
			impulse: data.readFloat()
		};

	}

};

SEA3D.HingeConstraint.prototype = Object.create( SEA3D.Constraints.prototype );
SEA3D.HingeConstraint.prototype.constructor = SEA3D.HingeConstraint;

SEA3D.HingeConstraint.prototype.type = "hnec";

//
//	Cone Twist Constraint
//

SEA3D.ConeTwistConstraint = function ( name, data, sea3d ) {

	SEA3D.Constraints.call( this, name, data, sea3d );

	this.axisA = data.readVector3();

	if ( this.attrib & 1 ) {

		this.axisB = data.readVector3();

	}

	if ( this.attrib & 4 ) {

		this.limit = {
			swingSpan1: data.readFloat(),
			swingSpan2: data.readFloat(),
			twistSpan: data.readFloat(),
			softness: data.readFloat(),
			biasFactor: data.readFloat(),
			relaxationFactor: data.readFloat()
		};

	}

};

SEA3D.ConeTwistConstraint.prototype = Object.create( SEA3D.Constraints.prototype );
SEA3D.ConeTwistConstraint.prototype.constructor = SEA3D.ConeTwistConstraint;

SEA3D.ConeTwistConstraint.prototype.type = "ctwc";

//
//	Extension
//

SEA3D.File.setExtension( function () {

	// PHYSICS
	this.addClass( SEA3D.Sphere );
	this.addClass( SEA3D.Box );
	this.addClass( SEA3D.Cone );
	this.addClass( SEA3D.Capsule );
	this.addClass( SEA3D.Cylinder );
	this.addClass( SEA3D.ConvexGeometry );
	this.addClass( SEA3D.TriangleGeometry );
	this.addClass( SEA3D.Compound );
	this.addClass( SEA3D.RigidBody );
	this.addClass( SEA3D.P2PConstraint );
	this.addClass( SEA3D.HingeConstraint );
	this.addClass( SEA3D.ConeTwistConstraint );
	this.addClass( SEA3D.CarController );

} );

/**   _     _   _         _____  __   _______  ______
*    | |___| |_| |__    /__  |  |  |     |  _  | * *
*    | / _ \  _|    |    __\    |  |  \  |  _  |  U _
*    |_\___/\__|_||_| _ |____/____ |__ \_|_  |_|_____|
*
*    @author LoTh / http://3dflashlo.wordpress.com/
*    @author SUNAG / http://www.sunag.com.br/
*    @author Ammo.lab / https://github.com/lo-th/Ammo.lab/
*/

'use strict';

SEA3D.AMMO = {

	world: null,

	rigidBodies: [],
	rigidBodiesTarget: [],
	rigidBodiesEnabled: [],

	constraints: [],

	vehicles: [],
	vehiclesWheels: [],

	ACTIVE: 1,
	ISLAND_SLEEPING: 2,
	WANTS_DEACTIVATION: 3,
	DISABLE_DEACTIVATION: 4,
	DISABLE_SIMULATION: 5,
	VERSION: 0.8,

	init: function ( gravity, worldScale, broadphase ) {

		gravity = gravity !== undefined ? gravity : - 90.8;

		this.worldScale = worldScale == undefined ? 1 : worldScale;
		this.broadphase = broadphase == undefined ? 'bvt' : broadphase;

		this.solver = new Ammo.btSequentialImpulseConstraintSolver();
		this.collisionConfig = new Ammo.btDefaultCollisionConfiguration();
		this.dispatcher = new Ammo.btCollisionDispatcher( this.collisionConfig );

		switch ( this.broadphase ) {

			case 'bvt':

				this.broadphase = new Ammo.btDbvtBroadphase();

				break;

			case 'sap':

				this.broadphase = new Ammo.btAxisSweep3(
					new Ammo.btVector3( - this.worldScale, - this.worldScale, - this.worldScale ),
					new Ammo.btVector3( this.worldScale, this.worldScale, this.worldScale ),
					4096
				);

				break;

			case 'simple':

				this.broadphase = new Ammo.btSimpleBroadphase();

				break;

		}

		this.world = new Ammo.btDiscreteDynamicsWorld( this.dispatcher, this.broadphase, this.solver, this.collisionConfig );

		this.setGravity( gravity );

		console.log( "THREE.AMMO " + this.VERSION );

	},

	setGravity: function ( gravity ) {

		this.gravity = gravity;

		this.world.setGravity( new Ammo.btVector3( 0, gravity, 0 ) );

		return this;

	},
	getGravity: function () {

		return this.gravity;

	},

	setEnabledRigidBody: function ( rb, enabled ) {

		var index = this.rigidBodies.indexOf( rb );

		if ( this.rigidBodiesEnabled[ index ] == enabled ) return;

		if ( enabled ) this.world.addRigidBody( rb );
		else this.world.removeRigidBody( rb );

		this.rigidBodiesEnabled[ index ] = true;

		return this;

	},
	getEnabledRigidBody: function ( rb ) {

		return this.rigidBodiesEnabled[ this.rigidBodies.indexOf( rb ) ];

	},
	addRigidBody: function ( rb, target, enabled ) {

		enabled = enabled !== undefined ? enabled : true;

		this.rigidBodies.push( rb );
		this.rigidBodiesTarget.push( target );
		this.rigidBodiesEnabled.push( false );

		this.setEnabledRigidBody( rb, enabled );

		return this;

	},
	removeRigidBody: function ( rb, destroy ) {

		var index = this.rigidBodies.indexOf( rb );

		this.setEnabledRigidBody( rb, false );

		this.rigidBodies.splice( index, 1 );
		this.rigidBodiesTarget.splice( index, 1 );
		this.rigidBodiesEnabled.splice( index, 1 );

		if ( destroy ) Ammo.destroy( rb );

		return this;

	},
	containsRigidBody: function ( rb ) {

		return this.rigidBodies.indexOf( rb ) > - 1;

	},

	addConstraint: function ( ctrt, disableCollisionsBetweenBodies ) {

		disableCollisionsBetweenBodies = disableCollisionsBetweenBodies == undefined ? true : disableCollisionsBetweenBodies;

		this.constraints.push( ctrt );
		this.world.addConstraint( ctrt, disableCollisionsBetweenBodies );

		return this;

	},
	removeConstraint: function ( ctrt, destroy ) {

		this.constraints.splice( this.constraints.indexOf( ctrt ), 1 );
		this.world.removeConstraint( ctrt );

		if ( destroy ) Ammo.destroy( ctrt );

		return this;

	},
	containsConstraint: function ( ctrt ) {

		return this.constraints.indexOf( rb ) > - 1;

	},

	addVehicle: function ( vehicle, wheels ) {

		this.vehicles.push( vehicle );
		this.vehiclesWheels.push( wheels != undefined ? wheels : [] );

		this.world.addAction( vehicle );

		return this;

	},
	removeVehicle: function ( vehicle, destroy ) {

		var index = this.vehicles.indexOf( vehicle );

		this.vehicles.splice( index, 1 );
		this.vehiclesWheels.splice( index, 1 );

		this.world.removeAction( vehicle );

		if ( destroy ) Ammo.destroy( vehicle );

		return this;

	},
	containsVehicle: function ( vehicle ) {

		return this.vehicles.indexOf( vehicle ) > - 1;

	},

	createTriangleMesh: function ( geometry, index, removeDuplicateVertices ) {

		index = index == undefined ? - 1 : index;
		removeDuplicateVertices = removeDuplicateVertices == undefined ? false : removeDuplicateVertices;

		var mTriMesh = new Ammo.btTriangleMesh();

		var v0 = new Ammo.btVector3( 0, 0, 0 );
		var v1 = new Ammo.btVector3( 0, 0, 0 );
		var v2 = new Ammo.btVector3( 0, 0, 0 );

		var vertex = geometry.getAttribute( 'position' ).array;
		var indexes = geometry.getIndex().array;

		var group = index >= 0 ? geometry.groups[ index ] : undefined,
			start = group ? group.start : 0,
			count = group ? group.count : indexes.length;

		var scale = 1 / this.worldScale;

		for ( var idx = start; idx < count; idx += 3 ) {

			var vx1 = indexes[ idx ] * 3,
				vx2 = indexes[ idx + 1 ] * 3,
				vx3 = indexes[ idx + 2 ] * 3;

			v0.setValue( vertex[ vx1 ] * scale, vertex[ vx1 + 1 ] * scale, vertex[ vx1 + 2 ] * scale );
			v1.setValue( vertex[ vx2 ] * scale, vertex[ vx2 + 1 ] * scale, vertex[ vx2 + 2 ] * scale );
			v2.setValue( vertex[ vx3 ] * scale, vertex[ vx3 + 1 ] * scale, vertex[ vx3 + 2 ] * scale );

			mTriMesh.addTriangle( v0, v1, v2, removeDuplicateVertices );

		}

		return mTriMesh;

	},
	createConvexHull: function ( geometry, index ) {

		index = index == undefined ? - 1 : index;

		var mConvexHull = new Ammo.btConvexHullShape();

		var v0 = new Ammo.btVector3( 0, 0, 0 );

		var vertex = geometry.getAttribute( 'position' ).array;
		var indexes = geometry.getIndex().array;

		var group = index >= 0 ? geometry.groups[ index ] : undefined,
			start = group ? group.start : 0,
			count = group ? group.count : indexes.length;

		var scale = 1 / this.worldScale;

		for ( var idx = start; idx < count; idx += 3 ) {

			var vx1 = indexes[ idx ] * 3;

			var point = new Ammo.btVector3(
				vertex[ vx1 ] * scale, vertex[ vx1 + 1 ] * scale, vertex[ vx1 + 2 ] * scale
			);

			mConvexHull.addPoint( point );

		}

		return mConvexHull;

	},

	getTargetByRigidBody: function ( rb ) {

		return this.rigidBodiesTarget[ this.rigidBodies.indexOf( rb ) ];

	},
	getRigidBodyByTarget: function ( target ) {

		return this.rigidBodies[ this.rigidBodiesTarget.indexOf( target ) ];

	},
	getTransformFromMatrix: function ( mtx ) {

		var transform = new Ammo.btTransform();

		var pos = THREE.SEA3D.VECBUF.setFromMatrixPosition( mtx );
		transform.setOrigin( new Ammo.btVector3( pos.x, pos.y, pos.z ) );

		var scl = THREE.SEA3D.VECBUF.setFromMatrixScale( mtx );
		mtx.scale( scl.set( 1 / scl.x, 1 / scl.y, 1 / scl.z ) );

		var quat = new THREE.Quaternion().setFromRotationMatrix( mtx );

		var q = new Ammo.btQuaternion();
		q.setValue( quat.x, quat.y, quat.z, quat.w );
		transform.setRotation( q );

		Ammo.destroy( q );

		return transform;

	},
	getMatrixFromTransform: function ( transform ) {

		var position = new THREE.Vector3();
		var quaternion = new THREE.Quaternion();
		var scale = new THREE.Vector3( 1, 1, 1 );

		return function ( transform, matrix ) {

			matrix = matrix || new THREE.Matrix4();

			var pos = transform.getOrigin(),
				quat = transform.getRotation();

			position.set( pos.x(), pos.y(), pos.z() );
			quaternion.set( quat.x(), quat.y(), quat.z(), quat.w() );

			matrix.compose( position, quaternion, scale );

			return matrix;

		};

	}(),

	updateTargetTransform: function () {

		var matrix = new THREE.Matrix4();

		var position = new THREE.Vector3();
		var quaternion = new THREE.Quaternion();
		var scale = new THREE.Vector3( 1, 1, 1 );

		return function ( obj3d, transform, offset ) {

			var pos = transform.getOrigin(),
				quat = transform.getRotation();

			if ( offset ) {

				position.set( pos.x(), pos.y(), pos.z() );
				quaternion.set( quat.x(), quat.y(), quat.z(), quat.w() );

				matrix.compose( position, quaternion, scale );

				matrix.multiplyMatrices( matrix, offset );

				obj3d.position.setFromMatrixPosition( matrix );
				obj3d.quaternion.setFromRotationMatrix( matrix );

			} else {

				obj3d.position.set( pos.x(), pos.y(), pos.z() );
				obj3d.quaternion.set( quat.x(), quat.y(), quat.z(), quat.w() );

			}

			return this;

		};

	}(),
	update: function ( delta, iteration, fixedDelta ) {

		this.world.stepSimulation( delta, iteration || 0, fixedDelta || ( 60 / 1000 ) );

		var i, j;

		for ( i = 0; i < this.vehicles.length; i ++ ) {

			var vehicle = this.vehicles[ i ],
				numWheels = vehicle.getNumWheels(),
				wheels = this.vehiclesWheels[ i ];

			for ( j = 0; j < numWheels; j ++ ) {

				vehicle.updateWheelTransform( j, true );

				var wheelsTransform = vehicle.getWheelTransformWS( j ),
					wheelTarget = wheels[ j ];

				if ( wheelTarget ) {

					this.updateTargetTransform( wheelTarget, wheelsTransform, wheelTarget.physics ? wheelTarget.physics.offset : null );

				}

			}

		}

		for ( i = 0; i < this.rigidBodies.length; i ++ ) {

			var rb = this.rigidBodies[ i ],
				target = this.rigidBodiesTarget[ i ];

			if ( target && rb.isActive() ) {

				this.updateTargetTransform( target, rb.getWorldTransform(), target.physics ? target.physics.offset : null );

			}

		}

		return this;

	}
};

/**
 * 	SEA3D+AMMO for Three.JS
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

THREE.SEA3D.prototype.toAmmoVec3 = function ( v ) {

	return new Ammo.btVector3( v.x, v.y, v.z );

};

//
//	Sphere
//

THREE.SEA3D.prototype.readSphere = function ( sea ) {

	var shape = new Ammo.btSphereShape( sea.radius );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Box
//

THREE.SEA3D.prototype.readBox = function ( sea ) {

	var shape = new Ammo.btBoxShape( new Ammo.btVector3( sea.width * .5, sea.height * .5, sea.depth * .5 ) );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Cone
//

THREE.SEA3D.prototype.readCone = function ( sea ) {

	var shape = new Ammo.btConeShape( sea.radius, sea.height );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Cylinder
//

THREE.SEA3D.prototype.readCylinder = function ( sea ) {

	var shape = new Ammo.btCylinderShape( new Ammo.btVector3( sea.height, sea.radius, sea.radius ) );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Capsule
//

THREE.SEA3D.prototype.readCapsule = function ( sea ) {

	var shape = new Ammo.btCapsuleShape( sea.radius, sea.height );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Convex Geometry
//

THREE.SEA3D.prototype.readConvexGeometry = function ( sea ) {

	if ( this.config.convexHull ) {

		var shape = SEA3D.AMMO.createConvexHull( sea.geometry.tag, sea.subGeometryIndex );

	} else {

		var triMesh = SEA3D.AMMO.createTriangleMesh( sea.geometry.tag, sea.subGeometryIndex );

		var shape = new Ammo.btConvexTriangleMeshShape( triMesh, true );

	}

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Triangle Geometry
//

THREE.SEA3D.prototype.readTriangleGeometry = function ( sea ) {

	var triMesh = SEA3D.AMMO.createTriangleMesh( sea.geometry.tag, sea.subGeometryIndex );

	var shape = new Ammo.btBvhTriangleMeshShape( triMesh, true, true );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Compound
//

THREE.SEA3D.prototype.readCompound = function ( sea ) {

	var shape = new Ammo.btCompoundShape();

	for ( var i = 0; i < sea.compounds.length; i ++ ) {

		var compound = sea.compounds[ i ];

		THREE.SEA3D.MTXBUF.elements = compound.transform;

		var transform = SEA3D.AMMO.getTransformFromMatrix( THREE.SEA3D.MTXBUF );

		shape.addChildShape( transform, compound.shape.tag );

	}

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Rigid Body Base
//

THREE.SEA3D.prototype.readRigidBodyBase = function ( sea ) {

	var shape = sea.shape.tag,
		transform, target;

	if ( sea.target ) {

		target = sea.target.tag;

		target.physics = { enabled: true };
		target.updateMatrix();

		transform = SEA3D.AMMO.getTransformFromMatrix( sea.target.tag.matrix );

	} else {

		THREE.SEA3D.MTXBUF.fromArray( sea.transform );
		transform = SEA3D.AMMO.getTransformFromMatrix( THREE.SEA3D.MTXBUF );


	}

	var motionState = new Ammo.btDefaultMotionState( transform );
	var localInertia = new Ammo.btVector3( 0, 0, 0 );

	shape.calculateLocalInertia( sea.mass, localInertia );

	var info = new Ammo.btRigidBodyConstructionInfo( sea.mass, motionState, shape, localInertia );
	info.set_m_friction( sea.friction );
	info.set_m_restitution( sea.restitution );
	info.set_m_linearDamping( sea.linearDamping );
	info.set_m_angularDamping( sea.angularDamping );

	var rb = new Ammo.btRigidBody( info );

	if ( target ) {

		target.physics.rigidBody = rb;

		if ( sea.offset ) {

			target.physics.offset = new THREE.Matrix4().fromArray( sea.offset );

		}

	}

	Ammo.destroy( info );

	this.domain.rigidBodies = this.rigidBodies = this.rigidBodies || [];
	this.rigidBodies.push( this.objects[ "rb/" + sea.name ] = sea.tag = rb );

	return rb;

};

//
//	Rigid Body
//

THREE.SEA3D.prototype.readRigidBody = function ( sea ) {

	var rb = this.readRigidBodyBase( sea );

	SEA3D.AMMO.addRigidBody( rb, sea.target ? sea.target.tag : undefined, this.config.enabledPhysics );

};

//
//	Car Controller
//

THREE.SEA3D.prototype.readCarController = function ( sea ) {

	var body = this.readRigidBodyBase( sea );

	body.setActivationState( SEA3D.AMMO.DISABLE_DEACTIVATION );

	// Car

	var vehicleRayCaster = new Ammo.btDefaultVehicleRaycaster( SEA3D.AMMO.world );

	var tuning = new Ammo.btVehicleTuning();

	tuning.set_m_suspensionStiffness( sea.suspensionStiffness );
	tuning.set_m_suspensionDamping( sea.suspensionDamping );
	tuning.set_m_suspensionCompression( sea.suspensionCompression );
	tuning.set_m_maxSuspensionTravelCm( sea.maxSuspensionTravelCm );
	tuning.set_m_maxSuspensionForce( sea.maxSuspensionForce );
	tuning.set_m_frictionSlip( sea.frictionSlip );

	var vehicle = new Ammo.btRaycastVehicle( tuning, body, vehicleRayCaster ),
		wheels = [];

	vehicle.setCoordinateSystem( 0, 1, 2 );

	for ( var i = 0; i < sea.wheel.length; i ++ ) {

		var wheel = sea.wheel[ i ];

		var wheelInfo = vehicle.addWheel(
			this.toAmmoVec3( wheel.pos ),
			this.toAmmoVec3( wheel.dir ),
			this.toAmmoVec3( wheel.axle ),
			wheel.suspensionRestLength,
			wheel.radius,
			tuning,
			wheel.isFront
		);

		var target = wheels[ i ] = wheel.target ? wheel.target.tag : undefined;

		if ( target ) {

			target.physics = { enabled: true, rigidBody: wheelInfo };

			if ( wheel.offset ) {

				target.physics.offset = new THREE.Matrix4().fromArray( wheel.offset );

			}

			if ( target.parent ) {

				target.parent.remove( target );

			}

			if ( this.container ) {

				this.container.add( target );

			}

		}

		wheelInfo.set_m_suspensionStiffness( sea.suspensionStiffness );
		wheelInfo.set_m_wheelsDampingRelaxation( sea.dampingRelaxation );
		wheelInfo.set_m_wheelsDampingCompression( sea.dampingCompression );
		wheelInfo.set_m_frictionSlip( sea.frictionSlip );

	}

	SEA3D.AMMO.addVehicle( vehicle, wheels );
	SEA3D.AMMO.addRigidBody( body, sea.target ? sea.target.tag : undefined, this.config.enabledPhysics );

	this.domain.vehicles = this.vehicles = this.vehicles || [];
	this.vehicles.push( this.objects[ "vhc/" + sea.name ] = sea.tag = vehicle );

};

//
//	P2P Constraint
//

THREE.SEA3D.prototype.readP2PConstraint = function ( sea ) {

	var ctrt;

	if ( sea.targetB ) {

		ctrt = new Ammo.btPoint2PointConstraint(
			sea.targetA.tag,
			sea.targetB.tag,
			this.toAmmoVec3( sea.pointA ),
			this.toAmmoVec3( sea.pointB )
		);

	} else {

		ctrt = new Ammo.btPoint2PointConstraint(
			sea.targetA.tag,
			this.toAmmoVec3( sea.pointA )
		);

	}

	SEA3D.AMMO.addConstraint( ctrt );

	this.domain.constraints = this.constraints = this.constraints || [];
	this.constraints.push( this.objects[ "ctnt/" + sea.name ] = sea.tag = ctrt );

};

//
//	Hinge Constraint
//

THREE.SEA3D.prototype.readHingeConstraint = function ( sea ) {

	var ctrt;

	if ( sea.targetB ) {

		ctrt = new Ammo.btHingeConstraint(
			sea.targetA.tag,
			sea.targetB.tag,
			this.toAmmoVec3( sea.pointA ),
			this.toAmmoVec3( sea.pointB ),
			this.toAmmoVec3( sea.axisA ),
			this.toAmmoVec3( sea.axisB ),
			false
		);

	} else {

		ctrt = new Ammo.btHingeConstraint(
			sea.targetA.tag,
			this.toAmmoVec3( sea.pointA ),
			this.toAmmoVec3( sea.axisA ),
			false
		);

	}

	if ( sea.limit ) {

		ctrt.setLimit( sea.limit.low, sea.limit.high, sea.limit.softness, sea.limit.biasFactor, sea.limit.relaxationFactor );

	}

	if ( sea.angularMotor ) {

		ctrt.enableAngularMotor( true, sea.angularMotor.velocity, sea.angularMotor.impulse );

	}

	SEA3D.AMMO.addConstraint( ctrt );

	this.domain.constraints = this.constraints = this.constraints || [];
	this.constraints.push( this.objects[ "ctnt/" + sea.name ] = sea.tag = ctrt );

};

//
//	Cone Twist Constraint
//

THREE.SEA3D.prototype.readConeTwistConstraint = function ( sea ) {

	var ctrt;

	if ( sea.targetB ) {

		ctrt = new Ammo.btConeTwistConstraint(
			sea.targetA.tag,
			sea.targetB.tag,
			this.toAmmoVec3( sea.pointA ),
			this.toAmmoVec3( sea.pointB ),
			false
		);

	} else {

		ctrt = new Ammo.btConeTwistConstraint(
			sea.targetA.tag,
			this.toAmmoVec3( sea.pointA ),
			false
		);

	}

	SEA3D.AMMO.addConstraint( ctrt );

	this.domain.constraints = this.constraints = this.constraints || [];
	this.constraints.push( this.objects[ "ctnt/" + sea.name ] = sea.tag = ctrt );

};

//
//	Domain
//

THREE.SEA3D.Domain.prototype.enabledPhysics = function ( enabled ) {

	var i = this.rigidBodies ? this.rigidBodies.length : 0;

	while ( i -- ) {

		SEA3D.AMMO.setEnabledRigidBody( this.rigidBodies[ i ], enabled );

	}

};

THREE.SEA3D.Domain.prototype.applyContainerTransform = function () {

	this.container.updateMatrix();

	var matrix = this.container.matrix.clone();

	this.container.position.set( 0, 0, 0 );
	this.container.rotation.set( 0, 0, 0 );
	this.container.scale.set( 1, 1, 1 );

	this.applyTransform( matrix );

};

THREE.SEA3D.Domain.prototype.applyTransform = function ( matrix ) {

	var mtx = THREE.SEA3D.MTXBUF, vec = THREE.SEA3D.VECBUF;

	var i = this.rigidBodies ? this.rigidBodies.length : 0,
		childs = this.container ? this.container.children : [],
		targets = [];

	while ( i -- ) {

		var rb = this.rigidBodies[ i ],
			target = SEA3D.AMMO.getTargetByRigidBody( rb ),
			transform = rb.getWorldTransform(),
			transformMatrix = SEA3D.AMMO.getMatrixFromTransform( transform );

		transformMatrix.multiplyMatrices( transformMatrix, matrix );

		transform = SEA3D.AMMO.getTransformFromMatrix( transformMatrix );

		rb.setWorldTransform( transform );

		if ( target ) targets.push( target );

	}

	for ( i = 0; i < childs.length; i ++ ) {

		var obj3d = childs[ i ];

		if ( targets.indexOf( obj3d ) > - 1 ) continue;

		obj3d.updateMatrix();

		mtx.copy( obj3d.matrix );

		mtx.multiplyMatrices( matrix, mtx );

		obj3d.position.setFromMatrixPosition( mtx );
		obj3d.scale.setFromMatrixScale( mtx );

		// ignore rotation scale

		mtx.scale( vec.set( 1 / obj3d.scale.x, 1 / obj3d.scale.y, 1 / obj3d.scale.z ) );
		obj3d.rotation.setFromRotationMatrix( mtx );

	}

};

//
//	Extension
//

THREE.SEA3D.Domain.prototype.getShape = THREE.SEA3D.prototype.getShape = function ( name ) {

	return this.objects[ "shpe/" + name ];

};

THREE.SEA3D.Domain.prototype.getRigidBody = THREE.SEA3D.prototype.getRigidBody = function ( name ) {

	return this.objects[ "rb/" + name ];

};

THREE.SEA3D.Domain.prototype.getConstraint = THREE.SEA3D.prototype.getConstraint = function ( name ) {

	return this.objects[ "ctnt/" + name ];

};

THREE.SEA3D.EXTENSIONS_LOADER.push( {

	parse: function () {

		delete this.shapes;
		delete this.rigidBodies;
		delete this.vehicles;
		delete this.constraints;

	},

	setTypeRead: function () {

		// CONFIG

		this.config.physics = this.config.physics !== undefined ? this.config.physics : true;
		this.config.convexHull = this.config.convexHull !== undefined ? this.config.convexHull : true;
		this.config.enabledPhysics = this.config.enabledPhysics !== undefined ? this.config.enabledPhysics : true;

		if ( this.config.physics ) {

			// SHAPES

			this.file.typeRead[ SEA3D.Sphere.prototype.type ] = this.readSphere;
			this.file.typeRead[ SEA3D.Box.prototype.type ] = this.readBox;
			this.file.typeRead[ SEA3D.Capsule.prototype.type ] = this.readCapsule;
			this.file.typeRead[ SEA3D.Cone.prototype.type ] = this.readCone;
			this.file.typeRead[ SEA3D.Cylinder.prototype.type ] = this.readCylinder;
			this.file.typeRead[ SEA3D.ConvexGeometry.prototype.type ] = this.readConvexGeometry;
			this.file.typeRead[ SEA3D.TriangleGeometry.prototype.type ] = this.readTriangleGeometry;
			this.file.typeRead[ SEA3D.Compound.prototype.type ] = this.readCompound;

			// CONSTRAINTS

			this.file.typeRead[ SEA3D.P2PConstraint.prototype.type ] = this.readP2PConstraint;
			this.file.typeRead[ SEA3D.HingeConstraint.prototype.type ] = this.readHingeConstraint;
			this.file.typeRead[ SEA3D.ConeTwistConstraint.prototype.type ] = this.readConeTwistConstraint;

			// PHYSICS

			this.file.typeRead[ SEA3D.RigidBody.prototype.type ] = this.readRigidBody;
			this.file.typeRead[ SEA3D.CarController.prototype.type ] = this.readCarController;

		}

	}
} );

THREE.SEA3D.EXTENSIONS_DOMAIN.push( {

	dispose: function () {

		var i;

		i = this.rigidBodies ? this.rigidBodies.length : 0;
		while ( i -- ) SEA3D.AMMO.removeRigidBody( this.rigidBodies[ i ], true );

		i = this.vehicles ? this.vehicles.length : 0;
		while ( i -- ) SEA3D.AMMO.removeVehicle( this.vehicles[ i ], true );

		i = this.constraints ? this.constraints.length : 0;
		while ( i -- ) SEA3D.AMMO.removeConstraint( this.constraints[ i ], true );

		i = this.shapes ? this.shapes.length : 0;
		while ( i -- ) Ammo.destroy( this.shapes[ i ] );

	}

} );

