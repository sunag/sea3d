package sunag.sea3d.debug
{
	import away3d.audio.Sound3D;
	import away3d.cameras.Camera3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;

	public interface IDebug
	{
		function get events():Vector.<IEventDebug>;
		function get objects():Vector.<ObjectContainer3D>;
		function get container():ObjectContainer3D;
		
		function creatCamera(camera:Camera3D):ObjectContainer3D;
		function creatPointLight(light:PointLight):ObjectContainer3D;
		function creatDirectionalLight(light:DirectionalLight):ObjectContainer3D;
		function creatPointSound(sound:Sound3D, distance:Number):ObjectContainer3D;		
		function creatLookAt(source:ObjectContainer3D, target:ObjectContainer3D):ObjectContainer3D;
		
		function dispose():void;		
	}
}