/**
 * @about: http://blog.as3er.com/?p=1006
 * */
package away3d.filters.tasks
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.textures.Texture;
	
	import away3d.cameras.Camera3D;
	import away3d.core.managers.Stage3DProxy;
	import away3d.filters.tasks.Filter3DTaskBase;
	
	/**
	 * GodRays Effect
	 * @author vancopper
	 * 
	 */
	public class Filter3DGodRaysTask extends Filter3DTaskBase
	{
		private var _numSteps:int = 30;
		private var _lightPos:Vector.<Number> = Vector.<Number>([.5, .5, 1, 1]);
		private var _values1:Vector.<Number> = Vector.<Number>([1, 1, 1, 1]);//numsamples, density, numsamples*density, 1 / numsamples * density
		private var _values2:Vector.<Number> = Vector.<Number>([1, 1, 1, 1]);//weight, decay, exposure
		
		private var _lightX:Number = 0;
		private var _lightY:Number = 0;
		private var _weight:Number = .5;
		private var _decay:Number = .87;
		private var _exposure:Number = .35;
		private var _density:Number = 2.0;
		
		public function Filter3DGodRaysTask(requireDepthRender:Boolean=false)
		{
			super(requireDepthRender);
		}
		
		override protected function getFragmentCode():String
		{
			var code:String = "";
			
			// Calculate vector from pixel to light source in screen space.
			code += "sub ft0.xy, v0.xy, fc0.xy \n";
			
			// Divide by number of samples and scale by control factor.  
			code += "mul ft0.xy, ft0.xy, fc1.ww \n";
			
			// Store initial sample.  
			code += "tex ft1,  v0, fs0 <2d, clamp, linear, mipnone> \n";
			
			// Set up illumination decay factor.  
			code += "mov ft2.x, fc0.w \n";
			
			// Store the texcoords
			code += "mov ft4.xy, v0.xy \n";
			
			for (var i:int = 0; i < _numSteps; i++)
			{
				// Step sample location along ray. 
				code += "sub ft4.xy, ft4.xy, ft0.xy \n";
				
				// Retrieve sample at new location.  
				code += "tex ft3,  ft4.xy, fs0 <2d, clamp, linear, mipnone> \n";
				
				// Apply sample attenuation scale/decay factors.  
				code += "mul ft2.y, ft2.x, fc2.x \n";
				code += "mul ft3.xyz, ft3.xyz, ft2.yyy \n";
				
				// Accumulate combined color.  
				code += "add ft1.xyz, ft1.xyz, ft3.xyz \n";
				
				// Update exponential decay factor.  
				code += "mul ft2.x, ft2.x, fc2.y \n";
			}
			
			// Output final color with a further scale control factor. 
			code += "mul ft1.xyz, ft1.xyz, fc2.zzz \n";
			code += "mov oc, ft1";
			return code;
		}
		
		override public function activate(stage3DProxy:Stage3DProxy, camera:Camera3D, depthTexture:Texture):void
		{
			// light position
			_lightPos[0] = this._lightX / stage3DProxy.width;
			_lightPos[1] = this._lightY / stage3DProxy.height;
			
			// numsamples, density, numsamples * density, 1 / numsamples * density
			_values1[0] = _numSteps;
			_values1[1] = this._density;
			_values1[2] = _numSteps * _values1[1];
			_values1[3] = 1 / _values1[2];
			
			// weight, decay, exposure
			_values2[0] = this._weight;
			_values2[1] = this._decay;
			_values2[2] = this._exposure;
			
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _lightPos, 1 );  
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, _values1,  1 );
			stage3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, _values2,  1 );
			
		}
		
		public function set lightX(value:Number):void { this._lightX = value; }
		public function get lightX():Number { return this._lightX; }
		
		public function set lightY(value:Number):void { this._lightY = value; }
		public function get lightY():Number { return this._lightY; }
		
		public function set decay(value:Number):void { this._decay = value; }
		public function get decay():Number { return this._decay; }
		
		public function set exposure(value:Number):void { this._exposure = value; }
		public function get exposure():Number { return this._exposure; }
		
		public function set weight(value:Number):void { this._weight = value; }
		public function get weight():Number { return this._weight; }
		
		public function set density(value:Number):void { this._density = value; }
		public function get density():Number { return this._density; }
	}
}