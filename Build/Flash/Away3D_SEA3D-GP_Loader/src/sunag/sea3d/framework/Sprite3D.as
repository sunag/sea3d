package sunag.sea3d.framework
{
	import away3d.entities.Sprite3D;
	import away3d.materials.ColorMaterial;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAMesh2D;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class Sprite3D extends Object3D		
	{					
		private static var MAT_NULL:ColorMaterial = new ColorMaterial(0xFF0000, 0);
		
		sea3dgp var sprite:away3d.entities.Sprite3D;		
		
		sea3dgp var mtl:Material;
		
		public function Sprite3D(material:Material=null, width:Number=256, height:Number=256)
		{
			sprite = new away3d.entities.Sprite3D(material ? material.scope : MAT_NULL, width, height)
			
			super(sprite);			
		}
		
		//
		//	MATERIAL
		//
		
		public function set material(val:Material):void
		{
			sprite.material = (mtl = val) ? mtl.scope : MAT_NULL;
		}
		
		public function get material():Material
		{
			return mtl;
		}
		
		public function set castShadow(val:Boolean):void
		{
			//sprite.castsShadows = val;
		}
		
		public function get castShadow():Boolean
		{
			return sprite.castsShadows;
		}
		
		//
		//	HIERARCHY
		//
		
		public function set height(val:Number):void			
		{
			sprite.height = val;
		}
		
		public function get height():Number			
		{
			return sprite.height;
		}
		
		public function set width(val:Number):void				
		{
			sprite.width = val;
		}
		
		public function get width():Number			
		{
			return sprite.width;
		}
		
		//
		//	LOADER
		//
		
		override public function clone(force:Boolean=false):Asset			
		{
			var asset:sunag.sea3d.framework.Sprite3D = new sunag.sea3d.framework.Sprite3D();
			asset.copyFrom( this );
			return asset;
		}
		
		sea3dgp override function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var spt:sunag.sea3d.framework.Sprite3D = asset as sunag.sea3d.framework.Sprite3D;
			var obj3d:Object3D = asset as Object3D;
			
			position = obj3d.position;
			scale = obj3d.scale; 
			
			material = spt.material;
			sprite.width = spt.width;
			sprite.height = spt.height;
			castShadow = spt.castShadow;				
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	MESH
			//
			
			var spt:SEAMesh2D = sea as SEAMesh2D;
			
			castShadow = spt.castShadow;
			
			scope.position = spt.position;			
			
			sprite.width = spt.width;
			sprite.height = spt.height;
			
			if (spt.material)
			{
				material = spt.material.tag;
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}