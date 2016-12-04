package sunag.sea3d.debug
{
	import away3d.audio.Sound3D;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.primitives.WireframeSphere;
	
	import sunag.sea3d.debug.utils.ConstraintTransform;
	import sunag.sea3d.debug.utils.LookAtEvent;
	
	public class DefaultDebug implements IDebug
	{
		private var _event:Vector.<IEventDebug> = new Vector.<IEventDebug>();
		private var _object:Vector.<ObjectContainer3D> = new Vector.<ObjectContainer3D>();		
		private var _container:ObjectContainer3D = new ObjectContainer3D();	
		
		public function get events():Vector.<IEventDebug>
		{
			return _event;
		}
		
		public function get objects():Vector.<ObjectContainer3D>
		{
			return _object;
		}
		
		public function get container():ObjectContainer3D
		{
			return _container;
		}
		
		public function creatCamera(camera:Camera3D):ObjectContainer3D
		{
			return appendObject(camera, new WireframeSphere(10, 2, 4, 0x9AB9E5));
		}
		
		public function creatPointLight(light:PointLight):ObjectContainer3D
		{
			return appendObject(light, new WireframeSphere(6, 4, 2, 0x9AB9E5))
		}
		
		public function creatDirectionalLight(light:DirectionalLight):ObjectContainer3D
		{
			return appendObject(light, new WireframeSphere(10, 2, 4, 0x9AB9E5));
		}
		
		public function creatPointSound(sound:Sound3D, distance:Number):ObjectContainer3D
		{
			return appendObject(sound, new WireframeSphere(distance, 6, 6, 0x9AB9E5, 1));
		}
						
		public function creatLookAt(source:ObjectContainer3D, target:ObjectContainer3D):ObjectContainer3D
		{
			var debugEvent:LookAtEvent = new LookAtEvent(source, target, 0x9AB9E5, 0x9AB9E5);
			
			_object.push(debugEvent.lookAtLine);
			_event.push(debugEvent);
			
			debugEvent.lookAtLine.name = source.name;
			
			_container.addChild(debugEvent.lookAtLine);
			
			return debugEvent.lookAtLine;
		}
		
		private function appendObject(source:ObjectContainer3D, target:ObjectContainer3D):ObjectContainer3D
		{
			_event.push(new ConstraintTransform(source, target));
			_object.push(target);
			
			_container.addChild(target);
			
			target.name = source.name;			

			return target;
		}
		
		public function dispose():void
		{
			for each(var ideb:IEventDebug in _event)
			{
				ideb.dispose();
			}
			
			for each(var debugObj:ObjectContainer3D in _object)
			{
				debugObj.dispose();
			}
			
			_event = new Vector.<IEventDebug>();
			_object = new Vector.<ObjectContainer3D>();
			
			_container.dispose();
		}
	}
}