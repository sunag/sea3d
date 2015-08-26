package com.adobe.flascc
{
	import flash.display.Sprite;
	
	import AWPC_Run.CModule;
	
	import awayphysics.collision.dispatch.AWPCollisionObject;
	import awayphysics.dynamics.AWPDynamicsWorld;
	
	public class Console extends Sprite
	{
		private var _physicsWorld:AWPDynamicsWorld;
		
		public function Console(physicsWorld:AWPDynamicsWorld)
		{
			CModule.rootSprite = this;
			_physicsWorld = physicsWorld;
		}
		public function collisionCallback(obj1:uint, mpt:uint, obj2:uint) : void {
			var obj:AWPCollisionObject = _physicsWorld.collisionObjects[obj1.toString()];
			if(obj) obj.collisionCallback(mpt,_physicsWorld.collisionObjects[obj2.toString()]);
		}
		public function rayCastCallback(obj1:uint, mpt:uint, obj2:uint) : void {
			var obj:AWPCollisionObject = _physicsWorld.collisionObjects[obj1.toString()];
			if(obj) obj.rayCastCallback(mpt,_physicsWorld.collisionObjects[obj2.toString()]);
		}
	}
}