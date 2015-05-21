package sunag.sea3d.core.assets
{
	import away3d.loaders.misc.AssetLoaderContext;
	
	import sunag.sea3dgp;
	import sunag.sea3d.framework.Asset;
	import sunag.sea3d.framework.Scene3D;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEAReference;

	use namespace sea3dgp;
	
	public class Reference extends Asset		
	{
		sea3dgp static const TYPE:String = 'Reference/'; 
		
		sea3dgp var context:AssetLoaderContext = new AssetLoaderContext();
		
		public function Reference()
		{
			super(TYPE);
		}
		
		sea3dgp override function setScene(scene:Scene3D):void
		{
			if (_scene)
				_scene.references.splice( _scene.references.indexOf(this), 1 );
			
			super.setScene( scene );
			
			if (scene)
				scene.references.push( this );
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	REFERENCES
			//
			
			for each(var ref:Object in SEAReference(sea).refs)
			{
				context.mapUrlToData(ref.name, ref.data ? ref.data : ref.name);
			}
		}
		
		override public function dispose():void
		{
			super.dispose();
			
			if (context)
			{
				context = null;
			}		
		}
	}
}