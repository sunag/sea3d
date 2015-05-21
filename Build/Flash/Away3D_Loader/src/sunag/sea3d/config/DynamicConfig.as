package sunag.sea3d.config
{
	import away3d.lights.LightBase;
	import away3d.lights.shadowmaps.DynamicCascadeShadowMapMethod;
	import away3d.lights.shadowmaps.DynamicNearShadowMapMethod;
	import away3d.lights.shadowmaps.DynamicShadowMapper;
	import away3d.lights.shadowmaps.IDynamicShadow;
	import away3d.lights.shadowmaps.ShadowMapperBase;
	import away3d.materials.ITextureMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.DynamicLightPicker;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.ShadowMapMethodBase;
	
	import sunag.sunag;
	import sunag.animation.AnimationBlendMethod;
	import sunag.animation.IAnimationPlayer;
	
	use namespace sunag;
	
	public class DynamicConfig extends ConfigBase implements IConfig
	{
		private var _normalDisplacement:Number = 100;
		private var _updateGlobalPose:Boolean = true;		
		private var _shadowMethod:String = ShadowMethod.NEAR;		
		private var _lightPicker:StaticLightPicker = DynamicLightPicker.instance;
		private var _forceCPU:Boolean = false;
		private var _forceMorphCPU:Boolean = false;
		private var _forceSkeletonCPU:Boolean = false;
		private var _forceCompactGeometry:Boolean = false;
		private var _autoUpdate:Boolean = true;
		private var _enabledShadow:Boolean = true;
		private var _enabledFog:Boolean = true;
		private var _mipmap:Boolean = true;		
		private var _autoWriteDepth:Boolean = false;
		private var _timeLimit:int = 16;		
		private var _cameraNear:Number = 1;
		private var _cameraFar:Number = 6000;
		private var _animationBlendMethod:uint = AnimationBlendMethod.LINEAR;
		private var _container:*;	
		private var _player:IAnimationPlayer;
		
		public function DynamicConfig()
		{			
		}
		
		public function get addLightInPicker():Boolean
		{
			return false;
		}
		
		public function get lightPicker():StaticLightPicker
		{
			return _lightPicker;
		}
		
		public function set lightPicker(val:StaticLightPicker):void
		{
			_lightPicker = val;
		}
		
		public function set animationBlendMethod(value:uint):void
		{
			_animationBlendMethod = value;
		}
		
		public function get animationBlendMethod():uint
		{
			return _animationBlendMethod;
		}
		
		public function set normalDisplacement(value:Number):void
		{
			_normalDisplacement = value;
		}
		
		public function get normalDisplacement():Number
		{
			return _normalDisplacement;
		}
		
		public function set autoWriteDepth(value:Boolean):void
		{
			_autoWriteDepth = value;
		}
		
		public function get autoWriteDepth():Boolean
		{
			return _autoWriteDepth;
		}
		
		public function set cameraNear(value:Number):void
		{
			_cameraNear = value;
		}
		
		public function get cameraNear():Number
		{
			return _cameraNear;
		}
		
		public function set cameraFar(value:Number):void
		{
			_cameraFar = value;
		}
		
		public function get cameraFar():Number
		{
			return _cameraFar;
		}
		
		public function set updateGlobalPose(value:Boolean):void
		{
			_updateGlobalPose = value;
		}
		
		public function get updateGlobalPose():Boolean
		{
			return _updateGlobalPose;
		}
		
		public function set autoUpdate(value:Boolean):void
		{
			_autoUpdate = value;
		}
		
		public function get autoUpdate():Boolean
		{
			return _autoUpdate;
		}
		
		public function set forceCompactGeometry(value:Boolean):void
		{
			_forceCompactGeometry = value;
		}
		
		public function get forceCompactGeometry():Boolean
		{
			return _forceCompactGeometry;
		}
		
		public function set forceCPU(value:Boolean):void
		{
			_forceCPU = value;
		}
		
		public function get forceCPU():Boolean
		{
			return _forceCPU;
		}
		
		public function set forceMorphCPU(value:Boolean):void
		{
			_forceMorphCPU = value;
		}
		
		public function get forceMorphCPU():Boolean
		{
			return _forceMorphCPU;
		}
		
		public function set forceSkeletonCPU(value:Boolean):void
		{
			_forceSkeletonCPU = value;
		}
		
		public function get forceSkeletonCPU():Boolean
		{
			return _forceSkeletonCPU;
		}
		
		public function set shadowMethod(value:String):void
		{
			_shadowMethod = value;
		}
		
		public function get shadowMethod():String
		{						
			return _shadowMethod;
		}
		
		public function set enabledShadow(value:Boolean):void
		{
			_enabledShadow = value;
		}
		
		public function get enabledShadow():Boolean
		{
			return _enabledShadow;
		}
		
		public function set enabledFog(value:Boolean):void
		{
			_enabledFog = value;
		}
		
		public function get enabledFog():Boolean
		{
			return _enabledFog;
		}
		
		public function set mipmap(value:Boolean):void
		{
			_mipmap = value;
		}
		
		public function get mipmap():Boolean
		{
			return _mipmap;
		}
		
		public function createMaterial():ITextureMaterial
		{
			return new TextureMaterial();
		}
		
		public function get smoothShadow():Boolean
		{
			return true;
		}
		
		public function get containsShadow():Boolean
		{
			return true;
		}
		
		//
		//	Internal
		//
		
		public function getCubeMapSize(quality:uint):int
		{
			switch(quality)
			{
				case ConfigBase.HIGH: return 512;
				case ConfigBase.NORMAL: return 256; 
				case ConfigBase.LOW: return 128;
				default: return 64; // ConfigBase.VERY_LOW
			}
		}
		
		public function getTextureSize(quality:uint):int
		{
			switch(quality)
			{
				case ConfigBase.HIGH: return 1024;
				case ConfigBase.NORMAL: return 512;
				case ConfigBase.LOW: return 256;
				default: return 128; // ConfigBase.VERY_LOW
			}
		}
		
		public function getShadowMapper():ShadowMapperBase
		{
			return new DynamicShadowMapper(getShadowMapMethod() as IDynamicShadow);
		}
		
		public function getShadowMapMethod(light:LightBase=null):ShadowMapMethodBase
		{
			if (_shadowMethod == ShadowMethod.NEAR)					
				return DynamicNearShadowMapMethod.instance;
			else if (_shadowMethod == ShadowMethod.CASCADE)	
				return DynamicCascadeShadowMapMethod.instance;
			
			return null;
		}
		
		/**
		 * Global animation player  
		 */
		public function set player(val:IAnimationPlayer):void
		{
			_player = val;
		}		
		
		public function get player():IAnimationPlayer
		{
			return _player;
		}
		
		/**
		 * Root of all children of the scene.
		 */
		public function set container(value:*):void
		{
			_container = value;
		}
		
		public function get container():*
		{
			return _container;
		}
		
		public function dispose():void
		{
		}
	}
}