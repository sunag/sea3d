package sunag.sea3d.framework
{
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import away3d.containers.ObjectContainer3D;
	
	import sunag.sea3dgp;
	import sunag.sea3d.config.ConfigBase;
	import sunag.sea3d.core.IGameObject;
	import sunag.sea3d.core.assets.Reference;
	import sunag.sea3d.core.assets.Script;
	import sunag.sea3d.engine.SEA3DGP;
	import sunag.sea3d.events.Event;
	import sunag.sea3d.events.EventDispatcher;
	import sunag.sea3d.events.ProgressEvent;
	import sunag.sea3d.loader.Scene3DLoader;

	use namespace sea3dgp;
	
	public class Scene3D extends Object3D
	{
		static sea3dgp var CACHE:Object = {};
		
		sea3dgp var stream:Boolean = true;
		sea3dgp var cache:Boolean = SEA3DGP.config.cacheable;
		sea3dgp var scripts:Vector.<Script> = new Vector.<Script>();
		sea3dgp var references:Vector.<Reference> = new Vector.<Reference>();
		sea3dgp var objects:Vector.<IGameObject> = new Vector.<IGameObject>();
		sea3dgp var physics:Vector.<Physics> = new Vector.<Physics>();
		sea3dgp var collided:Vector.<Physics> = new Vector.<Physics>();
		
		sea3dgp var list:Vector.<Asset> = new Vector.<Asset>();
		sea3dgp var lib:Object = {};	
				
		sea3dgp var loader:Scene3DLoader;
		
		public function Scene3D()
		{
			super(new ObjectContainer3D());	
			
			SEA3DGP.scenes.push( this );			
			SEA3DGP.c3d.addChild( scope );
		}
		
		sea3dgp function isolate():void
		{
			SEA3DGP.scenes.splice( SEA3DGP.scenes.indexOf( this ), 1 );
			SEA3DGP.c3d.removeChild( scope );
		}
		
		sea3dgp function update():void
		{
			//
			//	UPDATE ( ENTER-FRAME )
			//
			
			var enterFrame:sunag.sea3d.events.Event = 
				new sunag.sea3d.events.Event(sunag.sea3d.events.Event.UPDATE);
			
			for each(var obj:EventDispatcher in objects)	
			{
				obj.dispatchEvent( enterFrame );
			}
		}
		
		sea3dgp function loadScene(data:*):void
		{
			var config:ConfigBase;
			
			if (cache)
			{
				loader = Scene3DLoader.get(data);
				
				if (!loader)
				{
					config = new ConfigBase();
					config.streaming = stream;
					
					loader = Scene3DLoader.create(data, _name, config);				
				}
				
				loader.addCallback(onLoadCompleteCache, null, onProgress);
			}
			else
			{
				config = new ConfigBase();
				config.streaming = stream;
				
				loader = new Scene3DLoader(_name, config);
				
				loader.addCallback(onLoadComplete, onLoadAsset, onProgress);
			}
			
			if (!loader.status)
			{
				if (data is String)			
					data = new URLRequest( data );
				
				if (data is URLRequest)
				{
					loader.load( data );								
				}
				else if (data is ByteArray)
				{
					data.position = 0;
					
					loader.loadBytes( data );
				}
				
				SEA3DGP.manager.addLoader( loader );	
			}
		}
		
		private function onProgress(loaded:Number, total:Number):void
		{
			if (eDict[ProgressEvent.DOWLOAD_PROGRESS])
			{
				dispatchEvent(new ProgressEvent(ProgressEvent.DOWLOAD_PROGRESS, loaded, total));
			}
		}
		
		private function onLoadAsset(asset:Asset):void
		{
			asset.setScene( this );
		}
		
		private function dispatchComplete():void
		{
			// prevent not-loaded scripts
			//setTimeout(dispatchEvent, 1, new Event(Event.COMPLETE));
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		private function onLoadComplete(assets:Object):void
		{
			if (eDict[Event.COMPLETE])
			{
				dispatchComplete();
			}
		}
		
		private function onLoadCompleteCache(assets:Object):void
		{
			for each(var asset:Asset in assets)
			{
				if (!(asset is Object3D && Object3D(asset).parent))
				{
					asset = asset.clone();
					asset.setScene( this );
				}
			}
			
			dispatchComplete();
		}
		
		public function addPhysic(py:Physics):void
		{
			py.setScene( this );
		}
		
		public function removePhysic(py:Physics):void
		{
			py.setScene( null );
		}
		
		public function containsPhysic(py:Physics):Boolean
		{
			return physics.indexOf( py ) > -1;
		}
		
		public function load( url:String ):void
		{
			loadScene( url );
		}
		
		public function loadMesh( name:String ) : Mesh
		{			
			var asset:Mesh = loader.getAsset( name + '.m3d' ) as Mesh;			
			if (cache) asset = asset.clone() as Mesh;			
			asset.setScene( this );
			return asset;
		}
					
		public function set cacheable(val:Boolean):void
		{
			cache = val;
		}
		
		public function get cacheable():Boolean
		{
			return cache;
		}
				
		public function set streaming(val:Boolean):void
		{
			stream = val;
		}
		
		public function get streaming():Boolean
		{
			return stream;
		}
		
		public function set camera(camera:Camera3D):void
		{
			SEA3DGP.setCamera(0, camera);	
		}
		
		public function get camera():Camera3D
		{
			return SEA3DGP.getCamera(0);
		}
		
		public static function setCamera(camera:Camera3D, screen:int):void
		{
			SEA3DGP.setCamera(screen, camera);
		}
		
		public static function getCamera(screen:int):Camera3D
		{
			return SEA3DGP.getCamera(screen);
		}
		
		public function set fog(val:Boolean):void
		{
			SEA3DGP.fog = val;
		}
		
		public function get fog():Boolean
		{
			return SEA3DGP.fog;
		}
		
		public function set fogColor(color:Number):void
		{
			SEA3DGP.fogColor = color;
		}
		
		public function get fogColor():Number
		{
			return SEA3DGP.fogColor;
		}
		
		public function set fogMin(val:Number):void
		{
			SEA3DGP.fogMin = val;
		}
		
		public function get fogMin():Number
		{
			return SEA3DGP.fogMin;
		}
		
		public function set fogMax(min:Number):void
		{
			SEA3DGP.fogMax = min;
		}
		
		public function get fogMax():Number
		{
			return SEA3DGP.fogMax;
		}
		
		public function set environment(cube:CubeMap):void
		{
			SEA3DGP.environment = cube;
		}
		
		public function get environment():CubeMap
		{
			return SEA3DGP.environment;
		}
		
		public function set environmentColor(color:Number):void
		{
			SEA3DGP.environmentColor = color;
		}
		
		public function get environmentColor():Number
		{
			return SEA3DGP.environmentColor;
		}
		
		public function getAsset(ns:String):Asset
		{
			return lib[ns];
		}
		
		public function getCubeMap(name:String):CubeMap
		{
			return lib[CubeMap.TYPE+name];
		}
		
		public function getGeometry(name:String):GeometryBase
		{
			return lib[GeometryBase.TYPE+name];
		}
		
		public function getMaterial(name:String):Material
		{
			return lib[Material.TYPE+name];
		}
		
		public function getStandardMaterial(name:String):StandardMaterial
		{
			return lib[Material.TYPE+name] as StandardMaterial;
		}
		
		public function getMorph(name:String):Morph
		{
			return lib[Morph.TYPE+name];
		}
		
		public function getObject3D(name:String):Object3D
		{
			return lib[Object3D.TYPE+name];
		}
		
		public function getMesh(name:String):Mesh
		{
			return lib[Object3D.TYPE+name];
		}
		
		public function getSkeleton(name:String):Skeleton
		{
			return lib[Skeleton.TYPE+name];
		}
		
		public function getTexture(name:String):Texture
		{
			return lib[Texture.TYPE+name];
		}
		
		public function getPhysic(name:String):Physics
		{
			return lib[Physics.TYPE+name];
		}
		
		public function get library():Object
		{
			return lib;
		}
		
		override sea3dgp function setScene(scene:Scene3D):void
		{
			if (scene) throw new ReferenceError("This is already a scene");
		}		
		
		override public function get scene():Scene3D
		{
			return this;
		}
		
		override public function clone():Asset			
		{
			var game:Scene3D = new Scene3D();
			game.copyFrom( this );			
			return game;
		}
		
		override sea3dgp function copyFrom(asset:Asset):void
		{
			super.copyFrom( asset );
			
			var scene:Scene3D = asset as Scene3D;
						
			scripts = scene.scripts.concat();
		}
		
		override public function dispose():void
		{
			super.dispose();
					
			if (loader && loader.deps > 0)
			{
				if (cache) loader.removeCallback(onLoadCompleteCache, null, onProgress);
				else loader.removeCallback(onLoadComplete, onLoadAsset, onProgress);
				
				if (!loader.deps)
				{
					loader.close();
				}
			}
			
			fog = false;
			environment = null;
			environmentColor = SEA3DGP.stage.color;
				
			SEA3DGP.scenes.splice( SEA3DGP.scenes.indexOf( this ), 1 );
		}
	}
}