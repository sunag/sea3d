package away3d.loaders.parsers.particleSubParsers.geometries.shapes
{
	import away3d.arcane;
	import away3d.core.base.Geometry;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	
	import flash.net.URLRequest;
	use namespace arcane;
	
	public class ExternalShapeSubParser extends ShapeSubParserBase
	{
		private var _geometry:Geometry;
		
		public function ExternalShapeSubParser():void
		{
		
		}
		
		override public function getGeometry():Geometry
		{
			return _geometry;
		}
		
		override arcane function resolveDependency(resourceDependency:ResourceDependency):void
		{
			var assets:Vector.<IAsset> = resourceDependency.assets;
			var len:int = assets.length;
			for (var i:int; i < len; i++)
			{
				var asset:IAsset = assets[i];
				if (asset.assetType == AssetType.GEOMETRY)
				{
					//retire the first geometry
					_geometry = asset as Geometry;
					return;
				}
			}
			dieWithError("resolveDependencyFailure");
		}
		
		override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void
		{
			dieWithError("resolveDependencyFailure");
		}
		
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				if (_data.url)
				{
					addDependency("default", new URLRequest(_data.url));
				}
				else
				{
					dieWithError("no external geometry url");
					return MORE_TO_PARSE;
				}
			}
			return super.proceedParsing();
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.ExternalShapeSubParser;
		}
	}

}
