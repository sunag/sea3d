package away3d.lights
{
	import flash.geom.Vector3D;
	
	import away3d.containers.ObjectContainer3D;
	import away3d.lights.PointLight;

	public class ThreePointLight extends ObjectContainer3D
	{
		public var lightKey:PointLight;
		public var lightFill:PointLight;
		public var lightBack:PointLight;
		
		public function ThreePointLight(a:Number=1, b:Number=.3, c:Number=.5)
		{
			lightKey = new PointLight();
			lightKey.position = new Vector3D(1000000000,1000000000,-1000000000);
			lightKey.color = 0xFFFFFF; // 0xC7CDC0		
			lightKey.ambient = 0;
			lightKey.ambientColor = 0;
			lightKey.fallOff = lightKey.radius = 0xFFFFFFFF;
			addChild(lightKey);
			
			lightFill = new PointLight();
			lightFill.position = new Vector3D(-1000000000,1000000000,-1000000000);			
			lightFill.color = 0xFFFFFF;	// 0x7E753F		
			lightFill.ambient = 1;
			lightFill.ambientColor = 0xFFFFFF;
			lightFill.fallOff = lightFill.radius = 0xFFFFFFFF;
			addChild(lightFill);
			
			lightBack = new PointLight();
			lightBack.position = new Vector3D(1000000000,-1000000000,1000000000);
			lightBack.color = 0xFFFFFF; // 0xDF965B	
			lightBack.ambient = 0;
			lightBack.ambientColor = 0;
			lightBack.fallOff = lightBack.radius = 0xFFFFFFFF;
			addChild(lightBack);
			
			this.a = a;
			this.b = b;
			this.c = c;
		}
		
		public function set a(val:Number):void
		{
			lightKey.specular = lightKey.diffuse = val;
		}
		
		public function get a():Number
		{
			return lightKey.diffuse;
		}
		
		public function set b(val:Number):void
		{
			lightFill.specular = lightFill.diffuse = val;
		}
		
		public function get b():Number
		{
			return lightFill.diffuse;
		}
		
		public function set c(val:Number):void
		{
			lightBack.specular = lightBack.diffuse = val;
		}
		
		public function get c():Number
		{
			return lightBack.diffuse;
		}
		
		public function toArray():Array
		{
			return [lightKey,lightFill,lightBack];
		}
	}
}