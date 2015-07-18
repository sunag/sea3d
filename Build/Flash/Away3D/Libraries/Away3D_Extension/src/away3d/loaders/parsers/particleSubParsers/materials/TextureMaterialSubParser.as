package away3d.loaders.parsers.particleSubParsers.materials
{
	import away3d.arcane;
	import away3d.library.assets.AssetType;
	import away3d.library.assets.IAsset;
	import away3d.loaders.misc.ResourceDependency;
	import away3d.loaders.parsers.particleSubParsers.AllIdentifiers;
	import away3d.materials.MaterialBase;
	import away3d.materials.TextureMaterial;
	import away3d.textures.Texture2DBase;
	
	import flash.net.URLRequest;
	use namespace arcane;
	
	public class TextureMaterialSubParser extends MaterialSubParserBase
	{
		private var _texture:TextureMaterial;
		
		private var _repeat:Boolean;
		private var _smooth:Boolean;
		private var _alphaBlending:Boolean;
		private var _alphaThreshold:Number = 0;
		
		public function TextureMaterialSubParser()
		{
		
		}
		
		
		override protected function proceedParsing():Boolean
		{
			if (_isFirstParsing)
			{
				_repeat = _data.repeat;
				_smooth = _data.smooth;
				_alphaBlending = _data.alphaBlending;
				_alphaThreshold = _data.alphaThreshold;
				if (_data.url)
				{
					var url:URLRequest = new URLRequest(_data.url);
					addDependency("default1", url);
				}
				else
				{
					dieWithError("no texture url");
					return MORE_TO_PARSE;
				}
			}
			return super.proceedParsing();
		}
		
		override arcane function resolveDependency(resourceDependency:ResourceDependency):void
		{
			var assets:Vector.<IAsset> = resourceDependency.assets;
			var len:int = assets.length;
			for (var i:int; i < len; i++)
			{
				var asset:IAsset = assets[i];
				if (asset.assetType == AssetType.TEXTURE)
				{
					//retire the first bitmapTexture
					_texture = new TextureMaterial(asset as Texture2DBase, _smooth, _repeat);
					_texture.bothSides = _bothSide;
					_texture.alphaBlending = _alphaBlending;
					_texture.blendMode = _blendMode;
					_texture.alphaThreshold = _alphaThreshold;
					finalizeAsset(_texture);
					return;
				}
			}
			dieWithError("resolveDependencyFailure");
		}
		
		override arcane function resolveDependencyFailure(resourceDependency:ResourceDependency):void
		{
			dieWithError("resolveDependencyFailure");
		}
		
		override public function get material():MaterialBase
		{
			return _texture;
		}
		
		public static function get identifier():*
		{
			return AllIdentifiers.TextureMaterialSubParser;
		}
	
	}

}
