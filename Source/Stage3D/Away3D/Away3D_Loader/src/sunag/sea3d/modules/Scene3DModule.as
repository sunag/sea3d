package sunag.sea3d.modules
{
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	
	import sunag.sunag;
	import sunag.sea3d.SEA;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.objects.SEAObject3D;
	import sunag.sea3d.objects.SEAScene3D;

	use namespace sunag;
	
	public class Scene3DModule extends Scene3DModuleBase
	{
		protected var _scene:Vector.<Scene3D>;
		
		sunag var sea3d:SEA3D;
		
		public function Scene3DModule()
		{			
			regRead(SEAScene3D.TYPE, readScene3D);								
		}
		
		public function get scenes():Vector.<Scene3D>
		{
			return _scene;
		}
		
		/**
		 * List of all Scene3D
		 */
		public function get scene3D():Vector.<Scene3D>
		{
			return _scene;
		}
		
		protected function readScene3D(sea:SEAScene3D):void
		{
			var scene:Scene3D = new Scene3D();			
			
			for each(var obj:SEAObject3D in sea.object)
			{
				scene.addChild( obj.tag );
			}
			
			_scene ||= new Vector.<Scene3D>();
			_scene.push(this.sea.object[sea.filename] = sea.tag = scene);	
		}
		
		override public function dispose():void
		{
			for each(var obj3d:ObjectContainer3D in _scene)
			{
				obj3d.dispose();
			}					
		}
		
		override sunag function init(sea:SEA):void
		{
			this.sea = sea;
			sea3d = sea as SEA3D;
		}
	}
}