package sunag.ui.away3d
{
	import away3d.cameras.lenses.LensBase;
	import away3d.core.math.Matrix3DUtils;
	
	import ru.inspirit.asfeat.calibration.IntrinsicParameters;
	
	/**
	 * ...
	 * @author Eugene Zatepyakin
	 */
	public final class Away3D4Lens extends LensBase 
	{
		protected var _intrinsic:IntrinsicParameters;
		protected var _scale:Number;
		
		private var _fieldOfView : Number;
		private var _focalLengthInv : Number;
		private var _yMax : Number;
		private var _xMax : Number;
		
		public function Away3D4Lens(ip:IntrinsicParameters, frameWidth:int, frameHeight:int, scale:Number = 1.0) 
		{
			super();
			_intrinsic = ip;
			
			updateIntrinsic(frameWidth, frameHeight, scale);
		}
		
		public function updateIntrinsic(frameWidth:int, frameHeight:int, scale:Number=1.0):void
		{
			var fx:Number = _intrinsic.fx;
			var fy:Number = _intrinsic.fy;
			var w:Number = frameWidth;
			var h:Number = frameHeight;
			_aspectRatio = w / h;
			
			_near = fx / 32;
			_far = fx * 32;
			
			var fov:Number = 2.0 * Math.atan( (h - 1) / (2 * fy) );
			
			_focalLengthInv = Math.tan(fov * 0.5);
			_scale = scale;
			
			invalidateMatrix();
		}
		
		public function set scale(val:Number):void
		{
			_scale = val;
			invalidateMatrix();
		}
		
		override protected function updateMatrix() : void
		{
			var raw : Vector.<Number> = Matrix3DUtils.RAW_DATA_CONTAINER;
			
			_yMax = _near*_focalLengthInv;
			_xMax = _yMax*_aspectRatio;
			
			// assume symmetric frustum
			raw[uint(0)] = _near/_xMax * _scale;
			raw[uint(5)] = _near/_yMax * _scale;
			raw[uint(10)] = _far/(_far-_near);
			raw[uint(11)] = 1;
			raw[uint(1)] = raw[uint(2)] = raw[uint(3)] = raw[uint(4)] =
				raw[uint(6)] = raw[uint(7)] = raw[uint(8)] = raw[uint(9)] =
				raw[uint(12)] = raw[uint(13)] = raw[uint(15)] = 0;
			raw[uint(14)] = -_near*raw[uint(10)];
			
			_matrix.copyRawDataFrom(raw);
			
			var yMaxFar : Number = _far*_focalLengthInv;
			var xMaxFar : Number = yMaxFar*_aspectRatio;
			
			_frustumCorners[0] = _frustumCorners[9] = -_xMax;
			_frustumCorners[3] = _frustumCorners[6] = _xMax;
			_frustumCorners[1] = _frustumCorners[4] = -_yMax;
			_frustumCorners[7] = _frustumCorners[10] = _yMax;
			
			_frustumCorners[12] = _frustumCorners[21] = -xMaxFar;
			_frustumCorners[15] = _frustumCorners[18] = xMaxFar;
			_frustumCorners[13] = _frustumCorners[16] = -yMaxFar;
			_frustumCorners[19] = _frustumCorners[22] = yMaxFar;
			
			_frustumCorners[2] = _frustumCorners[5] = _frustumCorners[8] = _frustumCorners[11] = _near;
			_frustumCorners[14] = _frustumCorners[17] = _frustumCorners[20] = _frustumCorners[23] = _far;
		}
		
	}
	
}