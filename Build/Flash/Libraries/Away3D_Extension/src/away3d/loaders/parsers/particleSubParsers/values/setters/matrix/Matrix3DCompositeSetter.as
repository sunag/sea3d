package away3d.loaders.parsers.particleSubParsers.values.setters.matrix
{
	import away3d.animators.data.ParticleProperties;
	import away3d.loaders.parsers.particleSubParsers.values.setters.SetterBase;
	
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	
	public class Matrix3DCompositeSetter extends SetterBase
	{
		
		public static const SCALE:int = 2;
		public static const ROTATION:int = 1;
		public static const TANSLATION:int = 0;
		
		private static var _scaleHelpMatrix:Matrix3D = new Matrix3D;
		private var _transforms:Vector.<SetterBase>;
		
		public function Matrix3DCompositeSetter(propName:String, transforms:Vector.<SetterBase>)
		{
			super(propName);
			_transforms = transforms;
		}
		
		override public function setProps(prop:ParticleProperties):void
		{
			prop[_propName] = generateOneValue(prop.index, prop.total);
		}
		
		override public function generateOneValue(index:int = 0, total:int = 1):*
		{
			var matrix3D:Matrix3D = new Matrix3D;
			var value:Vector3D;
			for each (var setter:SetterBase in _transforms)
			{
				value = setter.generateOneValue(index, total);
				switch (int(setter.propName))
				{
					case SCALE:
					{
						//this can support zero scale
						var rawData:Vector.<Number> = _scaleHelpMatrix.rawData;
						rawData[0] = value.x;
						rawData[5] = value.y;
						rawData[10] = value.z;
						_scaleHelpMatrix.copyRawDataFrom(rawData);
						matrix3D.append(_scaleHelpMatrix);
						break;
					}
					case ROTATION:
					{
						matrix3D.appendRotation(value.x, Vector3D.X_AXIS);
						matrix3D.appendRotation(value.y, Vector3D.Y_AXIS);
						matrix3D.appendRotation(value.z, Vector3D.Z_AXIS);
						break;
					}
					
					default:
					{
						matrix3D.appendTranslation(value.x, value.y, value.z);
						break;
					}
				}
			}
			return matrix3D;
		}
		
		override public function startPropsGenerating(prop:ParticleProperties):void
		{
			for each (var setterBase:SetterBase in _transforms)
			{
				setterBase.startPropsGenerating(prop);
			}
		}
		
		override public function finishPropsGenerating(prop:ParticleProperties):void
		{
			for each (var setterBase:SetterBase in _transforms)
			{
				setterBase.finishPropsGenerating(prop);
			}
		}
	
	}

}
