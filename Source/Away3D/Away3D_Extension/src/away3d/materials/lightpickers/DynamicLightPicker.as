package away3d.materials.lightpickers
{
	import flash.geom.Vector3D;
	
	import away3d.arcane;
	import away3d.core.base.IRenderable;
	import away3d.core.traverse.EntityCollector;
	import away3d.lights.DirectionalLight;
	import away3d.lights.LightBase;
	import away3d.lights.PointLight;
	import away3d.lights.shadowmaps.DynamicShadowMapper;

	use namespace arcane;
	
	public class DynamicLightPicker extends StaticLightPicker
	{			
		arcane static const directionalLightInstance : DirectionalLight = new DirectionalLight(); 
		
		public static const instance : DynamicLightPicker = new DynamicLightPicker();
		
		private var pLightsCache:Array = [];
		
		private var _pLights : Array = [];
		private var _dLights : Array = [];
		
		arcane var _lights : Array = [];
		arcane var _shadow : DirectionalLight;
		arcane var _mapper : DynamicShadowMapper;
		
		private var _pointLightLimit : uint;
		private var _directionalLightLimit : uint;
		
		public var bestLight : Boolean = false;
		
		public function DynamicLightPicker(pointLightLimit:uint=3, directionalLightLimit:uint=1)
		{				
			super([]);
			
			_pointLightLimit = pointLightLimit;
			_directionalLightLimit = directionalLightLimit;		
			
			updateBaseLights();						
		}
		
		public function update(lights:Array=null):void
		{
			_lights = lights || _lights;
			
			//
			//	Dynamic Shadow
			//
			
			var shadow : DirectionalLight;
			
			for each(var l : LightBase in _lights)
			{
				if (l.shadowMapper is DynamicShadowMapper && l is DirectionalLight)
				{
					shadow = l as DirectionalLight;							
					break;
				}
			}
			
			if (shadow)
			{			
				directionalLightInstance.color = shadow.color;
				
				directionalLightInstance.diffuse = shadow.diffuse;
				directionalLightInstance.specular = shadow.specular;
				
				directionalLightInstance.position = shadow.scenePosition;
				directionalLightInstance.direction = shadow.sceneDirection;
				
				_mapper = shadow.shadowMapper as DynamicShadowMapper
				_mapper._method.enabled = true;
			}
			else if (_shadow)
			{
				_mapper._method.enabled = false;
				_mapper = null;
			}
			
			_shadow = shadow;
		}
		
		public function set pointLightLimit(value:uint):void
		{
			if (_pointLightLimit == value) return;
			_pointLightLimit = value;
			updateBaseLights();	
		}
		
		public function get pointLightLimit():uint
		{
			return _pointLightLimit;
		}
		
		public function set directionalLightLimit(value:uint):void
		{
			if (_directionalLightLimit == value) return;
			_directionalLightLimit = value;
			updateBaseLights();	
		}
		
		public function get directionalLightLimit():uint
		{
			return _directionalLightLimit;
		}
		
		protected function updateBaseLights():void
		{			
			var light : LightBase;
			for each(light in _pointLights) light.dispose();
				
			_pLights = [];
			_dLights = [];
				
			var cache:Array = [];
			
			var i : int;
			for(i = 0; i < _pointLightLimit; i++)		
			{
				cache.push( _pLights[i] = new PointLight() );
				
				if (i == 0)
				{
					_pLights[i].ambientColor = 0xFFFFFF;
					_pLights[i].ambient = 1;
				}
				else
				{
					_pLights[i].ambientColor = 0;
					_pLights[i].ambient = 0;
				}
			}
			
			if (_directionalLightLimit > 0)
			{
				cache.push( _dLights[0] = directionalLightInstance );
				
				for(i = 1; i < _directionalLightLimit; i++)			
					cache.push( _dLights[i] = new DirectionalLight() );
			}
			
			super.lights = cache;
		}
		
		override public function set lights(value:Array):void
		{
			_lights = value;
		}
		
		override public function get lights():Array
		{
			return _lights;
		}
		
		override public function collectLights(renderable : IRenderable, entityCollector : EntityCollector) : void
		{
			var i:int,
				pos : Vector3D = renderable.sourceEntity.scenePosition,		
				nearest : Number = Number.MAX_VALUE,
				pLights : Array = [], dLights : Array = [],				
				light : LightBase, dist : Number;							
				
			if (bestLight)
			{
				var pLightsDist : Array = [], dLightsDist : Array = [];
				
				searchLights : for each(light in _lights)
				{
					dist = Vector3D.distance( pos, light.scenePosition );
					
					if (light is PointLight)
					{
						for(i = 0; i < pLights.length && i < _pointLightLimit; i++)
						{
							if (dist < pLightsDist[i])
							{
								pLights.splice(i, 0, light);
								pLightsDist.splice(i, 0, dist);
								
								continue searchLights;
							}
						}
						
						if (pLights.length < _pointLightLimit)
						{
							pLights.push(light);
							pLightsDist.push(dist);
						}
					}
					else if (light is DirectionalLight)
					{
						for(i = 0; i < dLights.length && i < _directionalLightLimit; i++)
						{
							if (dist < dLightsDist[i])
							{
								dLights.splice(i, 0, light);
								dLightsDist.splice(i, 0, dist);
								
								continue searchLights;
							}
						}
						
						if (dLights.length < _directionalLightLimit)
						{
							dLights.push(light);
							dLightsDist.push(dist);
						}
					}		
				}
			}
			else
			{
				for each(light in _lights)
				{
					dist = Vector3D.distance( pos, light.scenePosition );
					
					if (dist < nearest)
					{
						if (light is PointLight) pLights.unshift( light );
						else if (light is DirectionalLight) dLights.unshift( light ); 
						
						nearest = dist;
					}
					else
					{
						if (light is PointLight) pLights.push( light );
						else if (light is DirectionalLight) dLights.push( light ); 
					}								
				}
			}
						
			for(i = 0; i < _pointLightLimit; i++)
			{
				var pointLight:PointLight = _pLights[i];
				
				if (i < pLights.length)
				{					
					var pointLightTarget:PointLight = pLights[i];
					
					pointLight.position = pointLightTarget.scenePosition;
					
					pointLight.color = pointLightTarget.color;
					
					pointLight.radius = pointLightTarget.radius;
					pointLight.fallOff = pointLightTarget.fallOff;
					
					pointLight.diffuse = pointLightTarget.diffuse;
					pointLight.specular = pointLightTarget.specular;				
				}
				else
				{					
					pointLight.diffuse = 									
						pointLight.specular = 0;
				}
			}
						
			if (_shadow)
			{
				pLights.splice( pLights.indexOf( _shadow ) , 1 );
				i = 1;
			}
			else i = 0;			
			
			for(; i < _directionalLightLimit; i++)
			{
				var dirLight:DirectionalLight = _dLights[i];
				
				if (i < dLights.length)
				{
					var dirLightTarget:DirectionalLight = dLights[i];
										
					dirLight.position = dirLightTarget.position;
					dirLight.direction = dirLightTarget.sceneDirection;
					
					dirLight.color = dirLightTarget.color;
					dirLight.ambientColor = dirLightTarget.ambientColor;
					
					dirLight.diffuse = dirLightTarget.diffuse;
					dirLight.specular = dirLightTarget.specular;
				}
				else
				{
					dirLight.diffuse = 								
						dirLight.specular = 0
				}
			}
			
			super.collectLights(renderable, entityCollector);
		}
	}
}
