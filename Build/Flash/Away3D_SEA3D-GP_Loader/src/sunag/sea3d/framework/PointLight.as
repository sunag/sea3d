package sunag.sea3d.framework
{
	import away3d.lights.PointLight;
	import away3d.sea3d.animation.PointLightAnimation;
	
	import sunag.sea3dgp;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAPointLight;
	
	use namespace sea3dgp;
	
	public class PointLight extends Light
	{
		sea3dgp var pointLight:away3d.lights.PointLight;
		
		public function PointLight(color:Number=0xFFFFFF, intensity:Number=1)
		{
			super(pointLight = new away3d.lights.PointLight(), PointLightAnimation);
			
			pointLight.color = color;
			pointLight.diffuse = intensity;
			pointLight.ambient = 1;
			
			pointLight.radius = 0xFFFFFFFF;
			pointLight.fallOff = 0xFFFFFFFF;
		}
		
		public function set color(color:Number):void
		{
			pointLight.color = color;
		}
		
		public function get color():Number
		{
			return pointLight.color;
		}
		
		public function set intensity(intensity:Number):void
		{
			pointLight.specular = pointLight.diffuse = intensity;
		}
		
		public function get intensity():Number
		{
			return pointLight.diffuse;
		}
				
		public function set attenuationEnabled(enabled:Boolean):void
		{
			if (enabled)
			{
				pointLight.radius = 100;
				pointLight.fallOff = 1000;
			}
			else
			{
				pointLight.radius = Number.MAX_VALUE;
				pointLight.fallOff = Number.MAX_VALUE;
			}
		}
		
		public function get attenuationEnabled():Boolean
		{
			return pointLight.fallOff == Number.MAX_VALUE;
		}
		
		public function set attenuationStart(radius:Number):void
		{
			pointLight.radius = radius;
		}
		
		public function get attenuationStart():Number
		{
			return pointLight.radius;
		}
		
		public function set attenuationEnd(end:Number):void
		{
			pointLight.fallOff = end;
		}
		
		public function get attenuationEnd():Number
		{
			return pointLight.fallOff;
		}
				
		//
		//	LOADER
		//
		
		override public function clone():Asset			
		{
			var asset:sunag.sea3d.framework.PointLight = new sunag.sea3d.framework.PointLight();
			asset.copyFrom( this );
			return asset;
		}
		
		sea3dgp override function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var light:sunag.sea3d.framework.PointLight = asset as sunag.sea3d.framework.PointLight;
			
			color = light.color;
			intensity = light.intensity;			
			attenuationEnabled = light.attenuationEnabled;
			attenuationStart = light.attenuationStart;
			attenuationEnd = light.attenuationEnd;
		}
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	POINT LIGHT
			//
			
			var pnt:SEAPointLight = sea as SEAPointLight;
									
			pointLight.position = pnt.position;
			
			pointLight.color = pnt.color;
			pointLight.specular = pointLight.diffuse = pnt.intensity;						
		}
	}
}