package away3d.loaders.parsers.particleSubParsers.values.setters.threeD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.core.math.MathConsts;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	public class ThreeDCylinderSetter extends SetterBase
	{
		private var _innerRadius:Number;
		private var _outerRadius:Number;
		private var _height:Number;
		private var _centerX:Number;
		private var _centerY:Number;
		private var _centerZ:Number;
		private var _matrix:Matrix3D;
		
		public function ThreeDCylinderSetter(propName:String, innerRadius:Number, outerRadius:Number, height:Number, centerX:Number, centerY:Number, centerZ:Number, dX:Number, dY:Number, dZ:Number)
		{
			super(propName);
			_innerRadius = innerRadius;
			_outerRadius = outerRadius;
			_height = height;
			_centerX = centerX;
			_centerY = centerY;
			_centerZ = centerZ;
			var direction:Vector3D = new Vector3D(dX, dY, dZ);
			if (direction.length > 0)
			{
				direction.normalize();
				var flag:int = direction.dotProduct(Vector3D.Y_AXIS) > 0 ? 1 : -1;
				var degree:Number = flag * Vector3D.angleBetween(Vector3D.Y_AXIS, direction) * MathConsts.RADIANS_TO_DEGREES;
				if (degree != 0)
				{
					var rotationAxis:Vector3D = Vector3D.Y_AXIS.crossProduct(direction);
					_matrix = new Matrix3D();
					_matrix.appendRotation(degree, rotationAxis);
				}
			}
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var h:Number = Math.random() * _height; // - _height / 2;
			var r:Number = _outerRadius * Math.pow(Math.random() * (1 - _innerRadius / _outerRadius) + _innerRadius / _outerRadius, 1 / 2);
			var degree1:Number = Math.random() * Math.PI * 2;
			var point:Vector3D = new Vector3D(r * Math.cos(degree1), h, r * Math.sin(degree1));
			if (_matrix)
				point = _matrix.deltaTransformVector(point);
			point.x += _centerX;
			point.y += _centerY;
			point.z += _centerZ;
			return point;
		}
	}

}
