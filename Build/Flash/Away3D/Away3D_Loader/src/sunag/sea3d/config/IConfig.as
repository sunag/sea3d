package sunag.sea3d.config
{
	import away3d.lights.LightBase;
	import away3d.lights.shadowmaps.ShadowMapperBase;
	import away3d.materials.ITextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.ShadowMapMethodBase;
	
	import sunag.sunag;
	import sunag.animation.IAnimationPlayer;

	use namespace sunag;
	
	public interface IConfig extends IConfigBase
	{
		function set updateGlobalPose(value:Boolean):void;
		function get updateGlobalPose():Boolean;
		
		function set normalDisplacement(value:Number):void;
		function get normalDisplacement():Number;
		
		function set autoWriteDepth(value:Boolean):void;
		function get autoWriteDepth():Boolean;
		
		function set cameraNear(value:Number):void;
		function get cameraNear():Number;				
		
		function set cameraFar(value:Number):void;
		function get cameraFar():Number;
		
		function set forceCompactGeometry(value:Boolean):void;
		function get forceCompactGeometry():Boolean;
		
		function set forceCPU(value:Boolean):void;
		function get forceCPU():Boolean;		
		
		function set forceSkeletonCPU(value:Boolean):void;
		function get forceSkeletonCPU():Boolean;
		
		function set forceMorphCPU(value:Boolean):void;
		function get forceMorphCPU():Boolean;
		
		function get addLightInPicker():Boolean;
		function get containsShadow():Boolean;		
		
		function set enabledShadow(value:Boolean):void;
		function get enabledShadow():Boolean;	
		
		function set enabledFog(value:Boolean):void;
		function get enabledFog():Boolean;	
		
		function set shadowMethod(value:String):void;
		function get shadowMethod():String;
		
		function set autoUpdate(value:Boolean):void;
		function get autoUpdate():Boolean;	
		
		function set animationBlendMethod(value:uint):void;
		function get animationBlendMethod():uint;
		
		function createMaterial():ITextureMaterial;		
		
		function getCubeMapSize(quality:uint):int;
		function getTextureSize(quality:uint):int;
		
		function getShadowMapper():ShadowMapperBase;
		function getShadowMapMethod(light:LightBase=null):ShadowMapMethodBase;
		
		function set mipmap(val:Boolean):void;
		function get mipmap():Boolean;	
		
		function set lightPicker(val:StaticLightPicker):void;
		function get lightPicker():StaticLightPicker;	
						
		function set player(value:IAnimationPlayer):void;	
		function get player():IAnimationPlayer;
		
		function set container(value:*):void;	
		function get container():*;
	}
}