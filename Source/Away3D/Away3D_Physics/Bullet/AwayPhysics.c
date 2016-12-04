
/*
compile: g++ -I./ AwayPhysics.c libbulletdynamics.a libbulletcollision.a libbulletmath.a -emit-swc=AWPC_Run -flto-api=exports.txt -fno-exceptions -O4 -o AwayPhysics.swc
*/

#include <stdlib.h>
#include <stdio.h>
#include <vector>
#include "AS3/AS3.h"
#include "btBulletDynamicsCommon.h"
#include "BulletCollision/CollisionShapes/btHeightfieldTerrainShape.h"
#include "BulletCollision/CollisionDispatch/btGhostObject.h"
#include "BulletCollision/Gimpact/btGImpactShape.h"
//#include "BulletCollision/Gimpact/btGImpactCollisionAlgorithm.h"
#include "BulletDynamics/Character/btKinematicCharacterController.h"


struct RayInfo
{
	RayInfo(btCollisionObject* collisionObject, const btVector3& rayFromLocal, const btVector3&	rayToLocal)
	:m_collisionObject(collisionObject),
	m_rayFromLocal(rayFromLocal),
	m_rayToLocal(rayToLocal)
	{
	}
	btCollisionObject* m_collisionObject;
	btVector3 m_rayFromLocal;
	btVector3 m_rayToLocal;
};
btAlignedObjectArray<RayInfo*> rays;
btCollisionWorld* collisionWorld;

void tickCallback(btDynamicsWorld *world, btScalar timeStep) {
    
    btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
    
	int rayLen = rays.size();
	for (int i=0;i<rayLen;i++)
	{
		RayInfo* ray = rays[i];
		btVector3 rayFrom = ray->m_collisionObject->m_worldTransform*ray->m_rayFromLocal;
		btVector3 rayTo = ray->m_collisionObject->m_worldTransform*ray->m_rayToLocal;
		btCollisionWorld::ClosestRayResultCallback resultCallback(rayFrom, rayTo);
		collisionWorld->rayTest(rayFrom,rayTo,resultCallback);
		if (resultCallback.hasHit()){
			btManifoldPoint* mpt=new btManifoldPoint();
			mpt->m_localPointA=rayFrom;
			mpt->m_localPointB=resultCallback.m_collisionObject->m_worldTransform.invXform(resultCallback.m_hitPointWorld);
			mpt->m_normalWorldOnB=resultCallback.m_hitNormalWorld;
			mpt->m_appliedImpulse=0;
			
			inline_as3(
				"import com.adobe.flascc.CModule;\n"
	  			"CModule.rootSprite.rayCastCallback(%0,%1,%2);\n"
                : : "r"(ray->m_collisionObject), "r"(mpt), "r"(resultCallback.m_collisionObject)
            );
			
			delete mpt;
		}
	}

	if(dynamicsWorld->m_collisionCallbackOn){
		int numManifolds = dynamicsWorld->getDispatcher()->getNumManifolds();
		for (int i=0;i<numManifolds;i++)
		{
			btPersistentManifold* contactManifold = dynamicsWorld->getDispatcher()->getManifoldByIndexInternal(i);
			const btCollisionObject* obA = contactManifold->getBody0();
			const btCollisionObject* obB = contactManifold->getBody1();

			if (obA->getCollisionFlags() & btCollisionObject::CF_CUSTOM_MATERIAL_CALLBACK){
				int numContacts = contactManifold->getNumContacts();
				if(numContacts>0){
					btManifoldPoint* mpt=new btManifoldPoint();
					mpt->m_localPointA=btVector3(0,0,0);
					mpt->m_localPointB=btVector3(0,0,0);
					mpt->m_normalWorldOnB=btVector3(0,0,0);
					mpt->m_appliedImpulse=0;
					for (int j=0;j<numContacts;j++)
					{
						btManifoldPoint& pt = contactManifold->getContactPoint(j);
						mpt->m_localPointA+=pt.m_localPointA;
						mpt->m_localPointB+=pt.m_localPointB;
						mpt->m_normalWorldOnB+=pt.m_normalWorldOnB;
						mpt->m_appliedImpulse+=pt.m_appliedImpulse;
					}
					mpt->m_localPointA/=numContacts;
					mpt->m_localPointB/=numContacts;
					mpt->m_normalWorldOnB.normalize();
					mpt->m_appliedImpulse/=numContacts;
					
					inline_as3(
						"import com.adobe.flascc.CModule;\n"
	  					"CModule.rootSprite.collisionCallback(%0,%1,%2);\n"
                		: : "r"(obA), "r"(mpt), "r"(obB)
           			);

					delete mpt;
				}
			}

			if(obB->getCollisionFlags() & btCollisionObject::CF_CUSTOM_MATERIAL_CALLBACK){
				int numContacts = contactManifold->getNumContacts();
				if(numContacts>0){
					btManifoldPoint* mpt=new btManifoldPoint();
					mpt->m_localPointA=btVector3(0,0,0);
					mpt->m_localPointB=btVector3(0,0,0);
					mpt->m_normalWorldOnB=btVector3(0,0,0);
					mpt->m_appliedImpulse=0;
					for (int j=0;j<numContacts;j++)
					{
						btManifoldPoint& pt = contactManifold->getContactPoint(j);
						mpt->m_localPointA+=pt.m_localPointB;
						mpt->m_localPointB+=pt.m_localPointA;
						mpt->m_normalWorldOnB+=pt.m_normalWorldOnB;
						mpt->m_appliedImpulse+=pt.m_appliedImpulse;
					}
					mpt->m_localPointA/=numContacts;
					mpt->m_localPointB/=numContacts;
					mpt->m_normalWorldOnB/=-1;
					mpt->m_normalWorldOnB.normalize();
					mpt->m_appliedImpulse/=numContacts;
					
					inline_as3(
						"import com.adobe.flascc.CModule;\n"
	  					"CModule.rootSprite.collisionCallback(%0,%1,%2);\n"
                		: : "r"(obB), "r"(mpt), "r"(obA)
           			);

					delete mpt;
				}
			}
		}
	}
}

void vector3() __attribute__((used, annotate("as3sig:public function vector3():uint"), annotate("as3package:AWPC_Run")));
void vector3() {
	btVector3* vect = new btVector3();
	AS3_Return(vect);
}
void matrix3x3() __attribute__((used, annotate("as3sig:public function matrix3x3():uint"), annotate("as3package:AWPC_Run")));
void matrix3x3() {
	btMatrix3x3* mat = new btMatrix3x3();
	AS3_Return(mat);
}

/// create the discrete dynamics world with btDbvtBroadphase
void createDiscreteDynamicsWorldWithDbvtInC() __attribute__((used, annotate("as3sig:public function createDiscreteDynamicsWorldWithDbvtInC():uint"), annotate("as3package:AWPC_Run")));
void createDiscreteDynamicsWorldWithDbvtInC() {
	btDefaultCollisionConfiguration* collisionConfiguration = new btDefaultCollisionConfiguration();
	btCollisionDispatcher* dispatcher = new	btCollisionDispatcher(collisionConfiguration);
	btBroadphaseInterface* overlappingPairCache = new btDbvtBroadphase();
	overlappingPairCache->getOverlappingPairCache()->setInternalGhostPairCallback(new btGhostPairCallback());
	btSequentialImpulseConstraintSolver* solver = new btSequentialImpulseConstraintSolver();

	collisionWorld = new btDiscreteDynamicsWorld(dispatcher,overlappingPairCache,solver,collisionConfiguration);
	((btDiscreteDynamicsWorld*)collisionWorld)->setInternalTickCallback(tickCallback, 0, true);

	AS3_Return(collisionWorld);
}

/// create the discrete dynamics world with btAxisSweep3
void createDiscreteDynamicsWorldWithAxisSweep3InC() __attribute__((used, annotate("as3sig:public function createDiscreteDynamicsWorldWithAxisSweep3InC(as3_worldMin:uint,as3_worldMax:uint):uint"), annotate("as3package:AWPC_Run")));
void createDiscreteDynamicsWorldWithAxisSweep3InC() {
	btVector3* worldMin;
	btVector3* worldMax;
	AS3_GetScalarFromVar(worldMin, as3_worldMin);
	AS3_GetScalarFromVar(worldMax, as3_worldMax);

	btDefaultCollisionConfiguration* collisionConfiguration = new btDefaultCollisionConfiguration();
	btCollisionDispatcher* dispatcher = new	btCollisionDispatcher(collisionConfiguration);

	btBroadphaseInterface* overlappingPairCache = new btAxisSweep3(*worldMin,*worldMax);
	overlappingPairCache->getOverlappingPairCache()->setInternalGhostPairCallback(new btGhostPairCallback());
	btSequentialImpulseConstraintSolver* solver = new btSequentialImpulseConstraintSolver();

	collisionWorld = new btDiscreteDynamicsWorld(dispatcher,overlappingPairCache,solver,collisionConfiguration);
	((btDiscreteDynamicsWorld*)collisionWorld)->setInternalTickCallback(tickCallback, 0, true);

	AS3_Return(collisionWorld);
}

void disposeDynamicsWorldInC() __attribute__((used, annotate("as3sig:public function disposeDynamicsWorldInC():uint"), annotate("as3package:AWPC_Run")));
void disposeDynamicsWorldInC() {
	delete collisionWorld;
	AS3_Return(0);
}

// create a static plane shape
void createStaticPlaneShapeInC() __attribute__((used, annotate("as3sig:public function createStaticPlaneShapeInC(as3_normal:uint,as3_constant:Number):uint"), annotate("as3package:AWPC_Run")));
void createStaticPlaneShapeInC(){
	btVector3* normal;
	float constant;
	AS3_GetScalarFromVar(normal, as3_normal);
	AS3_GetScalarFromVar(constant, as3_constant);
	
	btCollisionShape* shape = new btStaticPlaneShape(*normal,constant);

	AS3_Return(shape);
}

// create a cube
void createBoxShapeInC() __attribute__((used, annotate("as3sig:public function createBoxShapeInC(as3_extents:uint):uint"), annotate("as3package:AWPC_Run")));
void createBoxShapeInC(){
	btVector3* extents;
	AS3_GetScalarFromVar(extents, as3_extents);

	btCollisionShape* shape = new btBoxShape(btVector3(extents->m_floats[0]/2,extents->m_floats[1]/2,extents->m_floats[2]/2));

	AS3_Return(shape);
}

// create a sphere
void createSphereShapeInC() __attribute__((used, annotate("as3sig:public function createSphereShapeInC(as3_radius:Number):uint"), annotate("as3package:AWPC_Run")));
void createSphereShapeInC(){
	float radius;
	AS3_GetScalarFromVar(radius, as3_radius);

	btCollisionShape* shape =  new btSphereShape(radius);

	AS3_Return(shape);
}

// create a cylinder
void createCylinderShapeInC() __attribute__((used, annotate("as3sig:public function createCylinderShapeInC(as3_extents:uint):uint"), annotate("as3package:AWPC_Run")));
void createCylinderShapeInC(){
	btVector3* extents;
	AS3_GetScalarFromVar(extents, as3_extents);

	btCollisionShape* shape =  new btCylinderShape(btVector3(extents->m_floats[0]/2,extents->m_floats[1]/2,extents->m_floats[2]/2));
	
	AS3_Return(shape);
}

// create a capsule
void createCapsuleShapeInC() __attribute__((used, annotate("as3sig:public function createCapsuleShapeInC(as3_radius:Number,as3_height:Number):uint"), annotate("as3package:AWPC_Run")));
void createCapsuleShapeInC(){
	float radius,height;
	AS3_GetScalarFromVar(radius, as3_radius);
	AS3_GetScalarFromVar(height, as3_height);
	
	btCollisionShape* shape =  new btCapsuleShape(radius,height);
	
	AS3_Return(shape);
}

// create a cone
void createConeShapeInC() __attribute__((used, annotate("as3sig:public function createConeShapeInC(as3_radius:Number,as3_height:Number):uint"), annotate("as3package:AWPC_Run")));
void createConeShapeInC(){
	float radius,height;
	AS3_GetScalarFromVar(radius, as3_radius);
	AS3_GetScalarFromVar(height, as3_height);
	
	btCollisionShape* shape =  new btConeShape(radius,height);
	
	AS3_Return(shape);
}

// create a compound shape
void createCompoundShapeInC() __attribute__((used, annotate("as3sig:public function createCompoundShapeInC():uint"), annotate("as3package:AWPC_Run")));
void createCompoundShapeInC(){

	btCollisionShape* shape =  new btCompoundShape();
	
	AS3_Return(shape);
}

//add a child shape to compound shape
void addCompoundChildInC() __attribute__((used, annotate("as3sig:public function addCompoundChildInC(as3_cshape:uint,as3_shape:uint,as3_pos:uint,as3_col:uint):uint"), annotate("as3package:AWPC_Run")));
void addCompoundChildInC(){
	btCompoundShape* cshape;
	btCollisionShape* shape;
	btVector3* pos;
	btMatrix3x3* col;
	
	AS3_GetScalarFromVar(cshape, as3_cshape);
	AS3_GetScalarFromVar(shape, as3_shape);
	AS3_GetScalarFromVar(pos, as3_pos);
	AS3_GetScalarFromVar(col, as3_col);

	btTransform localTrans;
	localTrans.setIdentity();
	localTrans.setOrigin(*pos);
	localTrans.setBasis(*col);

	cshape->addChildShape(localTrans,shape);

	AS3_Return(0);
}

//remove a child shape from compound shape by index
void removeCompoundChildInC() __attribute__((used, annotate("as3sig:public function removeCompoundChildInC(as3_cshape:uint,as3_index:int):uint"), annotate("as3package:AWPC_Run")));
void removeCompoundChildInC(){
	btCompoundShape* cshape;
	int index;
	AS3_GetScalarFromVar(cshape, as3_cshape);
	AS3_GetScalarFromVar(index, as3_index);
	
	cshape->removeChildShapeByIndex(index);

	
	AS3_Return(0);
}

void createHeightmapDataBufferInC() __attribute__((used, annotate("as3sig:public function createHeightmapDataBufferInC(as3_size:int):uint"), annotate("as3package:AWPC_Run")));
void createHeightmapDataBufferInC(){
	int size;
	AS3_GetScalarFromVar(size, as3_size);

	btScalar* heightmapData = new btScalar[size];

	AS3_Return(heightmapData);
}

void removeHeightmapDataBufferInC() __attribute__((used, annotate("as3sig:public function removeHeightmapDataBufferInC(as3_heightmapData:uint):uint"), annotate("as3package:AWPC_Run")));
void removeHeightmapDataBufferInC(){
	btScalar* heightmapData;
	AS3_GetScalarFromVar(heightmapData, as3_heightmapData);

	delete [] heightmapData;

	AS3_Return(0);
}

void createTerrainShapeInC() __attribute__((used, annotate("as3sig:public function createTerrainShapeInC(as3_heightmapData:uint,as3_sw:int,as3_sh:int,as3_width:Number,as3_length:Number,as3_heightScale:Number,as3_minHeight:Number,as3_maxHeight:Number,as3_flipQuadEdges:int):uint"), annotate("as3package:AWPC_Run")));
void createTerrainShapeInC(){
	btScalar* heightmapData;
	int sw,sh,flipQuadEdges;
	float width,length,heightScale,minHeight,maxHeight;
	
	AS3_GetScalarFromVar(heightmapData, as3_heightmapData);
	AS3_GetScalarFromVar(sw, as3_sw);
	AS3_GetScalarFromVar(sh, as3_sh);
	AS3_GetScalarFromVar(flipQuadEdges, as3_flipQuadEdges);
	AS3_GetScalarFromVar(width, as3_width);
	AS3_GetScalarFromVar(length, as3_length);
	AS3_GetScalarFromVar(heightScale, as3_heightScale);
	AS3_GetScalarFromVar(minHeight, as3_minHeight);
	AS3_GetScalarFromVar(maxHeight, as3_maxHeight);

	btHeightfieldTerrainShape* heightFieldShape = new btHeightfieldTerrainShape(sw,sh,heightmapData, heightScale,minHeight, maxHeight,1, PHY_FLOAT,flipQuadEdges==1);
	heightFieldShape->setUseDiamondSubdivision(true);
	heightFieldShape->setLocalScaling(btVector3(width/sw,1,length/sh));
	
	AS3_Return(heightFieldShape);
}

void createTriangleIndexDataBufferInC() __attribute__((used, annotate("as3sig:public function createTriangleIndexDataBufferInC(as3_size:int):uint"), annotate("as3package:AWPC_Run")));
void createTriangleIndexDataBufferInC(){
	int size;
	AS3_GetScalarFromVar(size, as3_size);

	int* indexData = new int[size];

	AS3_Return(indexData);
}

void removeTriangleIndexDataBufferInC() __attribute__((used, annotate("as3sig:public function removeTriangleIndexDataBufferInC(as3_indexData:uint):uint"), annotate("as3package:AWPC_Run")));
void removeTriangleIndexDataBufferInC(){
	int* indexData;
	AS3_GetScalarFromVar(indexData, as3_indexData);

	delete [] indexData;

	AS3_Return(0);
}

void createTriangleVertexDataBufferInC() __attribute__((used, annotate("as3sig:public function createTriangleVertexDataBufferInC(as3_size:int):uint"), annotate("as3package:AWPC_Run")));
void createTriangleVertexDataBufferInC(){
	int size;
	AS3_GetScalarFromVar(size, as3_size);

	btScalar* vertexData = new btScalar[size];

	AS3_Return(vertexData);
}

void removeTriangleVertexDataBufferInC() __attribute__((used, annotate("as3sig:public function removeTriangleVertexDataBufferInC(as3_vertexData:uint):uint"), annotate("as3package:AWPC_Run")));
void removeTriangleVertexDataBufferInC(){
	btScalar* vertexData;
	AS3_GetScalarFromVar(vertexData, as3_vertexData);

	delete [] vertexData;

	AS3_Return(0);
}

void createTriangleIndexVertexArrayInC() __attribute__((used, annotate("as3sig:public function createTriangleIndexVertexArrayInC(as3_numTriangles:int,as3_indexBase:uint,as3_numVertices:int,as3_vertexBase:uint):uint"), annotate("as3package:AWPC_Run")));
void createTriangleIndexVertexArrayInC(){
	int numTriangles;
	int* indexBase;
	int numVertices;
	btScalar* vertexBase;
	AS3_GetScalarFromVar(numTriangles, as3_numTriangles);
	AS3_GetScalarFromVar(indexBase, as3_indexBase);
	AS3_GetScalarFromVar(numVertices, as3_numVertices);
	AS3_GetScalarFromVar(vertexBase, as3_vertexBase);

	int indexStride = 3*sizeof(int);
	int vertStride = 3*sizeof(btScalar);

	btTriangleIndexVertexArray* indexVertexArrays=new btTriangleIndexVertexArray(numTriangles,indexBase,indexStride,numVertices,vertexBase,vertStride);

	AS3_Return(indexVertexArrays);
}

void createBvhTriangleMeshShapeInC() __attribute__((used, annotate("as3sig:public function createBvhTriangleMeshShapeInC(as3_indexVertexArrays:uint,as3_useQuantizedAabbCompression:int,as3_buildBvh:int):uint"), annotate("as3package:AWPC_Run")));
void createBvhTriangleMeshShapeInC(){
	btTriangleIndexVertexArray* indexVertexArrays;
	int useQuantizedAabbCompression;
	int buildBvh;
	AS3_GetScalarFromVar(indexVertexArrays, as3_indexVertexArrays);
	AS3_GetScalarFromVar(useQuantizedAabbCompression, as3_useQuantizedAabbCompression);
	AS3_GetScalarFromVar(buildBvh, as3_buildBvh);

	btBvhTriangleMeshShape* bvhTriangleMesh=new btBvhTriangleMeshShape(indexVertexArrays,useQuantizedAabbCompression==1,buildBvh==1);

	AS3_Return(bvhTriangleMesh);
}

void createConvexHullShapeInC() __attribute__((used, annotate("as3sig:public function createConvexHullShapeInC(as3_numPoints:int,as3_points:uint):uint"), annotate("as3package:AWPC_Run")));
void createConvexHullShapeInC(){
	int numPoints;
	btScalar* points;
	AS3_GetScalarFromVar(numPoints, as3_numPoints);
	AS3_GetScalarFromVar(points, as3_points);

	btConvexHullShape* convexHullShape=new btConvexHullShape(points, numPoints, sizeof(btScalar) * 3);

	AS3_Return(convexHullShape);
}
/*
void createGImpactMeshShapeInC() __attribute__((used, annotate("as3sig:public function createGImpactMeshShapeInC(as3_indexVertexArrays:uint):uint")));
void createGImpactMeshShapeInC(){
	btTriangleIndexVertexArray* indexVertexArrays;
	AS3_GetScalarFromVar(indexVertexArrays, as3_indexVertexArrays);

	btGImpactMeshShape* gimpactMesh = new btGImpactMeshShape(indexVertexArrays);
	gimpactMesh->updateBound();

	btCollisionDispatcher * dispatcher = static_cast<btCollisionDispatcher *>(collisionWorld ->getDispatcher());
	btGImpactCollisionAlgorithm::registerAlgorithm(dispatcher);

	AS3_Return(gimpactMesh);
}
*/
void createTriangleShapeInC() __attribute__((used, annotate("as3sig:public function createTriangleShapeInC(as3_p0:uint,as3_p1:uint,as3_p2:uint):uint"), annotate("as3package:AWPC_Run")));
void createTriangleShapeInC(){
	btVector3* p0;
	btVector3* p1;
	btVector3* p2;
	AS3_GetScalarFromVar(p0, as3_p0);
	AS3_GetScalarFromVar(p1, as3_p1);
	AS3_GetScalarFromVar(p2, as3_p2);

	btTriangleShapeEx* triangleShape=new btTriangleShapeEx(*p0,*p1,*p2);

	AS3_Return(triangleShape);
}

void disposeCollisionShapeInC() __attribute__((used, annotate("as3sig:public function disposeCollisionShapeInC(as3_shape:uint):uint"), annotate("as3package:AWPC_Run")));
void disposeCollisionShapeInC(){
	btCollisionShape* shape;
	AS3_GetScalarFromVar(shape, as3_shape);
	delete shape;
	AS3_Return(0);
}

void setShapeScalingInC() __attribute__((used, annotate("as3sig:public function setShapeScalingInC(as3_shape:uint,as3_scale:uint):uint"), annotate("as3package:AWPC_Run")));
void setShapeScalingInC(){
	btCollisionShape* shape;
	btVector3* scale;
	AS3_GetScalarFromVar(shape, as3_shape);
	AS3_GetScalarFromVar(scale, as3_scale);
	
	shape->setLocalScaling(*scale);

	AS3_Return(0);
}

void createCollisionObjectInC() __attribute__((used, annotate("as3sig:public function createCollisionObjectInC(as3_shape:uint):uint"), annotate("as3package:AWPC_Run")));
void createCollisionObjectInC(){
	btCollisionShape* shape;
	AS3_GetScalarFromVar(shape, as3_shape);
	
	btCollisionObject* obj = new btCollisionObject();
	obj->setCollisionShape(shape);
	
	AS3_Return(obj);
}
void addCollisionObjectInC() __attribute__((used, annotate("as3sig:public function addCollisionObjectInC(as3_obj:uint,as3_group:int,as3_mask:int):uint"), annotate("as3package:AWPC_Run")));
void addCollisionObjectInC(){
	btCollisionObject* obj;
	int group;
	int mask;
	AS3_GetScalarFromVar(obj, as3_obj);
	AS3_GetScalarFromVar(group, as3_group);
	AS3_GetScalarFromVar(mask, as3_mask);

	collisionWorld->addCollisionObject(obj,group,mask);
	
	AS3_Return(0);
}
void removeCollisionObjectInC() __attribute__((used, annotate("as3sig:public function removeCollisionObjectInC(as3_obj:uint):uint"), annotate("as3package:AWPC_Run")));
void removeCollisionObjectInC(){
	btCollisionObject* obj;
	AS3_GetScalarFromVar(obj, as3_obj);

	collisionWorld->removeCollisionObject(obj);

	AS3_Return(0);
}

void addRayInC() __attribute__((used, annotate("as3sig:public function addRayInC(as3_obj:uint,as3_from:uint,as3_to:uint):uint"), annotate("as3package:AWPC_Run")));
void addRayInC(){
	btCollisionObject* obj;
	btVector3* from;
	btVector3* to;
	AS3_GetScalarFromVar(obj, as3_obj);
	AS3_GetScalarFromVar(from, as3_from);
	AS3_GetScalarFromVar(to, as3_to);
	
	RayInfo* ray=new RayInfo(obj,*from,*to);
	rays.push_back(ray);
	
	AS3_Return(ray);
}
void removeRayInC() __attribute__((used, annotate("as3sig:public function removeRayInC(as3_ray:uint):uint"), annotate("as3package:AWPC_Run")));
void removeRayInC(){
	RayInfo* ray;
	AS3_GetScalarFromVar(ray, as3_ray);
	
	rays.remove(ray);
	
	
	delete ray;
	
	AS3_Return(0);
}

// create rigidbody
void createBodyInC() __attribute__((used, annotate("as3sig:public function createBodyInC(as3_shape:uint,as3_mass:Number):uint"), annotate("as3package:AWPC_Run")));
void createBodyInC(){
	btCollisionShape* shape;
	float mass;
	
	AS3_GetScalarFromVar(shape, as3_shape);
	AS3_GetScalarFromVar(mass, as3_mass);
	
	//rigidbody is dynamic if and only if mass is non zero, otherwise static
	bool isDynamic = (mass != 0.f);

	btVector3 localInertia(0,0,0);
	if (isDynamic)
		shape->calculateLocalInertia(mass,localInertia);

	btDefaultMotionState* myMotionState = new btDefaultMotionState();
	btRigidBody::btRigidBodyConstructionInfo rbInfo(mass,myMotionState,shape,localInertia);
	btRigidBody* body = new btRigidBody(rbInfo);

	AS3_Return(body);
}

void setBodyMassInC() __attribute__((used, annotate("as3sig:public function setBodyMassInC(as3_body:uint,as3_mass:Number):uint"), annotate("as3package:AWPC_Run")));
void setBodyMassInC(){
	btRigidBody* body;
	float mass;
	AS3_GetScalarFromVar(body, as3_body);
	AS3_GetScalarFromVar(mass, as3_mass);	
	
	
	btCollisionShape* shape=body->getCollisionShape();
	
	
	bool isDynamic = (mass != 0.f);
	btVector3 localInertia(0,0,0);
	if (isDynamic)
		shape->calculateLocalInertia(mass,localInertia);
		
	
	body->setMassProps(mass, localInertia);
	
	body->updateInertiaTensor();
	
	btDiscreteDynamicsWorld* dynamicsWorld = (btDiscreteDynamicsWorld*)collisionWorld;
	if(dynamicsWorld->getCollisionObjectArray().findLinearSearch(body) != dynamicsWorld->getNumCollisionObjects()){
		short int group = body->getBroadphaseHandle()->m_collisionFilterGroup;
		short int mask = body->getBroadphaseHandle()->m_collisionFilterMask;
		dynamicsWorld->removeRigidBody(body);
		dynamicsWorld->addRigidBody(body,group,mask);
	}
	AS3_Return(0);
}

//add the body to the dynamics world
void addBodyInC() __attribute__((used, annotate("as3sig:public function addBodyInC(as3_body:uint):uint"), annotate("as3package:AWPC_Run")));
void addBodyInC(){
	btRigidBody* body;
	AS3_GetScalarFromVar(body, as3_body);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->addRigidBody(body);

	AS3_Return(0);
}

//add a body to the dynamics world with group and mask
void addBodyWithGroupInC() __attribute__((used, annotate("as3sig:public function addBodyWithGroupInC(as3_body:uint,as3_group:int,as3_mask:int):uint"), annotate("as3package:AWPC_Run")));
void addBodyWithGroupInC(){
	btRigidBody* body;
	int group;
	int mask;
	AS3_GetScalarFromVar(body, as3_body);
	AS3_GetScalarFromVar(group, as3_group);
	AS3_GetScalarFromVar(mask, as3_mask);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->addRigidBody(body,group,mask);

	AS3_Return(0);
}

/// remove rigidbody
void removeBodyInC() __attribute__((used, annotate("as3sig:public function removeBodyInC(as3_body:uint):uint"), annotate("as3package:AWPC_Run")));
void removeBodyInC(){
	btRigidBody* body;
	AS3_GetScalarFromVar(body, as3_body);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->removeRigidBody(body);

	
	AS3_Return(0);
}

void disposeCollisionObjectInC() __attribute__((used, annotate("as3sig:public function disposeCollisionObjectInC(as3_obj:uint):uint"), annotate("as3package:AWPC_Run")));
void disposeCollisionObjectInC(){
	btCollisionObject* obj;
	AS3_GetScalarFromVar(obj, as3_obj);

	delete obj;
	
	AS3_Return(0);
}

//create a btPoint2PointConstraint with one rigidbody
void createP2PConstraint1InC() __attribute__((used, annotate("as3sig:public function createP2PConstraint1InC(as3_bodyA:uint,as3_pivotInA:uint):uint"), annotate("as3package:AWPC_Run")));
void createP2PConstraint1InC(){
	btRigidBody* bodyA;
	btVector3* pivotInA;
	AS3_GetScalarFromVar(bodyA, as3_bodyA);
	AS3_GetScalarFromVar(pivotInA, as3_pivotInA);

	btPoint2PointConstraint* p2p = new btPoint2PointConstraint(*bodyA,*pivotInA);

	AS3_Return(p2p);
}

//create a btPoint2PointConstraint between tow rigidbodies
void createP2PConstraint2InC() __attribute__((used, annotate("as3sig:public function createP2PConstraint2InC(as3_bodyA:uint,as3_bodyB:uint,as3_pivotInA:uint,as3_pivotInB:uint):uint"), annotate("as3package:AWPC_Run")));
void createP2PConstraint2InC(){
	btRigidBody* bodyA;
	btRigidBody* bodyB;
	btVector3* pivotInA;
	btVector3* pivotInB;
	AS3_GetScalarFromVar(bodyA, as3_bodyA);
	AS3_GetScalarFromVar(bodyB, as3_bodyB);
	AS3_GetScalarFromVar(pivotInA, as3_pivotInA);
	AS3_GetScalarFromVar(pivotInB, as3_pivotInB);

	btPoint2PointConstraint* p2p = new btPoint2PointConstraint(*bodyA,*bodyB,*pivotInA,*pivotInB);

	AS3_Return(p2p);
}

void createHingeConstraint1InC() __attribute__((used, annotate("as3sig:public function createHingeConstraint1InC(as3_bodyA:uint,as3_pivotInA:uint,as3_axisInA:uint,as3_useReferenceFrameA:int):uint"), annotate("as3package:AWPC_Run")));
void createHingeConstraint1InC(){
	btRigidBody* bodyA;
	btVector3* pivotInA;
	btVector3* axisInA;
	int useReferenceFrameA;
	AS3_GetScalarFromVar(bodyA, as3_bodyA);
	AS3_GetScalarFromVar(pivotInA, as3_pivotInA);
	AS3_GetScalarFromVar(axisInA, as3_axisInA);
	AS3_GetScalarFromVar(useReferenceFrameA, as3_useReferenceFrameA);

	btHingeConstraint* hinge = new btHingeConstraint(*bodyA, *pivotInA, *axisInA,useReferenceFrameA==1);

	AS3_Return(hinge);
}

void createHingeConstraint2InC() __attribute__((used, annotate("as3sig:public function createHingeConstraint2InC(as3_bodyA:uint,as3_bodyB:uint,as3_pivotInA:uint,as3_pivotInB:uint,as3_axisInA:uint,as3_axisInB:uint,as3_useReferenceFrameA:int):uint"), annotate("as3package:AWPC_Run")));
void createHingeConstraint2InC(){
	btRigidBody* bodyA;
	btRigidBody* bodyB;
	btVector3* pivotInA;
	btVector3* pivotInB;
	btVector3* axisInA;
	btVector3* axisInB;
	int useReferenceFrameA;
	AS3_GetScalarFromVar(bodyA, as3_bodyA);
	AS3_GetScalarFromVar(bodyB, as3_bodyB);
	AS3_GetScalarFromVar(pivotInA, as3_pivotInA);
	AS3_GetScalarFromVar(pivotInB, as3_pivotInB);
	AS3_GetScalarFromVar(axisInA, as3_axisInA);
	AS3_GetScalarFromVar(axisInB, as3_axisInB);
	AS3_GetScalarFromVar(useReferenceFrameA, as3_useReferenceFrameA);

	btHingeConstraint* hinge = new btHingeConstraint(*bodyA,*bodyB, *pivotInA,*pivotInB, *axisInA,*axisInB,useReferenceFrameA==1);

	AS3_Return(hinge);
}

void createConeTwistConstraint1() __attribute__((used, annotate("as3sig:public function createConeTwistConstraint1(as3_bodyA:uint,as3_pivotInA:uint,as3_rot:uint):uint"), annotate("as3package:AWPC_Run")));
void createConeTwistConstraint1(){
	btRigidBody* bodyA;
	btVector3* pivotInA;
	btMatrix3x3* rot;
	AS3_GetScalarFromVar(bodyA, as3_bodyA);
	AS3_GetScalarFromVar(pivotInA, as3_pivotInA);
	AS3_GetScalarFromVar(rot, as3_rot);

	btTransform frameInA;
	frameInA.setIdentity();
	frameInA.setOrigin(*pivotInA);

	frameInA.setBasis(*rot);

	btConeTwistConstraint* coneTwist=new btConeTwistConstraint(*bodyA,frameInA);

	AS3_Return(coneTwist);
}

void createConeTwistConstraint2() __attribute__((used, annotate("as3sig:public function createConeTwistConstraint2(as3_bodyA:uint,as3_pivotInA:uint,as3_rotationInA:uint,as3_bodyB:uint,as3_pivotInB:uint,as3_rotationInB:uint):uint"), annotate("as3package:AWPC_Run")));
void createConeTwistConstraint2(){
	btRigidBody* bodyA;
	btVector3* pivotInA;
	btMatrix3x3* rotationInA;
	btRigidBody* bodyB;
	btVector3* pivotInB;
	btMatrix3x3* rotationInB;
	
	AS3_GetScalarFromVar(bodyA, as3_bodyA);
	AS3_GetScalarFromVar(pivotInA, as3_pivotInA);
	AS3_GetScalarFromVar(rotationInA, as3_rotationInA);
	AS3_GetScalarFromVar(bodyB, as3_bodyB);
	AS3_GetScalarFromVar(pivotInB, as3_pivotInB);
	AS3_GetScalarFromVar(rotationInB, as3_rotationInB);

	btTransform frameInA;
	frameInA.setIdentity();
	frameInA.setOrigin(*pivotInA);
	frameInA.setBasis(*rotationInA);

	btTransform frameInB;
	frameInB.setIdentity();
	frameInB.setOrigin(*pivotInB);
	frameInB.setBasis(*rotationInB);

	btConeTwistConstraint* coneTwist=new btConeTwistConstraint(*bodyA,*bodyB,frameInA,frameInB);

	AS3_Return(coneTwist);
}

void createGeneric6DofConstraint1() __attribute__((used, annotate("as3sig:public function createGeneric6DofConstraint1(as3_bodyA:uint,as3_pivotInA:uint,as3_rot:uint,as3_useLinearReferenceFrameA:int):uint"), annotate("as3package:AWPC_Run")));
void createGeneric6DofConstraint1(){
	btRigidBody* bodyA;
	btVector3* pivotInA;
	btMatrix3x3* rot;
	int useLinearReferenceFrameA;
	AS3_GetScalarFromVar(bodyA, as3_bodyA);
	AS3_GetScalarFromVar(pivotInA, as3_pivotInA);
	AS3_GetScalarFromVar(rot, as3_rot);
	AS3_GetScalarFromVar(useLinearReferenceFrameA, as3_useLinearReferenceFrameA);

	btTransform frameInA;
	frameInA.setIdentity();
	frameInA.setOrigin(*pivotInA);
	frameInA.setBasis(*rot);

	btGeneric6DofConstraint* generic6Dof=new btGeneric6DofConstraint(*bodyA,frameInA,useLinearReferenceFrameA==1);

	AS3_Return(generic6Dof);
}

void createGeneric6DofConstraint2() __attribute__((used, annotate("as3sig:public function createGeneric6DofConstraint2(as3_bodyA:uint,as3_pivotInA:uint,as3_rotationInA:uint,as3_bodyB:uint,as3_pivotInB:uint,as3_rotationInB:uint,as3_useLinearReferenceFrameA:int):uint"), annotate("as3package:AWPC_Run")));
void createGeneric6DofConstraint2(){
	btRigidBody* bodyA;
	btVector3* pivotInA;
	btMatrix3x3* rotationInA;
	btRigidBody* bodyB;
	btVector3* pivotInB;
	btMatrix3x3* rotationInB;
	int useLinearReferenceFrameA;
	
	AS3_GetScalarFromVar(bodyA, as3_bodyA);
	AS3_GetScalarFromVar(pivotInA, as3_pivotInA);
	AS3_GetScalarFromVar(rotationInA, as3_rotationInA);
	AS3_GetScalarFromVar(bodyB, as3_bodyB);
	AS3_GetScalarFromVar(pivotInB, as3_pivotInB);
	AS3_GetScalarFromVar(rotationInB, as3_rotationInB);
	AS3_GetScalarFromVar(useLinearReferenceFrameA, as3_useLinearReferenceFrameA);
	
	btTransform frameInA;
	frameInA.setIdentity();
	frameInA.setOrigin(*pivotInA);
	frameInA.setBasis(*rotationInA);

	btTransform frameInB;
	frameInB.setIdentity();
	frameInB.setOrigin(*pivotInB);
	frameInB.setBasis(*rotationInB);

	btGeneric6DofConstraint* generic6Dof=new btGeneric6DofConstraint(*bodyA,*bodyB,frameInA,frameInB,useLinearReferenceFrameA==1);
	
	AS3_Return(generic6Dof);
}

//add a constraint to the dynamics world
void addConstraintInC() __attribute__((used, annotate("as3sig:public function addConstraintInC(as3_constraint:uint,as3_disableCollisions:int):uint"), annotate("as3package:AWPC_Run")));
void addConstraintInC(){
	btTypedConstraint* constraint;
	int disableCollisions;
	AS3_GetScalarFromVar(constraint, as3_constraint);
	AS3_GetScalarFromVar(disableCollisions, as3_disableCollisions);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->addConstraint(constraint,disableCollisions==1);
	
	AS3_Return(0);
}

/// remove constraint
void removeConstraintInC() __attribute__((used, annotate("as3sig:public function removeConstraintInC(as3_constraint:uint):uint"), annotate("as3package:AWPC_Run")));
void removeConstraintInC(){
	btTypedConstraint* constraint;
	AS3_GetScalarFromVar(constraint, as3_constraint);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->removeConstraint(constraint);

	
	AS3_Return(0);
}

void disposeConstraintInC() __attribute__((used, annotate("as3sig:public function disposeConstraintInC(as3_constraint:uint):uint"), annotate("as3package:AWPC_Run")));
void disposeConstraintInC(){
	btTypedConstraint* constraint;
	AS3_GetScalarFromVar(constraint, as3_constraint);

	delete constraint;
	
	AS3_Return(0);
}

void createVehicleInC() __attribute__((used, annotate("as3sig:public function createVehicleInC(as3_chassis:uint,as3_suspensionStiffness:Number,as3_suspensionCompression:Number,as3_suspensionDamping:Number,as3_maxSuspensionTravelCm:Number,as3_frictionSlip:Number,as3_maxSuspensionForce:Number):uint"), annotate("as3package:AWPC_Run")));
void createVehicleInC() {
	btRigidBody* chassis;
	float suspensionStiffness;
	float suspensionCompression;
	float suspensionDamping;
	float maxSuspensionTravelCm;
	float frictionSlip;
	float maxSuspensionForce;
	AS3_GetScalarFromVar(chassis, as3_chassis);
	AS3_GetScalarFromVar(suspensionStiffness, as3_suspensionStiffness);
	AS3_GetScalarFromVar(suspensionCompression, as3_suspensionCompression);
	AS3_GetScalarFromVar(suspensionDamping, as3_suspensionDamping);
	AS3_GetScalarFromVar(maxSuspensionTravelCm, as3_maxSuspensionTravelCm);
	AS3_GetScalarFromVar(frictionSlip, as3_frictionSlip);
	AS3_GetScalarFromVar(maxSuspensionForce, as3_maxSuspensionForce);

	btRaycastVehicle::btVehicleTuning m_tuning;
	m_tuning.m_suspensionStiffness=suspensionStiffness;
	m_tuning.m_suspensionCompression=suspensionCompression;
	m_tuning.m_suspensionDamping=suspensionDamping;
	m_tuning.m_maxSuspensionTravelCm=maxSuspensionTravelCm;
	m_tuning.m_frictionSlip=frictionSlip;
	m_tuning.m_maxSuspensionForce=maxSuspensionForce;

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	btVehicleRaycaster*	m_vehicleRayCaster = new btDefaultVehicleRaycaster(dynamicsWorld);
	btRaycastVehicle* m_vehicle = new btRaycastVehicle(m_tuning,chassis,m_vehicleRayCaster);
	m_vehicle->setCoordinateSystem(0,1,2);

	AS3_Return(m_vehicle);
}

void addVehicleWheelInC() __attribute__((used, annotate("as3sig:public function addVehicleWheelInC(as3_vehicle:uint,as3_connectionPointCS0:uint,as3_wheelDirectionCS0:uint,as3_wheelAxleCS:uint,as3_suspensionStiffness:Number,as3_suspensionCompression:Number,as3_suspensionDamping:Number,as3_maxSuspensionTravelCm:Number,as3_frictionSlip:Number,as3_maxSuspensionForce:Number,as3_suspensionRestLength:Number,as3_wheelRadius:Number,as3_isFrontWheel:int):uint"), annotate("as3package:AWPC_Run")));
void addVehicleWheelInC(){
	btRaycastVehicle* m_vehicle;
	btVector3* connectionPointCS0;
	btVector3* wheelDirectionCS0;
	btVector3* wheelAxleCS;
	float suspensionStiffness;
	float suspensionCompression;
	float suspensionDamping;
	float maxSuspensionTravelCm;
	float frictionSlip;
	float maxSuspensionForce;
	float suspensionRestLength;
	float wheelRadius;
	int isFrontWheel;
	AS3_GetScalarFromVar(m_vehicle, as3_vehicle);
	AS3_GetScalarFromVar(connectionPointCS0, as3_connectionPointCS0);
	AS3_GetScalarFromVar(wheelDirectionCS0, as3_wheelDirectionCS0);
	AS3_GetScalarFromVar(wheelAxleCS, as3_wheelAxleCS);
	AS3_GetScalarFromVar(suspensionStiffness, as3_suspensionStiffness);
	AS3_GetScalarFromVar(suspensionCompression, as3_suspensionCompression);
	AS3_GetScalarFromVar(suspensionDamping, as3_suspensionDamping);
	AS3_GetScalarFromVar(maxSuspensionTravelCm, as3_maxSuspensionTravelCm);
	AS3_GetScalarFromVar(frictionSlip, as3_frictionSlip);
	AS3_GetScalarFromVar(maxSuspensionForce, as3_maxSuspensionForce);
	AS3_GetScalarFromVar(suspensionRestLength, as3_suspensionRestLength);
	AS3_GetScalarFromVar(wheelRadius, as3_wheelRadius);
	AS3_GetScalarFromVar(isFrontWheel, as3_isFrontWheel);

	btRaycastVehicle::btVehicleTuning m_tuning;
	m_tuning.m_suspensionStiffness=suspensionStiffness;
	m_tuning.m_suspensionCompression=suspensionCompression;
	m_tuning.m_suspensionDamping=suspensionDamping;
	m_tuning.m_maxSuspensionTravelCm=maxSuspensionTravelCm;
	m_tuning.m_frictionSlip=frictionSlip;
	m_tuning.m_maxSuspensionForce=maxSuspensionForce;

	m_vehicle->addWheel(*connectionPointCS0,*wheelDirectionCS0,*wheelAxleCS,suspensionRestLength,wheelRadius,m_tuning,isFrontWheel==1);

	AS3_Return(&m_vehicle->getWheelInfo(m_vehicle->getNumWheels()-1));
}

void addVehicleInC() __attribute__((used, annotate("as3sig:public function addVehicleInC(as3_vehicle:uint):uint"), annotate("as3package:AWPC_Run")));
void addVehicleInC(){
	btActionInterface* vehicle;
	AS3_GetScalarFromVar(vehicle, as3_vehicle);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->addVehicle(vehicle);

	AS3_Return(0);
}

void removeVehicleInC() __attribute__((used, annotate("as3sig:public function removeVehicleInC(as3_vehicle:uint):uint"), annotate("as3package:AWPC_Run")));
void removeVehicleInC(){
	btActionInterface* vehicle;
	AS3_GetScalarFromVar(vehicle, as3_vehicle);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->removeVehicle(vehicle);
	
	AS3_Return(0);
}

void disposeVehicleInC() __attribute__((used, annotate("as3sig:public function disposeVehicleInC(as3_vehicle:uint):uint"), annotate("as3package:AWPC_Run")));
void disposeVehicleInC(){
	btActionInterface* vehicle;
	AS3_GetScalarFromVar(vehicle, as3_vehicle);

	delete vehicle;
	
	AS3_Return(0);
}

void createGhostObjectInC() __attribute__((used, annotate("as3sig:public function createGhostObjectInC(as3_shape:uint):uint"), annotate("as3package:AWPC_Run")));
void createGhostObjectInC(){
	btCollisionShape* shape;
	AS3_GetScalarFromVar(shape, as3_shape);

	btPairCachingGhostObject* ghostObject = new btPairCachingGhostObject();
	ghostObject->setCollisionShape(shape);

	AS3_Return(ghostObject);
}

void createCharacterInC() __attribute__((used, annotate("as3sig:public function createCharacterInC(as3_ghostObject:uint,as3_shape:uint,as3_stepHeight:Number,as3_upAxis:int):uint"), annotate("as3package:AWPC_Run")));
void createCharacterInC(){
	btPairCachingGhostObject* ghostObject;
	btConvexShape* shape;
	float stepHeight;
	int upAxis;
	AS3_GetScalarFromVar(ghostObject, as3_ghostObject);
	AS3_GetScalarFromVar(shape, as3_shape);
	AS3_GetScalarFromVar(stepHeight, as3_stepHeight);
	AS3_GetScalarFromVar(upAxis, as3_upAxis);

	btKinematicCharacterController* character = new btKinematicCharacterController (ghostObject,shape,stepHeight,upAxis);

	AS3_Return(character);
}

void addCharacterInC() __attribute__((used, annotate("as3sig:public function addCharacterInC(as3_character:uint,as3_group:int,as3_mask:int):uint"), annotate("as3package:AWPC_Run")));
void addCharacterInC(){
	btKinematicCharacterController* character;
	int group;
	int mask;
	AS3_GetScalarFromVar(character, as3_character);
	AS3_GetScalarFromVar(group, as3_group);
	AS3_GetScalarFromVar(mask, as3_mask);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->addCollisionObject(character->m_ghostObject,group,mask);
	dynamicsWorld->addCharacter(character);

	AS3_Return(0);
}

void removeCharacterInC() __attribute__((used, annotate("as3sig:public function removeCharacterInC(as3_character:uint):uint"), annotate("as3package:AWPC_Run")));
void removeCharacterInC(){
	btKinematicCharacterController* character;
	AS3_GetScalarFromVar(character, as3_character);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->removeCollisionObject(character->m_ghostObject);
	
	dynamicsWorld->removeCharacter(character);
	
	AS3_Return(0);
}

void disposeCharacterInC() __attribute__((used, annotate("as3sig:public function disposeCharacterInC(as3_character:uint):uint"), annotate("as3package:AWPC_Run")));
void disposeCharacterInC(){
	btKinematicCharacterController* character;
	AS3_GetScalarFromVar(character, as3_character);

	delete character;
	
	AS3_Return(0);
}

/// physic step
void physicsStepInC() __attribute__((used, annotate("as3sig:public function physicsStepInC(as3_timestep:Number,as3_maxsubstep:int,as3_fixedtime:Number):uint"), annotate("as3package:AWPC_Run")));
void physicsStepInC() {
	float timestep;
	int maxsubstep;
	float fixedtime;
	AS3_GetScalarFromVar(timestep, as3_timestep);
	AS3_GetScalarFromVar(maxsubstep, as3_maxsubstep);
	AS3_GetScalarFromVar(fixedtime, as3_fixedtime);

	btDiscreteDynamicsWorld* dynamicsWorld=(btDiscreteDynamicsWorld*)collisionWorld;
	dynamicsWorld->stepSimulation(timestep,maxsubstep,fixedtime);

	int vehiclesLen=dynamicsWorld->m_vehicles.size();
	for (int i=0;i<vehiclesLen;i++)
	{
		btRaycastVehicle* vehicle=(btRaycastVehicle*)dynamicsWorld->m_vehicles[i];
		int wheelLen=vehicle->getNumWheels();
		for (int j=0;j<wheelLen;j++){
			vehicle->updateWheelTransform(j,true);
		}
	}

	AS3_Return(0);
}

int main() {

	AS3_GoAsync();
	
	return 0;
}