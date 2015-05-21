package sunag.sea3d.framework
{
	import away3d.textures.AsynBitmapCubeTexture;
	
	import sunag.sea3dgp;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.loader.CubeMapLoader;
	import sunag.sea3d.objects.SEACubeMap;
	import sunag.sea3d.objects.SEACubeURL;
	import sunag.sea3d.objects.SEAObject;
	
	use namespace sea3dgp;
	
	public class CubeMapFile extends CubeMap
	{
		sea3dgp var cache:Boolean = SEA3DGP.config.cacheable;
		sea3dgp var cubeMap:AsynBitmapCubeTexture;		
		
		public function CubeMapFile()
		{		
		}
		
		//
		//	LOADER
		//
		
		override sea3dgp function load(sea:SEAObject):void
		{
			super.load(sea);
			
			//
			//	CUBEMAP FILE
			//
			
			if (sea is SEACubeURL)
			{
				var cubeURL:SEACubeURL = sea as SEACubeURL;
				
				loadURL
					(
						cubeURL.urls[0],
						cubeURL.urls[1],
						cubeURL.urls[2],
						cubeURL.urls[3],
						cubeURL.urls[4],
						cubeURL.urls[5]						
					);
				
			}
			else 
			{
				var cubeData:SEACubeMap = sea as SEACubeMap;
				
				loadData
				(
					cubeData.faces[0], 
					cubeData.faces[1],	
					cubeData.faces[2],
					cubeData.faces[3],
					cubeData.faces[4],
					cubeData.faces[5]
				);	
			}	
		}
		
		public function set cacheable(val:Boolean):void
		{
			cache = val;
		}
		
		public function get cacheable():Boolean
		{
			return cache;
		}
		
		sea3dgp function loadData(negX:*, posX:*, negY:*, posY:*, negZ:*, posZ:*):void
		{
			if (cache)
			{
				cubeMap = CubeMapLoader.get(negX);
				
				if (!cubeMap)
				{
					cubeMap = CubeMapLoader.create(negX, negX, posX, negY, posY, negZ, posZ);
				}
			}
			else if (!cubeMap)
			{
				cubeMap = new AsynBitmapCubeTexture(posX, negX, posY, negY, posZ, negZ);
			}
			else
			{
				cubeMap.load(posX, negX, posY, negY, posZ, negZ);
			}
			
			scope = cubeMap;
		}
		
		public function loadURL(negX:String, posX:String, negY:String, posY:String, negZ:String, posZ:String):void
		{
			if ( SEA3DGP.isEnv( negX ) ) negX = SEA3DGP.parseEnv( negX );
			if ( SEA3DGP.isEnv( posX ) ) posX = SEA3DGP.parseEnv( posX );
			if ( SEA3DGP.isEnv( negY ) ) negY = SEA3DGP.parseEnv( negY );
			if ( SEA3DGP.isEnv( posY ) ) posY = SEA3DGP.parseEnv( posY );
			if ( SEA3DGP.isEnv( negZ ) ) negZ = SEA3DGP.parseEnv( negZ );
			if ( SEA3DGP.isEnv( posZ ) ) posZ = SEA3DGP.parseEnv( posZ );
			
			loadData(negX, posX, negY, posY, negZ, posZ);
		}
	}
}