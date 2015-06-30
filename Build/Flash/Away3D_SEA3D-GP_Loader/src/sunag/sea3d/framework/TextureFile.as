package sunag.sea3d.framework
{
	import away3d.textures.AsynBitmapTexture;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.loader.TextureLoader;
	import sunag.sea3d.objects.SEAObject;
	import sunag.sea3d.objects.SEATextureURL;
	
	use namespace sea3dgp;
	
	public class TextureFile extends Texture
	{
		sea3dgp var cache:Boolean = SEA3DGP.config.cacheableTexture;
		sea3dgp var bitmapTex:AsynBitmapTexture;
		sea3dgp var texData:*;
		
		public function TextureFile(url:String=null)
		{
			if (url) loadURL( url );
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	TEXTURE FILE
			//
			
			if ( sea is SEATextureURL )
			{
				loadURL( SEATextureURL(sea).url );
			}
			else
			{
				loadData( sea.data );	
			}
					
		}
		
		//
		//	PUBLIC
		//
		
		public function set cacheable(val:Boolean):void
		{
			cache = val;
		}
		
		public function get cacheable():Boolean
		{
			return cache;
		}
		
		sea3dgp function loadData(data:*):void
		{
			texData = data;
			
			if (cache)
			{
				bitmapTex = TextureLoader.get(data);
				
				if (!bitmapTex)
				{
					bitmapTex = TextureLoader.create(data);
				}
			}
			else if (!bitmapTex)
			{
				bitmapTex = new AsynBitmapTexture(data);
			}
			else
			{
				bitmapTex.load( data );
			}
			
			scope = bitmapTex;
		}
		
		public function loadURL(url:String):void
		{
			if ( SEA3DGP.isEnv( url ) ) url = SEA3DGP.parseEnv( url );
			
			loadData( url );
		}
		
		public function get url():String
		{
			return texData;
		}
		
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom(asset);
			
			var tex:TextureFile = asset as TextureFile;
			
			cacheable = tex.cacheable;
			if (tex.texData) loadData( tex.texData );			
		}
		
		override public function clone(force:Boolean=false):Asset
		{
			var clone:TextureFile = new TextureFile();
			clone.copyFrom(this);
			return clone;	
		}
	}
}