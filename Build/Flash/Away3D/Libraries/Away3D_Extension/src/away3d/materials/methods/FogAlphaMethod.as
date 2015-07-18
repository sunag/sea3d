package away3d.materials.methods
{
	import away3d.arcane;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.compilation.ShaderRegisterCache;
	import away3d.materials.compilation.ShaderRegisterElement;
	
	use namespace arcane;

	/**
	 * FogMethod provides a method to add distance-based fog to a material.
	 */
	public class FogAlphaMethod extends EffectMethodBase
	{
		private var _minDistance:Number;
		private var _maxDistance:Number;

		/**
		 * Creates a new FogMethod object.
		 * @param minDistance The distance from which the fog starts appearing.
		 * @param maxDistance The distance at which the fog is densest.		 
		 */
		public function FogAlphaMethod(minDistance:Number=0, maxDistance:Number=1000)
		{
			super();
			this.minDistance = minDistance;
			this.maxDistance = maxDistance;
		}

		/**
		 * @inheritDoc
		 */
		override arcane function initVO(vo:MethodVO):void
		{
			vo.needsProjection = true;			
		}

		/**
		 * The distance from which the fog starts appearing.
		 */
		public function get minDistance():Number
		{
			return _minDistance;
		}
		
		public function set minDistance(value:Number):void
		{
			_minDistance = value;
		}

		/**
		 * The distance at which the fog is densest.
		 */
		public function get maxDistance():Number
		{
			return _maxDistance;
		}
		
		public function set maxDistance(value:Number):void
		{
			_maxDistance = value;
		}

		/**
		 * @inheritDoc
		 */
		arcane override function activate(vo:MethodVO, stage3DProxy:Stage3DProxy):void
		{
			var data:Vector.<Number> = vo.fragmentData;
			var index:int = vo.fragmentConstantsIndex;
			data[index] = _minDistance;
			data[index + 1] = 1/(_maxDistance - _minDistance);
		}

		/**
		 * @inheritDoc
		 */
		arcane override function getFragmentCode(vo:MethodVO, regCache:ShaderRegisterCache, targetReg:ShaderRegisterElement):String
		{
			var fogData:ShaderRegisterElement = regCache.getFreeFragmentConstant();
			var temp2:ShaderRegisterElement = regCache.getFreeFragmentVectorTemp();			
			vo.fragmentConstantsIndex = fogData.index*4;
			
			var code:String = "sub " + temp2 + ".w, " + _sharedRegisters.projectionFragment + ".z, " + fogData + ".x          \n" +
				"mul " + temp2 + ".w, " + temp2 + ".w, " + fogData + ".y					\n" +
				"sat " + temp2 + ".w, " + temp2 + ".w										\n" +				
				"mul " + targetReg + ".w, " + targetReg + ".w, " + temp2 + ".w\n"; // fogRatio*(fogColor- col) + col
			
			return code;
		}
	}
}
