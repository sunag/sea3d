package sunag.sea3d.framework
{
	import away3d.core.base.Geometry;
	
	import sunag.sea3dgp;

	use namespace sea3dgp;
	
	public class GeometryBase extends Asset
	{
		sea3dgp static const TYPE:String = 'Geometry/';
		
		sea3dgp static const NULL:away3d.core.base.Geometry = new away3d.core.base.Geometry();
		
		sea3dgp var scope:away3d.core.base.Geometry;
		
		sea3dgp var numVertex:int = 0;
		sea3dgp var jointPerVertex:int = 0;
		
		public function GeometryBase(scope:away3d.core.base.Geometry)
		{
			this.scope = scope;
			
			super(TYPE);						
		}
	}
}