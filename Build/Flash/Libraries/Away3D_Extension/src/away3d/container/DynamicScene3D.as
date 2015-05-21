package away3d.container
{
	import away3d.arcane;
	import away3d.containers.Scene3D;
	import away3d.core.traverse.PartitionTraverser;
	import away3d.events.Scene3DEvent;
	import away3d.lights.LightBase;
	import away3d.lights.ThreePointLight;
	import away3d.materials.lightpickers.DynamicLightPicker;
	import away3d.materials.methods.DynamicFogMethod;
	import away3d.materials.methods.FogMethod;
	
	use namespace arcane;
	
	public class DynamicScene3D extends away3d.containers.Scene3D
	{
		private static const DefaultLights : Array = new ThreePointLight().toArray();
		
		private var _fog : FogMethod;
		private var _lights : Array = [];			
		private var _useDefaultLights : Boolean = true;
		
		public function DynamicScene3D()
		{
			super();
					
			addEventListener(Scene3DEvent.ADDED_TO_SCENE, onAdded);
			addEventListener(Scene3DEvent.REMOVED_FROM_SCENE, onRemoved);					
		}
		
		public function set useDefaultLights(val:Boolean):void
		{
			_useDefaultLights = val;
		}
		
		public function get useDefaultLights():Boolean
		{
			return _useDefaultLights;
		}
		
		private function onAdded(e:Scene3DEvent):void
		{
			if (e.objectContainer3D is LightBase && _lights.indexOf( e.objectContainer3D ) == -1)
			{
				if (e.objectContainer3D != DynamicLightPicker.directionalLightInstance)
					_lights.push( e.objectContainer3D );
			}
		}
		
		private function onRemoved(e:Scene3DEvent):void
		{
			if (e.objectContainer3D is LightBase && _lights.indexOf( e.objectContainer3D ) > -1)
			{
				if (e.objectContainer3D != DynamicLightPicker.directionalLightInstance)				
					_lights.splice( _lights.indexOf( e.objectContainer3D ), 1 );
			}
		}
		
		protected function updateScene():void
		{
			if ( !contains( DynamicLightPicker.directionalLightInstance ) )
			{
				addChild( DynamicLightPicker.directionalLightInstance );
			}
			
			//
			//	FOG
			//
			
			if (_fog)
			{
				var envFog : DynamicFogMethod = DynamicFogMethod.instance;
				
				envFog.minDistance = _fog.minDistance;
				envFog.maxDistance = _fog.maxDistance;
				envFog.fogColor = _fog.fogColor;
			}
			
			//
			//	LIGHT
			//

			lightPicker.update(_lights.length > 0 || !_useDefaultLights ? _lights : DefaultLights);			
		}
		
		override public function traversePartitions(traverser : PartitionTraverser) : void
		{
			updateScene();
			return super.traversePartitions( traverser );
		}
		
		public function get lightPicker():DynamicLightPicker
		{
			return DynamicLightPicker.instance;
		}
			
		public function get lights():Array
		{
			return _lights;
		}
		
		public function set fog(val:FogMethod):void
		{
			_fog = val;
		}
		
		public function get fog():FogMethod
		{
			return _fog;
		}		
	}
}