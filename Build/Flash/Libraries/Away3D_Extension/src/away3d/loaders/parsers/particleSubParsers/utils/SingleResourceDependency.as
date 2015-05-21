package away3d.loaders.parsers.particleSubParsers.utils
{
	import away3d.arcane;
	import away3d.library.assets.IAsset;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.CompositeParserBase;
	
	import flash.net.URLRequest;
	
	use namespace arcane;
	
	/**
	 * ...
	 * @author
	 */
	public class SingleResourceDependency extends ResourceDependency
	{
		private var _resolved:Boolean;
		private var _hasLoaded:Boolean;
		private var _originalUrl:String;
		public function SingleResourceDependency(id:String, req:URLRequest, data:*, parentParser:CompositeParserBase, retrieveAsRawData:Boolean = false, suppressAssetEvents:Boolean = false)
		{
			_originalUrl=req.url;
			var loadedAssets:Vector.<IAsset> = parentParser.root.getAssets(req.url);
			if (loadedAssets)
			{
				_hasLoaded=true;
				retrieveAsRawData=true;
				data=true;
			}
			super(id, req, data, parentParser, retrieveAsRawData, suppressAssetEvents);
			if(_hasLoaded)
			{
				trace("shared resource");
				for each(var asset:IAsset in loadedAssets)
					assets.push(asset);
			}
		}
		
		override public function resolve():void
		{
			if (!_resolved)
			{
				if(!_hasLoaded)
					CompositeParserBase(parentParser).root.addAssets(_originalUrl,assets);
				_resolved = true;
				super.resolve();
			}
		}
	
	}

}
