package sunag.manager
{
	import flash.utils.Dictionary;
	
	import away3d.core.base.SubMesh;
	import away3d.entities.Mesh;
	import away3d.library.assets.IAsset;
	import away3d.materials.ColorMaterial;
	import away3d.materials.IPassMaterial;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.EnvMapMethod;
	import away3d.materials.methods.LayeredDiffuseMethod;
	import away3d.materials.methods.LayeredTexture;
	import away3d.materials.methods.LightMapMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.textures.Texture2DBase;

	public class MemoryManager
	{
		private static var _count:uint = 0;
		
		public static const dict:Dictionary = new Dictionary(true);		
		
		public static const ADD:Function = function(asset:IAsset):int
		{
			if (!asset) return -1;
			else if (!dict[asset])
				dict[asset] = 0;
			
			++_count;
			
			dict[asset] += 1;
			
			return dict[asset];
		}
		
		public static const REMOVE:Function = function(asset:IAsset):int
		{
			if (!asset) return -1;
			else if (!dict[asset])
				throw new Error("asset not added");
			
			--_count;
			
			dict[asset] -= 1;						
			
			if (dict[asset] == 0)
			{
				asset.dispose();
				delete dict[asset];
				return 0;
			}
			
			return dict[asset];
		}
			
		public static function get count():uint
		{
			return _count;
		}
			
		public static function contains(asset:IAsset):Boolean
		{
			return dict[asset] != null;
		}
		
		public static function texture(tex:Texture2DBase, m:Function):void
		{
			m(tex);
			
			//trace(count, m == ADD ? "add" : "remove");
		}
		
		public static function effectMethod(mat:IPassMaterial, m:Function):void
		{
			for (var i:int = 0; i < mat.numMethods; i++)
			{
				var method:EffectMethodBase = mat.getMethodAt(i);
				
				if (method is LightMapMethod)
				{
					m((method as LightMapMethod).texture);						
				}
				else if (method is EnvMapMethod)
				{
					m((method as EnvMapMethod).envMap);
				}
				else if (method is RimLightMethod)
				{
					trace("automatic gc", method.toString());
				}
				else throw new Error("effect method no mapped.");				
			}
		}
		
		public static function textureMaterial(mat:TextureMaterial, m:Function):void
		{			
			if (!mat) return;
			
			var layered:LayeredDiffuseMethod;
												
			if (mat.diffuseMethod is BasicDiffuseMethod)
			{
				m(mat.texture);
			}
			else if (mat.diffuseMethod is LayeredDiffuseMethod)
			{
				layered = mat.diffuseMethod as LayeredDiffuseMethod;
				
				m(layered);
				
				for each(var layer:LayeredTexture in layered.layers)
				{
					m(layer.texture);
					m(layer.mask);
				}
			}
			else throw new Error("diffuse method no mapped.");
			
			m(mat.specularMap);
			m(mat.normalMap);
			
			effectMethod(mat, m);
			
			m(mat);
		}
		
		public static function colorMaterial(mat:ColorMaterial, m:Function):void
		{
			m(mat.specularMap);
			m(mat.normalMap);
			
			effectMethod(mat, m);
			
			m(mat);
		}
		
		public static function material(mat:MaterialBase, m:Function):void
		{
			if (!mat) return;
			
			if (mat is TextureMaterial)
				textureMaterial(mat as TextureMaterial, m);
			else if (mat is ColorMaterial)
				colorMaterial(mat as ColorMaterial, m);
			else
				throw new Error("material no mapped.");
		}
		
		public static function mesh(mesh:Mesh, m:Function):void
		{
			if (!mesh) return;
			
			var mat:MaterialBase,
				mats:Vector.<MaterialBase> = new Vector.<MaterialBase>();
			
			if (mat = mesh.material)
				mats.push(mat);
			
			for each(var subMesh:SubMesh in mesh.subMeshes)
			{
				mat = subMesh.material;
				
				if (mat && mats.indexOf(mat) == -1)
					mats.push(subMesh.material);
			}
			
			m(mesh);
			
			for each(mat in mats)
			{
				material(mat, m);
			}
			
			//trace(count, m == ADD ? "add" : "remove");
		}
		
		public static function meshes(meshes:Vector.<Mesh>, m:Function):void
		{
			for each(var mesh:Mesh in meshes)
			{
				MemoryManager.mesh(mesh, m);
			}
		}
	}
}