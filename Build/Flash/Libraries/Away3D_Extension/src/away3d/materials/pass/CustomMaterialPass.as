package away3d.materials.pass
{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.geom.Matrix3D;
	
	import away3d.arcane;
	import away3d.cameras.Camera3D;
	import away3d.core.base.IRenderable;
	import away3d.core.managers.Stage3DProxy;
	import away3d.materials.custom.ShaderData;
	import away3d.materials.passes.MaterialPassBase;

	use namespace arcane;
	
	public class CustomMaterialPass extends MaterialPassBase
	{
		private var _shader:ShaderData;
		
		public function CustomMaterialPass(shader:ShaderData)
		{
			_shader = shader;						
		}
		
		public function get shader():ShaderData
		{
			return _shader;
		}
		
		override arcane function getVertexCode():String
		{			
			return _shader._vertexAsm;
		}
		
		override arcane function getFragmentCode(code:String):String
		{
			return _shader._fragmentAsm;
		}
		
		/**
		 * Sets the render state which is constant for this pass
		 */
		override arcane function activate(stage3DProxy:Stage3DProxy, camera:Camera3D):void
		{
			super.activate(stage3DProxy, camera);
			
			var context : Context3D = stage3DProxy._context3D;
			
			if (_shader._enabledBlend) context.setBlendFactors(_shader._srcBlend, _shader._destBlend);
			
			context.setDepthTest(_shader._depthMask, _shader._depthCompareMode);
			
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 
				_shader._fragmentOffset, _shader._fragmentData);
			
			context.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 
				_shader._vertexOffset, _shader._vertexData);			
		}
		
		/**
		 * Set render state for the current renderable and draw the triangles.
		 */
		override arcane function render(renderable:IRenderable, stage3DProxy:Stage3DProxy, camera:Camera3D, viewProjection:Matrix3D):void
		{
			var context : Context3D = stage3DProxy._context3D;
			
			if (_shader.modelViewProjectionMatrixIndex > -1)
				context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, _shader.modelViewProjectionMatrixIndex, renderable.getModelViewProjectionUnsafe(), true);
			
			renderable.activateVertexBuffer(0, stage3DProxy);
			context.drawTriangles(renderable.getIndexBuffer(stage3DProxy), 0, renderable.numTriangles);			
		}
		
		/**
		 * Clear render state for the next pass.		 
		 */
		override arcane function deactivate(stage3DProxy:Stage3DProxy):void
		{
			super.deactivate(stage3DProxy);
		}
	}
}