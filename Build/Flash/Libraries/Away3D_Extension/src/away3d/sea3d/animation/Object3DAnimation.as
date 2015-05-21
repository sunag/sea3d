package away3d.sea3d.animation
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	
	import sunag.sunag;
	import sunag.animation.Animation;
	import sunag.animation.AnimationSet;
	
	use namespace sunag;
	
	public class Object3DAnimation extends Animation
	{
		protected var _object3d:ObjectContainer3D;
		
		protected var _temp:Vector3D;
		protected var _comps:Vector.<Vector3D>;
		
		public function Object3DAnimation(object3d:ObjectContainer3D, animationSet:AnimationSet=null, intrplFuncs:Object=null)
		{
			_object3d = object3d;
			super(animationSet, intrplFuncs);						
		}
		
		protected function updateRelativeTransform():void
		{
			_object3d.animateTransform.recompose(_comps);
			_object3d.animateTransform = _object3d.animateTransform;
		}
		
		public function get object3d():ObjectContainer3D
		{
			return _object3d;
		}
		
		override public function set relative(value:Boolean):void
		{			
			if (_relative == value) return;
			
			if ( (super.relative = value) )
			{
				_object3d.animateTransform = new Matrix3D();
				_comps = _object3d.animateTransform.decompose();				
			}
			else
			{					
				_object3d.animateTransform = null;
				_temp = null; _comps = null;
			}
		}
	}
}