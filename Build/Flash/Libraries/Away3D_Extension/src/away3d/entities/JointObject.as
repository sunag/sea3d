/*
*
* Copyright (c) 2013 Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

package away3d.entities
{
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.JointPose;
	import away3d.arcane;
	import away3d.containers.ObjectContainer3D;
	import away3d.core.base.Geometry;
	import away3d.core.base.Object3D;
	import away3d.core.math.MathConsts;
	
	import flash.geom.Vector3D;

	use namespace arcane;
	
	public class JointObject extends Mesh
	{
		private static const NULL:Geometry = new Geometry();
		
		private var _mesh : Mesh
		private var _index : int;
		private var _animationState : SkeletonAnimator;		
		private var _autoUpdate : Boolean = false; 				
		
		public function JointObject(mesh : Mesh = null, jointIndex : uint = 0, autoUpdate : Boolean = true, geometry : Geometry = null)
		{			
			super(geometry || NULL);
						
			_index = jointIndex;
			_autoUpdate = autoUpdate;
			
			target = mesh;			
		}
		
		public function set target(target:Mesh):void
		{
			_mesh = target;
			_animationState = _mesh ? _mesh.animator as SkeletonAnimator : null;
			this.jointIndex = _index;
		}
		
		public function get target():Mesh
		{
			return _mesh;
		}
		
		public function get joint():JointPose
		{
			return _animationState.globalPose.jointPoses[_index];
		}
		
		public function set jointIndex(value:uint):void
		{
			_index = value;
			//name = jointName;
		}
		
		public function get jointIndex():uint
		{
			return _index;
		}
		
		public function set jointName(value:String):void
		{
			jointIndex = _animationState.skeleton.jointIndexFromName(value);
		}
		
		public function get jointName():String
		{
			return _animationState.skeleton.joints[_index].name;
		}
		
		public function set autoUpdate(value:Boolean):void
		{
			if (_autoUpdate == value) return;
			_autoUpdate = value;			
			internalUpdate();
		}
		
		public function get autoUpdate():Boolean
		{
			return _autoUpdate;
		}
		
		arcane override function internalUpdate():void
		{			
			super.internalUpdate();
		
			if (_autoUpdate)
			{
				update();
			
				implicitPartition.markForUpdate(this);
			}
		}
		
		public function update():void
		{
			var joint : JointPose = _animationState.globalPose.jointPoses[_index];
			
			var rot : Vector3D = joint.orientation.toEulerAngles(_rot);
			rot.scaleBy(MathConsts.RADIANS_TO_DEGREES);
			
			position = joint.translation;
			rotation = rot;			
		}
		
		override public function clone():Object3D
		{
			var clone:JointObject = new JointObject(_mesh, _index, _autoUpdate, geometry);
			
			clone.transform = transform;
			clone.pivotPoint = pivotPoint;
			clone.partition = partition;
			clone.bounds = _bounds.clone();
			clone.name = name;
			clone.castsShadows = castsShadows;
			clone.mouseEnabled = mouseEnabled;
			clone.mouseChildren = mouseChildren;			
			clone.extra = extra;
			
			if (animator)
				clone.animator = animator.clone();
			
			var len : int = subMeshes.length;
			for (var i : int = 0; i < len; ++i) {
				clone.subMeshes[i]._material = subMeshes[i]._material;
			}
			
			len = numChildren;
			for (i = 0; i < len; ++i) {
				clone.addChild(ObjectContainer3D(getChildAt(i).clone()));
			}
			
			return clone;
		}
		
		public static function fromName(mesh:Mesh, jointName:String, autoUpdate:Boolean=true):JointObject
		{					
			return new JointObject(mesh, (mesh.animator as SkeletonAnimator).skeleton.jointIndexFromName(jointName), autoUpdate); 
		}
	}
}