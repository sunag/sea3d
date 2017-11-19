package sunag.sea3d.modules
{
	import away3d.textures.CubeReflectionTextureTarget;
	import away3d.textures.PlanarReflectionTextureTarget;
	import away3d.textures.RenderCubeTexture;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.config.ConfigBase;
	import sunag.sea3d.objects.SEACubeRender;
	import sunag.sea3d.objects.SEAPlanarRender;

	use namespace sunag;
	
	public class RTTModule extends RTTModuleBase
	{
		protected var _planarReflection:Vector.<PlanarReflectionTextureTarget>;
		protected var _cubemapReflection:Vector.<CubeReflectionTextureTarget>;
		
		sunag var sea3d:SEA3D;
		
		public function RTTModule()
		{						
			regRead(SEACubeRender.TYPE, readCubeRender);			
			regRead(SEAPlanarRender.TYPE, readPlanarRender);								
		}
		
		override sunag function reset():void
		{
			_planarReflection = null;
			_cubemapReflection = null;
		}
		
		/**
		 * List of CubeReflection with the target (Mesh)  
		 */
		public function get cubeReflections():Vector.<CubeReflectionTextureTarget>
		{			
			return _cubemapReflection;
		}
		
		/**
		 * List of PlanarReflection with the target (Mesh)  
		 */
		public function get planarReflections():Vector.<PlanarReflectionTextureTarget>
		{
			return _planarReflection;
		}
		
		protected function readCubeRender(sea:SEACubeRender):void
		{
			var cube:CubeReflectionTextureTarget = 
				new CubeReflectionTextureTarget( sea3d.config.getCubeMapSize(sea.quality) );
						
			cube.position = sea.position;			
			
			_cubemapReflection ||= new Vector.<CubeReflectionTextureTarget>();
			_cubemapReflection.push(this.sea.object[sea.filename] = sea.tag = cube);
		}
		
		protected function readPlanarRender(sea:SEAPlanarRender):void
		{
			var planar:PlanarReflectionTextureTarget = 
				new PlanarReflectionTextureTarget( sea3d.config.getTextureSize(sea.quality) / sea3d.config.getTextureSize(ConfigBase.HIGH) );
			
			planar.applyTransform( sea.transform );
			
			_planarReflection ||= new Vector.<PlanarReflectionTextureTarget>();
			_planarReflection.push(this.sea.object[sea.filename] = sea.tag = planar);
		}
		
		override public function dispose():void
		{
			for each(var planar:PlanarReflectionTextureTarget in _planarReflection)
				planar.dispose();
			
			for each(var cubeRef:CubeReflectionTextureTarget in _cubemapReflection)
				cubeRef.dispose();				
		}
		
		public function getPlanarReflection(name:String):PlanarReflectionTextureTarget
		{
			return sea.object[name + ".rttp"];
		}
		
		public function getCubeRender(name:String):RenderCubeTexture
		{
			return sea.object[name + ".rttc"];
		}
		
		override sunag function init(sea:SEA):void
		{
			this.sea = sea;
			sea3d = sea as SEA3D;
		}
	}
}