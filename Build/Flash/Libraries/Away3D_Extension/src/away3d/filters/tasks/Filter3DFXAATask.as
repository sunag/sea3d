/**
 * @about: https://gist.github.com/iY0Yi/9214656
 * */
package away3d.filters.tasks
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.tasks.Filter3DTaskBase;
	
	public class Filter3DFXAATask extends Filter3DTaskBase
	{
		private var _data : Vector.<Number>;
		
		private var SPAN_MAX : Number;
		private var REDUCE_MIN : Number;
		private var texW:Number;
		private var texH:Number;
		
		private var ratio:Number;
		
		public function Filter3DFXAATask(span : Number=8, reduce : Number=128, w:Number = 1024, h:Number = 1024)
		{
			super();
			_data = Vector.<Number>([0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1]);
			SPAN_MAX=span;
			REDUCE_MIN=reduce;
			texW = w;
			texH = h;
			updateEffectData();
		}
		
		public function get span() : Number
		{
			return SPAN_MAX;
		}
		
		public function set span(value : Number) : void
		{
			if (SPAN_MAX == value) return;
			SPAN_MAX = value;
			updateEffectData();
		}
		
		public function get reduce() : Number
		{
			return REDUCE_MIN;
		}
		
		public function set reduce(value : Number) : void
		{
			if (REDUCE_MIN == value) return;
			REDUCE_MIN = value;
			updateEffectData();
		}
		
		
		override protected function getFragmentCode():String
		{
			var code : String;
			code=(<agal><![CDATA[
				//AGAL FRAGMENT SHADER/////////

				add ft2.xy v0.xy fc1.xy
				tex ft0.xyz ft2.xy fs0<2d, linear, repeat>.xyz
				dp3 ft1.x ft0.xyz fc3.xyz

				add ft2.xy v0.xy fc1.zw
				tex ft0.xyz ft2.xy fs0<2d, linear, repeat>.xyz
				dp3 ft1.y ft0.xyz fc3.xyz

				add ft2.xy v0.xy fc2.xy
				tex ft0.xyz ft2.xy fs0<2d, linear, repeat>.xyz
				dp3 ft1.z ft0.xyz fc3.xyz

				add ft2.xy v0.xy fc2.zw
				tex ft0.xyz ft2.xy fs0<2d, linear, repeat>.xyz
				dp3 ft1.w ft0.xyz fc3.xyz

				tex ft0.xyz v0 fs0<2d, linear, repeat>.xyz
				dp3 ft2.x  ft0.xyz fc3.xyz

				min ft2.y ft1.x ft1.y
				min ft2.z ft1.z ft1.w
				min ft2.y ft2.y ft2.z

				max ft2.z ft1.x ft1.y
				max ft2.w ft1.z ft1.w
				min ft2.z ft2.z ft2.w

				min ft2.y ft2.x ft2.y
				max ft2.z ft2.x ft2.z

				add ft3.x ft1.x ft1.y
				add ft3.y ft1.z ft1.w
				add ft3.z ft1.x ft1.z
				add ft3.w ft1.y ft1.w
				sub ft3.x ft3.x ft3.y
				mul ft3.x ft3.x fc4.x
				sub ft3.y ft3.z ft3.w

				add ft3.z ft1.x ft1.y
				add ft3.z ft3.z ft1.z
				add ft3.z ft3.z ft1.w
				mul ft3.z ft3.z fc0.y

				max ft3.z ft3.z fc0.z

				abs ft4.x ft3.x
				abs ft4.y ft3.y
				min ft3.w ft4.x ft4.y
				add ft3.w ft3.w ft3.z
				div ft3.w fc3.w ft3.w

				mul ft0.xy ft3.xy ft3.w
				max ft0.xy fc6.zw ft0.xy
				min ft3.xy fc6.xy ft0.xy
				mul ft3.xy ft3.xy fc5.zw

				mul ft0.xy ft3.xy fc5.x
				add ft0.xy v0.xy ft0.xy
				mul ft1.xy ft3.xy fc5.y
				add ft1.xy v0.xy ft1.xy
				mul ft0.zw ft3.xy fc4.z
				add ft0.zw v0.xy ft0.zw
				mul ft1.zw ft3.xy fc4.y
				add ft1.zw v0.xy ft1.zw

				tex	ft3.xyz ft0.xy fs0<2d, linear, repeat>.xyz
				tex ft4.xyz ft1.xy fs0<2d, linear, repeat>.xyz
				add ft3.xyz ft3.xyz ft4.xyz
				mul ft3.xyz fc4.y ft3.xyz

				tex ft4.xyz ft0.zw fs0<2d, linear, repeat>.xyz
				tex ft5.xyz ft1.zw fs0<2d, linear, repeat>.xyz
				add ft4.xyz ft4.xyz ft5.xyz
				mul ft4.xyz fc4.w ft4.xyz
				mul ft4.xyz ft3.xyz fc4.y
				add ft4.xyz ft4.xyz ft4.xyz

				dp3 ft0.x ft4.xyz fc3.xyz

				slt ft0.y ft0.x ft2.y
				slt ft0.z ft2.z ft0.x

				max ft0.w ft0.y ft0.z
				mul ft3.xyz ft3.xyz ft0.w
				sub ft0.w fc3.w ft0.w
				mul ft4.xyz ft4.xyz ft0.w

				add ft5.xyz ft3.xyz ft4.xyz
				mov ft5.w fc3.w

				mov oc ft5

				///////////////////////////////
			]]></agal>).toString().replace(/^\s*/gm,"");
			
			return code;
		}
		
		override public function activate(stage3DProxy : Stage3DProxy, camera : Camera3D, depthTexture : Texture) : void
		{
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _data, -1);
		}
		
		override protected function updateTextures(stage : Stage3DProxy) : void
		{
			super.updateTextures(stage);
			texW = stage.width;
			texH = stage.height;
			updateEffectData();}
		
		private function updateEffectData() : void
		{
			
			//fc0.x = SPAN_MAX;
			//fc0.y = 0.25 * (1.0/SPAN_MAX);
			//fc0.z = (1.0/REDUCE_MIN);
			//fc0.w = 0.0;
			_data[0] = SPAN_MAX;
			_data[1] = 0.25 * (1.0/SPAN_MAX);
			_data[2] = 1.0/REDUCE_MIN;
			_data[3] = 0.0;
			
			//fc1.xy = float2(-1.0/texW, -1.0/texH);
			//fc1.zw = float2(+1.0/texW, -1.0/texH);
			_data[4] = -1.0/texW;
			_data[5] = -1.0/texH;
			_data[6] = +1.0/texW;
			_data[7] = -1.0/texH;
			
			//fc2.xy = float2(-1.0/texW, +1.0/texH);
			//fc2.zw = float2(+1.0/texW, +1.0/texH);		
			_data[8] = -1.0/texW;
			_data[9] = +1.0/texH;
			_data[10] =+1.0/texW;
			_data[11] =+1.0/texH;
			
			//fc3.xyz = float3(0.299, 0.587, 0.114);
			//fc3.w = 1.0;
			_data[12] = 0.299;
			_data[13] = 0.587;
			_data[14] = 0.114;
			_data[15] = 1.0;
			
			//fc4.x = -1.0;
			//fc4.y = .5;
			//fc4.z = -.5;
			//fc4.w = .25;
			_data[16] = -1.0;
			_data[17] = .5;
			_data[18] = -.5;
			_data[19] = .25;
			
			//fc5.x = 1.0/3.0 - 0.5;
			//fc5.y = 2.0/3.0 - 0.5;
			//fc5.z = 1.0 / texW;
			//fc5.w = 1.0 / texH;
			_data[20] = 1.0/3.0 - 0.5;
			_data[21] = 2.0/3.0 - 0.5;
			_data[22] = 1.0 / texW;
			_data[23] = 1.0 / texH;
			
			//fc6.x = SPAN_MAX;
			//fc6.y = SPAN_MAX;
			//fc6.z = -SPAN_MAX;
			//fc6.w = -SPAN_MAX;
			_data[24] = SPAN_MAX;
			_data[25] = SPAN_MAX;
			_data[26] = -SPAN_MAX;
			_data[27] = -SPAN_MAX;
		}
	}
}