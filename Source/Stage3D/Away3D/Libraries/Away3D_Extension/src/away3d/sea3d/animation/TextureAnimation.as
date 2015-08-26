/*
*
* Copyright (c) 2012 Sunag Entertainment
*
* Permission is hereby granted, free of charge, to any person obtaining a copy of
* this software and associated documentation files (the "Software"), to deal in
* the Software without restriction, including without limitation the rights to
* use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
* the Software, and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
* FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
* COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
* IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*
*/

package away3d.sea3d.animation
{
	import away3d.core.base.SubMesh;
	import away3d.core.math.MathConsts;
	import away3d.entities.Mesh;
	import away3d.materials.ITextureMaterial;
	
	import sunag.sunag;
	import sunag.animation.Animation;
	import sunag.animation.AnimationSet;
	import sunag.animation.data.AnimationFrame;
	
	use namespace sunag;
	
	public class TextureAnimation extends Animation
	{
		protected var _mesh:Mesh;
		protected var _subMesh:Vector.<SubMesh>;
		
		public function TextureAnimation(animationSet:AnimationSet, mesh:Mesh)
		{
			super(animationSet);
			
			this.mesh = mesh;
		}
		
		public function set mesh(value:Mesh):void
		{
			if ( (_mesh = value) )	
			{
				_subMesh = new Vector.<SubMesh>();
				
				for each(var subMesh:SubMesh in _mesh.subMeshes)
				{
					if (subMesh.material is ITextureMaterial)
					{
						var enabled:Boolean = Boolean(ITextureMaterial(subMesh.material).texture);
						
						ITextureMaterial(subMesh.material).animateUVs = enabled;
						
						if (enabled)
						{
							_subMesh.push(subMesh);
						}
					}
				}
			}
		}
		
		public function get mesh():Mesh
		{
			return _mesh;
		}
		
		override protected function updateAnimationFrame(frame:AnimationFrame, kind:Object):void		
		{
			for each(var subMesh:SubMesh in _subMesh)
			{
				switch(kind)					
				{
					case Animation.OFFSET_U:						
						subMesh.offsetU = frame.x;					
						break;							
					case Animation.OFFSET_V:
						subMesh.offsetV = frame.x;
						break;					
					case Animation.SCALE_U:						
						subMesh.scaleU = frame.x;		
						break;
					case Animation.SCALE_V:						
						subMesh.scaleV = frame.x;
						break;
					case Animation.ANGLE:					
						subMesh.uvRotation = frame.x * MathConsts.DEGREES_TO_RADIANS;
						break;
				}
			}
		}				
	}
}