package sunag.sea3d
{
	import away3d.cameras.lenses.LensBase;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	
	import sunag.sunag;
	import sunag.events.SEA3DDebugEvent;
	import sunag.sea3d.config.IConfig;
	import sunag.sea3d.debug.IDebug;
	import sunag.sea3d.objects.SEACamera;
	import sunag.sea3d.objects.SEADirectionalLight;
	import sunag.sea3d.objects.SEAGeometryData;
	import sunag.sea3d.objects.SEAMesh;
	import sunag.sea3d.objects.SEAPointLight;
	
	use namespace sunag;
	
	public class SEA3DDebug extends SEA3D
	{
		protected var _debug:IDebug
		
		/**
		 * Creates a new SEA3D loader 
		 * @param config Settings of loader
		 * @param player If you have a player all animations will be automatically added to it
		 * @param debug Creates Dummy and Log for the objects of the scene.
		 * 
		 * @see SEA3D
		 * @see SEA3DManager
		 */
		public function SEA3DDebug(debug:IDebug, config:IConfig=null)
		{
			super(config);
			_debug = debug;
			if (!_debug) throw new Error("Debug can not be null.");
		}
		
		override protected function readMesh(sea:SEAMesh):void
		{
			super.readMesh(sea);
			
			if (!sea.material)
			{
				var tex:TextureMaterial = new TextureMaterial();
				tex.color = 0xFFFFFF;
				tex.alpha = .5;
				
				Mesh(sea.tag).material = tex;
			}
		}
		
		override protected function readGeometry(sea:SEAGeometryData):void
		{
			super.readGeometry(sea);
			
			if (sea.isBig) 
			{
				dispatchEvent(new SEA3DDebugEvent(SEA3DDebugEvent.WARN, 'Geometry ' + sea.name + ' is big. Recommended to have less than ' + 0xFFFF.toString() + ' vertex.'));
			}
		}
		
		override protected function readCamera(sea:SEACamera, lens:LensBase):void
		{
			super.readCamera(sea, lens);
			_debug.creatCamera(sea.tag);
		}
		
		override protected function readPointLight(sea:SEAPointLight):void
		{
			super.readPointLight(sea);
			_debug.creatPointLight(sea.tag);
		}
		
		override protected function readDirectionalLight(sea:SEADirectionalLight):void
		{
			super.readDirectionalLight(sea);
			_debug.creatDirectionalLight(sea.tag);
		}
		
		/**
		 * Debug object  
		 */
		public function get debug():IDebug
		{
			return _debug;
		}
	}
}