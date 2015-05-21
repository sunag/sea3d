package away3d.loaders.parsers.particleSubParsers.values.setters.threeD
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Vector3D;
	
	public class ThreeDSphereSetter extends SetterBase
	{
		private var _innerRadius3:Number;
		private var _outerRadius3:Number;
		private var _centerX:Number;
		private var _centerY:Number;
		private var _centerZ:Number;
		
		public function ThreeDSphereSetter(propName:String, innerRadius:Number, outerRadius:Number, centerX:Number, centerY:Number, centerZ:Number)
		{
			super(propName);
			_innerRadius3 = Math.pow(innerRadius, 3);
			_outerRadius3 = Math.pow(outerRadius, 3);
			_centerX = centerX;
			_centerY = centerY;
			_centerZ = centerZ;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var degree1:Number = Math.random() * Math.PI * 2;
			
			var radius:Number = Math.pow(Math.random() * (_outerRadius3 - _innerRadius3) + _innerRadius3, 1 / 3);
			var direction:Vector3D = new Vector3D(Math.random() - 0.5, Math.random() - 0.5, Math.random() - 0.5);
			if (direction.length == 0)
				direction.x = 1;
			direction.normalize();
			direction.scaleBy(radius);
			direction.x += _centerX;
			direction.y += _centerY;
			direction.z += _centerZ;
			return direction;
		}
	}

}
