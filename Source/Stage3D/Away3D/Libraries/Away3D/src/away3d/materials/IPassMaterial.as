package away3d.materials
{
	import away3d.materials.lightpickers.LightPickerBase;
	import away3d.materials.methods.BasicAmbientMethod;
	import away3d.materials.methods.BasicDiffuseMethod;
	import away3d.materials.methods.BasicNormalMethod;
	import away3d.materials.methods.BasicSpecularMethod;
	import away3d.materials.methods.EffectMethodBase;
	import away3d.materials.methods.ShadowMapMethodBase;
	import away3d.textures.Texture2DBase;

	public interface IPassMaterial
	{
		function set name(value : String) : void
		
		function get name() : String
		
		function set smooth(value : Boolean) : void
		
		function get smooth() : Boolean
		
		function set bothSides(value : Boolean) : void
		
		function get bothSides() : Boolean
		
		function set writeDepth(value : Boolean) : void
		
		function get writeDepth() : Boolean
		
		function set autoWriteDepth(value : Boolean) : void
		
		function get autoWriteDepth() : Boolean
		
		function set alphaPremultiplied(value : Boolean) : void
		
		function get alphaPremultiplied() : Boolean
		
		function set repeat(value : Boolean) : void
		
		function get repeat() : Boolean
		
		function get alphaThreshold() : Number
		
		function set alphaThreshold(value : Number) : void		
		
		function set blendMode(value : String) : void
		
		function get blendMode() : String
		
		function set depthCompareMode(value : String) : void
		
		function get specularLightSources() : uint
		
		function set specularLightSources(value : uint) : void
		
		function get diffuseLightSources() : uint
		
		function set diffuseLightSources(value : uint) : void
		
		function get requiresBlending() : Boolean
		
		function get ambientMethod() : BasicAmbientMethod
		
		function set ambientMethod(value : BasicAmbientMethod) : void
		
		function get diffuseMethod() : BasicDiffuseMethod
		
		function set diffuseMethod(value : BasicDiffuseMethod) : void
		
		function get normalMethod() : BasicNormalMethod
		
		function set normalMethod(value : BasicNormalMethod) : void
		
		function get specularMethod() : BasicSpecularMethod
		
		function set specularMethod(value : BasicSpecularMethod) : void
		
		function set mipmap(value : Boolean) : void
		
		function get normalMap() : Texture2DBase
		
		function set normalMap(value : Texture2DBase) : void
		
		function get specularMap() : Texture2DBase
		
		function set specularMap(value : Texture2DBase) : void
		
		function get gloss() : Number
		
		function set gloss(value : Number) : void
		
		function get ambient() : Number
		
		function set ambient(value : Number) : void
		
		function get specular() : Number		
		
		function set specular(value : Number) : void		
		
		function get ambientColor() : uint
		
		function set ambientColor(value : uint) : void
		
		function get specularColor() : uint
		
		function set specularColor(value : uint) : void
		
		function set lightPicker(value : LightPickerBase) : void;
				
		function addMethod(method : EffectMethodBase) : void
		
		function get numMethods() : int
		
		function hasMethod(method : EffectMethodBase) : Boolean
		
		function getMethodAt(index : int) : EffectMethodBase
		
		function addMethodAt(method : EffectMethodBase, index : int) : void
		
		function removeMethod(method : EffectMethodBase) : void
						
		function get shadowMethod() : ShadowMapMethodBase
		
		function set shadowMethod(value : ShadowMapMethodBase) : void
	}
}