/**
 * 	SEA3D+AMMO for Three.JS
 * 	@author Sunag / http://www.sunag.com.br/
 */

'use strict';

THREE.SEA3D.prototype.toAmmoVec3 = function( v ) {

	return new Ammo.btVector3( v.x, v.y, v.z );

};

//
//	Sphere
//

THREE.SEA3D.prototype.readSphere = function( sea ) {

	var shape = new Ammo.btSphereShape( sea.radius );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Box
//

THREE.SEA3D.prototype.readBox = function( sea ) {

	var shape = new Ammo.btBoxShape( new Ammo.btVector3( sea.width * .5, sea.height * .5, sea.depth * .5 ) );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Cone
//

THREE.SEA3D.prototype.readCone = function( sea ) {

	var shape = new Ammo.btConeShape( sea.radius, sea.height );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Cylinder
//

THREE.SEA3D.prototype.readCylinder = function( sea ) {

	var shape = new Ammo.btCylinderShape( new Ammo.btVector3( sea.height, sea.radius, sea.radius ) );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Capsule
//

THREE.SEA3D.prototype.readCapsule = function( sea ) {

	var shape = new Ammo.btCapsuleShape( sea.radius, sea.height );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Convex Geometry
//

THREE.SEA3D.prototype.readConvexGeometry = function( sea ) {

	if ( this.config.convexHull ) {

		var shape = THREE.AMMO.createConvexHull( sea.geometry.tag, sea.subGeometryIndex );

	}
	else {

		var triMesh = THREE.AMMO.createTriangleMesh( sea.geometry.tag, sea.subGeometryIndex );

		var shape = new Ammo.btConvexTriangleMeshShape( triMesh, true );

	}

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Triangle Geometry
//

THREE.SEA3D.prototype.readTriangleGeometry = function( sea ) {

	var triMesh = THREE.AMMO.createTriangleMesh( sea.geometry.tag, sea.subGeometryIndex );

	var shape = new Ammo.btBvhTriangleMeshShape( triMesh, true, true );

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Compound
//

THREE.SEA3D.prototype.readCompound = function( sea ) {

	var shape = new Ammo.btCompoundShape();

	for ( var i = 0; i < sea.compounds.length; i ++ ) {

		var compound = sea.compounds[ i ];

		THREE.SEA3D.MTXBUF.elements = compound.transform;

		var transform = THREE.AMMO.transformFromMatrix( THREE.SEA3D.MTXBUF );

		shape.addChildShape( transform, compound.shape.tag );

	}

	this.domain.shapes = this.shapes = this.shapes || [];
	this.shapes.push( this.objects[ "shpe/" + sea.name ] = sea.tag = shape );

};

//
//	Rigid Body Base
//

THREE.SEA3D.prototype.readRigidBodyBase = function( sea ) {

	var shape = sea.shape.tag,
		transform;

	if ( sea.target ) {

		transform = THREE.AMMO.transformFromObject3D( sea.target.tag );

	}
	else {

		THREE.SEA3D.MTXBUF.elements = sea.transform;

		transform = THREE.AMMO.transformFromMatrix( THREE.SEA3D.MTXBUF );

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

	this.domain.rigidBodies = this.rigidBodies = this.rigidBodies || [];
	this.rigidBodies.push( this.objects[ "rb/" + sea.name ] = sea.tag = rb );

	return rb;

};

//
//	Rigid Body
//

THREE.SEA3D.prototype.readRigidBody = function( sea ) {

	var rb = this.readRigidBodyBase( sea );

	THREE.AMMO.addRigidBody( rb, sea.target ? sea.target.tag : undefined, sea.offset ? new THREE.Matrix4().elements.set( sea.offset ) : undefined );

};

//
//	Car Controller
//

THREE.SEA3D.prototype.readCarController = function( sea ) {

	var body = this.readRigidBodyBase( sea );

	body.setActivationState( THREE.AMMO.DISABLE_DEACTIVATION );

	// Car

	var vehicleRayCaster = new Ammo.btDefaultVehicleRaycaster( THREE.AMMO.world );

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

			if ( target.parent ) {

				target.parent.remove( target );

				if ( this.container ) {

					this.container.add( target );

				}

			}

		}

		wheelInfo.set_m_suspensionStiffness( sea.suspensionStiffness );
		wheelInfo.set_m_wheelsDampingRelaxation( sea.dampingRelaxation );
		wheelInfo.set_m_wheelsDampingCompression( sea.dampingCompression );
		wheelInfo.set_m_frictionSlip( sea.frictionSlip );

	}

	THREE.AMMO.addVehicle( vehicle, wheels );
	THREE.AMMO.addRigidBody( body, sea.target ? sea.target.tag : undefined, sea.offset ? new THREE.Matrix4().elements.set( sea.offset ) : undefined );

	this.domain.vehicles = this.vehicles = this.vehicles || [];
	this.vehicles.push( this.objects[ "vhc/" + sea.name ] = sea.tag = vehicle );

};

//
//	P2P Constraint
//

THREE.SEA3D.prototype.readP2PConstraint = function( sea ) {

	var ctrt;

	if ( sea.targetB ) {

		ctrt = new Ammo.btPoint2PointConstraint(
			sea.targetA.tag,
			sea.targetB.tag,
			this.toAmmoVec3( sea.pointA ),
			this.toAmmoVec3( sea.pointB )
		);

	}
	else {

		ctrt = new Ammo.btPoint2PointConstraint(
			sea.targetA.tag,
			this.toAmmoVec3( sea.pointA )
		);

	}

	THREE.AMMO.addConstraint( ctrt );

	this.domain.constraints = this.constraints = this.constraints || [];
	this.constraints.push( this.objects[ "ctnt/" + sea.name ] = sea.tag = ctrt );

};

//
//	Hinge Constraint
//

THREE.SEA3D.prototype.readHingeConstraint = function( sea ) {

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

	}
	else {

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

	THREE.AMMO.addConstraint( ctrt );

	this.domain.constraints = this.constraints = this.constraints || [];
	this.constraints.push( this.objects[ "ctnt/" + sea.name ] = sea.tag = ctrt );

};

//
//	Cone Twist Constraint
//

THREE.SEA3D.prototype.readConeTwistConstraint = function( sea ) {

	var ctrt;

	if ( sea.targetB ) {

		ctrt = new Ammo.btConeTwistConstraint(
			sea.targetA.tag,
			sea.targetB.tag,
			this.toAmmoVec3( sea.pointA ),
			this.toAmmoVec3( sea.pointB ),
			false
		);

	}
	else {

		ctrt = new Ammo.btConeTwistConstraint(
			sea.targetA.tag,
			this.toAmmoVec3( sea.pointA ),
			false
		);

	}

	THREE.AMMO.addConstraint( ctrt );

	this.domain.constraints = this.constraints = this.constraints || [];
	this.constraints.push( this.objects[ "ctnt/" + sea.name ] = sea.tag = ctrt );

};

//
//	Extension
//

THREE.SEA3D.prototype.getShape = function( name ) {

	return this.objects[ "shpe/" + name ];

};

THREE.SEA3D.prototype.getRigidBody = function( name ) {

	return this.objects[ "rb/" + name ];

};

THREE.SEA3D.prototype.getConstraints = function( name ) {

	return this.objects[ "ctnt/" + name ];

};

SEA3D.Domain.prototype.getShape = THREE.SEA3D.prototype.getShape;
SEA3D.Domain.prototype.getRigidBody = THREE.SEA3D.prototype.getRigidBody;

THREE.SEA3D.EXTENSIONS.push( function() {

	// CONFIG

	this.config.physics = this.config.physics == undefined ? true : this.config.physics;
	this.config.convexHull = this.config.convexHull == undefined ? true : this.config.convexHull;

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

} );

THREE.SEA3D.EXTENSIONS_PARSE.push( function() {

	delete this.shapes;
	delete this.rigidBodies;
	delete this.vehicles;
	delete this.constraints;

} );

THREE.SEA3D.EXTENSIONS_DOMAIN.push( {

	dispose : function () {

		var i;

		i = this.rigidBodies ? this.rigidBodies.length : 0;
		while ( i -- ) THREE.AMMO.removeRigidBody( this.rigidBodies[ i ], true );

		i = this.vehicles ? this.vehicles.length : 0;
		while ( i -- ) THREE.AMMO.removeVehicle( this.vehicles[ i ], true );

		i = this.constraints ? this.constraints.length : 0;
		while ( i -- ) THREE.AMMO.removeConstraint( this.constraints[ i ], true );

		i = this.shapes ? this.shapes.length : 0;
		while ( i -- ) Ammo.destroy( this.shapes[ i ] );

	}

} );
