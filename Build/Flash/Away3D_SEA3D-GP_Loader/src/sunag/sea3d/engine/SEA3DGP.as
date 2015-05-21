package sunag.sea3d.engine
{
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Vector3D;
	import flash.system.ApplicationDomain;
	
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.base.IRenderable;
	import away3d.core.base.SubMesh;
	import away3d.core.managers.Mouse3DManager;
	import away3d.core.managers.Stage3DManager;
	import away3d.core.managers.Stage3DProxy;
	import away3d.core.pick.IPicker;
	import away3d.core.pick.PickingType;
	import away3d.events.MouseEvent3D;
	import away3d.loaders.misc.SingleFileLoader;
	import away3d.loaders.parsers.Parsers;
	import away3d.loaders.parsers.ParticleGroupParser;
	import away3d.materials.SkyBoxMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FogMethod;
	import away3d.primitives.SkyBox;
	
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	
	import sunag.sea3dgp;
	import sunag.sea3d.core.assets.ABC;
	import sunag.sea3d.core.assets.Actions;
	import sunag.sea3d.core.assets.Reference;
	import sunag.sea3d.easing.Motion;
	import sunag.sea3d.events.CollisionEvent;
	import sunag.sea3d.events.TouchEvent;
	import sunag.sea3d.framework.ATFTexture;
	import sunag.sea3d.framework.AnimationStandard;
	import sunag.sea3d.framework.Camera3D;
	import sunag.sea3d.framework.CollisionSensor;
	import sunag.sea3d.framework.CubeMap;
	import sunag.sea3d.framework.CubeMapFile;
	import sunag.sea3d.framework.DirectionalLight;
	import sunag.sea3d.framework.Dummy;
	import sunag.sea3d.framework.Geometry;
	import sunag.sea3d.framework.JointObject;
	import sunag.sea3d.framework.Mesh;
	import sunag.sea3d.framework.Object3D;
	import sunag.sea3d.framework.OrthographicCamera;
	import sunag.sea3d.framework.ParticleContainer;
	import sunag.sea3d.framework.PerspectiveCamera;
	import sunag.sea3d.framework.Physics;
	import sunag.sea3d.framework.PointLight;
	import sunag.sea3d.framework.RigidBody;
	import sunag.sea3d.framework.Scene3D;
	import sunag.sea3d.framework.ScreenMode;
	import sunag.sea3d.framework.Skeleton;
	import sunag.sea3d.framework.SkeletonAnimation;
	import sunag.sea3d.framework.Sparticle;
	import sunag.sea3d.framework.StandardMaterial;
	import sunag.sea3d.framework.TextureFile;
	import sunag.sea3d.input.Input;
	import sunag.sea3d.input.InputBase;
	import sunag.sea3d.input.KeyboardInput;
	import sunag.sea3d.input.MouseInput;
	import sunag.sea3d.loader.LoaderManager;
	import sunag.sea3d.math.Vector3D;
	import sunag.sea3d.objects.SEAABC;
	import sunag.sea3d.objects.SEAATF;
	import sunag.sea3d.objects.SEAAction;
	import sunag.sea3d.objects.SEAAnimation;
	import sunag.sea3d.objects.SEACollisionSensor;
	import sunag.sea3d.objects.SEACubeMap;
	import sunag.sea3d.objects.SEACubeURL;
	import sunag.sea3d.objects.SEADirectionalLight;
	import sunag.sea3d.objects.SEADummy;
	import sunag.sea3d.objects.SEAGIF;
	import sunag.sea3d.objects.SEAGeometry;
	import sunag.sea3d.objects.SEAGeometryDelta;
	import sunag.sea3d.objects.SEAJPEG;
	import sunag.sea3d.objects.SEAJPEGXR;
	import sunag.sea3d.objects.SEAJointObject;
	import sunag.sea3d.objects.SEAMaterial;
	import sunag.sea3d.objects.SEAMesh;
	import sunag.sea3d.objects.SEAOrthographicCamera;
	import sunag.sea3d.objects.SEAPNG;
	import sunag.sea3d.objects.SEAParticleContainer;
	import sunag.sea3d.objects.SEAPerspectiveCamera;
	import sunag.sea3d.objects.SEAPointLight;
	import sunag.sea3d.objects.SEAReference;
	import sunag.sea3d.objects.SEARigidBody;
	import sunag.sea3d.objects.SEASkeleton;
	import sunag.sea3d.objects.SEASkeletonAnimation;
	import sunag.sea3d.objects.SEASparticle;
	import sunag.sea3d.objects.SEATextureURL;
	import sunag.sea3d.utils.TimeStep;

	use namespace sea3dgp;
	
	public class SEA3DGP
	{	
		sea3dgp static const REFERENCE:Object = {};
		sea3dgp static const GLOBAL:Object = {};
		sea3dgp static const TYPE_CLASS:Object = {};			
				
		sea3dgp static var scenes:Vector.<sunag.sea3d.framework.Scene3D> = new Vector.<sunag.sea3d.framework.Scene3D>();
		sea3dgp static var views:Vector.<View3D> = new Vector.<View3D>();
		sea3dgp static var frontView:View3D;		
		sea3dgp static var cameras:Vector.<Camera3D> = new Vector.<Camera3D>();
		sea3dgp static var content:Sprite = new Sprite;
		sea3dgp static var area:Sprite = new Sprite;
		
		sea3dgp static var events:EventDispatcher;
		sea3dgp static var stage:Stage;
		sea3dgp static var container:DisplayObjectContainer;		
		sea3dgp static var c3d:away3d.containers.Scene3D;
		sea3dgp static var f3d:away3d.containers.Scene3D;
		sea3dgp static var stage3DManager:Stage3DManager;
		sea3dgp static var proxy:Stage3DProxy;
		sea3dgp static var isPPAPI:Boolean;
		sea3dgp static var config:Config;
		sea3dgp static var manager:LoaderManager;
		sea3dgp static var renderMode:String;
		sea3dgp static var world:AWPDynamicsWorld;
		sea3dgp static var worldDraw:AWPDebugDraw;		
		
		sea3dgp static var envMap:CubeMap;
		
		sea3dgp static var fogMtd:FogMethod;
		sea3dgp static var skyBox:SkyBox;
		sea3dgp static var lightPicker:StaticLightPicker = new StaticLightPicker([]);	
		sea3dgp static var shadowLight:DirectionalLight;
		
		sea3dgp static var _overObject:Object3D;	
		
		sea3dgp static var overObj:IRenderable;	
		sea3dgp static var overPos:flash.geom.Vector3D;
		sea3dgp static var overNor:flash.geom.Vector3D;
		
		sea3dgp static var overFObj:IRenderable;	
		sea3dgp static var overFPos:flash.geom.Vector3D;
		sea3dgp static var overFNor:flash.geom.Vector3D;
		
		sea3dgp static var mouseManager:Mouse3DManager;
		sea3dgp static var mousePos:flash.geom.Vector3D = new flash.geom.Vector3D();
		
		sea3dgp static const envReg:RegExp = /^%\w+%/;
		sea3dgp static const env:Object = {};
		
		public static function init(container:DisplayObjectContainer, config:Config=null):void
		{						
			sea3dgp::container = container;
			
			stage = container.stage;
			stage.stageFocusRect = false;
			stage.showDefaultContextMenu = false;
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, function(e:MouseEvent):void { });			
			
			sea3dgp::config = config ||= new Config();
			
			stage3DManager = Stage3DManager.getInstance(stage);
			
			proxy = stage3DManager.getFreeStage3DProxy(false, config.profile);
			proxy.color = stage.color;
			proxy.antiAlias = config.antiAlias;
			proxy.mouse3DManager = mouseManager = new Mouse3DManager();
			
			mouseManager.forceMouseMove = true;
			
			manager = new LoaderManager();
			if (config.showProgress) container.addChild( manager );
									
			events = new EventDispatcher();
			
			//
			//	LOADERS
			//
			
			Parsers.enableAllBundled();
			
			SingleFileLoader.enableParser(ParticleGroupParser);			
			
			//
			//	CONTAINER
			//
			
			area.addEventListener(MouseEvent.CLICK, onMouseClick, false, 1000, true);					
			area.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 1000, true);
			area.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent, false, 1000, true);
			area.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent, false, 1000, true);
			area.addEventListener(MouseEvent.MOUSE_OVER, onMouseOver, false, 1000, true);
			area.addEventListener(MouseEvent.MOUSE_OUT, onMouseOut, false, 1000, true);
			area.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 1000, true);	
			
			container.addChild( content );
			container.addChild( area );
													
			//
			//	LOADER
			//
			
			TYPE_CLASS[SEAABC.TYPE] = ABC;
			
			TYPE_CLASS[SEAReference.TYPE] = Reference;
			TYPE_CLASS[SEAAction.TYPE] = Actions;		
			TYPE_CLASS[SEAMesh.TYPE] = Mesh;			
			TYPE_CLASS[SEAGeometry.TYPE] = Geometry;
			TYPE_CLASS[SEAGeometryDelta.TYPE] = Geometry;			
			TYPE_CLASS[SEASkeleton.TYPE] = Skeleton;
			TYPE_CLASS[SEASkeletonAnimation.TYPE] = SkeletonAnimation;
			TYPE_CLASS[SEAPerspectiveCamera.TYPE] = PerspectiveCamera;
			TYPE_CLASS[SEAOrthographicCamera.TYPE] = OrthographicCamera;
			TYPE_CLASS[SEAMaterial.TYPE] = StandardMaterial;
			TYPE_CLASS[SEAAnimation.TYPE] = AnimationStandard;
			TYPE_CLASS[SEAPointLight.TYPE] = PointLight;
			TYPE_CLASS[SEADirectionalLight.TYPE] = DirectionalLight;
			TYPE_CLASS[SEAJointObject.TYPE] = JointObject;
			TYPE_CLASS[SEADummy.TYPE] = Dummy;
			TYPE_CLASS[SEACubeMap.TYPE] = CubeMapFile;
			TYPE_CLASS[SEACubeURL.TYPE] = CubeMapFile;
			TYPE_CLASS[SEAParticleContainer.TYPE] = ParticleContainer;						
			
			TYPE_CLASS[SEASparticle.TYPE] = Sparticle;
			
			TYPE_CLASS[SEAJPEG.TYPE] = TextureFile;
			TYPE_CLASS[SEAJPEGXR.TYPE] = TextureFile;
			TYPE_CLASS[SEAPNG.TYPE] = TextureFile;
			TYPE_CLASS[SEAGIF.TYPE] = TextureFile;
			TYPE_CLASS[SEATextureURL.TYPE] = TextureFile;
			TYPE_CLASS[SEAATF.TYPE] = ATFTexture;			
			
			TYPE_CLASS[SEARigidBody.TYPE] = RigidBody;
			TYPE_CLASS[SEACollisionSensor.TYPE] = CollisionSensor;
									
			//
			//	PROXY CLASS ( PREVENT NOT-INCLUSION BY THE COMPILER )
			//
			
			sunag.sea3d.math.Vector3D;
			
			//
			//	FRAMEWORK
			//											
			
			var names:Vector.<String> = ApplicationDomain.currentDomain.getQualifiedDefinitionNames();
			
			var reserved:Object = {
				'sunag.sea3d.events::' : 'events.',
				'sunag.sea3d.framework::' : 'sea3d.',
				'sunag.sea3d.input::' : 'input.',
				'sunag.sea3d.math::' : 'math.',
				'sunag.sea3d.utils::' : 'utils.',
				'sunag.sea3d.easing::' : 'easing.'
			}
			
			for each(var name:String in names)
			{
				for(var ns:String in reserved)
				{
					if (name.indexOf(ns) == 0)
					{
						var CLASS:Class = ApplicationDomain.currentDomain.getDefinition(name) as Class;
						var NS:String = reserved[ns] + name.substring(ns.length);
						
						REFERENCE[NS] = CLASS['PROXY'] || CLASS;																	
					}
				}
			}
			
			//			
			//	MODULES
			//
						
			Input.init(stage);
			KeyboardInput.init(stage);
			MouseInput.init(stage);
			
			TimeStep.init(stage);						
			
			world = AWPDynamicsWorld.getInstance();
			world.initWithDbvtBroadphase();
			world.collisionCallbackOn = true;
			
			if (config.drawPhysics)
			{
				worldDraw = new AWPDebugDraw(null, world);
				worldDraw.debugMode = 
					AWPDebugDraw.DBG_DrawConstraints | 
					AWPDebugDraw.DBG_DrawConstraintLimits | 
					AWPDebugDraw.DBG_DrawRay | 
					AWPDebugDraw.DBG_DrawTransform | 
					AWPDebugDraw.DBG_DrawCollisionShapes;
			}
			
			//
			//	CROSS BROWSER
			//
			
			var jsCodeIsPPAPI:String = "function(){var type='application/x-shockwave-flash';var mimeTypes=navigator.mimeTypes;var endsWith=function(str,suffix){return str.indexOf(suffix,str.length-suffix.length)!==-1;};return(mimeTypes&&mimeTypes[type]&&mimeTypes[type].enabledPlugin&&(mimeTypes[type].enabledPlugin.filename=='pepflashplayer.dll'||mimeTypes[type].enabledPlugin.filename=='libpepflashplayer.so'||endsWith(mimeTypes[type].enabledPlugin.filename,'Chrome.plugin')));}";
			
			if (ExternalInterface.available)
			{										
				isPPAPI = ExternalInterface.call(jsCodeIsPPAPI);
			}
						
			//
			//	AWAY3D CONFIG
			//
			
			c3d = new away3d.containers.Scene3D();
			c3d.addEventListener(MouseEvent3D.MOUSE_MOVE, onMouseOver3D);
			c3d.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver3D);
			c3d.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut3D);
			
			f3d = new away3d.containers.Scene3D();
			f3d.addEventListener(MouseEvent3D.MOUSE_MOVE, onFMouseOver3D);
			f3d.addEventListener(MouseEvent3D.MOUSE_OVER, onFMouseOver3D);
			f3d.addEventListener(MouseEvent3D.MOUSE_OUT, onFMouseOut3D);
			
			frontView = createView(f3d);	
			
			screenMode = ScreenMode.SINGLE;
			
			//
			//	EVENTS
			//
			
			if (config.autoPlay)
			{
				stage.addEventListener(flash.events.Event.ENTER_FRAME, onUpdate, false, -1);
			}
			
			stage.addEventListener(flash.events.Event.RESIZE, onResize);
		}
		
		//
		//	RENDER
		//
		
		private static function createView(scene:away3d.containers.Scene3D):View3D
		{
			var view:View3D = new View3D(scene, Camera3D.NULL);
			
			view.stage3DProxy = proxy;			
			view.rightClickMenuEnabled = false;
			view.shareContext = view.layeredView = true;	
			view.mousePicker = config.shaderPicker ? PickingType.SHADER : PickingType.RAYCAST_BEST_HIT;
			view.stage3DProxy.enableErrorChecking = isPPAPI;						
			
			return view;
		}
		
		public static function set screenMode(val:String):void
		{
			if (renderMode == val) 
				return;
			
			function splitViewport(count:int):void
			{
				var i:int;
				
				for (i = count; i < views.length; i++)
				{
					content.removeChild( views[i] );					
					views[i].dispose();
				}
			
				if (count < views.length)
					views.length = count;
				
				for (i = views.length; i < count; i++)
				{
					views[i] = createView(c3d);
					content.addChild(views[i]);
				}
				
				if (worldDraw)
				{
					worldDraw.view = views[0];
				}
				
				cameras.length = views.length;
			}
			
			switch((renderMode = val))
			{
				case ScreenMode.SINGLE:
					splitViewport(1);					
					break;
				
				case ScreenMode.SPLIT_HORIZONTAL:
				case ScreenMode.SPLIT_VERTICAL:
					splitViewport(2);
					break;
			}
			
			updateViews();
			
			onResize();
		}
		
		public static function get screenMode():String
		{
			return renderMode;
		}
		
		private static function updateViews():void
		{
			for (var i:int = 0; i < views.length; i++)
			{
				if (views[i].stage) 
				{
					content.addChild( views[i] );
					mouseManager.addViewLayer( views[i] );
				}				
			}
			
			content.addChild( frontView );
			mouseManager.addViewLayer( frontView );
		}
		
		//
		//	ENVIRONMENT
		//
		
		public static function setEnv(name:String, ns:String=null):void
		{
			name = '%' + name + '%';
			
			if (ns) env[name] = ns;
			else delete env[name];
		}
		
		public static function isEnv(name:String):Boolean
		{
			return envReg.test( name ) && getEnv( envReg.exec( name )[0] ) != null;
		}
		
		public static function parseEnv(name:String):String
		{
			return name.replace( envReg, env[ envReg.exec( name )[0] ] );
		}
		
		public static function getEnv(name:String):String
		{	
			return env[name];
		}
		
		//
		//	INPUT
		//
		
		public static function addPlayer(player:InputBase, name:String="p1"):void
		{		
			Input.players[name] = player;
		}
		
		public static function removePlayer(name:String):void
		{
			delete Input.players[name];
		}
		
		public static function getPlayer(name:String):InputBase
		{
			return Input.players[name];
		}
		
		//
		//	GAME
		//
		
		
		public static function set camera(camera:Camera3D):void
		{
			setCamera(0, camera);
		}
		
		public static function get camera():Camera3D
		{
			return cameras[0];
		}
		
		public static function setScreen(screen:int, visible:Boolean):void
		{
			if (getScreen(screen) == visible) return;
			
			if (visible)
			{
				content.addChild(views[screen]);
			}
			else
			{
				content.removeChild(views[screen]);
			}
			
			updateViews();
			
			onResize();
		}
		
		public static function getScreen(screen:int):Boolean
		{
			return Boolean(views[screen].stage);
		}
		
		public static function setCamera(screen:int, camera:Camera3D):void
		{
			if (camera)
			{
				cameras[screen] = camera;
				
				camera.view3d = views[screen];				
				camera.view3d.camera = camera.camera;
			}
			else
			{
				if (cameras[screen])
				{
					cameras[screen].view3d = null;
					cameras[screen] = null;
				}
				
				views[screen].camera = Camera3D.NULL;				
			}
		}
		
		public static function getCamera(screen:int):Camera3D
		{
			return cameras[screen];
		}
		
		public static function set fog(val:Boolean):void
		{
			if (val && !fogMtd)
			{
				fogMtd = new FogMethod(100, 1000, 0x0000FF);
				
				events.dispatchEvent(new SEA3DGPEvent(SEA3DGPEvent.INVALIDATE_MATERIAL));
			}			
			else if (!val && fogMtd)
			{
				fogMtd.dispose();
				fogMtd = null;
				
				events.dispatchEvent(new SEA3DGPEvent(SEA3DGPEvent.INVALIDATE_MATERIAL));
			}
		}
		
		public static function get fog():Boolean
		{
			return fog;
		}
		
		public static function set fogColor(color:Number):void
		{
			fogMtd.fogColor = color;
		}
		
		public static function get fogColor():Number
		{
			return fogMtd.fogColor;
		}
		
		public static function set fogMin(val:Number):void
		{
			fogMtd.minDistance = val;
		}
		
		public static function get fogMin():Number
		{
			return fogMtd.minDistance;
		}
		
		public static function set fogMax(min:Number):void
		{
			fogMtd.maxDistance = min;
		}
		
		public static function get fogMax():Number
		{
			return fogMtd.maxDistance;
		}
		
		public static function set mouseEnabled(val:Boolean):void
		{
			if (val == mouseEnabled) return;
			
			var picker:IPicker = val ? (config.shaderPicker ? PickingType.SHADER : PickingType.RAYCAST_BEST_HIT) : null;
			proxy.mouse3DManager = val ? mouseManager : null;
			
			for each(var v:View3D in views)
			{
				v.mousePicker = picker;
			}
		}
		
		public static function get mouseEnabled():Boolean
		{
			return proxy.mouse3DManager != null;
		}
		
		public static function set environment(val:CubeMap):void
		{
			if ((envMap = val))
			{
				if (!skyBox) 
				{
					skyBox = new SkyBox( val.scope );
					c3d.addChild( skyBox );
				}
				else SkyBoxMaterial(skyBox.material).cubeMap = val.scope;
			}
			else if (skyBox)
			{
				skyBox.dispose();
				skyBox = null;				
			}
		}
		
		public static function get environment():CubeMap
		{
			return envMap;
		}
		
		public static function set environmentColor(color:Number):void
		{
			if (proxy.color == color) 
				return;
			
			proxy.color = color;						
		}
		
		public static function get environmentColor():Number
		{
			return proxy.color;
		}
		
		//
		//	PUBLIC METHODS
		//
		
		public static function update():void
		{
			var game:sunag.sea3d.framework.Scene3D,
				i:int, physics:Physics;
			
			//
			//	NETWORK-RECEIVE
			//
			
			//
			//	INPUT
			//
			
			Input.update();						
			
			//
			//	MOTION
			//
			
			Motion.update();
			
			//
			//	PHYSICS
			//
			
			for each(game in scenes)
			{
				for each(physics in game.collided)								
					physics.cls = false;				
			}
			
			world.physicsStep(TimeStep.step / 1000);
			
			for each(game in scenes)
			{
				i = 0;				
				
				while ( i < game.collided.length )
				{
					physics = game.collided[i];
					
					if (!physics.cls)
					{
						var c:Physics = physics.collision;
						
						physics.collision = null;
						physics.clsAdded = false;
						
						game.collided.splice( i, 1 );
						
						physics.dispatchEvent(new CollisionEvent(CollisionEvent.COLLISION_OUT, c));																		
						continue;
					}
					++i;
				}			
			}
			
			//
			//	GAME STATE
			//
			
			for each(game in scenes)
				game.update();
			
			//
			//	NETWORK-SEND
			//
			
			//
			//	TIMER
			//
			
			TimeStep.updateTime();						
		}
		
		public static function render(bitmapData:BitmapData=null):void
		{
			if (worldDraw && worldDraw.view)
			{
				worldDraw.debugDrawWorld();
			}
			
			//
			//	RENDER
			//
			
			var v:View3D;
			
			proxy.clear();			
			
			for each(var view:View3D in views)
			{
				if (view.stage) 
				{					
					view.render();
					v = view;
				}
			}
			
			proxy.clearDepthBuffer();
			
			frontView.x = v.x;
			frontView.y = v.y;
			frontView.width = v.width;
			frontView.height = v.height;
			frontView.camera = v.camera;
			frontView.render();			
			
			if (bitmapData)
			{
				proxy.context3D.drawToBitmapData( bitmapData );
			}
			else
			{
				proxy.present();
			}					
		}
				
		public static function get overObject():Object3D
		{
			var over:IRenderable = overFObj ? overFObj : overObj;
			
			if (over is SubMesh)
			{
				return SubMesh(over).sourceEntity.extra as Object3D;
			}
			
			return null;
		}
		
		public static function get overPosition():flash.geom.Vector3D
		{
			if (overFObj)
				return overFPos.clone();
			
			return overObj ? overPos.clone() : new flash.geom.Vector3D();
		}
		
		public static function get overNormal():flash.geom.Vector3D
		{
			if (overFObj)
				return overFNor.clone();
			
			return overObj ? overNor.clone() : flash.geom.Vector3D.Y_AXIS;
		}
		
		//
		//	VIEW3D
		//
						
		protected static function get isClick():Boolean
		{
			return Math.abs(mousePos.x - stage.mouseX) < 2 && Math.abs(mousePos.y - stage.mouseY) < 2;
		}
		
		private static function onMouseDown(e:MouseEvent):void
		{
			mousePos = new flash.geom.Vector3D(stage.mouseX, stage.mouseY);
			onMouseEvent(e);
		}
		
		private static function onMouseClick(e:MouseEvent):void
		{
			if (isClick)
			{
				onMouseEvent(e);
			}
		}
		
		private static function onMouseOver(e:MouseEvent):void
		{
			onMouseMove(e);
		}
		
		private static function onMouseOut(e:MouseEvent):void
		{
			var overObj:Object3D = overObject;
			
			if (overObj)
			{
				overObj.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OUT, overPosition, overNormal, e.delta));
				
				_overObject = null
			}
		}
		
		private static function onMouseMove(e:MouseEvent):void
		{
			var overObj:Object3D = overObject;
			
			if (_overObject != overObj)
			{
				if (_overObject)
					_overObject.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OUT, overPosition, overNormal, e.delta));
				
				if (overObj)
					overObj.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_OVER, overPosition, overNormal, e.delta));
			}
			else if (_overObject)
			{
				_overObject.dispatchEvent(new TouchEvent(TouchEvent.TOUCH_MOVE, overPosition, overNormal, e.delta));
			}
			
			_overObject = overObj;
		}
		
		private static function onMouseEvent(e:MouseEvent):void
		{
			var obj3d:Object3D = overObject;
			
			if (obj3d)
			{
				var type:String = TouchEvent.MouseDict[e.type];
				
				if (obj3d.eDict[type])
				{
					obj3d.dispatchEvent( new TouchEvent(type, overPosition, overNormal, e.delta) );
				}
			}
		}
		
		private static function onMouseOver3D(e:MouseEvent3D):void
		{
			overObj = e.renderable;
			overPos = e.scenePosition;
			overNor = e.sceneNormal;
		}
		
		private static function onMouseOut3D(e:MouseEvent3D):void
		{
			overObj = null;
		}
		
		private static function onFMouseOver3D(e:MouseEvent3D):void
		{
			overFObj = e.renderable;
			overFPos = e.scenePosition;
			overFNor = e.sceneNormal;	
		}
		
		private static function onFMouseOut3D(e:MouseEvent3D):void
		{
			overFObj = null;
		}
		
		//
		//	INTERNAL
		//
		
		private static function onUpdate(e:flash.events.Event=null):void
		{
			update();
			render();
		}
		
		private static function onResize(e:flash.events.Event=null):void
		{
			var w:int = stage.stageWidth,
				h:int = stage.stageHeight;
			
			manager.width = w;
			manager.height = h;
			
			proxy.width = w;
			proxy.height = h;
			
			area.graphics.clear();
			area.graphics.beginFill(0xFF,0);
			area.graphics.drawRect(0, 0, w, h);
			area.graphics.endFill();			
			
			switch(renderMode)
			{
				case ScreenMode.SINGLE:
					views[0].width = w;
					views[0].height = h;
					break;
				
				case ScreenMode.SPLIT_HORIZONTAL:					
					if (!views[0].stage || !views[1].stage)
					{
						views[1].x = views[0].x = 0;
						views[1].y = views[0].y = 0;
						views[1].width = views[0].width = w;
						views[1].height = views[0].height = h;	
					}
					else
					{
						w = Math.round( w / 2);
												
						views[0].x = 0;
						views[0].y = 0;
						views[0].width = w;
						views[0].height = h;
						
						views[1].x = w;
						views[1].y = 0;
						views[1].width = w;
						views[1].height = h;
					}

					break;
					
				case ScreenMode.SPLIT_VERTICAL:
					views[0].width = w;
					views[0].height = Math.round( h / 2);
					
					views[1].x = 0;
					views[1].y = views[0].height;
					views[1].width = w;
					views[1].height = views[0].height;
					break;
			}
		}
	}
}