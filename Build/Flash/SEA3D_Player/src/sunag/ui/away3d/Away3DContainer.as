package sunag.ui.away3d
{	
	import away3d.containers.ObjectContainer3D;
	
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;

	/**
	 * ...
	 * @author Eugene Zatepyakin
	 */
	public class Away3DContainer extends ObjectContainer3D
	{
		public var maxLostCount:uint = 7;
		public var lostCount:uint = 0;
		public var detected:Boolean = false;
		
		protected const transformData:Vector.<Number> = new Vector.<Number>(16, true);
		public var newMatrix:Matrix3D = new Matrix3D();
		public var nextMatrix:Matrix3D = new Matrix3D();
		
		public function Away3DContainer() 
		{
			super();
			
			visible = false;
		}
		
		public function setTransform(R:Vector.<Number>, t:Vector.<Number>, matrixError:Number):void
		{
			get3DMatrixLH( transformData, R, t );
			newMatrix.rawData = transformData;
			nextMatrix.interpolateTo(newMatrix, 0.85);
			
			this.transform = nextMatrix;
			
			rotationX += 90;
			
			x *= 13;
			y *= 13;
			z *= 13;
			
			visible = true;
			detected = true;
			lostCount = 0;
		}
		
		public function lost():void
		{
			if(++lostCount == maxLostCount)
			{
				hideObject();
			}
		}
		
		public function hideObject(e:Event = null):void
		{
			visible = false;
			detected = false;
			nextMatrix.identity();
		}
		
		public function get3DMatrixLH(data:Vector.<Number>, R:Vector.<Number>, t:Vector.<Number>):void
		{
			data[0] = R[0];
			data[1] = -R[3];
			data[2] = R[6];
			data[3] = 0.0;
			data[4] = R[1];
			data[5] = -R[4];
			data[6] = R[7];
			data[7] = 0.0;
			data[8] = -R[2];
			data[9] = R[5];
			data[10] = -R[8];
			data[11] = 0.0;
			data[12] = t[0];
			data[13] = -t[1];
			data[14] = t[2];
			data[15] = 1.0;
		}
		
	}	
}