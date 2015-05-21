/* Copyright (c) 2013 Sunag Entertainment
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:

* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.

* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE. */

package
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DProfile;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.system.System;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.VertexAnimationSet;
	import away3d.animators.VertexAnimator;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.nodes.VertexClipNode;
	import away3d.bounds.BoundingSphere;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.container.DynamicScene3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.core.managers.Stage3DManager;
	import away3d.entities.JointObject;
	import away3d.entities.Mesh;
	import away3d.filters.BloomFilter3D;
	import away3d.filters.ColorBalanceFilter3D;
	import away3d.filters.ColorMatrixFilter3D;
	import away3d.filters.Filter3DBase;
	import away3d.filters.LevelsFilter3D;
	import away3d.filters.MotionBlurFilter3D;
	import away3d.filters.RadialBlurFilter3D;
	import away3d.lights.ThreePointLight;
	import away3d.loaders.misc.SingleFileLoader;
	import away3d.loaders.parsers.Parsers;
	import away3d.loaders.parsers.ParticleGroupParser;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.DynamicFogMethod;
	import away3d.sea3d.animation.SkeletonAnimation;
	import away3d.sea3d.animation.VertexAnimation;
	import away3d.textures.BitmapTexture;
	import away3d.textures.CubeReflectionTextureTarget;
	import away3d.textures.PlanarReflectionTextureTarget;
	import away3d.tools.utils.Bounds;
	
	import awayphysics.debug.AWPDebugDraw;
	import awayphysics.dynamics.AWPDynamicsWorld;
	
	import sunag.sunag;
	import sunag.animation.Animation;
	import sunag.animation.AnimationPlayer;
	import sunag.animation.AnimationSet;
	import sunag.controller.FreeCameraController;
	import sunag.events.SEA3DDebugEvent;
	import sunag.events.SEAEvent;
	import sunag.filters.ColorMatrix;
	import sunag.player.ModeButton;
	import sunag.player.PlayerEvent;
	import sunag.player.PlayerState;
	import sunag.progressbar.ProgressCircleLoader;
	import sunag.sea3d.SEA3D;
	import sunag.sea3d.SEA3DDebug;
	import sunag.sea3d.config.DefaultConfig;
	import sunag.sea3d.config.DynamicConfig;
	import sunag.sea3d.config.IConfig;
	import sunag.sea3d.config.ShadowMethod;
	import sunag.sea3d.debug.DefaultDebug;
	import sunag.sea3d.debug.IDebug;
	import sunag.sea3d.modules.ActionModuleDebug;
	import sunag.sea3d.modules.HelperModule;
	import sunag.sea3d.modules.ParticleModule;
	import sunag.sea3d.modules.PhysicsModule;
	import sunag.sea3d.modules.RTTModule;
	import sunag.sea3d.modules.SoundModuleDebug;
	import sunag.sea3d.objects.SEAFileInfo;
	import sunag.sea3d.player.Player;
	import sunag.utils.TimeStep;
	
	[SWF(width="1024", height="632", backgroundColor="0x333333", frameRate="60")] // 0x2f3032
	public class SEA3DPlayer extends Sprite
	{
		protected var player:Player;		
		protected var sea3d:SEA3D;		
		
		protected var sea3dDebug:IDebug;
		protected var sea3dConfig:IConfig;
		
		protected var scene:Scene3D;
		protected var view:View3D;
		
		private var background:BitmapTexture;
		private var rttModule:RTTModule;				
		private var controller:FreeCameraController;
		private var defaultCamera:Camera3D;
		private var orbitCamera:Camera3D;
		private var progressBar:ProgressCircleLoader;						
		private var stage3DManager:Stage3DManager;
		private var isPPAPI:Boolean;
		private var defaultLights:ThreePointLight;
		private var timer:TimeStep = new TimeStep(stage.frameRate, false);
		private var center:Vector3D;
		private var container:ObjectContainer3D = new ObjectContainer3D;
		
		private var physicsWorld:AWPDynamicsWorld; 
		private var debugDraw:AWPDebugDraw;
		
		protected var actualCamera:String = "";
		protected var autoPlay:Boolean = false;		
		protected var forceCPU:Boolean = true;
		protected var enabledFog:Boolean = true;
		protected var shadowMethod:String = ShadowMethod.NEAR;
		protected var isDebug:Boolean = false;
		protected var showWarning:Boolean = true;
		protected var alignCamera:Boolean = false;
		protected var dynamicMode:Boolean = false;
		protected var compactGeometry:Boolean = false;
		
		private var _actualPreset:int = 0;
		
		public function SEA3DPlayer()
		{
			//
			//	FLASH CONFIG
			//
						
			stage.stageFocusRect = false;
			stage.showDefaultContextMenu = false;	
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, function(e:MouseEvent):void {} );
			
			try
			{
				Security.allowDomain("*");
			}
			catch(e:Error)
			{
				
			}
			
			//
			//	AWAY3D CONFIG
			//
			
			scene = dynamicMode ? new DynamicScene3D() : new Scene3D();
			scene.addChild( container );
			
			stage3DManager = Stage3DManager.getInstance(stage);
						
			view = new View3D(scene);	
			view.stage3DProxy = stage3DManager.getFreeStage3DProxy(false, Context3DProfile.BASELINE);
			view.backgroundColor = stage.color;
			view.antiAlias = 4;
			view.rightClickMenuEnabled = false;	
			view.background = background = new BitmapTexture( getRadialBitmap() );
			
			addChild(view);																		
			
			//
			//	AWAY3D PHYSICS
			//
			
			physicsWorld = AWPDynamicsWorld.getInstance();
			physicsWorld.initWithDbvtBroadphase();
			
			debugDraw = new AWPDebugDraw(view, physicsWorld);
			debugDraw.debugMode = 
				AWPDebugDraw.DBG_DrawConstraints | 
				AWPDebugDraw.DBG_DrawConstraintLimits | 
				AWPDebugDraw.DBG_DrawRay | 
				AWPDebugDraw.DBG_DrawTransform | 
				AWPDebugDraw.DBG_DrawCollisionShapes;
									
			//
			//	SEA3D CONFIG
			//
			
			// static lights = fast
			// dynamic lights = compatible
			
			sea3dDebug = new DefaultDebug();
			
			sea3dConfig = dynamicMode ? new DynamicConfig() : new DefaultConfig();	
			
			//
			//	External Config
			//
			
			sea3dConfig.updateGlobalPose = true;			
			sea3dConfig.autoUpdate = false;			
			sea3dConfig.container = container;
			sea3dConfig.forceStreaming = true;
			
			//
			//	Enable Sparticle Parser
			//
			
			SingleFileLoader.enableParser(ParticleGroupParser);
			
			Parsers.enableAllBundled();
			
			//
			//	SEA3D
			//
			
			sea3d = new SEA3DDebug(sea3dDebug, sea3dConfig);
			sea3d.addModule(new SoundModuleDebug());
			sea3d.addModule(new HelperModule());			
			sea3d.addModule(rttModule = new RTTModule());
			sea3d.addModule(new ActionModuleDebug(view));
			sea3d.addModule(new PhysicsModule(physicsWorld));
			sea3d.addModule(new ParticleModule());
			
			if (isDebug) scene.addChild(sea3dDebug.container);	
			
			sea3d.addEventListener(SEAEvent.COMPLETE, onComplete);
			sea3d.addEventListener(SEAEvent.PROGRESS, onProgress);
			sea3d.addEventListener(SEAEvent.COMPLETE_OBJECT, onCompleteObject);
			sea3d.addEventListener(SEA3DDebugEvent.WARN, onWarn);
			
			//
			//	CROSS-BROWSER
			//
			
			var jsCodeIsPPAPI:String = "function(){var type='application/x-shockwave-flash';var mimeTypes=navigator.mimeTypes;var endsWith=function(str,suffix){return str.indexOf(suffix,str.length-suffix.length)!==-1;};return(mimeTypes&&mimeTypes[type]&&mimeTypes[type].enabledPlugin&&(mimeTypes[type].enabledPlugin.filename=='pepflashplayer.dll'||mimeTypes[type].enabledPlugin.filename=='libpepflashplayer.so'||endsWith(mimeTypes[type].enabledPlugin.filename,'Chrome.plugin')));}";
			
			if (ExternalInterface.available)
			{										
				view.stage3DProxy.enableErrorChecking = isPPAPI = ExternalInterface.call(jsCodeIsPPAPI);
			}
			
			if (ExternalInterface.available)
			{				
				ExternalInterface.addCallback("browserURLChange", onBrowserURLChange);
			}
			
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError,false,int.MAX_VALUE);
			
			//
			//	USER INTERFACE
			//
			
			player = new Player();				
			player.console.background.visible = false;
			player.upload.addEventListener(PlayerEvent.UPLOAD, onUpload);
			player.mode.addEventListener(Event.CHANGE, onMode);
			player.ar.visible = false;			
			
			addChild(player);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			stage.addEventListener(Event.RESIZE, updateAlign);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			reloadTips();
			updateAlign();
		}
		
		private function getRadialBitmap(size:int=1024):BitmapData
		{
			var s:Sprite = new Sprite;
			var g:Graphics = s.graphics;
			
			var r:Number = size;
			
			var m:Matrix = new Matrix();
			m.createGradientBox(r*2,r*2,0,-r/2,-r/2);
			g.beginGradientFill(GradientType.RADIAL, [0x555555, 0x111111], [1,1], [0,255], m);
			g.drawCircle(r/2,r/2,r);
			
			var bitmap:BitmapData = new BitmapData(size, size, false, 0x000000);			
			bitmap.draw( s );
			
			return bitmap;
		}
		
		private function reloadTips():void
		{
			switch(Math.round(Math.random() * 2))
			{				
				case 0:
					player.tips = "Use the key <b>C</b> to change the Camera.";
					break;
				case 1:
					player.tips = "Use the keys <b>Page Down</b> and <b>Page Up</b> to change the effect of <b>Post-Processing</b>.";
					break;
				case 2:
					player.tips = "Use the keys <b>+</b> and <b>-</b> to change the <b>time scale</b> of animations.";
					break;
			}
		}
		
		public function printError(msg:String):void
		{
			
		}
		
		public function printWarn(msg:String):void
		{
			
		}
		
		private function onBrowserURLChange(url:String):void
		{			
		}							
		
		public function unload():void
		{
			sea3dConfig.forceMorphCPU = forceCPU || dynamicMode; // force compatibility
			sea3dConfig.forceCPU = forceCPU;
			sea3dConfig.enabledFog = enabledFog;
			sea3dConfig.shadowMethod = shadowMethod;
			sea3dConfig.forceCompactGeometry = compactGeometry;
			sea3dConfig.forceStreaming = true;
			
			player.markerVisible = false;			
			player.progress = 0;
			player.target = null;
			player.error = "";
			player.title = null;
			player.tips = "";							
			player.logo.visible = false;
			
			setTitle(null);
			
			if (sea3d)
			{			
				view.backgroundColor = stage.color;
				
				sea3d.dispose();
				
				if (sea3dConfig is DefaultConfig)
				{
					DefaultConfig(sea3dConfig).dispose();
					DefaultConfig(sea3dConfig).lightPicker = new StaticLightPicker([]);
				}
				else if (sea3dConfig is DynamicConfig)
					DynamicConfig(sea3dConfig).dispose();
				
				sea3dDebug.dispose();
				
				player.position = 0;
				
				if (sea3dConfig.player)
					AnimationPlayer(sea3dConfig.player).stop();
				
				DynamicFogMethod.instance.enabled = false;
			}						
			
			sea3dConfig.player = new AnimationPlayer();
			
			if (defaultCamera) 
			{
				defaultCamera.dispose();
				defaultCamera = null;
			}
			
			defaultCamera = getDefaultCamera();
			
			setCamera();
		}
		
		public function load(data:*):void
		{
			unload();
			
			if (data is URLRequest)
				sea3d.load(data);
			else if (data is ByteArray) 
				sea3d.loadBytes(data);	
			else if (data is String)
				sea3d.load(new URLRequest(data));
		}				
		
		public function loadBytes(data:ByteArray):void
		{
			sea3d.loadBytes(data);	
		}
		
		private function setTitle(value:String):void
		{
			if (ExternalInterface.available)			
				ExternalInterface.call("setTitle", value);			
		}
		
		private function onMode(e:Event):void
		{		
			if (!orbitCamera || !defaultCamera) return;
			
			if (view.camera != orbitCamera && view.camera != defaultCamera)
			{				
				orbitCamera.transform = defaultCamera.transform = view.camera.transform;
			}			
			
			if (player.mode.mode == ModeButton.ORBIT)
			{
				orbitCamera.transform = defaultCamera.transform;
			}
			else
			{
				defaultCamera.transform = orbitCamera.transform;
			}
			
			setCamera();
		}
		
		private function onUpload(e:PlayerEvent):void
		{						
			load(player.upload.data);	
		}				
		
		private function onProgress(e:SEAEvent):void
		{						
			player.progress = sea3d.length == 0 ? 0 : sea3d.position / sea3d.length;					
		}
		
		private function onWarn(e:SEA3DDebugEvent):void
		{
			printWarn( 'GPU Warning: ' + e.message );
			player.tips += '<b><font color="#FF9900">GPU Warning:</font></b> ' + e.message + '\n';
		}
		
		protected function onCompleteObject(e:SEAEvent):void
		{
			trace(e.object.name + "." + e.object.type, e.time);
			
			switch(e.object.type)
			{
				case SEAFileInfo.TYPE:
					if (sea3d.getFileInfo())
					{
						var info:Object = sea3d.getFileInfo();
						var title:Array = [];
						
						if (info["title"])		
						{
							title.push("<b>" + info["title"] + "</b>\n");
							setTitle(info.title);
						}
						
						if (info["author"])	title.push(info["author"]);				
						
						if (info["website"])
						{
							var website:String = info["website"];
							if (website.substr(0, 7) == "http://") website = website.substr(7);
							title.push("<a href='event:" + info["website"] + "'>" + website + "</a>\n");
						}				
						
						player.title = title.join("\n"); 
					}
					break;
			}
		}
		
		protected function alignCameraToMesh(mesh:Mesh):void
		{		
			Bounds.getMeshBounds(mesh);
			
			var depth:Number = Bounds.depth;
			var height:Number = Bounds.height;
			var width:Number = Bounds.width;
			
			if (depth<width) depth = width;
			else width = depth;			
						
			// mesh offset to center
			var offset:Vector3D = new Vector3D
				(
					(mesh.minX+mesh.maxX)*.5,
					(mesh.minY+mesh.maxY)*.5,
					(mesh.minZ+mesh.maxZ)*.5
				);
			
			defaultCamera.position = mesh.position.add(offset).add(new Vector3D(depth, height/1.5, width));	
			defaultCamera.lookAt(mesh.position.add(offset));
		}
		
		protected function onComplete(e:SEAEvent):void
		{
			trace("SEA3D: " + sea3d.totalTime + "ms, " + sea3d.objects.length + " objects");
					
			if (!dynamicMode && !sea3d.lights && sea3dConfig.lightPicker)
			{
				defaultLights ||= new ThreePointLight();
				StaticLightPicker(sea3dConfig.lightPicker).lights = defaultLights.toArray();
			}
			
			//
			// UI STATUS
			//
			
			player.markerVisible = true;
			player.progress = 0;			
			player.tips = (sea3d.meshes ? sea3d.meshes.length : 0) + " Scene Objects\n\n";
			
			var maxAnmSet:int = 1;
			var mesh:Mesh;		
			
			if (alignCamera && sea3d.meshes && sea3d.meshes.length == 1)
			{
				alignCameraToMesh(sea3d.meshes[0]);
			}
			
			for each(mesh in sea3d.vertexAnimations)
			{
				var va:VertexAnimator = mesh.animator as VertexAnimator;
				
				va.play(VertexAnimationSet(va.animationSet).animations[0].name);
				
				if (VertexAnimationSet(va.animationSet).animations.length > maxAnmSet)
					maxAnmSet = VertexAnimationSet(va.animationSet).animations.length;
			}
			
			for each(mesh in sea3d.skeletonAnimations)
			{
				var skl:SkeletonAnimator = mesh.animator as SkeletonAnimator;
				
				skl.play(SkeletonAnimationSet(skl.animationSet).animations[0].name);
				
				if (SkeletonAnimationSet(skl.animationSet).animations.length > maxAnmSet)
					maxAnmSet = SkeletonAnimationSet(skl.animationSet).animations.length;
			}
			
			for each(var jointObject:JointObject in sea3d.jointObjects)
			{
				jointObject.autoUpdate = true;
			}
			
			for each(var anm:AnimationSet in sea3d.animationsSet)
			{
				if (anm.animations.length > maxAnmSet)
					maxAnmSet = anm.animations.length;
			}
			
			if (maxAnmSet > 1)
			{
				player.tips += "Use the keys <b>" + (maxAnmSet < 10 ? ("1-" + maxAnmSet) : "0-9") + "</b> for change the state of the animation.\n\n";
			}
			
			if (!forceCPU && showWarning)
			{
				for each(var skinMesh:Mesh in sea3d.skeletonAnimations)
				{
					if (SkeletonAnimator(skinMesh.animator).animationSet.usesCPU)
					{
						printWarn('GPU Warning: ' + 'Model' + skinMesh.name + ' can not use GPU animation.');
						
						player.tips += '<b><font color="#FF9900">GPU Warning:</font></b> Model <b>' + skinMesh.name + '</b> can not use GPU animation.\n';
												
						var sklAnmSet:SkeletonAnimationSet = SkeletonAnimator(skinMesh.animator).animationSet as SkeletonAnimationSet;
						
						if (sklAnmSet.jointsPerVertex > 4) 
						{
							printWarn(' - Joints Per Vertex> can not be greater than 4 (currently "' + sklAnmSet.jointsPerVertex + '"). Decrease the number of joints per vertex');
							
							player.tips += '<b>Joints Per Vertex</b> can not be greater than 4 (currently <b>' + sklAnmSet.jointsPerVertex + '</b>). Decrease the number of <b>joints per vertex</b>.\n';												
						}
						else
						{
							printWarn(' - Vertex Count * Number of Joints are too great (currently "' + sklAnmSet.jointsPerVertex + '". joints, 32 recommended). Decrease the number of bones or vertices.');
							
							player.tips += '<b>Vertex Count * Number of Joints</b> are too great (currently <b>' + SkeletonAnimator(skinMesh.animator).skeleton.numJoints + '</b> joints, <b>32</b> recommended). Decrease the number of bones or vertices.\n';	
						}
					}
				}
			}		
			
			//
			// Fit camera over scene (Orbit Camera)
			//
			
			orbitCamera = new Camera3D();			
			orbitCamera.name = "Orbit Camera";
			
			Bounds.getObjectContainerBounds(container, true, false, true);
			
			var bounding:BoundingSphere = new BoundingSphere();
			bounding.fromExtremes(Bounds.minX, Bounds.minY, Bounds.minZ, Bounds.maxX, Bounds.maxY, Bounds.maxZ);
			
			center = Bounds.getCenter();						
			
			var fov:Number = PerspectiveLens(orbitCamera.lens).fieldOfView = 60;				
			var distanceToCenter:Number = bounding.radius / Math.sin(fov / 2);			
			distanceToCenter *= 1;
			
			orbitCamera.lens.near = .5;
			orbitCamera.lens.far = bounding.radius * 10;
						
			orbitCamera.position = 
				new Vector3D
				(
					-distanceToCenter, 
					-distanceToCenter / 2, 
					-distanceToCenter
				);
			
			orbitCamera.lookAt( new Vector3D() );
			
			//var sphere:WireframeSphere = new WireframeSphere(bounding.radius);
			//sphere.position = center;
			//scene.addChild( sphere );
			
			//
			// Camera
			//
			
			setCamera(actualCamera ? sea3d.getCamera(actualCamera) : null);						
			
			//
			// Animation
			//
			
			player.target = sea3d.player as AnimationPlayer;		
			
			playSequence(0);
			
			if (autoPlay && player.duration > 0)
				player.state = PlayerState.PLAYING;
									
			System.gc();
		}
		
		private function setCamera(camera:Camera3D=null):void
		{					
			camera ||= orbitCamera && player.mode.mode == ModeButton.ORBIT ? orbitCamera : defaultCamera;			
			
			player.camera = camera.name;
			
			if (controller) controller.dispose();
			
			view.camera = camera;	
			
			if (player.mode.visible)
			{				
				controller = new FreeCameraController(camera, stage);
				controller.pivot = camera == orbitCamera ? center : null;
			}
		}
		
		private function getDefaultCamera():Camera3D
		{
			var cam:Camera3D = new Camera3D();
			cam.lens.near = 1;
			cam.lens.far = 6000;
			cam.name = "Default Camera";
			cam.position = new Vector3D(150, 125, 150);
			cam.lookAt(new Vector3D());
			
			return cam;
		}
		
		private function onUncaughtError(e:UncaughtErrorEvent):void
		{							
			//view.stage3DProxy = stage3DManager.getFreeStage3DProxy();
			if (e.error is Error) player.error = (e.error as Error).message				
			else player.error = String(e.error);
			e.preventDefault();		
		}		
		
		private function onEnterFrame(e:Event):void
		{
			if (controller)			
				controller.update();			
			
			player.update();
			
			render();
		}
		
		private function playSequence(value:int):void
		{			
			var duration:uint = 0;
			
			for each(var anm:Animation in sea3d.animations)
			{
				if (anm is SkeletonAnimation)
				{
					var skl:SkeletonAnimator = SkeletonAnimation(anm).animator;		
					
					if (value < SkeletonAnimationSet(skl.animationSet).animations.length)
					{						
						var sklNode:SkeletonClipNode = SkeletonAnimationSet(skl.animationSet).animations[value] as SkeletonClipNode;
						
						anm.play(sklNode.name, .3);
						//skl.play(sklNode.name, new CrossfadeTransition(.3));
						
						if (!sklNode.looping) 
							skl.reset(sklNode.name);
						
						if (duration < sklNode.totalDuration)
							duration = sklNode.totalDuration;
					}
				}
				else if (anm is VertexAnimation)
				{
					var va:VertexAnimator = VertexAnimation(anm).animator;	
					
					if (value < VertexAnimationSet(va.animationSet).animations.length)
					{
						var vaNode:VertexClipNode = VertexAnimationSet(va.animationSet).animations[value] as VertexClipNode;
						
						anm.play(vaNode.name, .3);
						//va.play(vaNode.name, new CrossfadeTransition(.3));
						
						if (!vaNode.looping) 
							skl.reset(vaNode.name);
						
						if (duration < vaNode.totalDuration)
							duration = vaNode.totalDuration;
					}
				}
				else if (value < anm.animations.length)		
				{
					anm.play( anm.animations[value].name, .3 );
										
					if (!anm.getNodeByName(anm.animations[value].name).repeat)
					{
						anm.reset( anm.animations[value].name );
					}
					
					if (duration < anm.animations[value].duration)
						duration = anm.animations[value].duration;
				}
			}
			
			if (duration > 0)
			{
				player.duration = duration;
				AnimationPlayer(player.target).sunag::_duration = duration;
			}
		}
		
		protected function setPreset(value:int):void
		{
			var levels:LevelsFilter3D, colors:ColorBalanceFilter3D;
			
			for each(var filter:Filter3DBase in view.filters3d)
			{
				filter.dispose();
			}
			
			if (value<0)
				value = 10-value;
			
			switch(value%10)
			{
				case 0:
					view.filters3d = [];
					break;
				
				case 1:					
					view.filters3d = [new BloomFilter3D(18,18,.9,1,4)];
					break;
				
				case 2:		
					levels = new LevelsFilter3D();
					levels.rgb = new Point(0.1,1)
					view.filters3d = [levels];	
					break;	
				
				case 3:
					levels = new LevelsFilter3D();
					levels.rgb = new Point(.1,.9);
					view.filters3d = [levels];
					break;
				
				case 4:
					colors = new ColorBalanceFilter3D(true);
					colors.shadows = new Vector3D(-.2,-.1,.60);
					colors.midtones = new Vector3D(0,.2,0);
					colors.highlights = new Vector3D(.1,.1,.20);
					colors.amount = 1;
					view.filters3d = [colors];
					break;
				
				case 5:
					colors = new ColorBalanceFilter3D(true);
					colors.shadows = new Vector3D(0,0,0);
					colors.midtones = new Vector3D(0,0,0);
					colors.highlights = new Vector3D(.4,.3,0);
					colors.amount = 1;
					view.filters3d = [colors];
					break;
				
				case 6:
					view.filters3d = [new ColorMatrixFilter3D(new ColorMatrix(.2).filter)];
					break;
				
				case 7:
					view.filters3d = [new ColorMatrixFilter3D(new ColorMatrix(2).filter)];
					break;
				
				case 8:
					view.filters3d = [new MotionBlurFilter3D(.3)];
					break;
				
				case 9:
					view.filters3d = [new RadialBlurFilter3D(1, 1)];
					break;
			}
			
			_actualPreset = value;
		}
		
		private function onKeyDown(e:KeyboardEvent):void
		{
			switch(e.keyCode)
			{								
				case Keyboard.NUMBER_1:
					playSequence(0);
					break;
				
				case Keyboard.NUMBER_2:		
					playSequence(1);
					break;
				
				case Keyboard.NUMBER_3:
					playSequence(2);
					break;
				
				case Keyboard.NUMBER_4:
					playSequence(3);
					break;
				
				case Keyboard.NUMBER_5:
					playSequence(4);
					break;
				
				case Keyboard.NUMBER_6:
					playSequence(5);
					break;
				
				case Keyboard.NUMBER_7:
					playSequence(6);
					break;
				
				case Keyboard.NUMBER_8:
					playSequence(7);
					break;
				
				case Keyboard.NUMBER_9:
					playSequence(8);
					break;
				
				case Keyboard.NUMBER_0:
					playSequence(9);
					break;
				
				case Keyboard.PAGE_UP:
					setPreset(_actualPreset+1);
					break;
				
				case Keyboard.PAGE_DOWN:
					setPreset(_actualPreset-1);
					break;
				
				case Keyboard.NUMPAD_ADD:
				case Keyboard.EQUAL:
					if (sea3d) setTimeScale(sea3d.player.timeScale * 2);
					break;
				
				case Keyboard.NUMPAD_SUBTRACT:
				case Keyboard.MINUS:
					if (sea3d) setTimeScale(sea3d.player.timeScale / 2);
					break;
				
				case Keyboard.C:
				case Keyboard.SPACE:
					if (sea3d && sea3d.cameras)
					{
						var cameraIndex:int = sea3d.cameras.indexOf(view.camera);
						
						if (cameraIndex+1 == sea3d.cameras.length) setCamera();	
						else if (cameraIndex == -1) setCamera(sea3d.cameras[0]);
						else setCamera(sea3d.cameras[(cameraIndex+1) % sea3d.cameras.length]);
					}							
					break;
			}				
		}
		
		private function setTimeScale(value:Number):void
		{
			if (value < .1) value = .1;
			else if (value > 10) value = 10;
			
			sea3d.player.timeScale = value;
		}
		
		private function updateAlign(e:Event=null):void
		{		
			player.width = stage.stageWidth;
			player.height = stage.stageHeight;
			
			view.width = stage.stageWidth;
			view.height = stage.stageHeight;
			
			render();
		}
				
		protected function renderReflections():void
		{
			for each(var cube:CubeReflectionTextureTarget in rttModule.cubeReflections)			
			{
				cube.backgroundColor = view.backgroundColor;
				cube.render(view);	
			}
			
			for each(var planar:PlanarReflectionTextureTarget in rttModule.planarReflections)			
			{
				planar.backgroundColor = view.backgroundColor;
				planar.render(view);			
			}
		}
		
		/*
		private function render():void
		{
			timer.update();
			
			physicsWorld.step(timer.deltaStep / 1000);
			
			if (sea3d)
			{
				renderReflections();
			}
			
			debugDraw.debugDrawWorld();
			
			view.render();
		}
		*/
				
		private function render():void
		{		
			try
			{
				timer.update();
				
				physicsWorld.step(timer.deltaStep / 1000);
				
				if (sea3d)
				{
					renderReflections();
				}
				
				debugDraw.debugDrawWorld();
				
				view.render();
			}
			catch(er:Error)
			{
				// PPAPI fix in full-screen
				
				if (er.errorID == 3694)
				{
					view.stage3DProxy.dispose();					
					view.stage3DProxy = Stage3DManager.getInstance(stage).getFreeStage3DProxy();
					view.stage3DProxy.enableErrorChecking = isPPAPI;
				}
				else
				{
					printError(String(er.message));
					player.error = String(er.message);
				}
			}
		}
	}
}