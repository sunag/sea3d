/**
 * @author: http://www.margaretscratcher.co.uk/
 */
package away3d.materials.pass
{
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.passes.MaterialPassBase;
	
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	
	use namespace arcane;
	
	/**
	 * Attempt at a sub surface ambient occlusion pass, based on this: http://blog.bwhiting.co.uk/?p=383
	 */
	public class SSAmbOccPass extends MaterialPassBase
	{
		
		
		private var _matrix : Matrix3D = new Matrix3D();
		
		public function SSAmbOccPass()
		{
			super();
			
		}
		
		
		private static function reflect(target:String, view:String, normal:String):String
		{
			var code:String = "";
			code += "dp3 " + target + ", " +view + ", " +normal + " \n";
			code += "add " +target +", " +target +", " +target+" \n";
			code += "mul "+target+", " +normal+", " +target+" \n";
			code += "sub "+target+", " +view+", " +target+" \n";
			code += "neg "+target+", " +target+" \n";
			code += "nrm "+target+ ".xyz, " +target+" \n";
			return code;
		}
		/**
		 * Get the vertex shader code for this shader
		 */
		override arcane function getVertexCode() : String
		{
			// transform to view space and pass on uv coords to the fragment shader
			return "m44 op, va0, vc0\n"+
				"mov v0, va1";
		}
		
		/**
		 * Get the fragment shader code for this shader
		 * @param fragmentAnimatorCode Any additional fragment animation code imposed by the framework, used by some animators. Ignore this for now, since we're not using them.
		 */
		override arcane function getFragmentCode(fragmentAnimatorCode : String) : String
		{
			
			//FROM HERE
			var flags:String = (smooth) ? "linear" : "nearest";
			
			//varying registers
			var uv_in:String = "v0";
			
			//samplers
			var tex_normal:String = "fs1";
			var tex_depth:String = "fs2";
			var tex_noise:String = "fs3";
			
			//float3 - float4
			var colour:String = "ft0";
			var normal:String = "ft1";
			var position:String = "ft2";
			var random:String = "ft3";
			var ray:String = "ft4";
			var hemi_ray:String = "ft5";
			
			//float1
			var depth:String = "ft6.x";
			var radiusDepth:String = "ft6.y";
			var occlusion:String = "ft6.z";
			var occ_depth:String = "ft6.w";
			var difference:String = "ft7.x";
			var temp:String = "ft7.y";
			var temp2:String = "ft7.z";
			var temp3:String = "ft7.w";			//NOT USED
			var fallOff:String = "ft0.x";		//NOT USED
			
			//float2
			var uv:String = "ft0";
			
			//constants
			var radius:String = "fc0.z";
			var scale:String = "fc0.w";
			var decoder:String = "fc2.z";
			var zero:String = "fc0.x";
			var one:String = "fc0.y";
			var two:String = "fc1.z";			//NOT USED
			var thresh:String = "fc1.w";
			var neg_one:String = "fc2.y";		//NOT USED
			
			var depth_decoder:String = "fc3.xyzw";
			
			var area:String = "fc1.x";			//NOT USED
			var falloff:String = "fc1.y";
			var total_strength:String = "fc2.x";
			var base:String = "fc4.x";
			
			var invSamples:String = "fc2.w";
			
			//SHADER OF DOOOOOOOOOM
			//AGAL.init();
			//sample normal at current fragment, and decode
			fragmentAnimatorCode = "tex ft0, v0, fs0 <2d,wrap,linear> \n"+//AGAL.tex(normal, uv_in, tex_normal, "2d", "clamp", flags);//ex ft0, v0, fs0 <2d,wrap,linear> \n"+
				
				//commented this out as there was no 'decode' function in AGAL.as
				//AGAL.decode(normal, normal, decoder);
				//sample deopth at current fragment, and decode
				"tex ft0, v0, fs0 <2d,wrap,linear> \n"+//AGAL.tex(colour, uv_in, tex_depth, "2d", "clamp", flags);//ex ft0, v0, fs0 <2d,wrap,linear> \n"+
				
				//commented this out as there was no 'decodeFloatFromRGBA' function in AGAL.as
				//AGAL.decodeFloatFromRGBA(depth, colour, depth_decoder);
				
				//use this instead if depth is not encoded
				"mov oc.a, "+one+" \n"+ //AGAL.mov("oc.a", one);
				"mov oc, "+depth+" \n"+//AGAL.mov("oc", depth);//col+".xyz");
				
				//sample random vector
				"mov "+uv+", "+uv_in+" \n"+//AGAL.mov(uv, uv_in);
				"mul "+uv+", "+ uv+","+ scale+" \n"+//AGAL.mul(uv, uv, scale);					
				"tex "+random+", "+ uv+","+ tex_noise+", 2d ,  wrap,"+ flags+" \n"+//AGAL.tex(random, uv, tex_noise, "2d", "wrap", flags);
				
				
				"mul "+ random+".z, "+ random+".z, "+ neg_one+" \n"+//AGAL.mul(random+".z", random+".z", neg_one);		//not sure if negation needed?
				
				//position
				"mov "+ position +".xy, "+ uv_in+".xy \n"+//AGAL.mov(position+".xy", uv_in+".xy");
				"mov "+ position+".z, "+ depth+" \n"+//AGAL.mov(position+".z", depth); //depth is causing issue..
				
				//radiusDepth
				"div "+radiusDepth+", "+ radius+","+ depth+" \n"+//AGAL.div(radiusDepth, radius, depth);
				
				//occlusion
				"mov " + occlusion + ", " + zero + " \n"+//AGAL.mov(occlusion, zero);					
				
				//start pass 1 - in the original there are 8x loops of this, with I'm guessing the 'i' affecting a value of each pass..
				
				//reflect the random normal against the current normal and size accoring to depth, further should be larger
				//AGAL.reflect(ray,"fc"+(5+(i*2)), random);	//could just add but will look crap?
				
				//reflect from agal.as:
				
				/*
				*public static function reflect(target:String, view:String, normal:String):String
				{
				// r = V - 2(V.N)*N
				var code:String = "";
				code += dp3(target, view, normal);
				code += add(target, target, target);
				code += mul(target, normal, target);
				code += sub(target, view, target);
				code += neg(target, target);
				code += nrm(target+".xyz", target); 
				
				
				converted into normal agal:
				"dp3 " + target + ", "+view+", "+random+" \n"+
				"add "+target+", "+target+", "+ target+" \n"+
				"mul "+target+", " +normal+", " +target+" \n"+
				"sub "+target+", "+ view+", "+ target+" \n"+
				"neg "+target+", "+ target+" \n"+
				"nrm "+target+".xyz, "+ target+" \n"+ 
				
				*/
				
				//converted to static function
				reflect (ray, "fc" + (5 + (0 * 2)), random) +
				
				"mul "+ray+", " +ray+", "+ radiusDepth+" \n"+//AGAL.mul(ray, ray, radiusDepth);
				
				//dot the ray against normal
				"dp3 "+hemi_ray+", "+ ray+", "+normal+" \n"+//AGAL.dp3(hemi_ray, ray, normal);
				
				
				//commented this out as there was no 'sign' function in AGAL.as
				//AGAL.sign(hemi_ray, hemi_ray, temp);
				"mul "+hemi_ray+", "+hemi_ray+", "+ray+" \n"+//AGAL.mul(hemi_ray, hemi_ray, ray);
				"add "+hemi_ray+", "+hemi_ray+", "+position+".xyz \n"+//AGAL.add(hemi_ray, hemi_ray, position+".xyz");
				
				//use position to sample from 
				"sat "+hemi_ray+".xy, "+ hemi_ray+".xy \n"+//AGAL.sat(hemi_ray+".xy", hemi_ray+".xy");
				"tex " + colour+", " + hemi_ray + ".xy, " + tex_depth+", 2d, clamp, "+ flags+" \n"+//AGAL.tex(colour, hemi_ray + ".xy", tex_depth, "2d", "clamp", flags);
				
				
				//commented this out as there was no 'decodeFloatFromRGBA' function in AGAL.as
				//AGAL.decodeFloatFromRGBA(occ_depth, colour, depth_decoder);
				
				//gets the difference in depth between the current depth and sampled depth
				"sub "+difference+", "+ depth+", "+ occ_depth+" \n"+//AGAL.sub(difference, depth, occ_depth);				
				"sge "+temp+", "+difference+", "+ thresh+" \n"+//AGAL.sge(temp, difference, thresh);	// 1 if difference is bigger than the threshold, 0 otherwise
				"slt "+temp2+", "+ difference+", "+falloff+ " \n"+//AGAL.slt(temp2, difference, falloff);	// 1 if difference is less than the falloff, 0 otherwise
				
				//set difference to range 0 - 1 (and clamp)
				"div "+difference+", "+difference+", "+falloff+" \n"+ //AGAL.div(difference, difference, falloff);
				"mul "+difference+", " +temp+", "+difference+" \n"+//AGAL.mul(difference, temp, difference);						
				"mul "+difference+", " +temp2+", "+ difference+" \n"+//AGAL.mul(difference, temp2, difference);
				
				//accumulate the occusion
				"add "+occlusion+", "+occlusion+", "+difference+" \n"+//AGAL.add(occlusion, occlusion, difference);
				//end pass 1
				
				
				//bring back into range 0-1
				"mul "+occlusion+", " +occlusion+", " +invSamples+" \n"+//AGAL.mul(occlusion, occlusion, invSamples);
				//apply any multiplier
				"mul "+occlusion+", " +occlusion+", " +total_strength+" \n"+//AGAL.mul(occlusion, occlusion, total_strength);
				//add it to a base value
				"add "+occlusion+", " +occlusion+", " +base+" \n"+//AGAL.add(occlusion, occlusion, base);
				//invert and boom headshot
				"sub oc, fc0.y, " + occlusion;//AGAL.sub("oc", fc0.y, occlusion);
			
			//fragmentAnimatorCode = AGAL.code;
			
			trace (fragmentAnimatorCode);
			return fragmentAnimatorCode;
			
		}
		
		/**
		 * Sets the render state which is constant for this pass
		 * @param stage3DProxy The stage3DProxy used for the current render pass
		 * @param camera The camera currently used for rendering
		 */
		override arcane function activate(stage3DProxy : Stage3DProxy, camera : Camera3D) : void
		{
			super.activate(stage3DProxy, camera);
			//stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _fragmentData, 1);
			var sample_sphere:Vector.<Number> = new Vector.<Number>();
			
			
			//more constants: //Should this be in here? if not, where?
			//uv sample offset
			var radius:Number = 0.002;		//you should derive from texture size
			//noise uv scale
			var scaler : Number = 24;		//much smaller and the noise blocks become more apparent
			//unused at the mo
			var falloff : Number = 0.05;		//not using this so ignore it / remove it
			//unused at the mo
			var area : Number = 5;			//not using this so ignore it / remove it
			//the depth difference threshold
			var depthThresh:Number = 0.0001;
			//strength of the effect
			var total_strength : Number = 1;
			//base value for the effect
			var base : Number = 0;
			
			
			//TO HERE
			
			sample_sphere.push( 0.5381, 0.1856,-0.4319, 0);
			sample_sphere.push( 0.1379, 0.2486, 0.4430, 0);
			sample_sphere.push( 0.3371, 0.5679,-0.0057, 0); 
			sample_sphere.push(-0.6999,-0.0451,-0.0019, 0);
			sample_sphere.push( 0.0689,-0.1598,-0.8547, 0); 
			sample_sphere.push( 0.0560, 0.0069,-0.1843, 0);
			sample_sphere.push(-0.0146, 0.1402, 0.0762, 0); 
			sample_sphere.push( 0.0100,-0.1924,-0.0344, 0);
			sample_sphere.push(-0.3577,-0.5301,-0.4358, 0); 
			sample_sphere.push(-0.3169, 0.1063, 0.0158, 0);
			sample_sphere.push( 0.0103,-0.5869, 0.0046, 0); 
			sample_sphere.push(-0.0897,-0.4940, 0.3287, 0);
			sample_sphere.push( 0.7119,-0.0154,-0.0918, 0); 
			sample_sphere.push(-0.0533, 0.0596,-0.5411, 0);
			sample_sphere.push( 0.0352,-0.0631, 0.5460, 0); 
			sample_sphere.push(-0.4776, 0.2847,-0.0271, 0);
			
			
			//from the source file
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0, 1, radius, scaler]));
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, Vector.<Number>([area, falloff, 2, depthThresh]));
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, Vector.<Number>([total_strength, -1, 0.5, 1/8]));
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, Vector.<Number>([1/(255*255*255), 1/(255*255), 1/255, 1]));
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, Vector.<Number>([base, 0, 0, 0]));
			stage3DProxy._context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, sample_sphere);
		}
		
		/**
		 * Set render state for the current renderable and draw the triangles.
		 * @param renderable The renderable that needs to be drawn.
		 * @param stage3DProxy The stage3DProxy used for the current render pass.
		 * @param camera The camera currently used for rendering.
		 * @param viewProjection The matrix that transforms world space to screen space.
		 */
		override arcane function render(renderable : IRenderable, stage3DProxy : Stage3DProxy, camera : Camera3D, viewProjection : Matrix3D) : void
		{
			var context : Context3D = stage3DProxy._context3D;
			_matrix.copyFrom(renderable.sceneTransform);
			_matrix.append(viewProjection);
			renderable.activateVertexBuffer(0, stage3DProxy);
			renderable.activateUVBuffer(1, stage3DProxy);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, _matrix, true);
			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);
		}
		
		/**
		 * Clear render state for the next pass.
		 * @param stage3DProxy The stage3DProxy used for the current render pass.
		 */
		override arcane function deactivate(stage3DProxy : Stage3DProxy) : void
		{
			// just go for default behaviour
			super.deactivate(stage3DProxy);
		}
	}
}